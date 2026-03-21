-- ======================================================================
-- main.lua - planGOD
-- @slasten3826
-- ======================================================================

local flow     = require("modules.flow.flow")
local connect  = require("modules.connect.connect")
local encode   = require("modules.encode.encode")
local observe  = require("modules.observe.observe")
local manifest = require("modules.manifest.manifest")
local runtime  = require("modules.runtime.runtime")
local history  = require("core.history")
local router   = require("core.router")
local runner   = require("eva.core")
local voice    = require("server.web")

local function dev_enabled()
    return os.getenv("EVA_DEV") == "1"
end

local hist = history.load()

os.execute("clear")
voice.header()
print("")

while true do
    local input = voice.read_input()

    if not input or input == "exit" or input == "quit" then
        history.save(hist)
        voice.sys("\nDISSOLVE: Сессия сохранена. До связи.")
        break
    end

    if input == "" then goto continue end

    if input == "memory" then
        local tmp = { header = { mode = "active" }, E_momentum = nil, E_edges = {} }
        tmp = runtime.load(tmp)
        local s = runtime.stats(tmp)
        voice.sys(string.format(
            "RUNTIME: total=%d | habits=%d | edges=%d | size=%dkb | history=%dkb",
            s.total, s.habits, s.edges, s.size_kb, history.size_kb()
        ))
        goto continue
    end

    if input == "clear" then
        hist = {}
        history.clear()
        voice.sys("DISSOLVE: История очищена.")
        goto continue
    end

    local _, events
    _, events, hist = runner.run_once(input, hist)

    for _, event in ipairs(events) do
        if     event.type == "thinking"    then voice.thinking()
        elseif event.type == "response"    then if dev_enabled() then voice.response(event.data) end
        elseif event.type == "runtime"     then if dev_enabled() then voice.runtime(event.data) end
        elseif event.type == "exec_error"  then voice.exec_error(event.data)
        elseif event.type == "exec_result" then if dev_enabled() then voice.exec_result(event.data) end
        elseif event.type == "llm_error"   then voice.llm_error(event.data)
        elseif event.type == "sys"         then if dev_enabled() then voice.sys(event.data) end
        elseif event.type == "manifest"    then voice.response(event.data)
        end
    end
    history.save(hist)

    ::continue::
end

history.save(hist)
