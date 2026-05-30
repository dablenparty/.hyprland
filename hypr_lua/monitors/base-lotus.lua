hl.config({
	cursor = {
		default_monitor = "desc:Samsung Electric Company LC27G7xT H4ZTB01524",
		no_hardware_cursors = 0,
	},

	misc = {
		-- only enable in fullscreen games/videos
		vrr = 3,
	},

	general = {
		-- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
		-- BUG: currently has some big issues: https://github.com/hyprwm/Hyprland/pull/10020#issuecomment-3094396984
		allow_tearing = false,
	},

	render = {
		direct_scanout = 2,
		-- auto-set to 1 (hdr) or 2 (hdredid)
		cm_auto_hdr = 2,
	},

	quirks = {
		-- needed for Jedi Survivor
		prefer_hdr = 1,
	},
})

hl.workspace_rule({
	workspace = "1",

	monitor = "desc:ASUSTek COMPUTER INC ROG PG278QR #ASORhydAMyjd",
	default = true,
})

hl.workspace_rule({
	workspace = "2",

	monitor = "desc:Samsung Electric Company LC27G7xT H4ZTB01524",
	default = true,
})

hl.workspace_rule({
	workspace = "3",

	monitor = "desc:Samsung Electric Company SAMSUNG 0x01000E00",
	default = true,
})
