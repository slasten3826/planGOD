-- eva/runtime.lua
-- Eva.RUNTIME provides stable basis and memory slices for manifestations.

local runtime = {}

function runtime.slice(pkt, spec)
    spec = spec or {}

    local slice = {
        mode = pkt and pkt.header and pkt.header.mode or "active",
        memory_mode = spec.memory_mode or "none",
        substrate = pkt and pkt.substrate or nil,
        has_runtime = pkt and pkt.E_momentum ~= nil or false,
        edge_count = pkt and pkt.E_edges and #pkt.E_edges or 0,
        last_residue = pkt and pkt.last_residue or nil,
    }

    if spec.memory_mode == "runtime" then
        slice.runtime = {
            E_edges = pkt and pkt.E_edges or {},
            E_momentum = pkt and pkt.E_momentum or {},
        }
    elseif spec.memory_mode == "residue" then
        slice.runtime = {
            last_residue = pkt and pkt.last_residue or nil,
        }
    else
        slice.runtime = nil
    end

    return slice
end

return runtime
