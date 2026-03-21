-- modules/runtime/residue.lua
-- Layer 2 nanoPL residue memory for Eva

local llm = require("core.llm")
local debuglog = require("core.debug")
local storage = require("modules.runtime.residue_storage")

local residue = {}

local MAX_ENTRIES = 128

local function read_nanopl()
    local f = io.open("nanoPL.txt", "r")
    if not f then return "" end
    local text = f:read("*a")
    f:close()
    return text or ""
end

local function extract_nanopl_line(text)
    if not text or text == "" then return nil end
    for line in text:gmatch("[^\r\n]+") do
        if line:match("^%s*NANOPL:%s*") then
            return line:gsub("^%s*NANOPL:%s*", "")
        end
    end
    local first = text:match("^%s*(.-)%s*$")
    if first and first ~= "" then
        return first
    end
    return nil
end

local function encode_prompt(pkt)
    local nanopl = read_nanopl()
    return table.concat({
        "nanoPL:",
        nanopl,
        "",
        "Task:",
        "Encode Eva's final answer into one compact nanoPL residue line.",
        "",
        "Rules:",
        "- output exactly one line",
        "- start with: NANOPL:",
        "- no prose explanation",
        "- use compact nanoPL only",
        "- preserve cognitive state, not wording",
        "",
        "User input:",
        pkt.input or "",
        "",
        "Eva final answer:",
        pkt.output or "",
    }, "\n")
end

function residue.load(pkt)
    pkt.residues = storage.load()
    return pkt
end

function residue.append(pkt, entry)
    if not pkt.residues then
        pkt.residues = storage.load()
    end

    table.insert(pkt.residues, entry)
    while #pkt.residues > MAX_ENTRIES do
        table.remove(pkt.residues, 1)
    end

    storage.save(pkt.residues)
    return pkt
end

function residue.capture(pkt)
    if not pkt or not pkt.output or pkt.output == "" then
        debuglog.log(pkt, nil, "residue.skip | no_output")
        return pkt
    end

    local raw, err = llm.ask({
        { role = "user", content = encode_prompt(pkt) }
    }, {
        provider = pkt.S and pkt.S.provider,
        model = pkt.S and pkt.S.model,
        temperature = 0.1,
        max_tokens = 200,
    })

    if not raw then
        pkt.residue_error = err
        debuglog.log(pkt, nil, "residue.error | llm_ask_failed | " .. tostring(err))
        return pkt
    end

    local line = extract_nanopl_line(raw)
    if not line or line == "" then
        pkt.residue_error = "empty residue"
        debuglog.log(pkt, nil, "residue.error | empty_residue")
        return pkt
    end

    pkt.last_residue = line
    debuglog.log(pkt, nil, string.format(
        "residue.capture | residue_len=%d",
        #line
    ))
    return residue.append(pkt, {
        ts = os.time(),
        residue = line,
    })
end

function residue.context_string(pkt, max_items)
    local items = pkt and pkt.residues or {}
    if not items or #items == 0 then return "" end

    max_items = max_items or 5
    local lines = { "\n## MEMORY: Recent nanoPL residues\n" }
    local start_idx = math.max(1, #items - max_items + 1)

    for i = start_idx, #items do
        local item = items[i]
        lines[#lines + 1] = string.format("- %s", item.residue or "")
    end

    lines[#lines + 1] = "\n"
    return table.concat(lines, "\n")
end

return residue
