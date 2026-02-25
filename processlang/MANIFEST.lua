-- ProcessLang :: MANIFEST operator
-- Function: crystallize output, make real, render result

local manifest = {}

-- Render: convert internal state to output format
function manifest.render(value, format)
    if format == "json" then
        -- Simple JSON serializer
        local function serialize(v, indent)
            indent = indent or 0
            local t = type(v)
            if t == "nil" then return "null"
            elseif t == "boolean" then return tostring(v)
            elseif t == "number" then return tostring(v)
            elseif t == "string" then return '"' .. v:gsub('"', '\\"') .. '"'
            elseif t == "table" then
                local is_array = #v > 0
                local parts = {}
                local pad = string.rep("  ", indent + 1)
                if is_array then
                    for _, item in ipairs(v) do
                        parts[#parts+1] = pad .. serialize(item, indent + 1)
                    end
                    return "[\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", indent) .. "]"
                else
                    for k, item in pairs(v) do
                        parts[#parts+1] = pad .. '"' .. tostring(k) .. '": ' .. serialize(item, indent + 1)
                    end
                    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", indent) .. "}"
                end
            end
        end
        return serialize(value)
    elseif format == "text" then
        if type(value) == "table" then
            local parts = {}
            for k, v in pairs(value) do
                parts[#parts+1] = tostring(k) .. ": " .. tostring(v)
            end
            return table.concat(parts, "\n")
        end
        return tostring(value)
    else
        return value
    end
end

-- Emit: produce final output with metadata
function manifest.emit(value, meta)
    return {
        value = value,
        meta = meta or {},
        timestamp = os.time(),
        manifest = true
    }
end

-- Assert manifest: value must not be nil
function manifest.required(value, name)
    if value == nil then
        error("MANIFEST: required value '" .. (name or "?") .. "' is nil")
    end
    return value
end

-- Seal: freeze output, mark as final
function manifest.seal(value)
    local sealed = {_sealed = true, _at = os.time()}
    if type(value) == "table" then
        for k, v in pairs(value) do sealed[k] = v end
    else
        sealed.value = value
    end
    return setmetatable(sealed, {
        __newindex = function() error("MANIFEST: cannot modify sealed value") end
    })
end

return manifest
