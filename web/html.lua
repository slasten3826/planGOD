-- web/html.lua v2
-- DFA HTML Parser: O(N), без backtracking
local html = {}

local S_TEXT   = 1
local S_TAG    = 2
local S_ATTR   = 3
local S_QUOTE  = 4
local S_IGNORE = 5
local S_ENTITY = 6

local TAG_PREFIX = {
    h1="\n# ", h2="\n## ", h3="\n### ",
    h4="\n#### ", h5="\n##### ", h6="\n###### ",
    p="\n\n", li="\n* ", br="\n",
    blockquote="\n> ", tr="\n",
}

local SKIP_TAGS = {
    script=true, style=true, nav=true, footer=true,
    aside=true, svg=true, canvas=true, head=true,
}

local ENTITIES = {
    nbsp=" ", quot='"', amp="&", lt="<", gt=">",
    mdash="—", ndash="–", hellip="…", copy="©",
    laquo="«", raquo="»", apos="'",
}

local function decode_entity(e)
    if e:sub(1,1) == "#" then
        local code = e:sub(2,2)=="x" and tonumber(e:sub(3),16) or tonumber(e:sub(2))
        if code then
            if code < 128 then return string.char(code) end
            if code == 160 then return " " end
            if code == 8212 then return "—" end
            if code == 8211 then return "–" end
        end
        return " "
    end
    return ENTITIES[e:lower()] or ("&"..e..";")
end

function html.parse(raw_html)
    if not raw_html or raw_html == "" then return "" end

    local state      = S_TEXT
    local out        = {}
    local i          = 1
    local len        = #raw_html

    local tag_name   = ""
    local tag_close  = false
    local attr_buf   = ""   -- весь буфер атрибутов
    local quote_char = ""
    local in_link    = false
    local link_href  = nil
    local link_text  = ""
    local text_buf   = ""
    local entity_buf = ""
    local skip_until = ""

    local function flush_text()
        local t = text_buf:gsub("%s+", " ")
        if t ~= "" and t ~= " " then
            if in_link then
                link_text = link_text .. t
            else
                table.insert(out, t)
            end
        end
        text_buf = ""
    end

    local function extract_href(attrs)
        -- ищем href="..." или href='...'
        return attrs:match('[Hh][Rr][Ee][Ff]%s*=%s*"([^"]*)"')
            or attrs:match("[Hh][Rr][Ee][Ff]%s*=%s*'([^']*)'")
    end

    local function handle_open(name, attrs)
        name = name:lower()
        if SKIP_TAGS[name] then
            flush_text()
            skip_until = "</" .. name
            state = S_IGNORE
            return
        end
        if name == "a" then
            flush_text()
            in_link   = true
            link_text = ""
            link_href = extract_href(attrs)
            return
        end
        local prefix = TAG_PREFIX[name]
        if prefix then
            flush_text()
            table.insert(out, prefix)
        end
    end

    local function handle_close(name)
        name = name:lower()
        if name == "a" and in_link then
            flush_text()
            local lt = link_text:gsub("^%s+",""):gsub("%s+$","")
            if link_href and link_href ~= "" and lt ~= "" then
                table.insert(out, "[" .. lt .. "](" .. link_href .. ")")
            elseif lt ~= "" then
                table.insert(out, lt)
            end
            in_link = false; link_text = ""; link_href = nil
        end
    end

    while i <= len do
        local c = raw_html:sub(i, i)

        if state == S_TEXT then
            if c == "<" then
                if raw_html:sub(i, i+3) == "<!--" then
                    flush_text()
                    skip_until = "-->"
                    state = S_IGNORE
                    i = i + 3
                else
                    flush_text()
                    state = S_TAG; tag_name = ""; tag_close = false; attr_buf = ""
                end
            elseif c == "&" then
                flush_text(); entity_buf = ""; state = S_ENTITY
            else
                text_buf = text_buf .. c
            end

        elseif state == S_TAG then
            if c == "/" and tag_name == "" then
                tag_close = true
            elseif c == ">" then
                if tag_close then handle_close(tag_name)
                else handle_open(tag_name, "") end
                if state ~= S_IGNORE then state = S_TEXT end
            elseif c == " " or c == "\t" or c == "\n" or c == "\r" then
                if tag_name ~= "" then state = S_ATTR end
            else
                tag_name = tag_name .. c
            end

        elseif state == S_ATTR then
            if c == ">" then
                if tag_close then handle_close(tag_name)
                else handle_open(tag_name, attr_buf) end
                if state ~= S_IGNORE then state = S_TEXT end
            elseif c == '"' or c == "'" then
                quote_char = c; state = S_QUOTE
                attr_buf = attr_buf .. c
            else
                attr_buf = attr_buf .. c
            end

        elseif state == S_QUOTE then
            attr_buf = attr_buf .. c
            if c == quote_char then state = S_ATTR end

        elseif state == S_IGNORE then
            local slice = raw_html:sub(i, i + #skip_until - 1)
            if slice:lower() == skip_until:lower() then
                i = i + #skip_until - 1
                while i <= len and raw_html:sub(i,i) ~= ">" do i = i + 1 end
                state = S_TEXT
            end

        elseif state == S_ENTITY then
            if c == ";" then
                text_buf = text_buf .. decode_entity(entity_buf)
                state = S_TEXT
            elseif c == " " or c == "<" then
                text_buf = text_buf .. "&" .. entity_buf
                state = S_TEXT; i = i - 1
            else
                entity_buf = entity_buf .. c
            end
        end

        i = i + 1
    end

    flush_text()

    local result = table.concat(out)
    result = result:gsub("\n\n\n+", "\n\n")
    result = result:gsub("^[\n%s]+", "")
    result = result:gsub("[\n%s]+$", "")
    return result
end

return html
