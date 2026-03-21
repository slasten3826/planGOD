-- drivers/packet.lua
-- Direct Packet CLI machine driver without Python wrapper.

local packet = {}

local PACKET_ROOT = "/home/slasten/dev/packet3/packetcli2machine"
local PACKET_BIN = "./packet_cli"
local OUTPUT_DIR = "workspace/packet_reports"
local CORE_REF_DIR = "workspace/packet_core_ref"
local CORE_REF_FILES = {
    "core.h",
    "runtime_internal.h",
    "pa_cognitive.h",
    "pa_cognitive.c",
    "app.c",
    "world_runtime.c",
    "manifestation_runtime.c",
    "packet_runtime.c",
}
local function shell_escape(str)
    return "'" .. tostring(str):gsub("'", "'\"'\"'") .. "'"
end

local function ensure_output_dir()
    os.execute("mkdir -p " .. OUTPUT_DIR)
end

local function now_label()
    return os.date("%Y%m%d_%H%M%S")
end

local function token_to_chars(token)
    local upper = token:upper()
    if upper == "SPACE" then return " " end
    if upper == "TAB" then return "\t" end
    if upper == "ENTER" then return "\n" end
    if upper == "QUIT" then return "q" end
    if #token == 1 then return token end
    error("PACKET DRIVER: unsupported token: " .. tostring(token))
end

