#!/usr/bin/env zsh

set -e

echo "installing base dependencies"
sudo pacman --overwrite "*" --noconfirm -S \
  base-devel \
  cmake \
  curl \
  devtools \
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

echo "setting git config"
git config --global init.defaultBranch main
read -rep 'git username: ' git_username
git config --global user.name "$git_username"
read -rep 'git email: ' git_email
git config --global user.email "$git_email"

echo "creating ssh keys (you have to install them yourself)"
ssh_home="$HOME/.ssh"
mkdir -vp "$ssh_home"
ssh-keygen -t ed25519 -f "$ssh_home/forgejo" -P "" -C "$git_email"
ssh-keygen -t ed25519 -f "$ssh_home/github" -P "" -C "$git_email"
ssh-keygen -t rsa -f "$ssh_home/aur" -P ""
ssh-keygen -t rsa -f "$ssh_home/couchlab" -P ""
echo > "$ssh_home/config" <<EOF
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User $git_username

Host forgejo-ssh.couchlab.me
	IdentityFile ~/.ssh/forgejo
	ProxyCommand /usr/bin/env cloudflared access ssh --hostname %h

Host github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/github
EOF

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

echo "cloning dotfiles"
paru --noconfirm -S boxunbox
dotfiles_dir="$HOME/dotfiles"
git clone --recurse-submodules=hyprland https://forgejo.couchlab.me/dablenparty/.unix.git "$dotfiles_dir"
unbox --force "$dotfiles_dir/pacman" "$dotfiles_dir/makepkg" "$dotfiles_dir/hyprland/paru"

echo "installing Hyprland"
paru --needed --rebuild=all --sudoloop --noconfirm -S \
  avahi \
  bat \
  blueman \
  dot-hyprland/hypridle-git \
  dot-hyprland/hyprutils-git \
  dysk \
  dust \
  eza \
  fd \
  firefox \
  fnm \
  foot \
  fzf \
  hyprland \
  hyprlock-git \
  hyprshot-git \
  jenv \
  lib32-nvidia-utils \
  mako \
  mpvpaper \
  neovim \
  nvidia-open \
  nvidia-settings \
  nvidia-utils \
  nvtop \
  obsidian \
  oh-my-posh-bin \
  perl-image-exiftool \
  python-pywal16 \
  ripgrep \
  rofi-wayland \
  sddm \
  seatd \
  socat \
  speech-dispatcher \
  swww-git \
  tesseract \
  tesseract-data-eng \
  ttf-jetbrains-mono-nerd \
  udiskie \
  unzip \
  upscayl-ncnn \
  waybar \
  waypaper \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-kde \
  xdg-terminal-exec \
  xdg-user-dirs \
  zoxide

# no chroot for this
paru --needed --rebuild=all --sudoloop --nochroot --noconfirm -S dot-hyprland/glfw-wayland-minecraft-git

setopt EXTENDEDGLOB

hypr_boxes=( "$dotfiles_dir"/hyprland/*~pkgbuild(DNF) )
unbox --force "$hypr_boxes[@]"

echo "installing rustup from rustup.rs"
paru --noconfirm -Rus rust
eval "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
source "$HOME/.cargo/env"

echo "installing Rust toolchains"
rustup toolchain install stable
rustup toolchain install nightly
rustup default stable
rustup component add rust-analyzer

echo 'enabling system services'
sudo systemctl enable \
  avahi.service \
  sddm.service

echo 'enabling user services'
systemctl enable --user \
  bluman-applet.service \
  hypridle.service \
  mako.service \
  waybar.service

echo "Installation complete! Make sure you double-check pacman and reboot when you're done!"
