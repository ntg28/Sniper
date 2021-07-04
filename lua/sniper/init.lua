-- [[ sniper ]] --

-- [[ sniper Utils ]] --
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
    local _snippets = {
	fn = {
	    "function #()",
	    "    @",
	    "end"
	},
	fnr = {
	    "function #()",
	    "    return #@",
	    "end"
	},
	fna = {
	    "function #(@)",
	    "end"
	},
	_for = {
	    "for #, # in pairs(#) do",
	    "    @",
	    "end"
	},
	perr = {
	    "print(\"e: @\")"
	}
    }

    local line = vim.fn.getline(".")
    local line_table = Util.split_white_space(line)
    local snippet = nil

    if _snippets[line_table[1]] then
	snippet = _snippets[line_table[1]]
    else
	return nil
    end

    local args = {}
    for i = 2, #line_table do
	table.insert(args, line_table[i])
    end

    Util.str_table_replace(snippet, "#", args)

    local curpos = vim.fn.getcurpos()
    local snpcurpos = M.snippet_get_cursor(snippet)

    Util.str_table_replace(snippet, "@", "")

    table.insert(snippet, "")

    vim.cmd("delete")
    vim.paste(snippet, 1)

    if snpcurpos == nil then
        vim.fn.cursor(curpos[2], curpos[3])
    else
        vim.fn.cursor(curpos[2]+snpcurpos.y-1, snpcurpos.x)
    end
end

return M
