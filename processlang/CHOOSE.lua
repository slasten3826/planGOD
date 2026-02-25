-- ProcessLang :: CHOOSE operator
-- Function: branch, decide, collapse possibilities into one path

local choose = {}

-- Branch: choose path based on condition
function choose.branch(value, conditions)
    for _, case in ipairs(conditions) do
        local predicate, fn = case[1], case[2]
        if type(predicate) == "function" then
            if predicate(value) then return fn(value) end
        elseif predicate == true then
            return fn(value)  -- default case
        end
    end
    return nil
end

-- First: choose first non-nil value
function choose.first(...)
    for _, v in ipairs({...}) do
        if v ~= nil then return v end
    end
    return nil
end

-- Best: choose value with highest score
function choose.best(t, score_fn)
    local best_val, best_score = nil, -math.huge
    for _, v in ipairs(t) do
        local score = score_fn(v)
        if score > best_score then
            best_score = score
            best_val = v
        end
    end
    return best_val, best_score
end

-- Gate: pass value only if condition is met
function choose.gate(value, predicate, fallback)
    if predicate(value) then return value
    else return fallback end
end

-- Either: choose between two paths
function choose.either(condition, if_true, if_false)
    if condition then return if_true
    else return if_false end
end

return choose
