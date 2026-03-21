-- eva/logic.lua
-- Eva.LOGIC executes encoded phantom patterns into manifestation specs.

local logic = {}

function logic.execute(pattern, opts)
    if not pattern or type(pattern) ~= "table" or not pattern._encoded then
        error("Eva.LOGIC: execute() expects encoded phantom pattern")
    end

    opts = opts or {}
    local count = tonumber(opts.count) or 1

    if count < 1 then
        error("Eva.LOGIC: invalid manifestation spec: count must be >= 1")
    end

    return {
        target = pattern.target or "social",
        task = pattern.task or "unspecified",
        count = count,
        thinking_mode = pattern.thinking_mode or "parallel",
        memory_mode = pattern.memory_mode or "none",
        convergence = pattern.convergence or "none",
        constraints = pattern.constraints or {},
        format = pattern.format or "conversational",
        loss = pattern.loss,
        pattern = pattern,
    }
end

return logic
