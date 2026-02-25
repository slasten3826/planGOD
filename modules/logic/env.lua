-- modules/logic/env.lua
-- Контракт доступа LOGIC — что Ева видит в sandbox
-- Если чего-то нет здесь — этого не существует для Евы

local env = {}
local guard = require("modules.logic.guard")

local WORKSPACE = "workspace"

-- Системные драйверы (загружаются один раз)
local drivers = {
    txt  = require("drivers.txt"),
    md   = require("drivers.md"),
    fs   = require("drivers.fs"),
    web  = require("drivers.web"),
    port = require("drivers.port"),
}

-- Есть midi не везде — грузим опционально
local ok, midi = pcall(require, "drivers.midi")
if ok then drivers.midi = midi end

-- ======================================================================
-- Вспомогательные функции
-- ======================================================================

local function safe_path(path)
    local normalized = path:gsub("^/+", "")
    if normalized:sub(1, 10) == "workspace/" then
        normalized = normalized:sub(11)
    end
    if normalized == "" then normalized = "." end

    local safe, err = guard.safe_path(WORKSPACE, normalized)
    if not safe then
        error("LOGIC access denied: '" .. tostring(path) .. "'\n" .. tostring(err))
    end
    return safe
end

local function safe_mkdir(path)
    local normalized = path:gsub("^/+", "")
    if not normalized:match("^workspace") then return nil end
    os.execute("mkdir -p " .. normalized)
end

local function routed_io_open(path, mode)
    local safe = safe_path(path)
    local ext  = path:match("%.([^%.]+)$")

    -- Запись midi
    if mode and (mode:match("w") or mode:match("a")) and drivers.midi then
        if ext == "mid" or ext == "midi" then
            return {
                write = function(self, events, tpb)
                    local ok, err = drivers.midi.write(safe, events, tpb)
                    if not ok then error(err) end
                end,
                close = function(self) end
            }
        end
    end

    -- Запись md
    if mode and (mode:match("w") or mode:match("a")) then
        if ext == "md" then
            return {
                write = function(self, content)
                    local ok, err
                    if type(content) == "table" then
                        ok, err = drivers.md.build(safe, content)
                    else
                        ok, err = drivers.md.write(safe, content)
                    end
                    if not ok then error(err) end
                end,
                close = function(self) end
            }
        end
    end

    return io.open(safe, mode)
end

-- ======================================================================
-- Публичный API
-- ======================================================================

-- Строит окружение для одного выполнения
function env.build()
    local sandbox = {
        -- Базовые Lua примитивы
        tostring = tostring, tonumber = tonumber,
        type     = type,     ipairs   = ipairs,
        pairs    = pairs,    select   = select,
        unpack   = table.unpack,
        error    = error,    pcall    = pcall,
        xpcall   = xpcall,   assert   = assert,
        math     = math,     table    = table,
        string   = string,   print    = print,

        -- Ограниченный os — только время
        os = {
            time    = os.time,
            date    = os.date,
            clock   = os.clock,
            execute = function(cmd)
                if cmd:match("^mkdir") then
                    return safe_mkdir(
                        cmd:match("mkdir%s+%-?p?%s*(.+)$")
                    )
                end
                return nil  -- всё остальное запрещено
            end
        },

        -- Ограниченный io — только через guard
        io = {
            open  = routed_io_open,
            write = io.write,
            read  = io.read,
        },

        -- Драйверы — только workspace/ для записи
        drivers = {
            txt = {
                read       = function(p) return drivers.txt.read(safe_path(p)) end,
                write      = function(p, c) return drivers.txt.write(safe_path(p), c) end,
                append     = function(p, c) return drivers.txt.append(safe_path(p), c) end,
                read_lines = function(p) return drivers.txt.read_lines(safe_path(p)) end,
            },
            md = {
                read   = function(p) return drivers.md.read(safe_path(p)) end,
                write  = function(p, c) return drivers.md.write(safe_path(p), c) end,
                append = function(p, c) return drivers.md.append(safe_path(p), c) end,
                build  = function(p, b) return drivers.md.build(safe_path(p), b) end,
                h      = drivers.md.h,
                list   = drivers.md.list,
                code   = drivers.md.code,
            },
            -- fs: read-only весь planGOS root
            fs = drivers.fs,
            web = {
                fetch = function(url) return drivers.web.fetch(url) end
            },
            port = {
                load = function(name) return drivers.port.load(name) end,
                list = function()     return drivers.port.list()     end,
            },
        }
    }

    -- midi опционально
    if drivers.midi then
        sandbox.drivers.midi = drivers.midi
    end

    sandbox._G = sandbox
    return sandbox
end

return env
