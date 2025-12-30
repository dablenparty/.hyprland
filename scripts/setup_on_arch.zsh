#!/usr/bin/env zsh

set -e

echo "Before continuing, please make sure your system is up-to-date and you've run the previous setup_on_arch.sh script."
echo "    sudo pacman -Syu"
echo "I also highly recommend running this script with an inhibitor, i.e. 'systemd-inhibit $0'"
read -r -k 1 "Continue? [Y\n]"$'\n' key

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
if ! command -v paru >/dev/null 2>&1; then
  echo "installing AUR helper: paru"
  if ! sudo pacman --noconfirm -S paru; then
    echo "failed to install paru from repos, installing manually..."
    paru_path="$HOME/aur/paru"
    mkdir -vp "$paru_path"
    git clone https://aur.archlinux.org/paru.git "$paru_path"
    cd "$paru_path" || exit
    # paru is a Rust project and I don't use any crazy custom RUSTFLAGS,
    # so it's OK to do this before unboxing the makepkg config in my dotfiles.
    makepkg -si
    cd "$ORIG_DIR" || exit
  fi
  paru --gendb || exit
fi

echo "cloning dotfiles"
paru --needed --noconfirm -S \
  7zip \
  base-devel \
  boxunbox \
  cmake \
  curl \
  devtools \
  fzf \
  gcc \
  git \
  make \
  pacman-contrib \
  ripgrep \
  rust \
  unzip \
  yazi
dotfiles_path="$HOME/dotfiles"
if ! [[ -d "$dotfiles_path" ]]; then
  echo "$dotfiles_path is not a directory!"
  exit 1
fi
# save the original dir for undoing cd commands
ORIG_DIR="$PWD"
cd "$dotfiles_path" || exit
git submodule update --init --remote hyprland
cd "$dotfiles_path/hyprland" || exit
# checkout might fail, ignore that
git checkout main || :
# generate udev gpu rules (PWD is important hence cd)
cd "$dotfiles_path"/hyprland/udev && ./generate_rules.zsh && cd .. || exit
setopt EXTENDED_GLOB
root_required=(
  keyd
  scripts
  udev
)
sudo unbox --if-exists move $(print "$dotfiles_path"/hyprland/${^root_required})
# get the rest (now includes PKGBUILDs)
hypr_boxes=( *~${~${(j.~.)root_required}}(DNF) )
unbox --if-exists overwrite $(print "$dotfiles_path"/hyprland/${^hypr_boxes})
cd "$ORIG_DIR" || exit
# new paru conf; refresh
paru -Syy
paru -Ly

echo "installing Hyprland"
paru --needed --sudoloop --noconfirm -S \
  avahi \
  awww-git \
  bat \
  blueman \
  brightnessctl \
  btop \
  dot-hyprland/hypridle-git \
  dot-hyprland/hyprland-git \
  dot-hyprland/hyprutils-git \
  dust \
  dysk \
  eza \
  fd \
  firefox \
  fnm \
  foot \
  fuzzel \
  fzf \
  hyprlock-git \
  hyprpicker-git \
  hyprpolkitagent-git \
  hyprshot-git \
  jenv \
  jq \
  lib32-nvidia-utils \
  libheif \
  librsvg \
  libspng \
  libwebp \
  mako \
  mpd \
  mpd-mpris \
  mpvpaper \
  neovim \
  network-manager-applet \
  nvidia-settings \
  nvidia-utils \
  nvtop \
  nwg-look \
  obsidian \
  oh-my-posh-bin \
  perl-image-exiftool \
  playerctl \
  python-pywal16 \
  ripgrep \
  seatd \
  socat \
  speech-dispatcher \
  systemd \
  tesseract \
  tesseract-data-eng \
  ttf-jetbrains-mono-nerd \
  udiskie \
  unzip \
  upscayl-ncnn \
  vk-hdr-layer-kwin6-git \
  waybar-git \
  waypaper-git \
  xdg-desktop-portal-kde \
  xdg-terminal-exec \
  xdg-user-dirs \
  zoxide

# no chroot for this
paru --needed --sudoloop --nochroot --noconfirm --useask -S dot-hyprland/glfw-wayland-minecraft-git

# allow service startups to fail
set +e

echo 'enabling system services'
sudo systemctl enable avahi-daemon.service

echo 'enabling user services'
systemctl enable --user \
  awww.service \
  hypridle.service \
  mako.service \
  mpd-mpris.service \
  playerctld.service \
  waybar.service
set -e

echo 'beginning post-install setup'
monitor_conf_path="$dotfiles_path/hyprland/hypr/monitors"
declare -a selected_confs fzf_args
fzf_args=(--delimiter '/' --with-nth -1 --accept-nth -1)
monitor_confs=( $monitor_conf_path/^base-*(.) )
selected_confs+=( $(print ${(j.\n.)monitor_confs} | fzf --multi "${fzf_args[@]}" --prompt 'Activate monitors > ') )
primary_conf="$(print ${(j.\n.)selected_confs} | fzf --prompt 'Primary monitor > ')"
base_monitor_confs=( $monitor_conf_path/base*.conf )
selected_confs+=( $(print ${(j.\n.)base_monitor_confs} | fzf "${fzf_args[@]}" --prompt 'Select your base config > ') )
mon_path="$dotfiles_path/hyprland/scripts/mon.zsh"
for conf_name in ${selected_confs[@]}; do
  $mon_path enable "$conf_name"
done
$mon_path primary "$primary_conf"

uwsm_extras_path="$dotfiles_path/hyprland/uwsm/extras"
declare -a selected_extras
uwsm_extra_confs=( $uwsm_extras_path/*~.gitignore(.) )
selected_extras=(  $(print ${(j.\n.)uwsm_extra_confs} | fzf --multi "${fzf_args[@]}" --prompt 'Enable UWSM extras? > ')  )
echo $selected_extras
for conf_name in "${selected_extras[@]}"; do
  ln -s ../$conf_name "$uwsm_extras_path/active/$conf_name"
done

echo "Installation complete! Make sure you double-check pacman and reboot when you're done!"
