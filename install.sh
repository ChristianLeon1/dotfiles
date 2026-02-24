#!/bin/bash

set -e

smart_clone() {
    local REPO_URL=$1
    # Si no das un nombre de carpeta, extrae el nombre del repo de la URL
    local REPO_DIR=${2:-$(basename "$REPO_URL" .git)}

    if [ -d "$REPO_DIR" ]; then
        echo "--> [Aviso]: La carpeta '$REPO_DIR' ya existe. Saltando clonado."
    else
        echo "--> [Info]: Clonando en '$REPO_DIR' con --depth=1..."
        git clone --depth=1 "$REPO_URL" "$REPO_DIR"
    fi
}

echo "░█▀▄░▀█▀░█▀▀░█▀█░█░█░█▀▀░█▀█░▀█▀░█▀▄░█▀█░░░█▀▀░█▀█░▀█▀░█▀▀░█▄█░█▀█"
echo "░█▀▄░░█░░█▀▀░█░█░▀▄▀░█▀▀░█░█░░█░░█░█░█░█░░░█▀▀░█░█░░█░░█░█░█░█░█▀█"
echo "░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀░░▀▀▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀░▀"

echo "Iniciando la instalación de Hyprland y herramientas relacionadas en Fedora"
sleep 2 

# --------------------------- Instalación de paquetes y dependencias -------------------------
#
echo "Actualizando el sistema..."
sudo dnf update -y

echo "Habilitando repositorios RPM Fusion para drivers y multimedia..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Para Hyprland y herramientas relacionadas
sudo dnf copr enable -y < /dev/null solopasha/hyprland 

# Para Yazi (terminal file manager)
sudo dnf copr enable -y < /dev/null varlad/yazi 


echo "Instalando dependencias..."

PAQUETES=(
    # Herramientas Base y Compilación
    git stow wget curl gcc gcc-c++ make cmake cargo rust 
    nodejs npm ripgrep fd-find unzip wl-clipboard
    
    # Python y Qt (Desarrollo)
    python3 python3-pip python3-devel python3-gobject python3-neovim
    qt6-qtbase-devel qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia
    
    # Desarrollo GTK/Wayland
    gtk3-devel gtk-layer-shell-devel pango-devel gdk-pixbuf2-devel cairo-devel glib2-devel libdbusmenu-glib-devel libdbusmenu-gtk3-devel 
    
    # Entorno Hyprland
    hyprland hypridle hyprlock dunst fastfetch kitty yazi rofi-wayland eww-git
    grim slurp light pamixer ydotool sddm luarocks ImageMagick ImageMagick-devel
    # Terminal y Extras
    zsh neovim flatpak bluez tuned-ppd
    
    # Documentación (LaTeX) - TEN CUIDADO CON EL ESPACIO EN DISCO
    texlive-scheme-full latexmk zathura zathura-pdf-mupdf readline-devel
)

sudo dnf install -y --allowerasing --skip-broken --skip-unavailable "${PAQUETES[@]}" 

sudo systemctl daemon-reload
sudo systemctl disable power-profiles-daemon.service 2>/dev/null || true
sudo systemctl enable --now tuned.service

sudo systemctl enable --now bluetooth.service

echo "Configurando SDDM como gestor de inicio de sesión principal..."
sudo systemctl disable gdm.service 2>/dev/null || true
sudo systemctl enable --force sddm.service
sudo pip3 install pywal

# ---------------------------- Configuración de eww ---------------------------------------

# ---------------------------- Configuración de Oh My Zsh --------------------------------------- 
echo "Configurando Oh My Zsh..." 

ZSH_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sudo chsh -s $(which zsh) $(whoami)  

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
fi


# --------------------------- Configuración de dotfiles con Stow -------------------------

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/ChristianLeon1/dotfiles.git"

echo "Descargando dotfiles..."

if [ -d "$DOTFILES_DIR" ]; then
    echo "--> [Aviso]: La carpeta '$DOTFILES_DIR' ya existe. Eliminando." 
    rm -rf "$DOTFILES_DIR"
fi
git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR" 

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

cp -r "$DOTFILES_DIR/WallPapers" "$HOME/Documentos/"

# -------------- Configuración de networkmanager-dmenu y rofi-bluetooth ------------------

sudo mv "$DOTFILES_DIR/network_bt/networkmanager-dmenu" /usr/bin/
sudo mv "$DOTFILES_DIR/network_bt/rofi-bluetooth" /usr/bin/

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
