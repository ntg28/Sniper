function! Sniper()
lua << EOF
    for k in pairs(package.loaded) do
	if k:match("^sniper") then
	    package.loaded[k] = nil
	end
    end
    require("sniper").sniper()
EOF
endfunction

inoremap <C-j> <cmd>:call Sniper()<cr>
