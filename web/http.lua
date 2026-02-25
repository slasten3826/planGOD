-- web/http.lua v2
-- Слой 1: HTTP Transport
-- Контракт: возвращает {status, body, error}
-- Fixes: sanitize_url, уникальный разделитель, status=0, body при ошибках, set_config

local http = {}

-- Конфигурация
local CONFIG = {
    timeout    = 15,
    max_redirs = 5,
    user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    proxy      = nil,  -- "socks5h://127.0.0.1:1080"
}

-- Глобальная настройка конфига (рекомендация Евы)
function http.set_config(new_config)
for k, v in pairs(new_config) do
    CONFIG[k] = v
    end
    end

    -- Безопасная очистка URL — оборачиваем в одинарные кавычки
    -- Одинарная кавычка внутри: ' → '\''
    local function sanitize_url(url)
    local safe = url:gsub("'", "'\"'\"'")
    return "'" .. safe .. "'"
    end

    -- Уникальный разделитель чтобы не спутать с телом (рекомендация Евы + Gemini)
    local SEPARATOR = "||HTTPSTATUS||"

    -- Основной запрос
    function http.get(url, options)
    options = options or {}

    local safe_url = sanitize_url(url)
    local timeout  = options.timeout    or CONFIG.timeout
    local proxy    = options.proxy      or CONFIG.proxy
    local ua       = options.user_agent or CONFIG.user_agent

    -- Строим команду с уникальным разделителем
    local cmd = string.format(
        'curl -sL --max-time %d --max-redirs %d -w "%s%%{http_code}" -H "User-Agent: %s"',
        timeout, CONFIG.max_redirs, SEPARATOR, ua
    )

    if proxy then
        cmd = cmd .. string.format(" -x '%s'", proxy)
        end

        cmd = cmd .. " " .. safe_url .. " 2>/dev/null"

        -- Выполняем
        local f, err = io.popen(cmd)
        if not f then
            return { status = 0, body = nil, error = "io.popen failed: " .. tostring(err) }
            end

            local raw = f:read("*a")
            f:close()

            if not raw or raw == "" then
                return { status = 0, body = nil, error = "empty response" }
                end

                -- Парсим через уникальный разделитель
                local body, status_str = raw:match("^(.*)" .. SEPARATOR .. "(%d%d%d)%s*$")
                local status = tonumber(status_str) or 0

                if not body then
                    return { status = 0, body = nil, error = "failed to parse curl response" }
                    end

                    -- Фикс Gemini: status=0 означает сетевую ошибку
                    if status == 0 then
                        return { status = 0, body = nil, error = "network or DNS error (curl failed)" }
                        end

                        -- Фикс Евы: возвращаем body даже при ошибках
                        local body_or_nil = (body ~= "") and body or nil

                        if status == 451 then
                            return { status = 451, body = body_or_nil, error = "unavailable for legal reasons (geo-block)" }
                            elseif status == 403 then
                                return { status = 403, body = body_or_nil, error = "forbidden" }
                                elseif status == 404 then
                                    return { status = 404, body = body_or_nil, error = "not found" }
                                    elseif status >= 400 then
                                        return { status = status, body = body_or_nil, error = "HTTP error " .. status }
                                        end

                                        return { status = status, body = body, error = nil }
                                        end

                                        return http
