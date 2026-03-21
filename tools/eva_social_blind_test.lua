-- tools/eva_social_blind_test.lua
-- Blind prototype test for Eva.Social boundary logic.

local social = require("eva.social")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 120,
        temperature = 0.3,
        max_tokens = 400,
        difficulty = "easy",
        debug = false,
        prompt = "Придумай интересную игровую механику для Packet Adventure",
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif a == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif a == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif a == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif a == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        elseif a == "--difficulty" then
            opts.difficulty = argv[i + 1] or opts.difficulty
            i = i + 2
        elseif a == "--prompt" then
            opts.prompt = argv[i + 1] or opts.prompt
            i = i + 2
        elseif a == "--debug" then
            opts.debug = true
            i = i + 1
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    return opts
end

local opts = parse_args(arg)
local result, err = social.run(opts.prompt, opts)

if not result then
    print("ERROR:")
    for k, v in pairs(err or {}) do
        print(tostring(k) .. ": " .. tostring(v))
    end
    os.exit(1)
end

print("== social reply ==")
print(result.reply)

if opts.debug then
    print("")
    print("== ingress ==")
    for k, v in pairs(result.ingress or {}) do
        print(tostring(k) .. ": " .. tostring(v))
    end
    print("")
    print("== plan ==")
    for k, v in pairs(result.plan or {}) do
        if k ~= "spawn" then
        print(tostring(k) .. ": " .. tostring(v))
        end
    end
end
