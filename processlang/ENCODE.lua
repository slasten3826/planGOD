-- ProcessLang :: ENCODE operator
-- Function: compress, synthesize, accumulate into structure

local encode = {}

-- Accumulate: collect values into table
function encode.accumulate(t, fn)
    local result = {}
    for _, v in ipairs(t) do
        local key, val = fn(v)
        result[key] = val
    end
    return result
end

-- Group: encode table by key function
function encode.group(t, fn)
    local result = {}
    for _, v in ipairs(t) do
        local key = fn(v)
        if not result[key] then result[key] = {} end
        result[key][#result[key]+1] = v
    end
    return result
end

-- Compress: encode table to summary
function encode.compress(t, fn)
    local summary = {}
    for k, v in pairs(t) do
        summary[k] = fn(v)
    end
    return summary
end

-- Memoize: encode function results for reuse
function encode.memoize(fn)
    local cache = {}
    return function(x)
        if cache[x] == nil then
            cache[x] = fn(x)
        end
        return cache[x]
    end
end

-- Pack: encode multiple values into record
function encode.pack(keys, values)
    local result = {}
    for i, k in ipairs(keys) do
        result[k] = values[i]
    end
    return result
end

-- Freeze: encode current state as snapshot
function encode.freeze(t)
    local snapshot = {}
    for k, v in pairs(t) do
        snapshot[k] = v
    end
    snapshot._frozen_at = os.time()
    return snapshot
end

return encode
