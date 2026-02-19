# The ultimate Wayland/Niri setup
AUR_HELPER = yay
PKGS = niri waybar swaync kanshi swayosd hypridle hyprlock \
       polkit-gnome vicinae-bin awww-bin stow greetd ttf-jetbrains-mono-nerd alacritty dolphin

# Check if yay is installed
YAY_CHECK := $(shell command -v $(AUR_HELPER) 2> /dev/null)

all: bootstrap install-deps link-dots enable-services

# 1. The Bootstrap: Install yay if it's missing
bootstrap:
ifndef YAY_CHECK
	@echo "🚀 Yay missing. Bootstrapping AUR helper..."
	sudo pacman -S --needed --noconfirm base-devel git
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay && makepkg -si --noconfirm
	rm -rf /tmp/yay
else
	@echo "✅ Yay is already installed."
endif

# 2. Install everything
install-deps:
	@echo "🔥 Fetching the goods..."
	$(AUR_HELPER) -S --needed --noconfirm $(PKGS)

# 3. Use Stow to link the configs
link-dots:
	@echo "🔗 Linking configs with Stow..."
	stow -t ../ stow_wrapper/
	@echo "Linked"

	sudo mkdir -p /etc/greetd
	@sed "s@user = \"N/A\"@user = \"$(shell whoami)\"@" ./greetd/config.toml | sudo tee /etc/greetd/config.toml > /dev/null

enable-services:
	sudo systemctl enable --now greetd

# 4. Quick cleanup
clean:
	@echo "🧹 Cleaning up pacman cache..."
	sudo pacman -Sc --noconfirm

.PHONY: all bootstrap install-deps link-dots enable-services clean
