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
local voice    = require("server.web")

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

    local events = {}

    local pkt = flow.run(input, hist)
    if pkt.halted then goto save end

    pkt = router.transition(pkt, "CONNECT")
    pkt = connect.run(pkt)

    pkt = router.transition(pkt, "ENCODE")
    pkt = encode.run(pkt)

    pkt = router.transition(pkt, "OBSERVE")
    pkt, events = observe.run(pkt, events)

    if pkt.output then
        pkt = router.transition(pkt, "RUNTIME")
        pkt = runtime.dump(pkt)
        pkt = router.transition(pkt, "MANIFEST")
        pkt, events, hist = manifest.run(pkt, events, hist)
    end

    for _, event in ipairs(events) do
        if     event.type == "thinking"    then voice.thinking()
        elseif event.type == "response"    then voice.response(event.data)
        elseif event.type == "runtime"     then voice.runtime(event.data)
        elseif event.type == "exec_error"  then voice.exec_error(event.data)
        elseif event.type == "exec_result" then voice.exec_result(event.data)
        elseif event.type == "llm_error"   then voice.llm_error(event.data)
        elseif event.type == "sys"         then voice.sys(event.data)
        end
    end

    ::save::
    history.save(hist)

    ::continue::
end

history.save(hist)
