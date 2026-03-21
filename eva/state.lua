-- eva/state.lua
-- File-backed run state for Eva.Core telemetry.

local json = require("dkjson")

local state = {}
local DIR = "workspace/state"

local function ensure_dir()
    os.execute("mkdir -p " .. DIR)
end

local function path(run_id)
    return string.format("%s/%s.json", DIR, tostring(run_id))
end

local function read_obj(run_id)
    local f = io.open(path(run_id), "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then return nil end
    local obj = json.decode(content)
    return obj
end

local function write_obj(run_id, obj)
    ensure_dir()
    local f = assert(io.open(path(run_id), "w"))
    f:write(json.encode(obj, { indent = true }))
    f:close()
end

function state.new_run_id()
    local t = os.date("%Y%m%d_%H%M%S")
    local rand = tostring(math.random(1000, 9999))
    return t .. "_" .. rand
end

function state.begin(run_id, obj)
    local now = os.time()
    local base = obj or {}
    base.run_id = run_id
    base.started_at = base.started_at or now
    base.updated_at = now
    base.finished = false
    write_obj(run_id, base)
    return base
end

function state.get(run_id)
    return read_obj(run_id)
end

function state.update(run_id, patch)
    local obj = read_obj(run_id) or { run_id = run_id, started_at = os.time(), finished = false }
    for k, v in pairs(patch or {}) do
        obj[k] = v
    end
    obj.updated_at = os.time()
    write_obj(run_id, obj)
    return obj
end

function state.increment(run_id, key, delta)
    local obj = read_obj(run_id) or { run_id = run_id, started_at = os.time(), finished = false }
    obj[key] = (tonumber(obj[key]) or 0) + (delta or 1)
    obj.updated_at = os.time()
    write_obj(run_id, obj)
    return obj
end

function state.finish(run_id, patch)
    local obj = read_obj(run_id) or { run_id = run_id, started_at = os.time() }
    for k, v in pairs(patch or {}) do
        obj[k] = v
    end
    obj.finished = true
    obj.phase = obj.phase or "done"
    obj.finished_at = os.time()
    obj.elapsed_sec = math.max(0, obj.finished_at - (obj.started_at or obj.finished_at))
    obj.updated_at = obj.finished_at
    write_obj(run_id, obj)
    return obj
end

function state.path(run_id)
    return path(run_id)
end

return state
