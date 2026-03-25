-- tools/eva.dev.lua
-- Minimal placeholder for future Eva.dev CLI.

local command = arg[1]

local help = [[
Eva.dev (prototype)

Commands:
  chain       Run chain-based grokking for one operator or question
  grok        Compress an existing essence
  essence     Extract or inspect an essence artifact
  lens        Save, inspect, or probe a compiled lens
  probe       Run test batteries against a lens
  wiki        Future bridge to Eva.Wiki / slastris.org

Current state:
  Prototype only. This file defines the intended CLI surface.
]]

if not command or command == "--help" or command == "-h" then
    print(help)
    os.exit(0)
end

if command == "chain" then
    print("Eva.dev prototype: chain command not implemented yet.")
    print("Use tools/prose_grok_chain.lua for now.")
    os.exit(0)
end

if command == "grok" then
    print("Eva.dev prototype: grok command not implemented yet.")
    print("Intended input: essence.*")
    os.exit(0)
end

if command == "essence" then
    print("Eva.dev prototype: essence command not implemented yet.")
    os.exit(0)
end

if command == "lens" then
    print("Eva.dev prototype: lens command not implemented yet.")
    os.exit(0)
end

if command == "probe" then
    print("Eva.dev prototype: probe command not implemented yet.")
    print("Use tools/eva_lens_probe.lua for now.")
    os.exit(0)
end

if command == "wiki" then
    print("Eva.dev prototype: wiki bridge not implemented yet.")
    os.exit(0)
end

print("Unknown Eva.dev command: " .. tostring(command))
os.exit(1)
