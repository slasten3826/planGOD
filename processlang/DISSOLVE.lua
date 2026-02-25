-- ProcessLang :: DISSOLVE operator
-- Function: decompose, analyze, break structures apart

local dissolve = {}

-- Split table into parts by predicate
function dissolve.split(t, fn)
    local yes, no = {}, {}
    for _, v in ipairs(t) do
        if fn(v) then yes[#yes+1] = v
        else no[#no+1] = v end
    end
    return yes, no
end

-- Flatten nested table (one level)
function dissolve.flatten(t)
    local result = {}
    for _, v in ipairs(t) do
        if type(v) == "table" then
            for _, inner in ipairs(v) do result[#result+1] = inner end
        else
            result[#result+1] = v
        end
    end
    return result
end

-- Extract keys from table into array
function dissolve.keys(t)
    local result = {}
    for k, _ in pairs(t) do result[#result+1] = k end
    return result
end

-- Extract values from table into array
function dissolve.values(t)
    local result = {}
    for _, v in pairs(t) do result[#result+1] = v end
    return result
end

-- Reduce: dissolve table into single value
function dissolve.reduce(t, fn, init)
    local acc = init
    for _, v in ipairs(t) do
        acc = fn(acc, v)
    end
    return acc
end

-- Diff: find what changed between two tables
function dissolve.diff(a, b)
    local added, removed, changed = {}, {}, {}
    for k, v in pairs(b) do
        if a[k] == nil then added[k] = v
        elseif a[k] ~= v then changed[k] = {from = a[k], to = v} end
    end
    for k, v in pairs(a) do
        if b[k] == nil then removed[k] = v end
    end
    return {added = added, removed = removed, changed = changed}
end

return dissolve
