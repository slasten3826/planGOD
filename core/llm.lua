-- core/llm.lua
-- Eva LLM facade
-- Routes ask() calls to the selected provider while preserving the old API.

local llm = {}

local DEFAULT_PROVIDER = "deepseek"

local PROVIDERS = {
    deepseek = "llm.deepseek",
    glm = "llm.glm",
    ollama = "llm.ollama",
}

local function normalize_provider_name(name)
    if not name or name == "" then
        return DEFAULT_PROVIDER
    end
    return tostring(name):lower()
end

local function selected_provider_name(options)
    local opts = options or {}
    return normalize_provider_name(
        opts.provider or os.getenv("EVA_LLM_PROVIDER") or DEFAULT_PROVIDER
    )
end

local function load_provider(name)
    local module_name = PROVIDERS[name]
    if not module_name then
        return nil, "LLM ERROR: unknown provider '" .. tostring(name) .. "'"
    end

    local ok, provider = pcall(require, module_name)
    if not ok then
        return nil, "LLM ERROR: failed to load provider '" .. tostring(name) .. "': " .. tostring(provider)
    end

    if type(provider) ~= "table" or type(provider.ask) ~= "function" then
        return nil, "LLM ERROR: provider '" .. tostring(name) .. "' does not expose ask(messages, options)"
    end

    return provider
end

function llm.ask(messages, options)
    local provider_name = selected_provider_name(options)
    local provider, err = load_provider(provider_name)
    if not provider then
        return nil, err
    end

    return provider.ask(messages, options)
end

return llm
