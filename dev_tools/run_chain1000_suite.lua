package.path = package.path
    .. ";/home/slasten/planGOD/?.lua"
    .. ";/home/slasten/planGOD/?/init.lua"
    .. ";/home/slasten/planGOD/?/?.lua"
    .. ";/home/slasten/planGOD/workspace/lens_tests/chain1000/?.lua"

local json = require("dkjson")
local operators = require("operators")

local function shell_quote(s)
    return "'" .. tostring(s):gsub("'", "'\"'\"'") .. "'"
end

local function parse_args(argv)
    local opts = {
        provider = os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        model = nil,
        count = 1000,
        out_dir = nil,
        include_done = false,
        only = nil,
        dry_run = false,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--provider" then
            opts.provider = argv[i + 1] or opts.provider
            i = i + 2
        elseif a == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif a == "--count" then
            opts.count = tonumber(argv[i + 1]) or opts.count
            i = i + 2
        elseif a == "--out-dir" then
            opts.out_dir = argv[i + 1]
            i = i + 2
        elseif a == "--only" then
            opts.only = argv[i + 1]
            i = i + 2
        elseif a == "--include-done" then
            opts.include_done = true
            i = i + 1
        elseif a == "--dry-run" then
            opts.dry_run = true
            i = i + 1
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    return opts
end

local function ensure_dir(path)
    os.execute("mkdir -p " .. shell_quote(path))
end

local function split_csv(s)
    local out = {}
    if not s or s == "" then
        return out
    end
    for part in tostring(s):gmatch("[^,]+") do
        out[part:match("^%s*(.-)%s*$")] = true
    end
    return out
end

local function default_out_dir()
    local ts = os.date("%Y%m%d_%H%M%S")
    return string.format("/home/slasten/planGOD/workspace/lens_tests/chain1000/runs/%s", ts)
end

local function write_json(path, payload)
    local f = assert(io.open(path, "w"))
    f:write(json.encode(payload, { indent = true }))
    f:close()
end

local function pick_operators(opts)
    local only = split_csv(opts.only)
    local selected = {}

    for _, op in ipairs(operators) do
        local enabled = true
        if next(only) ~= nil and not only[op.id] then
            enabled = false
        end
        if not opts.include_done and op.status == "done" and next(only) == nil then
            enabled = false
        end
        if enabled then
            selected[#selected + 1] = op
        end
    end

    return selected
end

local opts = parse_args(arg)
local out_dir = opts.out_dir or default_out_dir()
local selected = pick_operators(opts)

ensure_dir(out_dir)

local manifest = {
    started_at = os.date("%Y%m%d_%H%M%S"),
    provider = opts.provider,
    model = opts.model,
    count = opts.count,
    out_dir = out_dir,
    include_done = opts.include_done,
    only = opts.only,
    dry_run = opts.dry_run,
    operators = {},
}

print("== chain1000 suite ==")
print("provider: " .. tostring(opts.provider))
print("model: " .. tostring(opts.model or "default"))
print("count: " .. tostring(opts.count))
print("out_dir: " .. out_dir)
print("")

if #selected == 0 then
    print("No operators selected.")
    manifest.finished_at = os.date("%Y%m%d_%H%M%S")
    write_json(out_dir .. "/manifest.json", manifest)
    os.exit(0)
end

for _, op in ipairs(selected) do
    local op_dir = out_dir .. "/" .. op.id
    local report_path = op_dir .. "/" .. string.lower(op.id) .. "_chain" .. tostring(opts.count) .. ".json"
    ensure_dir(op_dir)

    local cmd_parts = {
        "lua",
        "/home/slasten/planGOD/tools/prose_grok_chain.lua",
        "--provider", shell_quote(opts.provider),
        "--question", shell_quote(op.question),
        "--count", tostring(opts.count),
        "--out", shell_quote(report_path),
    }
    if opts.model then
        cmd_parts[#cmd_parts + 1] = "--model"
        cmd_parts[#cmd_parts + 1] = shell_quote(opts.model)
    end

    local cmd = table.concat(cmd_parts, " ")
    local record = {
        id = op.id,
        question = op.question,
        status = op.status,
        note = op.note,
        out = report_path,
        command = cmd,
        launched = false,
        exit_code = nil,
    }

    print(string.format("[%s] %s", op.id, op.question))
    print("out: " .. report_path)
    if opts.dry_run then
        print("dry-run")
        print("")
        manifest.operators[#manifest.operators + 1] = record
    else
        local ok = os.execute(cmd)
        record.launched = true
        record.exit_code = ok
        print("exit: " .. tostring(ok))
        print("")
        manifest.operators[#manifest.operators + 1] = record
        write_json(out_dir .. "/manifest.json", manifest)
    end
end

manifest.finished_at = os.date("%Y%m%d_%H%M%S")
write_json(out_dir .. "/manifest.json", manifest)
