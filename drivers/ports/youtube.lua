local youtube = {}

local KEY = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"

function youtube.search(q)
    if not q then return "# Нет запроса" end
    
    local json = string.format('{"context":{"client":{"clientName":"WEB","clientVersion":"2.20250220.01.00"}},"query":"%s"}', q:gsub('"', '\\"'))
    local url = "https://www.youtube.com/youtubei/v1/search?key=" .. KEY
    
    local cmd = string.format("curl -s -X POST -H 'Content-Type: application/json' -d '%s' '%s'", json, url)
    
    local f = io.popen(cmd)
    if not f then return "# Ошибка curl" end
    local resp = f:read("*a")
    f:close()
    
    if not resp then return "# Нет ответа" end
    
    local videos = {}
    
    -- Ищем videoRenderer блоки
    for block in resp:gmatch('"videoRenderer":(%b{})') do
        local vid = block:match('"videoId":"([^"]+)"')
        local title = block:match('"text":"([^"]+)"')
        
        if vid and title then
            table.insert(videos, {id=vid, title=title})
        end
    end
    
    local result = "# YouTube: " .. q .. "\n\n"
    
    if #videos == 0 then
        result = result .. "Не найдено\n"
    else
        for i, v in ipairs(videos) do
            if i > 3 then break end
            result = result .. i .. ". " .. v.title .. "\n"
            result = result .. "   https://youtu.be/" .. v.id .. "\n\n"
        end
    end
    
    return result
end

return youtube