local function strip_ansi(text)
    local out = {}
    local i = 1
    while i <= #text do
        local ch = text:sub(i, i)
        if ch == string.char(27) then
            i = i + 1
            if i <= #text and text:sub(i, i) == "[" then
                i = i + 1
                while i <= #text do
                    local c = text:sub(i, i)
                    if c >= "@" and c <= "~" then
                        i = i + 1
                        break
                    end
                    i = i + 1
                end
            end
        else
            out[#out + 1] = ch
            i = i + 1
        end
    end
    return table.concat(out)
end

local function split_commands(commands_csv)
    local parts = {}
    for token in tostring(commands_csv or ""):gmatch("[^,]+") do
        local trimmed = token:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            parts[#parts + 1] = trimmed
        end
    end
    return parts
end

local function build_sender_script(commands)
    local lines = { "#!/usr/bin/env bash", "set -euo pipefail" }
    for _, token in ipairs(commands) do
        local chars = token_to_chars(token)
        lines[#lines + 1] = string.format("printf %s", shell_escape(chars))
        lines[#lines + 1] = "sleep 0.2"
    end
    return table.concat(lines, "\n") .. "\n"
end

local function extract_snapshots(raw_text)
    local clean = strip_ansi(raw_text):gsub("\r", "")
    local snapshots = {}
    local starts = {}
    local pos = 1
    while true do
        local idx = clean:find("PACKET DEV CLI", pos, true)
        if not idx then break end
        starts[#starts + 1] = idx
        pos = idx + 1
    end

    for i, start_pos in ipairs(starts) do
        local next_pos = starts[i + 1]
        local part = clean:sub(start_pos, next_pos and (next_pos - 1) or #clean)
        local snap = part:gsub("^\n+", ""):gsub("\n+$", "")
        if snap ~= "" then
            snapshots[#snapshots + 1] = snap
        end
    end

    return snapshots
end

local function write_report(path, commands, snapshots)
    local f, err = io.open(path, "w")
    if not f then
        return nil, "PACKET DRIVER: failed to write report: " .. tostring(err)
    end

    f:write("PACKET_MACHINE_RENDER_REPORT\n")
    f:write("binary: " .. PACKET_BIN .. "\n")
    f:write("commands: " .. table.concat(commands, ",") .. "\n")
    f:write("snapshots: " .. tostring(#snapshots) .. "\n\n")

    for i, snap in ipairs(snapshots) do
        f:write(string.format("=== SNAPSHOT %02d ===\n", i - 1))
        f:write(snap)
        f:write("\n\n")
    end

    f:close()
    return true
end

function packet.probe(commands_csv, label)
    local commands = split_commands(commands_csv ~= "" and commands_csv or "n,QUIT")
    if #commands == 0 then
        commands = { "n", "QUIT" }
    end

    ensure_output_dir()

    local script_path = "/tmp/packet_sender_" .. tostring(os.time()) .. ".sh"
    local sender, err = io.open(script_path, "w")
    if not sender then
        return nil, "PACKET DRIVER: failed to create sender script: " .. tostring(err)
    end
    sender:write(build_sender_script(commands))
    sender:close()
    os.execute("chmod +x " .. shell_escape(script_path))

    local session_cmd = string.format(
        "bash %s | script -q -c %s /dev/null",
        shell_escape(script_path),
        shell_escape("cd " .. PACKET_ROOT .. " && " .. PACKET_BIN)
    )

    local handle = io.popen(session_cmd .. " 2>/dev/null")
    if not handle then
        os.remove(script_path)
        return nil, "PACKET DRIVER: failed to run packet_cli session"
    end
    local raw = handle:read("*a")
    handle:close()
    os.remove(script_path)

    local snapshots = extract_snapshots(raw)
    local out_path = string.format("%s/%s_%s.txt", OUTPUT_DIR, now_label(), label or "packet")
    local ok, write_err = write_report(out_path, commands, snapshots)
    if not ok then
        return nil, write_err
    end

    local report = ""
    local rf = io.open(out_path, "r")
    if rf then
        report = rf:read("*a") or ""
        rf:close()
    end

    return {
        report_path = out_path,
        report = report,
        snapshots = snapshots,
        commands = commands,
    }
end

function packet.read_report(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, "PACKET DRIVER: failed to read report: " .. tostring(err)
    end
    local content = f:read("*a")
    f:close()
    return content
end

function packet.latest_report()
    local handle = io.popen("ls -1t " .. OUTPUT_DIR .. "/*.txt 2>/dev/null | head -n 1")
    if not handle then
        return nil, "PACKET DRIVER: failed to list reports"
    end
    local path = handle:read("*l")
    handle:close()
    if not path or path == "" then
        return nil, "PACKET DRIVER: no reports found"
    end
    return packet.read_report(path), path
end

function packet.probe_and_read(commands_csv, label)
    local result, err = packet.probe(commands_csv, label)
    if not result then return nil, err end
    return result.report, result.report_path
end

function packet.status()
    return {
        driver = "packet",
        render_bridge = true,
        bare_core = true,
        root = PACKET_ROOT,
        core_ref_dir = CORE_REF_DIR,
    }
end

function packet.core_files()
    local out = {}
    for i, name in ipairs(CORE_REF_FILES) do
        out[i] = CORE_REF_DIR .. "/" .. name
    end
    return out
end

function packet.read_core(name)
    if not name or name == "" then
        return nil, "PACKET DRIVER: core file name is required"
    end

    for _, allowed in ipairs(CORE_REF_FILES) do
        if name == allowed then
            local path = CORE_REF_DIR .. "/" .. name
            local f, err = io.open(path, "r")
            if not f then
                return nil, "PACKET DRIVER: failed to read core ref: " .. tostring(err)
            end
            local content = f:read("*a")
            f:close()
            return content, path
        end
    end

    return nil, "PACKET DRIVER: unsupported core ref: " .. tostring(name)
end

function packet.core_bundle()
    local chunks = {}
    for _, name in ipairs(CORE_REF_FILES) do
        local content = packet.read_core(name)
        if content then
            chunks[#chunks + 1] = ("=== %s ===\n%s"):format(name, content)
        end
    end
    return table.concat(chunks, "\n\n")
end

function packet.inspect()
    local files = packet.core_files()
    local status = packet.status()
    status.core_files = files
    local pa_cognitive = packet.read_core("pa_cognitive.h")
    if pa_cognitive then
        status.has_cognitive_layer = pa_cognitive:match("PaCogState") ~= nil
    else
        status.has_cognitive_layer = false
    end
    return status
end

return packet
