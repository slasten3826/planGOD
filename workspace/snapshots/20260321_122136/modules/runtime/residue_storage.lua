-- modules/runtime/residue_storage.lua
-- IO layer for Layer 2 nanoPL residues

local storage = {}

local STORAGE_DIR = "runtime/storage/"
local RESIDUES_FILE = STORAGE_DIR .. "residues.lua"

local function serialize_string(s)
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"', '\\"')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\0', '\\0')
    return '"' .. s .. '"'
end

local function serialize_value(v, depth)
    depth = depth or 0
    local t = type(v)
    if t == "string" then return serialize_string(v) end
    if t == "number" then return tostring(v) end
    if t == "boolean" then return tostring(v) end
    if t == "nil" then return "nil" end
    if t == "table" then
        local indent = string.rep("  ", depth)
        local indent2 = string.rep("  ", depth + 1)
        local parts = {}
        local seen = {}
        for i, val in ipairs(v) do
            seen[i] = true
            parts[#parts + 1] = indent2 .. serialize_value(val, depth + 1)
        end
        for key, val in pairs(v) do
            if not seen[key] then
                local k = type(key) == "string"
                    and string.format("[%q]", key)
                    or string.format("[%s]", tostring(key))
                parts[#parts + 1] = indent2 .. k .. " = " .. serialize_value(val, depth + 1)
            end
        end
        if #parts == 0 then return "{}" end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
    end
    return "nil"
end

local function serialize(data)
    return "return " .. serialize_value(data, 0) .. "\n"
end

local function write_file(path, content)
    os.execute("mkdir -p " .. STORAGE_DIR)
    local f, err = io.open(path, "w")
    if not f then return false, err end
    f:write(content)
    f:close()
    return true
end

function storage.load()
    local f = io.open(RESIDUES_FILE, "r")
    if not f then return {} end
    f:close()

    local ok, data = pcall(dofile, RESIDUES_FILE)
    if ok and type(data) == "table" then
        return data
    end

    print("RESIDUE STORAGE: bad residues.lua, starting clean")
    return {}
end

function storage.save(entries)
    if type(entries) ~= "table" then return false end
    local ok, err = write_file(RESIDUES_FILE, serialize(entries))
    if not ok then
        print("RESIDUE STORAGE ERROR: " .. tostring(err))
        return false
    end
    return true
end

return storage
