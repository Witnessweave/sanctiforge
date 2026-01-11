#!/usr/bin/env bash
set -euo pipefail

LOG="$HOME/sanctiforge/logs/keyring_outlook_stack_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

say() { printf "\n[+] %s\n" "$*"; }
warn() { printf "\n[!] %s\n" "$*" >&2; }
need_sudo() { command -v sudo >/dev/null 2>&1 || { warn "sudo not found; install sudo or run as root."; exit 1; }; }

UIDNUM="$(id -u)"
XRD="${XDG_RUNTIME_DIR:-/run/user/$UIDNUM}"

say "Rocky 9.6 — Outlook paths: Evolution(EWS) + Prospect Mail + Wine prefix (optional)."

# --- 0) Repos & basic packages ---
need_sudo
say "Ensuring EPEL, Flatpak, Evolution + EWS, GNOME Keyring, Seahorse, Wine..."
sudo dnf install -y epel-release || true
sudo dnf install -y flatpak gnome-keyring seahorse evolution evolution-ews wine || true

# --- 1) winetricks (upstream script) ---
if ! command -v winetricks >/dev/null 2>&1; then
  say "Installing winetricks from upstream..."
  tmpfile="$(mktemp)"
  curl -fsSL -o "$tmpfile" https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
  chmod +x "$tmpfile"
  sudo mv "$tmpfile" /usr/local/bin/winetricks
  say "winetricks version: $(winetricks --version || true)"
else
  say "winetricks already present: $(winetricks --version || true)"
fi

# --- 2) Multilib libs (32-bit) for Wine (already did many, but make idempotent) ---
say "Installing core 32-bit libraries needed by Wine (safe if already installed)..."
sudo dnf install -y glibc.i686 freetype.i686 libX11.i686 mesa-libGL.i686 || true

# NOTE: On Rocky 9, do NOT request wine-core.i686/wine-opengl.i686 explicitly; multilib handled automatically.

# --- 3) GNOME Keyring + PAM integration (so Evolution can store creds) ---
PAM_LOGIN="/etc/pam.d/login"
PAM_GDM="/etc/pam.d/gdm-password"

add_pam_lines() {
  local file="$1"
  if [ -f "$file" ]; then
    sudo cp -n "$file" "${file}.bak.$(date +%s)"
    grep -q 'pam_gnome_keyring.so' "$file" || {
      say "Patching PAM in $(basename "$file") for gnome-keyring..."
      printf '\n# gnome-keyring (enable keyring on login)\n' | sudo tee -a "$file" >/dev/null
      printf 'auth     optional    pam_gnome_keyring.so\n' | sudo tee -a "$file" >/dev/null
      printf 'session  optional    pam_gnome_keyring.so auto_start\n' | sudo tee -a "$file" >/dev/null
    }
  else
    warn "PAM file not found: $file (skipping)"
  fi
}

say "Enabling PAM hooks for GNOME Keyring..."
add_pam_lines "$PAM_LOGIN"
add_pam_lines "$PAM_GDM"

# --- 4) If not using GDM (e.g., startx/i3/xfce), auto-start keyring in X session ---
XINIT="$HOME/.xinitrc"
START_SNIPPET='eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg); export SSH_AUTH_SOCK'
if [ -n "${DISPLAY-}" ] || [ -f "$XINIT" ]; then
  if [ -f "$XINIT" ]; then
    if ! grep -Fq "$START_SNIPPET" "$XINIT"; then
      say "Adding keyring autostart to ~/.xinitrc"
      {
        echo
        echo "# --- GNOME Keyring autostart (Outlook/Evolution creds) ---"
        echo "$START_SNIPPET"
      } >> "$XINIT"
    else
      say "~/.xinitrc already contains keyring autostart."
    fi
  fi
fi

# --- 5) Try to start keyring now (works best inside GUI) ---
say "Attempting to start gnome-keyring-daemon for this session (best-effort)..."
if command -v /usr/bin/gnome-keyring-daemon >/dev/null 2>&1; then
  eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg || true)"
else
  warn "gnome-keyring-daemon binary not found (unexpected on Rocky GNOME)."
fi

# --- 6) Verify socket path ---
say "Verifying keyring control/socket path..."
echo "XDG_RUNTIME_DIR = ${XRD}"
if [ -d "$XRD/keyring" ]; then
  ls -l "$XRD/keyring" || true
else
  warn "Keyring socket dir not present yet. This is normal if not in a full GUI login. After reboot/login via GDM, it should appear at: $XRD/keyring"
fi

# --- 7) Evolution quality-of-life: add alias 'outlook' ---
BASHRC="$HOME/.bashrc"
if ! grep -Fq "alias outlook=" "$BASHRC"; then
  say "Creating alias 'outlook' -> 'evolution --component=mail'"
  echo "alias outlook='evolution --component=mail'" >> "$BASHRC"
fi

# --- 8) Prospect Mail (Outlook web wrapper via Flatpak), optional but handy ---
if command -v flatpak >/dev/null 2>&1; then
  say "Configuring flathub and offering Prospect Mail..."
  flatpak remotes | grep -q flathub || sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  # Install silently only if not present
  if ! flatpak list | grep -q 'app.drey.ProspectMailer'; then
    say "Installing Prospect Mail (Outlook wrapper)..."
    flatpak install -y flathub app.drey.ProspectMailer || warn "Prospect Mail install skipped/failed."
  else
    say "Prospect Mail already installed."
  fi
else
  warn "Flatpak not available; skipping Prospect Mail."
fi

# --- 9) Wine prefix prep (optional Outlook for Windows) ---
say "Preparing optional Wine prefix for Outlook (Windows build)..."
export WINEPREFIX="$HOME/.wine-outlook"
wineboot --init || warn "wineboot reported issues (may still be OK)."

# Best-practice baseline for Office/Outlook on Wine:
if command -v winetricks >/dev/null 2>&1; then
  say "Running winetricks baseline (Windows 10, fonts, XML, .NET 4.7.2)..."
  winetricks -q settings win10 || warn "winetricks: settings win10 failed (continuing)"
  winetricks -q corefonts msxml6 || warn "winetricks: corefonts/msxml6 failed (continuing)"
  # dotnet48 can be brittle; 4.7.2 is often safer:
  winetricks -q dotnet472 || warn "winetricks: dotnet472 failed (you can try dotnet48 later)"
else
  warn "winetricks missing unexpectedly; skipping Wine extras."
fi

# --- 10) Summary & next steps ---
say "DONE. Summary:"
echo "  • Evolution (with EWS) installed — use:  evolution"
echo "  • Alias 'outlook' created — use:  outlook"
echo "  • GNOME Keyring PAM patched. If you weren't in GDM, log out/in (or reboot) for sockets to appear."
echo "  • Prospect Mail (if installed): flatpak run app.drey.ProspectMailer"
echo "  • Wine prefix prepared at: \$WINEPREFIX"
echo "    To run an Office/Outlook offline installer:  wine /path/to/OfficeSetup.exe"
echo
say "Log saved at:  $LOG"
