#!/usr/bin/env bash
# ---------- install_battlenet_prereqs_rocky.sh (generated) ------------------
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)!" >&2
  exit 1
fi
dnf -y upgrade

RHELVER=$(rpm -E '%rhel')
if [[ $RHELVER -ge 9 ]]; then
  dnf config-manager --set-enabled crb
else
  dnf config-manager --set-enabled powertools
fi

dnf -y install epel-release
dnf -y install \
  "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$RHELVER.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$RHELVER.noarch.rpm"

dnf -y groupinstall "Development Tools"
dnf -y install \
  wine wine-wow64 winetricks lutris gamemode steam \
  vkd3d vulkan-loader mesa-dri-drivers mesa-vulkan-drivers \
  mesa-libGL mesa-libGLU vulkan-loader.i686 vulkan-tools \
  mesa-libGL.i686 mesa-dri-drivers.i686 gamemode.i686 \
  libcurl.i686 libXcomposite.i686 libXcursor.i686 libXi.i686 libXrandr.i686

read -rp "Install Nvidia proprietary driver (y/N)? " ANS
if [[ ${ANS,,} == y ]]; then
  dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda
fi

dnf -y install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub net.davidotek.pupgui2

cat >/usr/local/bin/proton-ge-update <<'EOF'
#!/usr/bin/env bash
flatpak run net.davidotek.pupgui2 --install-latest
EOF
chmod +x /usr/local/bin/proton-ge-update

echo -e "\n🎮  Prerequisites complete.  Log out/in before gaming!"
# ---------------------------------------------------------------------------
