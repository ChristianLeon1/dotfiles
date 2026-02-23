#!/bin/bash

# Script de instalación para Hyprland y herramientas relacionadas en Fedora

set -e

echo"░█▀▄░▀█▀░█▀▀░█▀█░█░█░█▀▀░█▀█░▀█▀░█▀▄░█▀█░░░█▀▀░█▀█░▀█▀░█▀▀░█▄█░█▀█"
echo"░█▀▄░░█░░█▀▀░█░█░▀▄▀░█▀▀░█░█░░█░░█░█░█░█░░░█▀▀░█░█░░█░░█░█░█░█░█▀█"
echo"░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀░░▀▀▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀░▀"

echo "Iniciando la instalación de Hyprland y herramientas relacionadas en Fedora"
sleep 2 

# --------------------------- Instalación de paquetes y dependencias -------------------------
#
echo "Actualizando el sistema..."
sudo dnf update -y

echo "Habilitando repositorios RPM Fusion para drivers y multimedia..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "Instalando dependencias..."
sudo dnf install -y git stow wget curl gcc gcc-c++ make cmake cargo rust \
                    python3-pip python3-devel qt6-qtbase-devel python3-gobject \
                    nodejs npm ripgrep fd-find wl-clipboard unzip \
                    python3-neovim texlive-scheme-full texlab latexmk zathura zathura-pdf-mupdf \
                    hyprland hypridle hyprlock dunst fastfetch kitty neovim python3-pywal yazi zsh rofi-wayland \
                    gtk3-devel gtk-layer-shell-devel pango-devel gdk-pixbuf2-devel cairo-devel glib2-devel \
                    python3 power-profiles-daemon bluez flatpak \
                    grim slurp light pamixer ydotool \  
                    sddm qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia 

sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable sddm.service

# ---------------------------- Configuración de eww ---------------------------------------

echo "Compilando eww..."
if ! command -v eww &> /dev/null; then
    cargo install --git https://github.com/elkowar/eww --no-default-features --features wayland eww
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "eww ya se encuentra instalado."
fi

echo "Configurando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sudo chsh -s $(which zsh) $(whoami) 

# -------------- Configuración de networkmanager-dmenu y rofi-bluetooth ------------------

wget https://raw.githubusercontent.com/firecat53/networkmanager-dmenu/main/networkmanager_dmenu -O "$HOME/.local/bin/networkmanager_dmenu"
chmod +x "$HOME/.local/bin/networkmanager_dmenu"
wget https://raw.githubusercontent.com/nickclyde/rofi-bluetooth/master/rofi-bluetooth -O "$HOME/.local/bin/rofi-bluetooth"
chmod +x "$HOME/.local/bin/rofi-bluetooth"

# --------------------------- Configuración de dotfiles con Stow -------------------------

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/ChristianLeon1/dotfiles.git"

echo "Descargando dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    cd "$DOTFILES_DIR"
    git pull origin main
fi 


echo "Desplegando configuraciones con Stow..."
DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

rm -f "$HOME/.zshrc"

carpetas=(dunst eww fastfetch hyprland kitty nvim pywal rofi yazi zsh)

for carpeta in "${carpetas[@]}"; do
    if [ -d "$carpeta" ]; then
        stow "$carpeta"
        echo "Directorio enlazado: $carpeta"
    else
        echo "Aviso: No existe el directorio $carpeta"
    fi
done 

cp -r "$DOTFILES_DIR/Wallpapers" "$Home/Documentos/Wallpapers"

# --------------------------- Configuración de Flathub y Spotify -------------------------
echo "Configurando Flathub e instalando Spotify..."
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client

# --------------------------- Instalando NerdFonts -------------------------------- 

bash "$HOME/dotfiles/Fonts/install_nerdfonts.sh" 
curl -fsS https://dl.brave.com/install.sh | sh 

# --------------------------- Configuración de SDDM ---------------------------------------  
bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"

echo "Proceso finalizado."
