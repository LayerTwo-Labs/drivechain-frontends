#!/usr/bin/env bash
#
# BitWindow Installer Script
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/LayerTwo-Labs/drivechain-frontends/master/install-bitwindow.sh | bash
#   or
#   wget -qO- https://raw.githubusercontent.com/LayerTwo-Labs/drivechain-frontends/master/install-bitwindow.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APPIMAGE_URL="https://releases.drivechain.info/BitWindow-latest-x86_64-unknown-linux-gnu.AppImage"
APP_NAME="BitWindow"
APP_NAME_LOWER="bitwindow"
INSTALL_DIR="$HOME/.local/bin"
ICON_URL="https://raw.githubusercontent.com/LayerTwo-Labs/drivechain-frontends/master/bitwindow/assets/bitwindow.png"

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Header
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     BitWindow AppImage Installer       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check dependencies
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    fi
    return 0
}

missing_deps=false
if ! check_dependency "curl" && ! check_dependency "wget"; then
    print_error "Either curl or wget is required"
    missing_deps=true
fi

if [ "$missing_deps" = true ]; then
    print_error "Please install missing dependencies and try again"
    exit 1
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/share/icons"

# Download AppImage
APPIMAGE_PATH="$INSTALL_DIR/$APP_NAME_LOWER.AppImage"
print_info "Downloading BitWindow..."
print_info "This may take a few minutes depending on your connection..."

if command -v curl &> /dev/null; then
    curl -L --progress-bar -o "$APPIMAGE_PATH" "$APPIMAGE_URL" || {
        print_error "Failed to download AppImage"
        exit 1
    }
elif command -v wget &> /dev/null; then
    wget --show-progress -q -O "$APPIMAGE_PATH" "$APPIMAGE_URL" || {
        print_error "Failed to download AppImage"
        exit 1
    }
fi

print_success "AppImage downloaded successfully"

# Make executable
chmod +x "$APPIMAGE_PATH"

# Download icon
ICON_PATH="$HOME/.local/share/icons/$APP_NAME_LOWER.png"

if command -v curl &> /dev/null; then
    curl -sL -o "$ICON_PATH" "$ICON_URL" 2>/dev/null || {
        print_warning "Could not download icon, will try to extract from AppImage"
        ICON_PATH=""
    }
elif command -v wget &> /dev/null; then
    wget -q -O "$ICON_PATH" "$ICON_URL" 2>/dev/null || {
        print_warning "Could not download icon, will try to extract from AppImage"
        ICON_PATH=""
    }
fi

# If icon download failed, try to extract from AppImage
if [ -z "$ICON_PATH" ] || [ ! -f "$ICON_PATH" ]; then
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    "$APPIMAGE_PATH" --appimage-extract .DirIcon >/dev/null 2>&1 || \
    "$APPIMAGE_PATH" --appimage-extract "$APP_NAME_LOWER.png" >/dev/null 2>&1 || true

    if [ -f "squashfs-root/.DirIcon" ]; then
        cp "squashfs-root/.DirIcon" "$HOME/.local/share/icons/$APP_NAME_LOWER.png"
        ICON_PATH="$HOME/.local/share/icons/$APP_NAME_LOWER.png"
    elif [ -f "squashfs-root/$APP_NAME_LOWER.png" ]; then
        cp "squashfs-root/$APP_NAME_LOWER.png" "$HOME/.local/share/icons/$APP_NAME_LOWER.png"
        ICON_PATH="$HOME/.local/share/icons/$APP_NAME_LOWER.png"
    else
        print_warning "Could not extract icon, application will use default icon"
    fi

    cd - >/dev/null
    rm -rf "$temp_dir"
fi

# Create desktop entry
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME_LOWER.desktop"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Type=Application
Name=BitWindow
GenericName=Drivechain Node Manager
Comment=Manage Bitcoin and Drivechain nodes
Exec=$APPIMAGE_PATH %U
Terminal=false
Categories=Network;P2P;Finance;
StartupWMClass=bitwindow
Keywords=bitcoin;drivechain;bip300;bip301;node;
EOF

if [ -n "$ICON_PATH" ] && [ -f "$ICON_PATH" ]; then
    echo "Icon=$ICON_PATH" >> "$DESKTOP_FILE"
fi

chmod +x "$DESKTOP_FILE"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons" 2>/dev/null || true
fi

# Create command line shortcut
ln -sf "$APPIMAGE_PATH" "$INSTALL_DIR/bitwindow"
print_success "Created command line shortcut"

# Check PATH
path_configured=false
if echo "$PATH" | grep -q "$HOME/.local/bin"; then
    path_configured=true
fi

# Success message
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Installation Complete! 🎉          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}BitWindow has been successfully installed!${NC}"
echo ""
echo "Installation details:"
echo "  • AppImage: $APPIMAGE_PATH"
echo "  • Desktop entry: $DESKTOP_FILE"
[ -n "$ICON_PATH" ] && echo "  • Icon: $ICON_PATH"
echo "  • Command: $INSTALL_DIR/bitwindow"
echo ""
echo "You can now:"
echo "  • Find BitWindow in your application menu"
echo "  • Launch from terminal: $APPIMAGE_PATH"

if [ "$path_configured" = true ]; then
    echo "  • Run directly: bitwindow"
else
    echo ""
    print_warning "To run 'bitwindow' from anywhere, you need to add ~/.local/bin to your PATH"
    echo ""

    # Detect current shell
    current_shell=$(basename "$SHELL")

    echo "Run this command to add bitwindow to your PATH:"
    echo ""

    case "$current_shell" in
        bash)
            echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
            echo ""
            echo "  Then reload with:"
            echo "    source ~/.bashrc"
            ;;
        zsh)
            echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
            echo ""
            echo "  Then reload with:"
            echo "    source ~/.zshrc"
            ;;
        fish)
            echo "    fish_add_path \$HOME/.local/bin"
            ;;
        *)
            echo "  For Bash (~/.bashrc):"
            echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
            echo "    source ~/.bashrc"
            ;;
    esac
fi

echo ""
echo "To uninstall BitWindow, run:"
echo "  rm $APPIMAGE_PATH"
echo "  rm $DESKTOP_FILE"
[ -n "$ICON_PATH" ] && echo "  rm $ICON_PATH"
echo "  rm $INSTALL_DIR/bitwindow"
echo ""
print_info "Enjoy using BitWindow!"
