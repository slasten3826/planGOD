-- drivers/md.lua
-- Обработчик файлов разметки Markdown

local md = {}
local txt = require("drivers.txt")

md.read = txt.read
md.write = txt.write
md.append = txt.append

-- Хелперы для генерации структуры
function md.h(level, text)
level = math.max(1, math.min(6, level or 1))
return string.rep("#", level) .. " " .. text
end

function md.list(items)
local out = {}
for _, item in ipairs(items) do
    table.insert(out, "- " .. tostring(item))
    end
    return table.concat(out, "\n")
    end

    function md.code(language, code_text)
    return "```" .. (language or "") .. "\n" .. code_text .. "\n```"
    end

    -- Сборка документа из блоков (CONNECT)
    function md.build(filepath, blocks)
    local content = table.concat(blocks, "\n\n")
    return md.write(filepath, content)
    end

    return md
