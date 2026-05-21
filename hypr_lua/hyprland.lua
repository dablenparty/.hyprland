local utils = require("utils")
local theme = utils.load_pywal_theme()

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 2,

		-- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
		col = {
			active_border = { colors = { theme.color14, theme.color10 }, angle = 45 },
			inactive_border = theme.color8,
		},

		-- sometimes, smaller dialogs need resizing
		resize_on_border = true,

		layout = "dwindle",
	},

	debug = {
		-- if something goes wrong, enable this and run the below command to watch the logs
		-- tail -f $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log
		-- OR
		-- journalctl --user -u wayland-wm@hyprland.desktop.service
		disable_logs = false,
	},

	misc = {
		enable_anr_dialog = false,
	},
})

require("decoration")
require("animations")
require("layout")
require("monitors")
require("rules")
require("autostart")
require("inputs")
require("binds")
