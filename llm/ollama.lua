-- llm/ollama.lua
-- Local Ollama provider for Eva

local provider = {}

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

local function flatten_messages(messages)
    local parts = {}
    for _, msg in ipairs(messages or {}) do
        local role = tostring((msg and msg.role) or "user")
        local content = tostring((msg and msg.content) or "")
        parts[#parts + 1] = string.format("[%s]\n%s", role, content)
    end
    return table.concat(parts, "\n\n")
end

function provider.ask(messages, options)
    local opts = options or {}
    local model = opts.model or os.getenv("EVA_OLLAMA_MODEL") or "paradox"
    local timeout = provider_timeout(opts)
    local prompt = flatten_messages(messages)

    local cmd = string.format(
        "timeout %d ollama run %s %s",
        timeout,
        escape_shell_single(model),
        escape_shell_single(prompt)
    )

    local pipe, err = io.popen(cmd .. " 2>&1")
    if not pipe then
        return nil, "OLLAMA ERROR: failed to spawn ollama: " .. tostring(err)
    end

    local raw = pipe:read("*a") or ""
    local ok, _, code = pipe:close()
    if ok == nil or code ~= 0 then
        return nil, "OLLAMA ERROR: command failed\n" .. raw
    end

    local text = raw:gsub("\r", "")
    text = text:gsub("\27%[[0-9;?]*[A-Za-z]", "")
    text = text:gsub("[\8\127]", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    if text == "" then
        return nil, "OLLAMA ERROR: empty response"
    end

    return text
end

return provider
