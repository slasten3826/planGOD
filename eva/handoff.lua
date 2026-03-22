-- eva/handoff.lua
-- Eva.HANDOFF builds phantom-to-phantom task continuity.

local handoff = {}

function handoff.build_chain_task(base_task, step_index, prev_result, format)
    local output = prev_result and prev_result.output or ""
    local residue = prev_result and prev_result.residue or ""

    if format == "processlang" then
        local lines = { base_task }
        if output ~= "" then
            lines[#lines + 1] = ""
            lines[#lines + 1] = tostring(output)
        end
        if residue ~= "" then
            lines[#lines + 1] = ""
            lines[#lines + 1] = tostring(residue)
        end
        return table.concat(lines, "\n")
    end

    return table.concat({
        base_task,
        "",
        string.format("Phantom %d already proposed this idea:", step_index),
        output,
        "",
        string.format("Phantom %d nanoPL residue:", step_index),
        residue,
    }, "\n")
end

function handoff.build_debate_task(base_task, round_index, self_index, round_results)
    local lines = {
        base_task,
        "",
        string.format("Debate round: %d", round_index),
        string.format("You are phantom %d in a debate.", self_index),
        "Read the other positions, keep what is strong, reject what is weak, and return your updated position.",
        "",
        "Other phantom positions:",
    }

    for i, result in ipairs(round_results or {}) do
        if i ~= self_index then
            lines[#lines + 1] = ""
            lines[#lines + 1] = string.format("Phantom %d output:", i)
            lines[#lines + 1] = tostring(result.output or "")
            lines[#lines + 1] = string.format("Phantom %d nanoPL residue:", i)
            lines[#lines + 1] = tostring(result.residue or "")
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Return one revised position only."

    return table.concat(lines, "\n")
end

return handoff
