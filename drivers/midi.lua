-- drivers/midi.lua
-- Генератор бинарных MIDI-файлов (Type 0)

local midi = {}

-- Упаковка числа переменной длины (VLQ) для дельта-времени (стандарт MIDI)
local function to_vlq(n)
if n == 0 then return string.char(0) end
    local bytes = {}
    while n > 0 do
        table.insert(bytes, 1, n & 0x7F) -- Берем нижние 7 бит
        n = n >> 7                       -- Сдвигаем вправо
        end
        -- Устанавливаем старший бит в 1 для всех байт, кроме последнего
        for i = 1, #bytes - 1 do
            bytes[i] = bytes[i] | 0x80
            end

            local res = ""
            for _, b in ipairs(bytes) do
                res = res .. string.char(b)
                end
                return res
                end

                -- Базовые MIDI-события
                function midi.note_on(dt, channel, note, velocity)
                -- 0x90 = Note On. Канал от 0 до 15.
                return to_vlq(dt) .. string.pack(">B >B >B", 0x90 | (channel & 0x0F), note, velocity)
                end

                function midi.note_off(dt, channel, note)
                -- 0x80 = Note Off
                return to_vlq(dt) .. string.pack(">B >B >B", 0x80 | (channel & 0x0F), note, 0)
                end

                function midi.set_tempo(dt, bpm)
                local microseconds_per_quarter = math.floor(60000000 / bpm)
                -- Meta Event: 0xFF 0x51 0x03 (3 байта данных темпа)
                return to_vlq(dt) .. string.char(0xFF, 0x51, 0x03) .. string.pack(">I4", microseconds_per_quarter):sub(2)
                end

                -- Финальная сборка и запись (MANIFEST)
                function midi.write(filepath, events, ticks_per_beat)
                ticks_per_beat = ticks_per_beat or 480

                local f, err = io.open(filepath, "wb")
                if not f then return false, "MIDI driver ERROR: " .. tostring(err) end

                    -- Заголовок MThd: Length=6, Format=0 (один трек), Tracks=1, Division=ticks_per_beat
                    f:write("MThd")
                    f:write(string.pack(">I4 >I2 >I2 >I2", 6, 0, 1, ticks_per_beat))

                    -- Трек MTrk
                    local track_data = table.concat(events)
                    -- Обязательный конец трека (Meta Event 0xFF 0x2F 0x00)
                    track_data = track_data .. string.char(0x00, 0xFF, 0x2F, 0x00)

                    f:write("MTrk")
                    f:write(string.pack(">I4", #track_data))
                    f:write(track_data)

                    f:close()
                    return true
                    end

                    return midi
