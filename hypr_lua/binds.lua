-- See https://wiki.hyprland.org/Configuring/Keywords/
local main_mod = "SUPER"
local terminal = "foot"
local file_manager = terminal .. "-e yazi"
local music_player = terminal .. "-e rmpc"
local browser = "firefox"

local reset = "hyprctl dispatch submap reset"
local timeout = 3.0
local submap_timeout_cmd = string.format("uwsm app -- sleep %.2f && %s", timeout, reset)
-- 1-sec timeout for submap
hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(submap_timeout_cmd))
hl.bind(main_mod .. " + Return", hl.dsp.submap("menus"))
hl.define_submap("menus", "reset", function()
	hl.bind("W", hl.dsp.exec_cmd(string.format("uwsm app -- %s && waypaper", reset)))
	hl.bind("S", hl.dsp.exec_cmd(string.format("uwsm app -- %s && steam", reset)))
	hl.bind(
		"A",
		hl.dsp.exec_cmd(string.format("uwsm app -- %s && pkill -x rofi || ~/.local/share/rofi/audio-select.sh", reset))
	)
	hl.bind("M", hl.dsp.exec_cmd(string.format("uwsm app -- %s && %s", reset, music_player)))
	-- Exit submap on any other key
	hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- screenshot submap
hl.bind(main_mod .. " + Z", hl.dsp.exec_cmd(submap_timeout_cmd))
hl.bind(main_mod .. " + Z", hl.dsp.submap("screenshots"))
hl.define_submap("screenshots", "reset", function()
	-- Window
	hl.bind("W", hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -m window", reset)))
	hl.bind(
		main_mod .. " + W",
		hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -s -o /tmp/ocr -m window -- ocr_image.sh", reset))
	)
	-- Region
	hl.bind("R", hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -m region", reset)))
	hl.bind(
		main_mod .. " + R",
		hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -s -o /tmp/ocr -m region -- ocr_image.sh", reset))
	)
	-- Monitor
	hl.bind(" + O", hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -m output", reset)))
	hl.bind(
		main_mod .. " + O",
		hl.dsp.exec_cmd(string.format("uwsm app -- %s && hyprshot -z -s -o /tmp/ocr -m output -- ocr_image.sh", reset))
	)
	hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- rotation submap
hl.bind(main_mod .. " + ALT + R", hl.dsp.exec_cmd(submap_timeout_cmd))
hl.bind(main_mod .. " + ALT + R", hl.dsp.submap("rotation"))
hl.define_submap("rotation", "reset", function()
	-- there are only 8 transforms, although you probably don't want to use anything higher
	-- than 3
	hl.bind("R", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh", reset)))
	hl.bind("0", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 0", reset)))
	hl.bind("1", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 1", reset)))
	hl.bind("2", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 2", reset)))
	hl.bind("3", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 3", reset)))
	hl.bind("4", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 4", reset)))
	hl.bind("5", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 5", reset)))
	hl.bind("6", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 6", reset)))
	hl.bind("7", hl.dsp.exec_cmd(string.format("uwsm app -- %s && rotate_monitor.zsh 7", reset)))
	hl.bind("catchall", hl.dsp.submap("reset"))
end)

hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(string.format("uwsm app -- %s", browser)))
-- NOTE: Firefox specific
hl.bind(main_mod .. " + SHIFT + B", hl.dsp.exec_cmd(string.format("uwsm app -- %s --private-window", browser)))
hl.bind(main_mod .. " + Y", hl.dsp.exec_cmd(string.format("uwsm app -- %s", file_manager)))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen())
-- don't use "exit" dispatcher with uwsm
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(
	main_mod .. " + O",
	hl.dsp.exec_cmd(
		"uwsm app -- obsidian --no-sandbox --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations"
	)
)
-- dwindle
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
-- closes (not kills) the active window
-- TODO: maybe use kill()?
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(string.format("uwsm app -- %s", terminal)))
hl.bind(main_mod .. " + V", hl.dsp.window.float())
hl.bind(main_mod .. " + W", hl.dsp.exec_raw("waypaper --random || update_wallpaper.sh"))
hl.bind(main_mod .. " + Space", hl.dsp.exec_cmd("pkill -x fuzzel || fuzzel --launch-prefix='uwsm app --' --counter"))

-- Move focus with mainMod + Vim keys
hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "r" }))

-- Move windows around with mainMod + Shift + Vim keys
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

hl.bind(main_mod .. " + ALT + L", hl.dsp.exec_cmd("lock_screen.sh"))

-- Switch workspaces with mainMod + [0-9]
hl.bind(main_mod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(main_mod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(main_mod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(main_mod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(main_mod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(main_mod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(main_mod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(main_mod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(main_mod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(main_mod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(main_mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind(main_mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind(main_mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind(main_mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind(main_mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind(main_mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind(main_mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind(main_mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind(main_mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind(main_mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))
hl.bind(main_mod .. " + SHIFT + C", hl.dsp.exec_cmd("uwsm app -- hyprpicker -a -f hex"))

-- Example special workspace (scratchpad)
hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("music"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:music" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(main_mod .. " + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

-- Mimics the Task Manager bind from Windows
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(string.format("uwsm app -- %s -e btop", terminal)))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness (requires brightnessctl)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))
