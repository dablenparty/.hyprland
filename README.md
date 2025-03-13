# .hyprland

My Hyprland dotfiles.

# Installation

Clone Hyprland:

```bash
git clone --recursive https://github.com/hyprwm/Hyprland ~/Hyprland
```

Then, use the [update script](scripts/update_hyprland.sh). It will install all dependencies, programs, and Hyprland itself.

You'll also need to enable the experimental `bluez` features for bluetooth battery access:

```sh
# /etc/bluetooth/main.conf
# Add/edit this line
Experimental = true
```

> [!IMPORTANT]
> Be careful with `bluetoothctl`. Some of its subcommands can cause Hyprland to just... logout or crash. It's tracked by [this GitHub issue](https://github.com/bluez/bluez/issues/996).
