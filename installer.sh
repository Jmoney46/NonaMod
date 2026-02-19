#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log()    { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $1"; }
error()  { echo -e "${RED}[✖]${RESET} $1" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
    error "Please run this script as root (sudo bash $0)"
fi

log "Starting MushM Installer"

CROSH="/usr/bin/crosh"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"
BOOT_SKRIPT="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
BOOT_SK_DIR="/sbin/chromeos_startup"

log "Installing Needed Things And Shit."
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed To Installing Needed Things And Shit"

log "Installing MushM."
curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM"

log "Fixing Shity Boot Msg."
touch "$BOOT_SK_DIR"
curl -fsSLo "$BOOT_SK_DIR" "$BOOT_SKRIPT" || error "Failed to fix boot msg"

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    DIST="x86_64-unknown-linux-gnu"
elif [[ "$ARCH" == aarch64* ]]; then
    DIST="aarch64-unknown-linux-gnu"
else
    error "Unsupported architecture: $ARCH"
fi

PY_VERSION="3.13.3"
BASE="https://github.com/astral-sh/python-build-standalone/releases/latest/download"
FILE="cpython-$PY_VERSION+20250409-$DIST-install_only_stripped.tar.gz"
URL="$BASE/$FILE"

TMPDIR="/tmp/python-standalone"
sudo rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

log "Downloading standalone Python ($ARCH)..."
curl -L -o "$TMPDIR/python.tar.gz" "$URL"
log "Extracting Python..."
tar -xzf "$TMPDIR/python.tar.gz" -C "$TMPDIR"

SRC_PY_BIN=$(find "$TMPDIR" -type f -name "python3" | head -n 1)
if [ ! -f "$SRC_PY_BIN" ]; then
    error "Could not find python3 binary in downloaded package"
fi

log "Installing python3 to /usr/bin"
sudo cp "$SRC_PY_BIN" /usr/bin/python3
sudo chmod +x /usr/bin/python3
python3 --version || error "Python installation failed"
sudo rm -rf "$TMPDIR"

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11 and StarkMist111960 (to a lesser extent)${RESET}"
sleep 2
