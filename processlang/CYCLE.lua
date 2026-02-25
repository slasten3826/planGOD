-- ProcessLang :: CYCLE operator
-- Function: iterate, recurse, repeat until stable

local cycle = {}

-- Repeat: apply fn n times
function cycle.times(n, fn, init)
    local result = init
    for i = 1, n do
        result = fn(result, i)
    end
    return result
end

-- Until: cycle until predicate is true
function cycle.until_stable(value, fn, predicate, max_iter)
    max_iter = max_iter or 1000
    local result = value
    for i = 1, max_iter do
        local next = fn(result, i)
        if predicate(next, result) then return next, i end
        result = next
    end
    return result, max_iter
end

-- Converge: cycle until value stops changing (within epsilon)
function cycle.converge(value, fn, epsilon, max_iter)
    epsilon = epsilon or 1e-6
    max_iter = max_iter or 1000
    local result = value
    for i = 1, max_iter do
        local next = fn(result)
        if type(next) == "number" and math.abs(next - result) < epsilon then
            return next, i
        end
        result = next
    end
    return result, max_iter
end

-- Each: iterate over table with index
function cycle.each(t, fn)
    for i, v in ipairs(t) do
        fn(v, i)
    end
end

-- Generate: create sequence by cycling fn
function cycle.generate(n, fn)
    local result = {}
    for i = 1, n do
        result[i] = fn(i)
    end
    return result
end

-- Fibonacci example: CYCLE(CYCLE) pattern
function cycle.fibonacci(n)
    return cycle.times(n, function(state)
        return {state[2], state[1] + state[2]}
    end, {0, 1})[1]
end

return cycle
