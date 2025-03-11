# .hyprland

My Hyprland dotfiles.

# Installation

## Programs

- `hypridle`
- `hyprlock`
- `mako`
- `pywal`
- `rofi`
- `uwsm`
- `waybar`
- `waypaper`
  - I might replace this with gBar

Install them all:

```bash
paru -S hypridle-git hyprlock-git mako python-pywal16 rofi-wayland uwsm waybar ttf-font-awesome waypaper
```

See the [Hyprland Wiki](https://wiki.hyprland.org/Nvidia/#installation) and follow the instructions for cloning Hyprland. Then, use the [update script](scripts/update_hyprland.sh). It will install all dependencies and compile Hyprland.

You'll also need to enable the experimental `bluez` features for bluetooth battery access:

```sh
# /etc/bluetooth/main.conf
# Add this line
Experimental = true
```

> [!IMPORTANT]
> Be careful with `bluetoothctl`. Some of its subcommands can cause Hyprland to just... logout or crash. It's tracked by [this GitHub issue](https://github.com/bluez/bluez/issues/996).
