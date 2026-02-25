-- drivers/web.lua
-- Тонкая обёртка над web/ слоем

local web  = {}
local http = require('web.http')
local html = require('web.html')

function web.fetch(url)
if not url or type(url) ~= "string" or url == "" then
    return nil, "WEB ERROR: некорректный URL"
    end

    local result = http.get(url)

    if result.error then
        return nil, "WEB ERROR: " .. result.error
        end

        if not result.body then
            return nil, "WEB ERROR: пустой ответ (статус " .. result.status .. ")"
            end

            local is_html = result.body:match("^%s*<!") or result.body:match("<html")
            if is_html then
                return html.parse(result.body)
                end

                return result.body
                end

                return web
