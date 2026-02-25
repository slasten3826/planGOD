-- ProcessLang :: FLOW operator
-- Function: transform, map, pipe data through a process

local flow = {}

-- Core: apply a function to a value and return result
function flow.pipe(value, fn)
    return fn(value)
end

-- Chain: pipe through multiple functions sequentially
function flow.chain(value, ...)
    local result = value
    for _, fn in ipairs({...}) do
        result = fn(result)
    end
    return result
end

-- Map: apply function to each element
function flow.map(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = fn(v)
    end
    return result
end

-- Filter: keep elements where fn returns true
function flow.filter(t, fn)
    local result = {}
    for _, v in ipairs(t) do
        if fn(v) then
            result[#result + 1] = v
        end
    end
    return result
end

-- Source: create a flow from a value
function flow.source(value)
    return {
        value = value,
        pipe = function(self, fn)
            self.value = fn(self.value)
            return self
        end,
        manifest = function(self)
            return self.value
        end
    }
end

return flow
