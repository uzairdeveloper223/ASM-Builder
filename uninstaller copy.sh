#!/bin/bash

# ===============================
#   ASM Builder Uninstaller
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
CACHE_DIR="$HOME/.cache/asmbuilder"
BACKUP_DIR="$HOME/.asmbuilder-backups"

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

# Print functions
print_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  ASM Builder Uninstaller                     ║
║                        Version 1.0.0                         ║
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
        if [ "$EUID" -ne 0 ] && [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
            print_warning "This uninstaller may require sudo privileges for system-wide removal."
            echo -e "${YELLOW}Would you like to:"
            echo "1) Run with sudo (system-wide uninstall)"
            echo "2) Uninstall for current user only"
            echo -e "Choose (1/2): ${NC}"
            read -r choice

            case $choice in
                1)
                    print_info "Restarting with sudo..."
                    exec sudo "$0" "$@"
                    ;;
                2)
                    INSTALL_DIR="$HOME/.local/bin"
                    print_info "Uninstalling from $INSTALL_DIR"
                    ;;
                *)
                    print_error "Invalid choice"
                    exit 1
                    ;;
            esac
        fi
    elif [ "$OS" = "Mac" ]; then
        INSTALL_DIR="/usr/local/bin"
        if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ] && [ ! -w "$INSTALL_DIR" ]; then
            print_info "Requesting sudo privileges..."
            sudo -v
        fi
    fi
}

# Find installed script
find_installed_script() {
    local script_path=""

    # Check common installation locations
    for dir in "/usr/local/bin" "/usr/bin" "$HOME/.local/bin" "$HOME/bin"; do
        if [ -f "$dir/$SCRIPT_NAME" ]; then
            script_path="$dir/$SCRIPT_NAME"
            break
        fi
    done

    # Also check if it's in PATH
    if [ -z "$script_path" ]; then
        script_path=$(which "$SCRIPT_NAME" 2>/dev/null)
    fi

    echo "$script_path"
}

# Backup important files
create_backup() {
    print_info "Creating backup of important files..."
    mkdir -p "$BACKUP_DIR"

    local backup_name="uninstall_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"

    mkdir -p "$backup_path"

    # Backup configuration
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$backup_path/"
        print_success "Configuration backed up"
    fi

    # Backup cache
    if [ -d "$CACHE_DIR" ]; then
        cp -r "$CACHE_DIR" "$backup_path/"
        print_success "Cache backed up"
    fi

    # Backup installed script
    local script_path=$(find_installed_script)
    if [ -n "$script_path" ] && [ -f "$script_path" ]; then
        cp "$script_path" "$backup_path/"
        print_success "Script backed up"
    fi

    print_info "Backup created at: $backup_path"
}

# Remove installed script
remove_script() {
    local script_path=$(find_installed_script)

    if [ -n "$script_path" ] && [ -f "$script_path" ]; then
        print_info "Removing script from: $script_path"

        if [ -w "$script_path" ]; then
            rm -f "$script_path"
            print_success "Script removed successfully"
        else
            sudo rm -f "$script_path"
            print_success "Script removed successfully (with sudo)"
        fi
    else
        print_warning "No installed script found"
    fi
}

# Remove configuration files
remove_config() {
    print_info "Removing configuration files..."

    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        print_success "Configuration directory removed"
    else
        print_info "No configuration directory found"
    fi
}

# Remove cache files
remove_cache() {
    print_info "Removing cache files..."

    if [ -d "$CACHE_DIR" ]; then
        rm -rf "$CACHE_DIR"
        print_success "Cache directory removed"
    else
        print_info "No cache directory found"
    fi
}

# Remove desktop entry (Linux only)
remove_desktop_entry() {
    local OS=$(detect_os)

    if [ "$OS" = "Linux" ]; then
        local desktop_file="$HOME/.local/share/applications/asmbuilder.desktop"

        if [ -f "$desktop_file" ]; then
            rm -f "$desktop_file"
            print_success "Desktop entry removed"
        fi
    fi
}

# Clean PATH (if needed)
clean_path() {
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

    if [ -f "$shell_rc" ]; then
        # Check if ASM Builder PATH entry exists
        if grep -q "ASM Builder installer" "$shell_rc"; then
            print_info "Removing PATH entry from $shell_rc"
            sed -i '/# Added by ASM Builder installer/,+1d' "$shell_rc"
            print_success "PATH entry removed"
            print_warning "Please restart your terminal or run: source $shell_rc"
        fi
    fi
}

# Remove temporary files
clean_temp_files() {
    print_info "Cleaning temporary files..."

    # Remove any temp files created by the script
    rm -f "/tmp/$SCRIPT_NAME."* 2>/dev/null
    rm -f "/tmp/asmbuilder_install_"* 2>/dev/null

    print_success "Temporary files cleaned"
}

# Show uninstallation summary
show_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Uninstallation Completed Successfully!            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Uninstallation Summary:${NC}"
    echo -e "  • Script removed from system"
    echo -e "  • Configuration files removed"
    echo -e "  • Cache files removed"
    echo -e "  • Desktop entry removed (if existed)"
    echo -e "  • PATH cleaned (if modified)"
    echo -e "  • Temporary files cleaned"
    echo ""
    echo -e "${YELLOW}Backup Location:${NC} $BACKUP_DIR"
    echo -e "${YELLOW}Note:${NC} You can restore from backup if needed"
    echo ""
    echo -e "${CYAN}To reinstall:${NC}"
    echo -e "  ${GREEN}./installer.sh${NC}"
    echo ""
}

# Main uninstallation function
main() {
    # Set trap for cleanup
    trap clean_temp_files EXIT

    print_header

    # System information
    echo -e "${CYAN}System Information:${NC}"
    echo -e "  OS: $(detect_os)"
    echo -e "  Architecture: $(uname -m)"
    echo -e "  User: $USER"
    echo ""

    # Check privileges
    check_privileges "$@"

    # Find installed script
    local script_path=$(find_installed_script)

    if [ -z "$script_path" ]; then
        print_warning "ASM Builder does not appear to be installed on this system."
        echo -e "${YELLOW}If you installed it manually, please remove it yourself.${NC}"
        exit 0
    fi

    echo -e "${CYAN}Found ASM Builder installation:${NC}"
    echo -e "  Location: $script_path"
    echo ""

    # Confirmation
    echo -e "${YELLOW}This will remove ASM Builder and all associated files.${NC}"
    echo -e "${YELLOW}A backup will be created in: $BACKUP_DIR${NC}"
    echo ""
    echo -e "${YELLOW}Continue with uninstallation? (y/n)${NC}"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi

    echo ""
    print_info "Starting uninstallation..."
    echo ""

    # Progress tracking
    local step=1
    local total_steps=7

    # Create backup
    progress_bar $step $total_steps
    create_backup
    step=$((step + 1))

    # Remove script
    progress_bar $step $total_steps
    remove_script
    step=$((step + 1))

    # Remove configuration
    progress_bar $step $total_steps
    remove_config
    step=$((step + 1))

    # Remove cache
    progress_bar $step $total_steps
    remove_cache
    step=$((step + 1))

    # Remove desktop entry
    progress_bar $step $total_steps
    remove_desktop_entry
    step=$((step + 1))

    # Clean PATH
    progress_bar $step $total_steps
    clean_path
    step=$((step + 1))

    # Clean temp files
    progress_bar $step $total_steps
    clean_temp_files
    step=$((step + 1))

    progress_bar $total_steps $total_steps
    echo ""

    show_summary
}

# Run main function
main "$@"
