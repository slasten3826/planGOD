-- eva/manifest.lua
-- Eva.MANIFEST creates temporary manifestation forms (phantoms).

local llm = require("core.llm")
local pl = require("processlang.processlang")
local state = require("eva.state")

local manifest = {}

local function read_nanopl()
    local f = io.open("nanoPL.txt", "r")
    if not f then return "" end
    local text = f:read("*a")
    f:close()
    return text or ""
end

local function new_phantom(spec, basis, index)
    return {
        kind = spec.target,
        index = index or 1,
        task = spec.task,
        pattern = spec.pattern,
        format = spec.format,
        loss = spec.loss,
        constraints = spec.constraints or {},
        memory_mode = spec.memory_mode or "none",
        basis = basis,
    }
end

function manifest.create(spec, basis, batch)
    local count = batch and batch.count or 1

    if count <= 1 then
        return new_phantom(spec, basis, 1)
    end

    local out = {}
    for i = 1, count do
        out[#out + 1] = new_phantom(spec, basis, i)
    end
    return out
end

local function execute_one(phantom)
    return {
        kind = phantom.kind,
        index = phantom.index,
        task = phantom.task,
        status = "completed",
        memory_mode = phantom.memory_mode,
        pattern_signature = phantom.pattern and phantom.pattern._signature or nil,
        output = string.format(
            "[%s:%d] %s",
            tostring(phantom.kind or "phantom"),
            tonumber(phantom.index) or 1,
            tostring(phantom.task or "unspecified")
        ),
    }
end

local function build_llm_messages(phantom)
    local basis = phantom.basis or {}
    local substrate = basis.substrate or {}

    local lines = {
        "You are a temporary Eva phantom.",
        "You have exactly one function.",
        "Return one short useful result for Eva.Core.",
        "",
        "Phantom kind: " .. tostring(phantom.kind or "unknown"),
        "Task: " .. tostring(phantom.task or "unspecified"),
        "Index: " .. tostring(phantom.index or 1),
        "Memory mode: " .. tostring(phantom.memory_mode or "none"),
        "Pattern signature: " .. tostring(phantom.pattern and phantom.pattern._signature or "none"),
        "Format: " .. tostring(phantom.format or "conversational"),
        "Basis mode: " .. tostring(basis.mode or "active"),
        "Basis edge count: " .. tostring(basis.edge_count or 0),
        "Substrate provider: " .. tostring(substrate.provider or "unknown"),
        "Substrate model: " .. tostring(substrate.model or "unknown"),
        "",
        "Rules:",
        "- do not explain your whole reasoning",
        "- produce one concise result",
        "- stay inside the assigned task",
        "- do not roleplay beyond the phantom function",
    }

    if phantom.format == "processlang" then
        lines[#lines + 1] = "- output only ProcessLang"
        lines[#lines + 1] = "- no prose"
        lines[#lines + 1] = "- no markdown"
        lines[#lines + 1] = "- preserve operator structure"
    end

    return {
        {
            role = "user",
            content = table.concat(lines, "\n"),
        }
    }
end

local function execute_one_llm(phantom, opts)
    local basis = phantom.basis or {}
    local substrate = basis.substrate or {}
    if opts.run_id then
        state.increment(opts.run_id, "llm_calls_started", 1)
        state.update(opts.run_id, {
            phase = opts.phase or "manifest",
            status = string.format("Running phantom %d", tonumber(phantom.index) or 1),
        })
    end
    local content, err = llm.ask(build_llm_messages(phantom), {
        provider = opts.provider or substrate.provider,
        model = opts.model or substrate.model,
        temperature = opts.temperature or 0.4,
        max_tokens = opts.max_tokens or 300,
        timeout = opts.timeout,
        debug = opts.debug,
    })
    if opts.run_id then
        state.increment(opts.run_id, "llm_calls_finished", 1)
    end

    if not content then
        return {
            kind = phantom.kind,
            index = phantom.index,
            task = phantom.task,
            status = "error",
            memory_mode = phantom.memory_mode,
            pattern_signature = phantom.pattern and phantom.pattern._signature or nil,
            error = tostring(err),
            output = nil,
        }
    end

    local residue = nil
    if opts.include_residue ~= false then
        if opts.run_id then
            state.increment(opts.run_id, "llm_calls_started", 1)
        end
        local residue_prompt = table.concat({
            "nanoPL:",
            read_nanopl(),
            "",
            "Task:",
            "Encode the phantom result into one compact nanoPL residue line.",
            "",
            "Rules:",
            "- output exactly one line",
            "- start with: NANOPL:",
            "- no prose explanation",
            "- preserve cognitive state, not wording",
            "",
            "Phantom task:",
            tostring(phantom.task or ""),
            "",
            "Phantom result:",
            tostring(content or ""),
        }, "\n")

        local residue_raw = llm.ask({
            { role = "user", content = residue_prompt }
        }, {
            provider = opts.provider or substrate.provider,
            model = opts.model or substrate.model,
            temperature = 0.1,
            max_tokens = 120,
            timeout = opts.timeout,
            debug = opts.debug,
        })
        if opts.run_id then
            state.increment(opts.run_id, "llm_calls_finished", 1)
        end

        if residue_raw then
            residue = residue_raw:match("^%s*NANOPL:%s*(.-)%s*$")
                or residue_raw:match("^%s*(.-)%s*$")
        end
    end

    local sealed = pl.MANIFEST.seal({ value = content })

    return {
        kind = phantom.kind,
        index = phantom.index,
        task = phantom.task,
        status = "completed",
        memory_mode = phantom.memory_mode,
        pattern_signature = phantom.pattern and phantom.pattern._signature or nil,
        output = sealed.value,
        residue = residue,
    }
end

function manifest.execute(phantoms, opts)
    opts = opts or {}
    if type(phantoms) ~= "table" then
        error("Eva.MANIFEST: execute() expects phantom table or phantom array")
    end

    local exec_one = execute_one
    if opts.mode == "llm" then
        exec_one = function(phantom)
            return execute_one_llm(phantom, opts)
        end
    end

    if phantoms.kind then
        return exec_one(phantoms)
    end

    local results = {}
    for i, phantom in ipairs(phantoms) do
        results[i] = exec_one(phantom)
    end
    return results
end

return manifest
