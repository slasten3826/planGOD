-- core/substrate.lua
-- Layer 0 provider substrate for Eva.

local substrate = {}

local DEFAULT_PROVIDER = "deepseek"
local DEFAULT_SWITCH = 0

local DEFAULT_MODELS = {
    deepseek = "deepseek-chat",
    glm = "zai-org/GLM-5-FP8",
}

local function normalize_provider_name(name)
    if not name or name == "" then
        return DEFAULT_PROVIDER
    end
    return tostring(name):lower()
end

function substrate.active_provider(options)
    local opts = options or {}
    return normalize_provider_name(
        opts.provider or os.getenv("EVA_LLM_PROVIDER") or DEFAULT_PROVIDER
    )
end

function substrate.active_model(options)
    local opts = options or {}
    local provider = substrate.active_provider(opts)
    return opts.model or DEFAULT_MODELS[provider] or DEFAULT_MODELS[DEFAULT_PROVIDER]
end

function substrate.provider_switch()
    return DEFAULT_SWITCH
end

function substrate.fingerprint(options)
    local opts = options or {}
    return {
        layer = 0,
        provider_switch = substrate.provider_switch(),
        provider = substrate.active_provider(opts),
        model = substrate.active_model(opts),
        temperature = opts.temperature,
        timeout = opts.timeout,
        ts = os.date("%Y-%m-%d %H:%M:%S"),
    }
end

function substrate.describe(fp)
    if not fp then
        return "layer=0 | provider=unknown | model=unknown | switch=0"
    end

    return string.format(
        "layer=%s | provider=%s | model=%s | switch=%s",
        tostring(fp.layer or 0),
        tostring(fp.provider or "unknown"),
        tostring(fp.model or "unknown"),
        tostring(fp.provider_switch or 0)
    )
end

return substrate
