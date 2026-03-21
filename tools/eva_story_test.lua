-- tools/eva_story_test.lua
-- Minimal manual helper for story-based semantic anchor retention tests.

local function read_file(path)
    local f, err = io.open(path, "r")
    if not f then
        io.stderr:write("file error: " .. tostring(err) .. "\n")
        os.exit(1)
    end
    local data = f:read("*a")
    f:close()
    return data
end

local function usage()
    io.stderr:write("usage:\n")
    io.stderr:write("  lua tools/eva_story_test.lua seed\n")
    io.stderr:write("  lua tools/eva_story_test.lua continue /abs/path/to/anchor.txt\n")
    os.exit(1)
end

if not arg[1] then
    usage()
end

if arg[1] == "seed" then
    io.write(read_file("workspace/tests/eva_story_seed_prompt.txt"))
    os.exit(0)
end

if arg[1] == "continue" then
    local anchor_path = arg[2]
    if not anchor_path then
        usage()
    end
    local template = read_file("workspace/tests/eva_story_continue_template.txt")
    local anchor = read_file(anchor_path)
    io.write((template:gsub("{{ANCHOR}}", anchor)))
    os.exit(0)
end

usage()
