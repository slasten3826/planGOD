-- core/eva_runner.lua
-- Shared Eva execution path for web UI and developer tooling.

local flow     = require("modules.flow.flow")
local connect  = require("modules.connect.connect")
local encode   = require("modules.encode.encode")
local observe  = require("modules.observe.observe")
local manifest = require("modules.manifest.manifest")
local runtime  = require("modules.runtime.runtime")
local residue  = require("modules.runtime.residue")
local router   = require("core.router")
local debuglog = require("core.debug")
local substrate = require("core.substrate")

local runner = {}

function runner.run_once(input, hist, opts)
    opts = opts or {}
    hist = hist or {}

    local events = {}
    local pkt = flow.run(input, hist, {
        mode = opts.mode or "active",
        temperature = opts.temperature or 0.7,
    })

    pkt.substrate = substrate.fingerprint({
        provider = opts.provider,
        model = opts.model,
        temperature = pkt.S.temperature,
        timeout = opts.timeout,
    })

    pkt.S.provider = pkt.substrate.provider
    pkt.S.model = pkt.substrate.model
    pkt.S.max_tokens = opts.max_tokens
    pkt.S.timeout = opts.timeout
    pkt.S.debug = opts.debug

    pkt = debuglog.start(pkt, string.format(
        "input_len=%d | mode=%s | %s",
        pkt.input and #pkt.input or 0,
        tostring(opts.mode or "active"),
        substrate.describe(pkt.substrate)
    ))

    if pkt.halted then
        debuglog.finish(pkt, events, "halted_before_observe")
        return pkt, events, hist
    end

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
        pkt = residue.capture(pkt)
    end

    debuglog.finish(pkt, events, string.format(
        "halted=%s | output=%s",
        tostring(pkt.halted),
        tostring(pkt.output ~= nil)
    ))

    return pkt, events, hist
end

return runner
