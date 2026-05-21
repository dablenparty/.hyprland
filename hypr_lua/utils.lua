local M = {}

M.load_pywal_theme = function()
	local os = require("os")
	local cache_dir = os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache"
	local theme_path = cache_dir .. "/wal/colors-hyprland.lua"
	local theme_file, theme_load_err = loadfile(theme_path)
	if theme_load_err then
		print(theme_load_err)
	elseif theme_file then
		theme_file()
		return THEME
	else
		print("No theme file found")
	end
end

return M
