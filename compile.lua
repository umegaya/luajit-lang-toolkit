local lex_setup = require('lexer')
local parse = require('parser')
local ast = require('lua-ast').New()
local generator = require('generator')
local reader = require('reader')
local dump = require('syntax').dump

local function lang_toolkit_error(msg)
   if string.sub(msg, 1, 9) == "LLT-ERROR" then
        return false, "luajit-lang-toolkit: " .. string.sub(msg, 10)
    else
        error(msg)
    end
end

local function compile(reader, filename, options)
    local ls = lex_setup(reader, filename)
    local parse_success, tree = pcall(parse, ast, ls)
    if not parse_success then
        return lang_toolkit_error(tree)
    end
    local success, luacode = pcall(generator, tree, filename)
    if not success then
        return lang_toolkit_error(luacode)
    end
    return true, luacode
end

local function lang_loadstring(src, filename, options)
    reader.string_init(src)
    return compile(reader.string, filename, options)
end

local function lang_loadfile(filename, options)
    reader.file_init(filename)
    return compile(reader.file, filename, options)
end

return { string = lang_loadstring, file = lang_loadfile }
