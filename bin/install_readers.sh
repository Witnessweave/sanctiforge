#!/usr/bin/env bash
set -euo pipefail

# === PATHS ===
ROOT="$HOME/sanctiforge"
BIN="$ROOT/bin"
LOG="$ROOT/logs"
DESKTOP="$HOME/Desktop"
mkdir -p "$BIN" "$LOG" "$DESKTOP"

log(){ echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a "$LOG/reader_install.log"; }

log "STARTING INSTALL OF READER SUITE"

# === Install Foliate via Flatpak ===
log "Installing Foliate via Flatpak"
flatpak install -y flathub com.github.johnfactotum.Foliate

# === Install Okular ===
log "Installing Okular"
sudo dnf install -y okular

# === Install Zathura ===
log "Installing Zathura"
sudo dnf install -y zathura zathura-pdf-poppler

# === Default File Associations ===
log "Setting Foliate as default for .epub"
xdg-mime default com.github.johnfactotum.Foliate.desktop application/epub+zip

log "Setting Okular as default for .pdf"
xdg-mime default okularApplication_pdf.desktop application/pdf

# === Desktop Icons ===
log "Creating desktop launchers"

cat > "$DESKTOP/Foliate.desktop" <<EOL
[Desktop Entry]
Name=Foliate
Exec=flatpak run com.github.johnfactotum.Foliate
Icon=com.github.johnfactotum.Foliate
Type=Application
Categories=Office;Viewer;
Terminal=false
EOL

cat > "$DESKTOP/Okular.desktop" <<EOL
[Desktop Entry]
Name=Okular
Exec=okular
Icon=okular
Type=Application
Categories=Office;Viewer;
Terminal=false
EOL

cat > "$DESKTOP/Zathura.desktop" <<EOL
[Desktop Entry]
Name=Zathura
Exec=zathura
Icon=accessories-text-editor
Type=Application
Categories=Office;Viewer;
Terminal=true
EOL

chmod +x "$DESKTOP"/*.desktop

log "INSTALL COMPLETE — LAUNCHERS READY"
