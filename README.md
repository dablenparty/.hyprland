# .hyprland

My Hyprland dotfiles.

## Installation

First, you need [boxunbox](https://github.com/dablenparty/boxunbox). This config depends on it.

Installation can be achieved with my custom [PKGBUILD](pkgbuild/hyprland-git/PKGBUILD). **I highly recommend the [setup script](scripts/setup_on_arch.zsh)**.

You'll need `paru` so that the PKGBUILD can be updated with your system. Add the following to your `paru.conf` or use [the conf in this repo](paru/paru.conf):

```confini
[dot-hyprland]
Url = https://github.com/dablenparty/.hyprland
Depth = 3
SkipReview
GenerateSrcinfo
```

Next time you run `paru -Sy`, it should download the [PKGBUILD](pkgbuild/PKGBUILD) so that it can be updated with the rest of the system.

### Post-Installation

You'll need to enable the experimental `bluez` features for Bluetooth battery access:

```sh
# /etc/bluetooth/main.conf
# Add/edit this line
Experimental = true
```

> [!IMPORTANT]
> This doesn't appear to be necessary anymore, but I haven't been able to confirm that reliably. For now, enable them.

Once you've installed Hyprland, you'll need to enable a few `systemd` services:

```bash
systemctl enable sddm.service
systemctl enable --user hypridle.service
systemctl enable --user hyprpolkitagent.service
systemctl enable --user mako.service
systemctl enable --user speech-dispatcher.socket
systemctl enable --user waybar.service
```

Don't forget to activate your base and monitor configs by symlinking the proper configs into the [`hypr/monitors/active` directory](hypr/monitors)!

#### GPU `udev` rule setup

Since this config is used for both laptops and desktops, you have to tell `aquamarine` what GPU to use. You can generate the `udev` rule with [this script](udev/generate_rules.zsh), then reload the rules like so:

```bash
sudo udevadm control --reload
sudo udevadm trigger
```

You may have to reload Hyprland afterward.
