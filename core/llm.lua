-- core/llm.lua
-- The Brain: Handles raw HTTPS communication with DeepSeek API

local llm = {}
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("dkjson")

local API_URL = "https://api.deepseek.com/v1/chat/completions"

-- Функция запроса к мозгу
function llm.ask(messages, options)
-- Если options не передали, создаем пустую таблицу
local opts = options or {}

-- Читаем ключ напрямую из операционной системы (Manjaro)
local api_key = os.getenv("DEEPSEEK_API_KEY")
if not api_key then
    return nil, "FATAL ERROR: Переменная окружения DEEPSEEK_API_KEY не задана!"
    end

    -- Формируем таблицу запроса с динамическими параметрами
    local request_data = {
        model = opts.model or "deepseek-chat",
        messages = messages,
        temperature = opts.temperature or 0.7
    }

    -- Превращаем таблицу в JSON-строку
    local request_body = json.encode(request_data)
    local response_body = {} -- Сюда по кусочкам скачается ответ

    -- Выполняем HTTPS POST запрос
    local res, code, response_headers, status = https.request{
        url = API_URL,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. api_key,
            ["Content-Length"] = tostring(#request_body)
        },
        -- LTN12: Магия потоков. Мы отправляем строку как поток, и собираем ответ в таблицу
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
        protocol = "tlsv1_2" -- Надежный протокол шифрования
    }

    -- 1. Проверка на разрыв соединения
    if not res then
        return nil, "NETWORK ERROR: Нет связи с сервером DeepSeek. Код: " .. tostring(code)
        end

        -- Склеиваем скачанные кусочки ответа в одну строку
        local response_str = table.concat(response_body)

        -- 2. Проверка на ошибки самого API (например, кончились деньги на балансе)
        if code ~= 200 then
            return nil, "API ERROR (HTTP " .. tostring(code) .. "): " .. response_str
            end

            -- 3. Декодируем JSON ответ
            local obj, pos, err = json.decode(response_str, 1, nil)
            if err then
                return nil, "JSON PARSE ERROR: " .. tostring(err)
                end

                -- 4. Извлекаем драгоценную мысль машины
                if obj.choices and obj.choices[1] and obj.choices[1].message then
                    return obj.choices[1].message.content
                    else
                        return nil, "UNEXPECTED FORMAT: Сервер вернул дичь вместо ответа."
                        end
                        end

                        return llm
