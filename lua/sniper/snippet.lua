local Snippet = {}
Snippet.__index = Snippet

function Snippet._get_file_path(name)
    local ext = vim.fn.expand("%:e")
    return string.format("%s/%s/%s.%s", vim.g.sniper_folder, ext, name, ext)
end

function Snippet._get_file(path)
    if vim.fn.filereadable(path) == 0 then
	return nil
    end
    return vim.fn.readfile(path)
end

function Snippet._replace(list, from, to)
    for i, line in pairs(list) do
        list[i], replaced = line:gsub(from, to, 1)
        if replaced > 0 then
            break
        end
    end
end

function Snippet:new(name)
    local t = {}
    setmetatable(t, Snippet)
    t.name = name
    t.path = Snippet._get_file_path(name)
    t.snippet = Snippet._get_file(t.path)
    t.arg_chr = "#"
    t.cursor_chr = "@"
    t.cursor_pos = nil
    return t
end

function Snippet:set_args(args)
    for _, arg in pairs(args) do
	Snippet._replace(self.snippet, self.arg_chr, arg)
    end
end

function Snippet:indent(size)
    for i, line in pairs(self.snippet) do
	self.snippet[i] = string.rep(" ", size) .. line
    end
end

function Snippet:set_cursor_pos()
    for i, v in pairs(self.snippet) do
	local found = v:find(self.cursor_chr)
	if found then
	    self.cursor_pos = { y = i, x = found }
	    return
	end
    end
end

function Snippet:rem_cursor_chr()
    Snippet._replace(self.snippet, self.cursor_chr, "")
end

return Snippet
