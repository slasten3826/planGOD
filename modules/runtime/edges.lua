-- modules/runtime/edges.lua
-- Материализует E_momentum в устойчивые E_edges
-- Теперь edge = структурный переход (source→target), не текст

local edges    = {}
local momentum = require("modules.runtime.momentum")

local TYPE_RECOGNITION = "RECOGNITION"
local TYPE_HABIT       = "HABIT"

function edges.build(E_momentum)
    local E_edges = {}
    local prune   = momentum.prune_threshold()
    local habit   = momentum.habit_threshold()

    for key, entry in pairs(E_momentum) do
        if entry.w >= prune then
            table.insert(E_edges, {
                key     = key,
                weight  = entry.w,
                source  = entry.source,
                target  = entry.target,
                domain  = entry.domain,
                type_id = entry.w >= habit and TYPE_HABIT or TYPE_RECOGNITION,
                hits    = entry.hits or 1,
            })
        end
    end

    table.sort(E_edges, function(a, b) return a.weight > b.weight end)
    return E_edges
end

function edges.habits(E_edges)
    local habits = {}
    for _, edge in ipairs(E_edges) do
        if edge.type_id == TYPE_HABIT then
            table.insert(habits, edge)
        end
    end
    return habits
end

-- Контекст для промпта Евы — показываем структурные привычки
function edges.to_context(E_edges, max_edges)
    max_edges = max_edges or 20
    if #E_edges == 0 then return "" end

    local lines = { "\n## RUNTIME: Когнитивные привычки\n" }
    local count = 0

    for _, edge in ipairs(E_edges) do
        if count >= max_edges then break end
        local marker = edge.type_id == TYPE_HABIT and "◆" or "◇"
        -- формат: ◆ OBSERVE→LOGIC [processlang | w=0.82 | x7]
        table.insert(lines, string.format(
            "%s %s→%s [%s | w=%.2f | x%d]",
            marker,
            edge.source or "?",
            edge.target or "?",
            edge.domain,
            edge.weight,
            edge.hits
        ))
        count = count + 1
    end

    table.insert(lines, "\n")
    return table.concat(lines, "\n")
end

return edges
