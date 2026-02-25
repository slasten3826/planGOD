-- server/web.lua - planGOD Web Server

local socket = require("socket")
local json   = require("dkjson")

local M = {}

local output_queue = {}

local server = assert(socket.bind("127.0.0.1", 8080))
server:setoption("reuseaddr", true)

local function send_response(client, status, content_type, body)
    client:send("HTTP/1.1 " .. status .. "\r\n")
    client:send("Content-Type: " .. content_type .. "; charset=utf-8\r\n")
    client:send("Access-Control-Allow-Origin: *\r\n")
    client:send("Content-Length: " .. tostring(#body) .. "\r\n")
    client:send("\r\n")
    client:send(body)
    client:close()
end

local function enqueue(msg_type, text)
    table.insert(output_queue, { type = msg_type, text = text })
end

-- ======================================================================
-- Главный цикл I/O сервера
-- ======================================================================

function M.read_input()
    print("planGOD: http://127.0.0.1:8080 | Ожидание подключения...")

    while true do
        local client = server:accept()
        client:settimeout(1)

        local req_line, err = client:receive()
        if not err and req_line then
            local method, path = req_line:match("^(%S+)%s+(%S+)")

            local content_length = 0
            while true do
                local header = client:receive()
                if not header or header:match("^%s*$") then break end
                local k, v = header:match("^(.-):%s*(.*)")
                if k and k:lower() == "content-length" then
                    content_length = tonumber(v) or 0
                end
            end

            if method == "GET" and (path == "/" or path == "/index.html") then
                local f    = io.open("www/index.html", "r")
                local html = f and f:read("*a") or "<h1>404: www/index.html не найден</h1>"
                if f then f:close() end
                send_response(client, "200 OK", "text/html", html)

            elseif method == "GET" and path == "/poll" then
                local body = json.encode(output_queue)
                output_queue = {}
                send_response(client, "200 OK", "application/json", body)

            elseif method == "POST" and path == "/chat" then
                local body = ""
                if content_length > 0 then
                    body = client:receive(content_length)
                end
                send_response(client, "200 OK", "application/json", '{"status":"ok"}')
                if body and body ~= "" then
                    return body
                end

            else
                send_response(client, "404 Not Found", "text/plain", "Not Found")
            end
        else
            client:close()
        end
    end
end

-- ======================================================================
-- Вывод
-- ======================================================================

function M.header()
    enqueue("sys", "========================================")
    enqueue("sys", "planGOD initialized. Protocol: Web.")
    enqueue("sys", "========================================")
end

function M.sys(text)          enqueue("sys",      text)                          end
function M.response(text)     enqueue("eva",       text)                          end
function M.thinking()                                                              end
function M.runtime(msg)       enqueue("runtime",  "⚡ RUNTIME: " .. msg)          end
function M.exec_error(err)    enqueue("error",    "[EXEC ERROR] " .. tostring(err)) end
function M.exec_result(res)   enqueue("manifest", "[EXEC RESULT]: " .. tostring(res)) end
function M.llm_error(err)     enqueue("error",    "[LLM ERROR] " .. tostring(err))  end

return M
