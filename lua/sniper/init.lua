-- [[ sniper ]] --

local M = {}

function M.split(str, sp)
    local result = {}
    for subs in str:gmatch(sp) do
	table.insert(result, subs)
    end
    return result
end

function M.split_white_space(str)
    return M.split(str, "%S+")
end

function M.split_new_line(str)
    return M.split(str, "%C+")
end

function M.paste(str, fmt)
    if (fmt) then
	str = string.format(str, unpack(fmt))
    end
    local value = M.split_new_line(str)
    table.insert(value, "")
    vim.paste(value, 1)
end

function M.move(y, x)
    local curpos = vim.fn.getcurpos()
    vim.fn.cursor(curpos[2]+y, curpos[3]+x)
end

function M.sniper()
    local curline = vim.api.nvim_get_current_line()
    local scurline = M.split_white_space(curline)
    if (scurline[1] == "fn") then
	vim.cmd("delete")
	M.paste([[
	function %s()
	    
	end
	]], {scurline[2]})
	M.move(-2, 80)
    end
end

return M
