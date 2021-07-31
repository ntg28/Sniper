local Snippet = require("sniper.snippet")

function split(str, sp)
    local result = {}
    for subs in str:gmatch(sp) do
	table.insert(result, subs)
    end
    return result
end

function split_white_space(str)
    return split(str, "%S+")
end

function goto_begin_of_line()
    vim.cmd("normal ^")
end

function parse_line(line)
    local t = split_white_space(vim.fn.getline(line))
    return {
	name = t[1],
	args = {unpack(t, 2)}
    }
end

function paste(list)
    vim.api.nvim_put(list, "l", true, false)
end

function delete(line)
    vim.cmd(string.format("%sdelete", line))
end

function sniper()
    if vim.g.sniper_folder == nil then
	print("ERROR: missing g:sniper_folder variable")
	return nil
    end

    local sn_info = parse_line(".")

    if sn_info.name == nil then
	print("ERROR: empty line")
	return nil
    end

    local sn = Snippet:new(sn_info.name)

    if sn.snippet == nil then
	print("ERROR: snippet not found at " .. sn.path)
	return nil
    end

    goto_begin_of_line()

    local curpos = vim.fn.getcurpos()

    sn:set_args(sn_info.args)
    sn:indent(curpos[5] - 1)
    sn:set_cursor_pos()
    sn:rem_cursor_chr()

    paste(sn.snippet)
    delete(curpos[2])

    if sn.cursor_pos then
        vim.fn.cursor(curpos[2]+sn.cursor_pos.y-1, sn.cursor_pos.x)
    else
        vim.fn.cursor(curpos[2], curpos[3])
    end
end

return { sniper = sniper }
