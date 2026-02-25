-- drivers/txt.lua
-- Обработчик простых текстовых файлов

local txt = {}

function txt.read(filepath)
local f = io.open(filepath, "r")
if not f then return nil, "txt driver: file not found" end
    local content = f:read("*a")
    f:close()
    return content
    end

    function txt.write(filepath, content)
    local f, err = io.open(filepath, "w")
    if not f then return false, "txt driver ERROR: " .. tostring(err) end
        f:write(content)
        f:close()
        return true
        end

        function txt.append(filepath, content)
        local f, err = io.open(filepath, "a")
        if not f then return false, "txt driver ERROR: " .. tostring(err) end
            f:write(content .. "\n")
            f:close()
            return true
            end

            function txt.read_lines(filepath)
            local lines = {}
            for line in io.lines(filepath) do
                table.insert(lines, line)
                end
                return lines
                end

                return txt
