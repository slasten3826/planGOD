-- llm/deepseek.lua
-- DeepSeek provider for Eva

local provider = {}

local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("dkjson")

local API_URL = "https://api.deepseek.com/v1/chat/completions"

function provider.ask(messages, options)
    local opts = options or {}
    local api_key = os.getenv("DEEPSEEK_API_KEY")

    if not api_key then
        return nil, "FATAL ERROR: DEEPSEEK_API_KEY is not set"
    end

    local request_data = {
        model = opts.model or "deepseek-chat",
        messages = messages,
        temperature = opts.temperature or 0.7,
    }

    if opts.max_tokens then
        request_data.max_tokens = opts.max_tokens
    end

    local request_body = json.encode(request_data)
    local response_body = {}

    local res, code = https.request{
        url = API_URL,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. api_key,
            ["Content-Length"] = tostring(#request_body),
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
        protocol = "tlsv1_2",
    }

    if not res then
        return nil, "NETWORK ERROR: DeepSeek request failed. Code: " .. tostring(code)
    end

    local response_str = table.concat(response_body)

    if code ~= 200 then
        return nil, "API ERROR (DeepSeek HTTP " .. tostring(code) .. "): " .. response_str
    end

    local obj, _, err = json.decode(response_str, 1, nil)
    if err then
        return nil, "JSON PARSE ERROR (DeepSeek): " .. tostring(err)
    end

    if obj and obj.choices and obj.choices[1] and obj.choices[1].message then
        return obj.choices[1].message.content
    end

    return nil, "UNEXPECTED FORMAT (DeepSeek): invalid response body"
end

return provider

