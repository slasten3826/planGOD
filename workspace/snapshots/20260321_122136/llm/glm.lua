-- llm/glm.lua
-- GLM-5 provider for Eva through Modal endpoint

local provider = {}

local json = require("dkjson")

local API_URL = "https://api.us-west-2.modal.direct/v1/chat/completions"
local SEPARATOR = "||GLMHTTPSTATUS||"

local function escape_shell_single(str)
    return "'" .. tostring(str):gsub("'", "'\"'\"'") .. "'"
end

local function provider_timeout(opts)
    if opts and opts.timeout then
        return tonumber(opts.timeout) or 180
    end
    local from_env = os.getenv("EVA_LLM_TIMEOUT")
    if from_env and from_env ~= "" then
        return tonumber(from_env) or 180
    end
    return 180
end

function provider.ask(messages, options)
    local opts = options or {}
    local api_key = os.getenv("MODAL_GLM_API_KEY") or os.getenv("GLM_API_KEY")
    if not api_key then
        return nil, "FATAL ERROR: MODAL_GLM_API_KEY or GLM_API_KEY is not set"
    end

    local request_data = {
        model = opts.model or "zai-org/GLM-5-FP8",
        messages = messages,
        temperature = opts.temperature or 0.7,
        max_tokens = opts.max_tokens or 500,
    }

    local request_body = json.encode(request_data)
    local stderr_path = string.format(
        "/tmp/eva_glm_stderr_%d_%d.log",
        os.time(),
        math.random(1000, 999999)
    )
    local timeout = provider_timeout(opts)
    local cmd = string.format(
        "curl -sS --show-error --max-time %d -w %s -X POST %s -H %s -H %s -d %s 2>%s",
        timeout,
        escape_shell_single(SEPARATOR .. "%{http_code}"),
        escape_shell_single(API_URL),
        escape_shell_single("Content-Type: application/json"),
        escape_shell_single("Authorization: Bearer " .. api_key),
        escape_shell_single(request_body),
        escape_shell_single(stderr_path)
    )

    local pipe, err = io.popen(cmd)
    if not pipe then
        return nil, "NETWORK ERROR: GLM curl spawn failed: " .. tostring(err)
    end

    local raw = pipe:read("*a")
    pipe:close()
    local stderr = ""
    local ferr = io.open(stderr_path, "r")
    if ferr then
        stderr = ferr:read("*a") or ""
        ferr:close()
    end
    os.remove(stderr_path)

    if not raw or raw == "" then
        return nil, "NETWORK ERROR: GLM returned empty response"
            .. (stderr ~= "" and ("\n[curl stderr]\n" .. stderr) or "")
    end

    local response_str, status_str = raw:match("^(.*)" .. SEPARATOR .. "(%d%d%d)%s*$")
    local code = tonumber(status_str) or 0

    if not response_str then
        local raw_tail = raw:sub(math.max(1, #raw - 800))
        return nil, "NETWORK ERROR: GLM response parse failed"
            .. "\n[raw tail]\n" .. raw_tail
            .. (stderr ~= "" and ("\n[curl stderr]\n" .. stderr) or "")
    end

    if code ~= 200 then
        local msg = "API ERROR (GLM HTTP " .. tostring(code) .. "): " .. response_str
        if stderr ~= "" then
            msg = msg .. "\n[curl stderr]\n" .. stderr
        end
        return nil, msg
    end

    local obj, _, json_err = json.decode(response_str, 1, nil)
    if json_err then
        local raw_tail = response_str:sub(math.max(1, #response_str - 800))
        return nil, "JSON PARSE ERROR (GLM): " .. tostring(json_err)
            .. "\n[response tail]\n" .. raw_tail
    end

    if obj and obj.choices and obj.choices[1] and obj.choices[1].message then
        return obj.choices[1].message.content
    end

    return nil, "UNEXPECTED FORMAT (GLM): invalid response body"
        .. "\n[response]\n" .. response_str:sub(1, 1200)
end

return provider
