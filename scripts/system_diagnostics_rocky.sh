#!/bin/bash
# === system_diagnostics_rocky.sh ===
# 🛡 Diagnostics: hardware, drivers, Steam, Proton, Wine

set -euo pipefail
mkdir -p ~/sanctiforge/logs
TS=$(date +"%Y%m%d_%H%M%S")
LOG=~/sanctiforge/logs/sys_diag_$TS.txt
exec &> >(tee "$LOG")

run() {
  echo -e "\n>> $1"
  eval "$1" || echo "⚠️ Failed: $1"
}

# Header
echo "🛡️ SYSTEM DIAGNOSTICS — $TS"
echo "====================================="
echo "User          : $USER"
run "hostname"
run "grep PRETTY_NAME /etc/*release | cut -d= -f2"
run "uname -r"
echo "Shell         : $SHELL"
run "uptime -p"

# CPU & Memory
echo -e "\n🧠 CPU & MEMORY"
run "lscpu | grep -E 'Model name|CPU\\(s\\)|Thread|Core|Socket|Vendor'"
run "free -h"

# GPU Info
echo -e "\n🎮 GPU INFO"
run "lspci | grep -i 'vga\\|3d\\|2d'"
if command -v nvidia-smi &>/dev/null; then run "nvidia-smi"; else echo "⚠️ NVIDIA driver not active"; fi

# Display
echo -e "\n🖥️ DISPLAY STACK"
echo "XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-not set}"
echo "DISPLAY         : ${DISPLAY:-not set}"
echo "Wayland         : ${WAYLAND_DISPLAY:-not set}"
run "xrandr --verbose || echo '(xrandr failed)'"

# Vulkan
echo -e "\n🧪 VULKAN"
run "vulkaninfo | grep -E 'deviceName|apiVersion' || echo '(vulkaninfo missing)'"

# Proton & Steam
echo -e "\n🍷 PROTON & STEAM"
run "find ~/.steam/root/compatibilitytools.d -type f -name wine64 || echo '(No Proton installs)'"
run "tail -n 20 ~/.steam/steam/logs/setup_log.txt || echo '(No Steam logs)'"

# Network
echo -e "\n🌐 NETWORK"
run "ip addr"
run "nmcli device status"

# Storage
echo -e "\n💽 STORAGE"
run "df -hT | grep -v tmpfs"
run "lsblk -o NAME,SIZE,TYPE,MOUNTPOINT"

# Wine
echo -e "\n🍷 WINE"
run "which wine || echo '(Wine not installed)'"
run "wine --version || true"

# Done
echo -e "\n✅ DONE — report saved to: $LOG"
echo "✝ Completed in Jesus' name."
