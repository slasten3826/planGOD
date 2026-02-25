-- drivers/fs.lua
-- Read-Only File System driver для интроспекции evaOS
-- Ева видит весь проект, но не может выйти за его пределы

local fs = {}

-- Корень evaOS — директория где лежит main.lua
-- Lua запускается из этой директории
local ROOT = "."

local function escape_shell(str)
return "'" .. str:gsub("'", "'\"'\"'") .. "'"
end

local function validate_path(path)
if not path or path == "" then return ROOT end
    -- Блокируем абсолютные пути и выход наверх
    if path:match("^/") then
        return nil, "SECURITY: абсолютные пути запрещены"
        end
        if path:match("%.%./") or path == ".." then
            return nil, "SECURITY: выход за пределы evaOS запрещён"
            end
            return path
            end

            -- Листинг директории
            function fs.list(path)
            local safe, err = validate_path(path)
            if not safe then return nil, err end

                local cmd = string.format("ls -1p %s 2>/dev/null", escape_shell(safe))
                local f = io.popen(cmd)
                if not f then return nil, "FS ERROR: не удалось выполнить ls" end

                    local result = f:read("*a")
                    f:close()

                    if result == "" then return "Директория пуста или не существует: " .. safe end
                        return result
                        end

                        -- Чтение файла
                        function fs.read(path)
                        local safe, err = validate_path(path)
                        if not safe then return nil, err end

                            local f, open_err = io.open(safe, "r")
                            if not f then
                                return nil, "FS ERROR: файл не найден: " .. tostring(open_err)
                                end

                                local content = f:read("*a")
                                f:close()
                                return content
                                end

                                return fs
