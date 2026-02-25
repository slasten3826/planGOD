-- ProcessLang :: OBSERVE operator
-- Function: measure, verify, fix value without changing it

local observe = {}

-- Watch: apply observer without modifying value
function observe.watch(value, fn)
    fn(value)  -- side effect only
    return value  -- value unchanged
end

-- Assert: verify condition, return value or error
function observe.assert(value, predicate, message)
    if not predicate(value) then
        error(message or "OBSERVE assertion failed")
    end
    return value
end

-- Measure: compute metrics about value
function observe.measure(t)
    local metrics = {
        count = 0,
        sum = 0,
        min = math.huge,
        max = -math.huge,
    }
    for _, v in ipairs(t) do
        if type(v) == "number" then
            metrics.count = metrics.count + 1
            metrics.sum = metrics.sum + v
            if v < metrics.min then metrics.min = v end
            if v > metrics.max then metrics.max = v end
        end
    end
    if metrics.count > 0 then
        metrics.avg = metrics.sum / metrics.count
    end
    return metrics
end

-- Tap: log value and pass through (debug)
function observe.tap(value, label)
    local label_str = label and ("[" .. label .. "] ") or ""
    print(label_str .. tostring(value))
    return value
end

-- Snapshot: capture state at this moment
function observe.snapshot(t)
    local snap = {}
    for k, v in pairs(t) do snap[k] = v end
    snap._observed_at = os.time()
    return snap, t  -- returns both snapshot and original unchanged
end

-- Check: non-destructive predicate test
function observe.check(value, predicate)
    return predicate(value), value  -- result + original
end

return observe
