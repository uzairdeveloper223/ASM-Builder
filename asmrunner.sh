#!/bin/bash

# ===============================
#   ASM Build & Run Helper
#   Author: UzairDeveloper223
#   Version: 1.0.0
# ===============================

VERSION="1.0.0"
GITHUB_RAW="https://raw.githubusercontent.com/uzairdeveloper223/asm-builder/main"
SCRIPT_NAME="asmbuild.sh"
REMOTE_VERSION_FILE="$GITHUB_RAW/version.txt"

check_deps() {
    echo "[*] Checking required dependencies..."
    local missing=0

    for dep in nasm gcc curl; do
        if ! command -v $dep &>/dev/null; then
            echo "[!] Missing dependency: $dep"
            missing=1
        else
            echo "[✓] $dep is installed"
        fi
    done

    if [ $missing -eq 1 ]; then
        echo "[!] Please install the missing dependencies and try again."
        exit 1
    fi
    echo "[*] All dependencies installed. Proceeding..."
}

usage() {
    cat <<EOF
Usage: $0 [options] <file.asm>

Options:
  -h, --help       Show this help message
  -v, --version    Show script version
  --update         Check for updates and install if available

Example:
  $0 hello.asm
EOF
    exit 0
}

show_version() {
    echo "ASM Builder version $VERSION"
    exit 0
}

update_script() {
    echo "[*] Checking for updates..."
    remote_version=$(curl -s "$REMOTE_VERSION_FILE")

    if [ -z "$remote_version" ]; then
        echo "[!] Failed to fetch remote version. Check your internet connection."
        exit 1
    fi

    if [ "$remote_version" == "$VERSION" ]; then
        echo "[*] You are already on the latest version ($VERSION)."
        exit 0
    else
        echo "[*] New version available: $remote_version"
        echo "[*] Updating script..."
        curl -s -o "$SCRIPT_NAME" "$GITHUB_RAW/$SCRIPT_NAME"
        chmod +x "$SCRIPT_NAME"
        echo "[✓] Updated to version $remote_version."
        exit 0
    fi
}

build_and_run() {
    local file="$1"
    local base=$(basename "$file" .asm)

    if [ ! -f "$file" ]; then
        echo "[!] File not found: $file"
        exit 1
    fi

    echo "[*] Assembling $file..."
    if ! nasm -f elf64 "$file" -o "$base.o"; then
        echo "[!] Assembly failed."
        exit 1
    fi

    echo "[*] Compiling $base.o..."
    if ! gcc "$base.o" -o "$base" -no-pie; then
        echo "[!] Compilation failed."
        exit 1
    fi

    echo "[*] Running $base..."
    echo "==============================="
    "./$base"
    echo "==============================="
}

# Main
check_deps

case "$1" in
    -h|--help)
        usage
        ;;
    -v|--version)
        show_version
        ;;
    --update)
        update_script
        ;;
    "")
        usage
        ;;
    *)
        build_and_run "$1"
        ;;
esac
