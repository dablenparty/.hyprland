local utils = require("utils")
local browser_class = "^([Ff]irefox)$"
local gaming_workspace = 10
local steam_app_class = "^steam_app(_\\d+|default)?$"
local minecraft_initial_title = "^(Minecraft|Tekxit|Craftoria).*$"

--#region Workspaces
hl.workspace_rule({
	workspace = tostring(gaming_workspace),
	default_name = "Gaming",
	no_border = true,
	no_shadow = true,
	no_rounding = true,
	decorate = false,
})

-- smart gaps (https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/#smart-gaps)
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })
--#endregion

--#region Windows
-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "xwayland-dragging-fix",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	match = { class = "^([Ss]team(webhelper)?)$" },
	opacity = "0.90 override 0.81 override",
})

hl.window_rule({
	match = { class = "^(net\\.)?([Ll]utris\\.?)+$" },
	opacity = "0.90 override 0.81 override",
})

hl.window_rule({
	match = { class = browser_class },
	opacity = "0.90 override 0.81 override",
})
--#endregion

--#region Content types
hl.window_rule({
	match = { initial_class = "(vlc|mpv|.*jellyfin-media-player$)" },
	content = "video",
})
hl.window_rule({
	match = { title = "^(Picture-In-Picture)$" },
	content = "video",
})
hl.window_rule({
	match = {
		title = "^.*(- YouTube).*$",
		class = browser_class,
	},
	content = "video",
})
--#endregion

--#region Gaming rules
-- Fix Steam launching floating
hl.window_rule({ match = { initial_class = "^steam$" }, tile = true })

hl.window_rule({
	match = { xdg_tag = "^(proton-game)$" },
	tag = "+video-game",
})

hl.window_rule({
	match = { content = "game" },
	tag = "+video-game",
})

hl.window_rule({
	match = { initial_class = steam_app_class },
	tag = "+video-game",
})

hl.window_rule({
	match = { initial_class = "^(artofrally|.*\\.exe)$" },
	tag = "+video-game",
})

hl.window_rule({
	match = { initial_title = minecraft_initial_title },
	tag = "+video-game",
})

hl.window_rule({
	match = {
		class = steam_app_class,
		title = "SplashScreen",
	},
	tag = "-video-game",
})

hl.window_rule({
	match = {
		tag = "video-game",
		title = "([Cc]rash.?[Rr]eport)",
	},
	tag = "-video-game",
})

-- TODO: test this
-- hl.window_rule({
-- 	match = {
-- 		tag = "video-game",
-- 		modal = true
-- 	},
-- 	tag = "-video-game"
-- })

hl.window_rule({
	name = "video-games",
	match = { tag = "video-game" },
	workspace = tostring(gaming_workspace),

	border_size = 0,
	-- even if they're tagged, they STILL might not have the right content type
	content = "game",
	-- do not let the pointer leave the window
	confine_pointer = true,
	decorate = false,
	float = true,
	-- truly opaque; ignores window alpha channel
	force_rgbx = true,
	fullscreen = true,
	fullscreen_state = "3 3",
	idle_inhibit = "always",
	no_anim = true,
	no_blur = true,
	no_dim = true,
	no_max_size = true,
	no_shadow = true,
	persistent_size = true,
	render_unfocused = true,
	rounding = 0,
	-- fixes games that fail to maximize *cough* ELDEN RING
	sync_fullscreen = true,
})

hl.window_rule({
	match = { initial_title = minecraft_initial_title },
	immediate = true,
	tag = "+tearing"
})

hl.window_rule({
	match = { class = "cs2" },
	immediate = true,
	tag = "+tearing"
})

-- NOTE: this is necessary because of a kernel limitation: https://github.com/hyprwm/Hyprland/pull/10020#issuecomment-3094396984
hl.on("window.open", function(win)
	-- enable tearing if there's a tearable window
	if utils.lcontains(win.tags, "tearing*") then
		hl.notification.create({ text = win.title .. " asks for tearing!", timeout = 4000 })
		hl.config({
			general = {
				allow_tearing = true
			},
			render = {
				async_commit = false,
				direct_scanout = 0
			},
			cursor = { no_hardware_cursors = 1 }
		})
	end
end)

hl.on("window.close", function(win)
	-- disable tearing when all tearable windows close
	if utils.lcontains(win.tags, "tearing*") then
		local windows = hl.get_windows({ tag = "tearing*" })
		-- the window has not been destroyed yet
		if #windows == 1 then
			hl.notification.create({ text = "No more windows ask for tearing!", timeout = 4000 })
			hl.config({
				general = {
					allow_tearing = false
				},
				render = {
					async_commit = true,
					direct_scanout = 2
				},
				cursor = { no_hardware_cursors = 0 }
			})
		end
	end
end)
--#endregion

--#region Music/Video players
hl.window_rule({
	match = { initial_class = "[sS]potify" },
	tag = "+music-player",
})

hl.window_rule({
	name = "music-players",
	match = { tag = "music-player" },

	workspace = "special:music",
	-- disallow focus stealing
	suppress_event = "activate,activatefocus",
})

hl.window_rule({
	name = "discord",
	match = { class = "discord", initial_title = "Discord" },

	-- TODO: multiple special workspaces
	workspace = "special:music",
	-- disallow focus stealing
	suppress_event = "activate,activatefocus",
})

hl.window_rule({
	match = { initial_class = "makemkv" },
	idle_inhibit = "always",
})

hl.window_rule({
	name = "makemkv-popup",
	match = {
		class = "makemkv",
		title = ".*popup$",
	},

	no_initial_focus = true,
	focus_on_activate = false,
	suppress_event = "activate,activatefocus",
})

-- WARN: These MUST be at the bottom
hl.window_rule({
	name = "opaque-video",
	match = { content = "video" },

	opacity = "1.00 override 1.00 override",
	idle_inhibit = "fullscreen",
})
--#endregion

--#region Layers
hl.layer_rule({
	name = "app-launcher-blur",
	match = { namespace = "launcher" },

	blur = true,
	ignore_alpha = 0,
	dim_around = true,
})

hl.layer_rule({
	name = "notifications-blur",
	match = { namespace = "notifications" },

	blur = true,
	ignore_alpha = 0,
	-- block from screen share
	no_screen_share = true,
})
--#endregion
