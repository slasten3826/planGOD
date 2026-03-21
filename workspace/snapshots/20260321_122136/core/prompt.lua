-- core/prompt.lua
-- Compatibility wrapper: prompt content is now assembled from bootloader + sections.

local prompt = {}
local assembler = require("core.prompt_assembler")

function prompt.build(active_lenses)
    return assembler.build({
        lenses = active_lenses or {},
        context = {},
        S = {},
    })
end

return prompt
