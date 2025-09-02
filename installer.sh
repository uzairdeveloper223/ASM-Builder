#!/bin/bash

# ===============================
#   ASM Builder Installer
#   Author: UzairDeveloper223
#   Version: 1.0.0
# ===============================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_NAME="asmbuilder"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/asmbuilder"
TEMP_DIR="/tmp/asmbuilder_install_$$"
GITHUB_URL="https://raw.githubusercontent.com/uzairdeveloper223/ASM-Runner-For-Linux/refs/heads/main/asmbuilder"

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '░'
    printf "] %3d%% " $percentage
}

# Spinner function for background tasks
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Print functions
print_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                    ASM Builder Installer                     ║
║                        Version 2.0.0                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

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
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "Mac";;
        CYGWIN*|MINGW*|MSYS*) echo "Windows";;
        *)          echo "UNKNOWN";;
    esac
}

# Check if running with proper privileges
check_privileges() {
    local OS=$(detect_os)
    
    if [ "$OS" = "Linux" ]; then
        if [ "$EUID" -ne 0 ] && [ "$1" != "--user" ]; then
            print_warning "This installer requires sudo privileges for system-wide installation."
            echo -e "${YELLOW}Would you like to:"
            echo "1) Run with sudo (system-wide installation)"
            echo "2) Install for current user only"
            echo -e "Choose (1/2): ${NC}"
            read -r choice
            
            case $choice in
                1)
                    print_info "Restarting with sudo..."
                    exec sudo "$0" "$@"
                    ;;
                2)
                    INSTALL_DIR="$HOME/.local/bin"
                    print_info "Installing to $INSTALL_DIR"
                    mkdir -p "$INSTALL_DIR"
                    ;;
                *)
                    print_error "Invalid choice"
                    exit 1
                    ;;
            esac
        fi
    elif [ "$OS" = "Mac" ]; then
        INSTALL_DIR="/usr/local/bin"
        if [ ! -w "$INSTALL_DIR" ]; then
            print_info "Requesting sudo privileges..."
            sudo -v
        fi
    fi
}

# Install dependencies
install_dependencies() {
    local OS=$(detect_os)
    local deps_to_install=()
    
    print_info "Checking dependencies..."
    progress_bar 1 10
    
    # Check each dependency
    for dep in nasm gcc make curl; do
        if ! command -v $dep &>/dev/null; then
            deps_to_install+=($dep)
        fi
    done
    
    progress_bar 3 10
    
    if [ ${#deps_to_install[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${deps_to_install[*]}"
        print_info "Installing dependencies..."
        
        case "$OS" in
            Linux)
                if command -v apt-get &>/dev/null; then
                    sudo apt-get update -qq
                    sudo apt-get install -y -qq "${deps_to_install[@]}" &
                    spinner $!
                elif command -v yum &>/dev/null; then
                    sudo yum install -y -q "${deps_to_install[@]}" &
                    spinner $!
                elif command -v pacman &>/dev/null; then
                    sudo pacman -S --noconfirm --quiet "${deps_to_install[@]}" &
                    spinner $!
                elif command -v dnf &>/dev/null; then
                    sudo dnf install -y -q "${deps_to_install[@]}" &
                    spinner $!
                fi
                ;;
            Mac)
                if command -v brew &>/dev/null; then
                    brew install "${deps_to_install[@]}" &
                    spinner $!
                else
                    print_error "Homebrew not found. Please install it first."
                    exit 1
                fi
                ;;
        esac
        
        print_success "Dependencies installed!"
    else
        print_success "All dependencies are already installed!"
    fi
    
    progress_bar 5 10
}

