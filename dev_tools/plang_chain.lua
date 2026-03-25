-- dev_tools/plang_chain.lua
-- ProcessLang/nanoPL chain runner with live checkpoints and resume support.

local json = require("dkjson")
local llm = require("core.llm")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        plang = nil,
        seed = nil,
        count = 3,
        continue_from = nil,
        out = nil,
        timeout = 180,
        temperature = 0.2,
        max_tokens = 220,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif a == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif a == "--plang" then
            opts.plang = argv[i + 1]
            i = i + 2
        elseif a == "--seed" then
            opts.seed = argv[i + 1]
            i = i + 2
        elseif a == "--count" then
            opts.count = tonumber(argv[i + 1]) or opts.count
            i = i + 2
        elseif a == "--continue-from" then
            opts.continue_from = argv[i + 1]
            i = i + 2
        elseif a == "--out" then
            opts.out = argv[i + 1]
            i = i + 2
        elseif a == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif a == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif a == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    if not opts.continue_from and not opts.plang then
        error("--plang is required unless --continue-from is used")
    end

    return opts
end

local function ensure_dir(path)
    os.execute("mkdir -p " .. path)
end

local function read_text(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("*a")
    f:close()
    return text
end

local function read_json(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("*a")
    f:close()
    return json.decode(text)
end

local function write_report(path, payload)
    local f = assert(io.open(path, "w"))
    f:write(json.encode(payload, { indent = true }))
    f:close()
end

local function save_report(path, payload)
    payload.updated_at = os.date("%Y%m%d_%H%M%S")
    payload.last_completed_step = 0
    for _, step in ipairs(payload.steps or {}) do
        if step.status == "completed" then
            payload.last_completed_step = step.step
        end
    end
    write_report(path, payload)
end

local function make_report_path()
    ensure_dir("workspace/tests")
    local ts = os.date("%Y%m%d_%H%M%S")
    return string.format("workspace/tests/%s_plang_chain.json", ts), ts
end

local function split_blocks(text)
    local blocks = {}
    local current = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        if line:match("^%s*$") then
            if #current > 0 then
                blocks[#blocks + 1] = table.concat(current, "\n")
                current = {}
            end
        else
            current[#current + 1] = line
        end
    end
    if #current > 0 then
        blocks[#blocks + 1] = table.concat(current, "\n")
    end
    return blocks
end

local function compact_block(block)
    local out = {}
    for line in block:gmatch("[^\r\n]+") do
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" and not trimmed:match("^[%a_]+:%s*$") then
            out[#out + 1] = trimmed
        end
    end
    return table.concat(out, " ")
end

local function parse_plang_sections(text)
    local blocks = split_blocks(text)
    local sections = {
        glossary = nil,
        seed = nil,
        runner = nil,
    }

    for _, block in ipairs(blocks) do
        local first = block:match("^([^\n]+)")
        local compact = compact_block(block)
        if first and first:match("^%s*processlang:%s*$") then
            sections.glossary = compact
        elseif first and first:match("^%s*seed:%s*$") then
            sections.seed = compact
        elseif compact:find("△") and compact:find("output_processlang_only") then
            sections.runner = compact
        elseif not sections.glossary then
            sections.glossary = compact
        elseif not sections.seed and compact:find("△") and compact:find("output") then
            sections.seed = compact
        end
    end

    if not sections.seed then
        sections.seed = sections.glossary
    end
    if not sections.runner then
        sections.runner = sections.glossary
    end

    return sections
end

local function build_messages(sections, prev_answer, seed)
    local body
    if not prev_answer or prev_answer == "" then
        body = table.concat({
            sections.glossary or "",
            "",
            sections.runner or "",
            "",
            seed or "",
        }, "\n")
    else
        body = table.concat({
            sections.glossary or "",
            "",
            sections.runner or "",
            "",
            prev_answer,
        }, "\n")
    end

    return {
        { role = "user", content = body },
    }, body
end

local opts = parse_args(arg)
local steps = {}
local prev_answer = nil
local start_step = 1
local report_path = opts.out
local report_ts = os.date("%Y%m%d_%H%M%S")
local payload = nil
local plang_text = nil
local sections = nil
local seed = opts.seed

if opts.continue_from then
    local prior = read_json(opts.continue_from)
    report_path = report_path or opts.continue_from
    report_ts = prior.timestamp or report_ts
    plang_text = prior.plang_text
    sections = prior.sections
    seed = prior.seed or seed

    local last_completed = 0
    for _, step in ipairs(prior.steps or {}) do
        if step.status == "completed" and step.output then
            steps[#steps + 1] = step
            prev_answer = step.output
            last_completed = step.step or last_completed
        end
    end
    if last_completed > 0 then
        start_step = last_completed + 1
    end
else
    plang_text = read_text(assert(opts.plang, "--plang required"))
    sections = parse_plang_sections(plang_text)
    seed = seed or sections.seed
end

if not report_path then
    report_path, report_ts = make_report_path()
end

payload = {
    timestamp = report_ts,
    started_at = report_ts,
    updated_at = report_ts,
    finished_at = nil,
    mode = "plang_chain",
    provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
    model = opts.model,
    plang_path = opts.plang,
    plang_text = plang_text,
    sections = sections,
    seed = seed,
    count = opts.count,
    steps = steps,
}

if opts.continue_from then
    payload.started_at = read_json(opts.continue_from).started_at or report_ts
end

save_report(report_path, payload)

print("== report ==")
print(report_path)
print("")
print("== seed ==")
print(seed or "")
print("")
print(string.format("== checkpoint == start_step=%d", start_step))
print("")

if start_step > opts.count then
    payload.finished_at = os.date("%Y%m%d_%H%M%S")
    save_report(report_path, payload)
    os.exit(0)
end

for step = start_step, opts.count do
    local messages, prompt = build_messages(sections or parse_plang_sections(plang_text or ""), prev_answer, seed)
    local answer, err = llm.ask(messages, {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature,
        max_tokens = opts.max_tokens,
    })

    local record = {
        step = step,
        prompt = prompt,
        output = answer,
        error = err,
        status = answer and "completed" or "error",
    }

    steps[#steps + 1] = record
    payload.steps = steps
    save_report(report_path, payload)

    if not answer then
        break
    end

    prev_answer = answer
end

payload.finished_at = os.date("%Y%m%d_%H%M%S")
save_report(report_path, payload)
