-- ProcessLang :: RUNTIME operator
-- Function: maintain state, execute, manage context

local runtime = {}

-- Create a stateful context
function runtime.context(initial)
    local ctx = {
        state = initial or {},
        history = {},
        _created_at = os.time()
    }

    function ctx:set(key, value)
        self.history[#self.history+1] = {key = key, old = self.state[key], new = value, t = os.time()}
        self.state[key] = value
        return self
    end

    function ctx:get(key, default)
        local v = self.state[key]
        if v == nil then return default end
        return v
    end

    function ctx:snapshot()
        local snap = {state = {}, t = os.time()}
        for k, v in pairs(self.state) do snap.state[k] = v end
        return snap
    end

    function ctx:rollback(snapshot)
        self.state = {}
        for k, v in pairs(snapshot.state) do self.state[k] = v end
        return self
    end

    return ctx
end

-- Execute with error handling
function runtime.safe(fn, fallback)
    local ok, result = pcall(fn)
    if ok then return result
    else return fallback, result end
end

-- Throttle: limit execution rate
function runtime.throttle(fn, interval_ms)
    local last_run = 0
    return function(...)
        local now = os.clock() * 1000
        if now - last_run >= interval_ms then
            last_run = now
            return fn(...)
        end
    end
end

-- Pipeline state machine
function runtime.machine(states, initial)
    local machine = {
        current = initial,
        states = states,
        log = {}
    }

    function machine:transition(event)
        local state_def = self.states[self.current]
        if state_def and state_def[event] then
            local next = state_def[event]
            self.log[#self.log+1] = {from = self.current, event = event, to = next, t = os.time()}
            self.current = next
            return true
        end
        return false
    end

    return machine
end

return runtime
