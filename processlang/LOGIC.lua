-- ProcessLang :: LOGIC operator
-- Function: reason, validate, apply rules

local logic = {}

-- All: true if all predicates pass
function logic.all(value, ...)
    for _, predicate in ipairs({...}) do
        if not predicate(value) then return false end
    end
    return true
end

-- Any: true if any predicate passes
function logic.any(value, ...)
    for _, predicate in ipairs({...}) do
        if predicate(value) then return true end
    end
    return false
end

-- Not: negate predicate
function logic.negate(predicate)
    return function(value)
        return not predicate(value)
    end
end

-- Implies: if A then B (logical implication)
function logic.implies(a, b)
    return (not a) or b
end

-- Validate: apply set of rules, return violations
function logic.validate(value, rules)
    local violations = {}
    for name, rule in pairs(rules) do
        if not rule.check(value) then
            violations[#violations+1] = {rule = name, message = rule.message}
        end
    end
    return #violations == 0, violations
end

-- Rule builder
function logic.rule(check_fn, message)
    return {check = check_fn, message = message}
end

-- Infer: simple forward chaining
function logic.infer(facts, rules)
    local derived = {}
    for k, v in pairs(facts) do derived[k] = v end
    local changed = true
    while changed do
        changed = false
        for _, rule in ipairs(rules) do
            local result = rule(derived)
            if result then
                for k, v in pairs(result) do
                    if derived[k] == nil then
                        derived[k] = v
                        changed = true
                    end
                end
            end
        end
    end
    return derived
end

return logic
