# .hyprland

My Hyprland dotfiles.

## Installation

Hyprland has become stable enough that you can stick to tagged releases:

```bash
sudo pacman -S hyprland
```

Or, you can continue with the custom PKGBUILD.

### Custom PKGBUILD

Installation can be achieved with my custom [PKGBUILD](pkgbuild/PKGBUILD).

You'll need `paru` so that the PKGBUILD can be updated with your system. Add the following to your `paru.conf` or use [the conf in this repo](paru/paru.conf):

```confini
[dot-hyprland]
Url = https://github.com/dablenparty/.hyprland
Depth = 3
SkipReview
GenerateSrcinfo
```

Next time you run `paru`, it should download the [PKGBUILD](pkgbuild/PKGBUILD) and update it with the rest of the system.

> [!NOTE]
> After installation, `paru` might throw the following error: `error: git  reset --hard HEAD: No such file or directory (os error 2)`. It doesn't appear to affect the installation, so ignore it. It's tracked by this [GitHub issue](https://github.com/Morganamilo/paru/issues/1234).

You'll need to enable the experimental `bluez` features for Bluetooth battery access:

```sh
# /etc/bluetooth/main.conf
# Add/edit this line
Experimental = true
```

> [!IMPORTANT]
> This doesn't appear to be necessary anymore, but I haven't been able to confirm that reliably. For now, enable them.

### Post-Installation

Once you've installed Hyprland, you'll need to enable a few `systemd` services:

```bash
systemctl enable sddm.service
systemctl enable --user hypridle.service
systemctl enable --user hyprpolkitagent.service
systemctl enable --user mako.service
systemctl enable --user speech-dispatcher.socket
systemctl enable --user waybar.service
```
