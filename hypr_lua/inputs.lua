-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
	input = {
		kb_layout = "us",

		follow_mouse = 1,
		-- force_no_accel = 1,

		-- -1.0 - 1.0, 0 means no modification.
		sensitivity = -0.84,

		touchpad = {
			natural_scroll = false,
			-- Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB respectively.
			clickfinger_behavior = true,
		},
	},
})

-- Example per-device config
-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
hl.device({
	-- MX Master 3S
	name = "logitech-usb-receiver-mouse",
	sensitivity = -0.8,
})

hl.device({
	name = "pulsar-x2-v2-1",
	sensitivity = -0.8,
})

hl.device({
	-- white zephyrus trackpad
	name = "elan1201:00-04f3:3098-touchpad",
	sensitivity = 0.05,
	natural_scroll = true,
})
