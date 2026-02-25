-- ProcessLang :: CONNECT operator
-- Function: link, compose, find analogies between structures

local connect = {}

-- Compose two functions: connect(f, g)(x) = g(f(x))
function connect.compose(...)
    local fns = {...}
    return function(x)
        local result = x
        for _, fn in ipairs(fns) do
            result = fn(result)
        end
        return result
    end
end

-- Zip two tables into pairs
function connect.zip(a, b)
    local result = {}
    local len = math.min(#a, #b)
    for i = 1, len do
        result[i] = {a[i], b[i]}
    end
    return result
end

-- Merge two tables (shallow)
function connect.merge(a, b)
    local result = {}
    for k, v in pairs(a) do result[k] = v end
    for k, v in pairs(b) do result[k] = v end
    return result
end

-- Bridge: find common keys between two tables
function connect.bridge(a, b)
    local common = {}
    for k, v in pairs(a) do
        if b[k] ~= nil then
            common[k] = {a = v, b = b[k]}
        end
    end
    return common
end

-- Analogy: map structure of source onto target
function connect.analogy(source, target, mapping_fn)
    local result = {}
    for k, v in pairs(source) do
        result[k] = mapping_fn(v, target[k])
    end
    return result
end

return connect
