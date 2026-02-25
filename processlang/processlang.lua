-- ProcessLang :: Main Entry Point
-- Version: 1.0
-- Author: @slasten3826
-- Usage: local pl = require("processlang.processlang")

local processlang = {}

-- Load all 10 operators (Указываем путь через папку!)
processlang.FLOW     = require("processlang.FLOW")
processlang.CONNECT  = require("processlang.CONNECT")
processlang.DISSOLVE = require("processlang.DISSOLVE")
processlang.ENCODE   = require("processlang.ENCODE")
processlang.CHOOSE   = require("processlang.CHOOSE")
processlang.OBSERVE  = require("processlang.OBSERVE")
processlang.CYCLE    = require("processlang.CYCLE")
processlang.LOGIC    = require("processlang.LOGIC")
processlang.RUNTIME  = require("processlang.RUNTIME")
processlang.MANIFEST = require("processlang.MANIFEST")

-- Version info
processlang._version = "1.0"
processlang._operators = 10

-- Shorthand: pl.pipe instead of pl.FLOW.pipe (Исправлен регистр!)
processlang.pipe    = processlang.FLOW.pipe
processlang.chain   = processlang.FLOW.chain

return processlang
