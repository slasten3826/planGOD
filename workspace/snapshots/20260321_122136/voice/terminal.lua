-- voice/terminal.lua
-- Human-facing CLI manifestation for Eva.Social.

local terminal = {}

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function terminal.clear()
    os.execute("clear")
end

function terminal.header()
    print("==================================================")
    print("Eva.Social CLI")
    print("Human-facing shell over Eva.Core")
    print("Type 'help' for commands, 'exit' to quit.")
    print("==================================================")
    print("")
end

function terminal.prompt()
    io.write("you> ")
    io.flush()
end

function terminal.read_input()
    terminal.prompt()
    return io.read("*l")
end

function terminal.assistant(text)
    local body = trim(text)
    if body == "" then
        return
    end

    print("eva> " .. body)
    print("")
end

function terminal.system(text)
    local body = trim(text)
    if body == "" then
        return
    end

    print("[sys] " .. body)
end

function terminal.status(text)
    local body = trim(text)
    if body == "" then
        return
    end

    print("[status] " .. body)
end

function terminal.error(text)
    local body = trim(text)
    if body == "" then
        return
    end

    io.stderr:write("[error] " .. body .. "\n")
end

function terminal.help(debug_enabled)
    print("Commands:")
    print("  help    show this help")
    print("  clear   clear saved dialogue history")
    print("  memory  show history/runtime size")
    print("  exit    quit Eva.Social")
    print("  quit    quit Eva.Social")
    print("")
    if debug_enabled then
        print("Debug mode is on: runtime/internal events will be shown.")
        print("")
    end
end

return terminal
