-- core/debug.lua
-- Technical trace layer for Eva runs.
-- This is not memory. It records execution events only.

local debuglog = {}

local DEBUG_DIR = "workspace/debug"
local LATEST_FILE = DEBUG_DIR .. "/latest.log"

local function ensure_dir()
    os.execute("mkdir -p " .. DEBUG_DIR)
end

local function write_line(path, line, mode)
    local f = io.open(path, mode or "a")
    if not f then
        return
    end
    f:write(line .. "\n")
    f:close()
end

local function is_enabled(pkt)
    return (pkt and pkt.S and pkt.S.debug) or os.getenv("EVA_DEV") == "1"
end

function debuglog.start(pkt, meta)
    if not is_enabled(pkt) then
        return pkt
    end

    ensure_dir()

    local ts = os.date("%Y%m%d_%H%M%S")
    local run_id = string.format("%s_%04d", ts, math.random(0, 9999))
    local path = string.format("%s/%s.log", DEBUG_DIR, run_id)

    pkt.debug = {
        run_id = run_id,
        path = path,
        started_at = os.date("%Y-%m-%d %H:%M:%S"),
    }

    write_line(path, "=== EVA DEBUG TRACE START ===", "w")
    write_line(path, string.format("[%s] run_id=%s", pkt.debug.started_at, run_id))

    if meta then
        write_line(path, string.format("[%s] meta=%s", os.date("%H:%M:%S"), meta))
    end

    write_line(LATEST_FILE, string.format("latest=%s", path), "w")
    return pkt
end

function debuglog.log(pkt, events, line)
    if not is_enabled(pkt) or not pkt or not pkt.debug or not pkt.debug.path then
        return
    end

    local stamped = string.format("%s %s", os.date("%H:%M:%S"), line)
    write_line(pkt.debug.path, stamped)
    write_line(LATEST_FILE, stamped, "a")

    if events then
        table.insert(events, { type = "sys", data = "[DEV] " .. line })
    end
end

function debuglog.finish(pkt, events, status)
    if not is_enabled(pkt) or not pkt or not pkt.debug or not pkt.debug.path then
        return pkt
    end

    debuglog.log(pkt, events, string.format("run.finish | %s", status or "ok"))
    write_line(pkt.debug.path, "=== EVA DEBUG TRACE END ===")
    return pkt
end

return debuglog
