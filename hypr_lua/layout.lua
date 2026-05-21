local utils = require("utils")
local theme = utils.load_pywal_theme()

hl.config({
	-- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
	dwindle = {
		-- pseudotile = true
		-- hard to explain; you want this
		preserve_split = true,
	},

	-- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
	master = {
		new_status = "master",
	},

	-- https://wiki.hyprland.org/Configuring/Variables/#misc
	misc = {
		-- Set to 0 or 1 to disable the anime mascot wallpapers
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
		col = { splash = theme.foreground },
		background_color = theme.background,

		enable_swallow = true,
		swallow_regex = "^(foot|kitty)$",
		-- exempt yazi, terminal file manager, from being swallowed
		swallow_exception_regex = "^([yY]azi(:.*?))$",
	},
})
