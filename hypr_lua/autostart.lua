hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- blueman-applet --syslog")
	hl.exec_cmd("uwsm app -- nm-applet")
	hl.exec_cmd("uwsm app -- udiskie --tray")
end)

hl.on("monitor.added", function(mon)
	local mon_to_ws = {
		["desc:ASUSTek COMPUTER INC ROG PG278QR #ASORhydAMyjd"] = 1,
		["desc:Samsung Electric Company LC27G7xT H4ZTB01524"] = 2,
		["desc:Samsung Electric Company SAMSUNG 0x01000E00"] = 3
	}
	local workspace = mon_to_ws[mon.output]
	if workspace then
		hl.dsp.workspace.move({ workspace = workspace, monitor = mon.output })
		hl.notification.create({
			text = "Detected monitor '" .. mon.output .. "', assigned workspace " .. workspace,
			timeout = 5000,
			icon = "info",
		})
	end
end)
