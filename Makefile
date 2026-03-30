# The ultimate Wayland/Niri setup
AUR_HELPER = yay
PKGS = niri waybar swaync kanshi swayosd hypridle hyprlock \
       polkit-gnome vicinae-bin awww-bin stow greetd-tuigreet \
       ttf-jetbrains-mono-nerd noto-fonts-cjk alacritty dolphin \
       curl ttf-twemoji iio-niri figlet zsh \
       starship zsh-autosuggestions zsh-syntax-highlighting 

# Check if yay is installed
YAY_CHECK := $(shell command -v $(AUR_HELPER) 2> /dev/null)

all: bootstrap install-deps link-dots prepare-startup enable-services

# 1. The Bootstrap: Install yay if it's missing
bootstrap:
ifndef YAY_CHECK
	@echo "🚀 Yay missing. Bootstrapping AUR helper..."
	sudo pacman -Syyu --needed --noconfirm base-devel git
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay && makepkg -si --noconfirm
	rm -rf /tmp/yay
else
	@echo "✅ Yay is already installed."
endif

# 2. Install everything
install-deps:
	$(AUR_HELPER) -Syyu --needed --noconfirm $(PKGS)

# 3. Use Stow to link the configs
link-dots:
	@echo "🔗 Linking configs with Stow..."
	stow -vt ../ stow_wrapper/
	@echo "Linked"

# 4. Prepare everything else
prepare-startup:
	mkdir -p ~/Pictures/Wallpapers
	mkdir -p ~/.local/share/vicinae/scripts
	stow -vt ~ homeStow
	sudo mkdir -p /etc/greetd
	@sed "s@user = \"N/A\"@user = \"$(shell whoami)\"@" ./greetd/config.toml | sudo tee /etc/greetd/config.toml > /dev/null
	starship preset no-runtime-versions -o ~/.config/starship.toml

# 5. Services and Shell
enable-services:
	sudo systemctl enable greetd
	sudo chsh -s /usr/bin/zsh $(shell whoami)
	@echo -e "\e[41m\e[1;97m$$(figlet -f big "  REBOOT NOW  ")\e[0m"
	@echo "Seriously, do it right now"

# Quick cleanup
clean:
	@echo "🧹 Cleaning up pacman cache..."
	sudo pacman -Sc --noconfirm

.PHONY: all bootstrap install-deps link-dots prepare-startup enable-services clean