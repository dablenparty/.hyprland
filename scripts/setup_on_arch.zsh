#!/usr/bin/env zsh

set -e

echo "Before continuing, please make sure your system is up-to-date and you've run the previous setup_on_arch.sh script."
echo "    sudo pacman -Syu"
read -rp "Continue? [Y\n]"$'\n' -n 1 key

case $key in
y | Y | "")
  echo "Beginning installation..."
  ;;
*)
  echo "aborting..."
  exit 0
  ;;
esac

echo "installing base dependencies"
sudo pacman --overwrite "*" --needed --noconfirm -S \
  base-devel \
  cmake \
  curl \
  devtools \
  fzf \
  gcc \
  git \
  make \
  man-db \
  ntfs-3g \
  openssh \
  pacman-contrib \
  ripgrep \
  rust \
  unzip \
  yazi

if ! command -v paru >/dev/null 2>&1; then
  echo "installing AUR helper: paru"
  if ! sudo pacman --noconfirm -S paru; then
    echo "failed to install paru from repos, installing manually..."
    paru_path="$HOME/aur/paru"
    mkdir -vp "$paru_path"
    git clone https://aur.archlinux.org/paru.git "$paru_path"
    cd "$paru_path" || exit 1
    # paru is a Rust project and I don't use any crazy custom RUSTFLAGS,
    # so it's OK to do this before unboxing the makepkg config in my dotfiles.
    makepkg -si
    cd "$ORIG_DIR" || exit 1
  fi
  paru --gendb
fi

echo "installing Hyprland"
paru --needed --rebuild=all --sudoloop --noconfirm -S \
  avahi \
  awww-git \
  bat \
  blueman \
  blueman-applet \
  dot-hyprland/hypridle-git \
  dot-hyprland/hyprutils-git \
  dysk \
  dust \
  eza \
  fd \
  firefox \
  fnm \
  foot \
  fuzzel \
  fzf \
  hyprland \
  hyprlock-git \
  hyprpolkitagent \
  hyprshot-git \
  jenv \
  jq \
  lib32-nvidia-utils \
  mako \
  mpd \
  mpd-mpris \
  mpvpaper \
  neovim \
  nm-applet \
  nvidia-settings \
  nvidia-utils \
  nvtop \
  obsidian \
  oh-my-posh-bin \
  perl-image-exiftool \
  playerctl \
  python-pywal16 \
  ripgrep \
  sddm \
  seatd \
  socat \
  speech-dispatcher \
  tesseract \
  tesseract-data-eng \
  ttf-jetbrains-mono-nerd \
  udiskie \
  unzip \
  upscayl-ncnn \
  waybar-git \
  waypaper-git \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-kde \
  xdg-terminal-exec \
  xdg-user-dirs \
  zoxide

# no chroot for this
paru --needed --rebuild=all --sudoloop --nochroot --noconfirm -S dot-hyprland/glfw-wayland-minecraft-git

paru --rebuild=all --sudoloop --noconfirm -S dot-hyprland/Hyprland-git

echo "cloning dotfiles"
dotfiles_path="$HOME/dotfiles"
if ! [[ -d "$dotfiles_path" ]]; then
  echo "$dotfiles_path is not a directory!"
  exit 1
fi
# save the original dir for undoing cd commands
ORIG_DIR="$PWD"
cd "$dotfiles_path" || exit 1
git submodule update --init --remote hyprland
cd "$dotfiles_path/hyprland" || exit 1
# checkout might fail
git checkout main || :
"$dotfiles_path"/hyprland/udev/generate_rules.zsh
setopt EXTENDEDGLOB
root_required=(
  keyd
  scripts
  udev
)
sudo unbox --if-exists move "$(print "$dotfiles_path"/hyprland/${^root_required})"
# get the rest
hypr_boxes=( *~${(j.~.)root_required}~pkgbuild(DNF) )
unbox --if-exists overwrite "$(print "$dotfiles_path"/hyprland/${^hypr_boxes})"

cd "$ORIG_DIR" || exit 1

echo 'enabling system services'
sudo systemctl enable \
  avahi.service \
  sddm.service

echo 'enabling user services'
systemctl enable --user \
  awww.service \
  hypridle.service \
  mako.service \
  mpd-mpris.service \
  playerctld.service \
  waybar.service

echo "Installation complete! Make sure you double-check pacman and reboot when you're done! Also, activate the proper monitor/uwsm configs!"
