-- core/prompt_assembler.lua
-- Builds provider-facing prompt sections from current Eva state.

local bootloader = require("core.bootloader")
local lens_reader = require("core.lens_reader")

local assembler = {}

local function provider_section(pkt)
    local provider = pkt and pkt.S and pkt.S.provider
    if not provider or provider == "" then
        return ""
    end
    return "\n## SUBSTRATE\nprovider=" .. tostring(provider) .. "\n"
end

function assembler.sections(pkt)
    local sections = {
        boot = bootloader.build(),
        optics = "",
        lenses = "",
        runtime = "",
        memory = "",
        provider = provider_section(pkt),
    }

    if pkt and pkt.context then
        sections.optics = pkt.context.optics or ""
        sections.lenses = pkt.context.lenses or ""
        sections.runtime = pkt.context.runtime or ""
        sections.memory = pkt.context.memory or ""
    elseif pkt and pkt.lenses and next(pkt.lenses) then
        sections.lenses = lens_reader.build_context(pkt.lenses)
    end

    sections.final = sections.boot
        .. sections.optics
        .. sections.lenses
        .. sections.runtime
        .. sections.memory
        .. sections.provider

    return sections
end

function assembler.build(pkt)
    return assembler.sections(pkt).final
end

return assembler
