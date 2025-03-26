# .hyprland

My Hyprland dotfiles.

# Installation

You can either install it manually or with my custom [PKGBUILD](pkgbuild/PKGBUILD).

## PKGBUILD

You'll need `paru`. Add the following to `paru.conf`:

```ini
[dot-hyprland]
Url = https://github.com/dablenparty/.hyprland
Depth = 3
SkipReview
GenerateSrcinfo
```

Next time you run `paru`, it should download the [PKGBUILD](pkgbuild/PKGBUILD) and update it with the rest of the system.

> [!NOTE]
> After installation, `paru` might throw the following error: `error: git  reset --hard HEAD: No such file or directory (os error 2)`. It doesn't appear to affect the installation, so ignore it. It's tracked by this [GitHub issue](https://github.com/Morganamilo/paru/issues/1234).

## Manually

Clone Hyprland:

```bash
git clone --recursive https://github.com/hyprwm/Hyprland ~/Hyprland
```

Then, use the [update script](scripts/update_hyprland.sh). It will install all dependencies, programs, and Hyprland itself.

No matter which method, you'll need to enable the experimental `bluez` features for bluetooth battery access:

```sh
# /etc/bluetooth/main.conf
# Add/edit this line
Experimental = true
```

> [!IMPORTANT]
> Be careful with `bluetoothctl`. Some of its subcommands can cause Hyprland to just... logout or crash. It's tracked by [this GitHub issue](https://github.com/bluez/bluez/issues/996).
