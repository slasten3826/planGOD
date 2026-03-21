-- eva/encode.lua
-- Eva.ENCODE crystallizes intent + basis into phantom patterns.

local encode = {}

local function normalize_thinking_mode(opts)
    opts = opts or {}
    local mode = opts.thinking_mode or opts.cycle_mode or opts.collaboration_mode

    if mode == nil or mode == "" then
        return "parallel"
    end

    mode = tostring(mode)
    if mode == "parallel" or mode == "separate" or mode == "independent" then
        return "parallel"
    end
    if mode == "chain" or mode == "collab" or mode == "collaborative" or mode == "together" then
        return "chain"
    end
    if mode == "debate" then
        return "debate"
    end

    error("Eva.ENCODE: invalid thinking_mode: " .. mode)
end

local function detect_seed_mode(target, basis, opts)
    opts = opts or {}

    if opts.seed_mode and opts.seed_mode ~= "" then
        return opts.seed_mode
    end

    if basis and basis.memory_mode == "runtime" then
        return "derive_from_runtime"
    end

    if basis and basis.memory_mode == "residue" then
        return "derive_from_residue"
    end

    if target == "social" then
        return "read_then_return"
    end

    return "direct_manifest"
end

local function freeze_pattern(pattern)
    pattern._encoded = true
    pattern._frozen_at = os.time()
    pattern._signature = table.concat({
        tostring(pattern.target or "unknown"),
        tostring(pattern.seed_mode or "unknown"),
        tostring(pattern.memory_mode or "none"),
        tostring(pattern.task or "unspecified"),
    }, "::")
    return pattern
end

function encode.pattern(target, task, basis, opts)
    opts = opts or {}

    local pattern = {
        target = target or "social",
        task = task or "unspecified",
        memory_mode = opts.memory_mode or "none",
        thinking_mode = normalize_thinking_mode(opts),
        seed_mode = detect_seed_mode(target, basis, opts),
        constraints = opts.constraints or {},
        convergence = opts.convergence or "none",
        format = opts.format or "conversational",
        loss = opts.loss,
        basis_mode = basis and basis.mode or "active",
        substrate = basis and basis.substrate or nil,
    }

    return freeze_pattern(pattern)
end

return encode
