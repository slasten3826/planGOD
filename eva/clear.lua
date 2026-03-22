-- eva/clear.lua
-- Explicit memory clearing helpers for sterile Eva experiments.

local clear = {}

local function clone_table(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        out[k] = v
    end
    return out
end

function clear.packet(pkt, opts)
    opts = opts or {}
    local out = clone_table(pkt or {})

    out.header = clone_table(out.header or {})
    if not out.header.mode or out.header.mode == "" then
        out.header.mode = "active"
    end

    if opts.clear_edges ~= false then
        out.E_edges = {}
    end

    if opts.clear_momentum ~= false then
        out.E_momentum = {}
    end

    if opts.clear_residue ~= false then
        out.last_residue = nil
    end

    if opts.clear_substrate then
        out.substrate = nil
    end

    return out
end

function clear.sterile_packet(opts)
    opts = opts or {}
    local substrate = nil
    if opts.provider or opts.model then
        substrate = {
            provider = opts.provider,
            model = opts.model,
            provider_switch = 0,
        }
    end

    return {
        header = { mode = opts.mode or "active" },
        substrate = substrate,
        E_edges = {},
        E_momentum = {},
        last_residue = nil,
    }
end

return clear
