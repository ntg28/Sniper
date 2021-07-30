-- [[ sniper ]] --

-- [[ sniper Util ]] --
local Util = {}

function Util.str_table_replace(table, from, to)
    if type(to) == "table" then
	for _, v_arg in pairs(to) do
	    for line, v_line in pairs(table) do
		table[line], replaced = v_line:gsub(from, v_arg, 1)
		if replaced > 0 then
		    break
		end
	    end
	end
	return
    end

    for i, v in pairs(table) do
	table[i] = v:gsub(from, to)
    end
end

function Util.split(str, sp)
    local result = {}
    for subs in str:gmatch(sp) do
	table.insert(result, subs)
    end
    return result
end

function Util.split_white_space(str)
    return Util.split(str, "%S+")
end

function map(table, fn)
    local t = {}
    for k, v in pairs(table) do
	t[k] = fn(v)
    end
    return t
end

function indent(table, size)
    return map(table, function(s)
	return string.rep(" ", size) .. s
    end)
end

function goto_begin_of_line()
    vim.cmd("normal ^")
end

-- [[ sniper Module ]] --
local M = {}

function M.snippet_get_cursor(snippet)
    local pos = {}
    local found = nil
    for i, v in pairs(snippet) do
	found = v:find("@")
	if found then
	    pos.y = i
	    pos.x = found
	    return pos
	end
    end
    return nil
end

function M.sniper()
    local file_ext = vim.fn.expand("%:e")
    local sniper_folder = vim.g.sniper_folder

    if sniper_folder == nil then
	print("e: missing g:sniper_folder variable")
	return nil
    end

    local line = vim.fn.getline(".")
    local line_table = Util.split_white_space(line)

    if line_table[1] == nil then
	print("e: empty line")
	return nil
    end

    local snippet_path = string.format("%s/%s/%s.%s",
	sniper_folder, file_ext, line_table[1], file_ext)

    if vim.fn.filereadable(snippet_path) == 0 then
	print(string.format("e: snippet not found at \"%s\"", snippet_path))
	return nil
    end

    local snippet = vim.fn.readfile(snippet_path)

    local args = {}
    for i = 2, #line_table do
        table.insert(args, line_table[i])
    end

    Util.str_table_replace(snippet, "#", args)

    goto_begin_of_line()

    local curpos = vim.fn.getcurpos()
    snippet = indent(snippet, curpos[5] - 1)

    local snpcurpos = M.snippet_get_cursor(snippet)

    Util.str_table_replace(snippet, "@", "")

    vim.api.nvim_put(snippet, "l", true, false)
    vim.cmd(string.format("%sdelete", curpos[2]))

    if snpcurpos == nil then
        vim.fn.cursor(curpos[2], curpos[3])
    else
        vim.fn.cursor(curpos[2]+snpcurpos.y-1, snpcurpos.x)
    end
end

return M