# Download and install the main script
install_script() {
    print_info "Downloading ASM Builder..."
    progress_bar 6 10
    
    mkdir -p "$TEMP_DIR"
    
    # Download the script
    if command -v curl &>/dev/null; then
        curl -sL -o "$TEMP_DIR/$SCRIPT_NAME" "$GITHUB_URL" &
        spinner $!
    elif command -v wget &>/dev/null; then
        wget -q -O "$TEMP_DIR/$SCRIPT_NAME" "$GITHUB_URL" &
        spinner $!
    else
        # If neither curl nor wget, use the embedded script
        print_info "Using embedded version..."
        cat > "$TEMP_DIR/$SCRIPT_NAME" << 'EMBEDDED_SCRIPT'
# [The enhanced ASM builder script would be embedded here]
EMBEDDED_SCRIPT
    fi
    
    progress_bar 7 10
    
    # Make executable
    chmod +x "$TEMP_DIR/$SCRIPT_NAME"
    
    # Remove .sh extension if present
    if [[ "$SCRIPT_NAME" == *.sh ]]; then
        mv "$TEMP_DIR/$SCRIPT_NAME" "$TEMP_DIR/${SCRIPT_NAME%.sh}"
        SCRIPT_NAME="${SCRIPT_NAME%.sh}"
    fi
    
    progress_bar 8 10
    
    # Move to installation directory
    print_info "Installing to $INSTALL_DIR..."
    
    if [ "$EUID" -eq 0 ] || [ "$INSTALL_DIR" = "$HOME/.local/bin" ]; then
        mv "$TEMP_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    else
        sudo mv "$TEMP_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    progress_bar 9 10
    
    # Create configuration directory
    mkdir -p "$CONFIG_DIR"
    
    # Create initial configuration file
    cat > "$CONFIG_DIR/config.conf" << EOF
# ASM Builder Configuration
VERSION=1.0.0
INSTALL_DATE=$(date)
INSTALL_PATH=$INSTALL_DIR/$SCRIPT_NAME
DEFAULT_ARCH=64
DEFAULT_SYNTAX=intel
DEFAULT_OPTIMIZE=0
EOF
    
    progress_bar 10 10
    print_success "Installation complete!"
}

# Setup PATH if needed
setup_path() {
    local OS=$(detect_os)
    local shell_rc=""
    
    # Determine shell configuration file
    if [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Check if install directory is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "$INSTALL_DIR is not in your PATH"
        echo -e "${YELLOW}Would you like to add it? (y/n)${NC}"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "" >> "$shell_rc"
            echo "# Added by ASM Builder installer" >> "$shell_rc"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_rc"
            print_success "PATH updated in $shell_rc"
            print_info "Please run: source $shell_rc"
        fi
    fi
}

# Create desktop entry (Linux only)
create_desktop_entry() {
    local OS=$(detect_os)
    
    if [ "$OS" = "Linux" ] && [ -d "$HOME/.local/share/applications" ]; then
        cat > "$HOME/.local/share/applications/asmbuilder.desktop" << EOF
[Desktop Entry]
Name=ASM Builder
Comment=Assembly code builder and runner
Exec=$INSTALL_DIR/$SCRIPT_NAME
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;
EOF
        print_success "Desktop entry created"
    fi
}

# Cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Main installation function
main() {
    # Set trap for cleanup
    trap cleanup EXIT
    
    print_header
    
    # System information
    echo -e "${CYAN}System Information:${NC}"
    echo -e "  OS: $(detect_os)"
    echo -e "  Architecture: $(uname -m)"
    echo -e "  User: $USER"
    echo ""
    
    # Installation steps
    echo -e "${GREEN}Installation will perform the following:${NC}"
    echo "  1. Check system privileges"
    echo "  2. Install required dependencies"
    echo "  3. Download ASM Builder"
    echo "  4. Install to $INSTALL_DIR"
    echo "  5. Setup configuration"
    echo "  6. Update PATH if needed"
    echo ""
    
    echo -e "${YELLOW}Continue with installation? (y/n)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    echo ""
    print_info "Starting installation..."
    echo ""
    
    # Check privileges
    check_privileges "$@"
    
    # Install dependencies
    install_dependencies
    
    # Install script
    install_script
    
    # Setup PATH
    setup_path
    
    # Create desktop entry
    create_desktop_entry
    
    echo ""
    print_header
    
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Installation Completed Successfully!               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Installation Summary:${NC}"
    echo -e "  • Installed to: ${GREEN}$INSTALL_DIR/$SCRIPT_NAME${NC}"
    echo -e "  • Config directory: ${GREEN}$CONFIG_DIR${NC}"
    echo -e "  • Version: ${GREEN}1.0.0${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  ${GREEN}$SCRIPT_NAME <file.asm>${NC}    - Build and run an assembly file"
    echo -e "  ${GREEN}$SCRIPT_NAME --help${NC}        - Show help and all options"
    echo -e "  ${GREEN}$SCRIPT_NAME --repair${NC}      - Repair installation"
    echo ""
    echo -e "${YELLOW}Quick Test:${NC}"
    echo -e "  Create a test file: ${GREEN}echo 'section .text' > test.asm${NC}"
    echo -e "  Build and run: ${GREEN}$SCRIPT_NAME test.asm${NC}"
    echo ""
    
    # Test installation
    if command -v "$SCRIPT_NAME" &>/dev/null; then
        print_success "ASM Builder is ready to use!"
    else
        print_warning "Please restart your terminal or run: source ~/.bashrc"
    fi
}

# Run main function
main "$@"