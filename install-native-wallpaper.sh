#!/usr/bin/env bash
set -euo pipefail

# Cambia el fondo a una imagen nativa (org.kde.image), necesaria para que Plasma
# extraiga el color de acento. No instala nada; usa plasma-apply-wallpaperimage.

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <ruta-a-imagen>" >&2
  echo "Ejemplo: $0 ~/Pictures/wallpaper.jpg" >&2
  exit 1
fi

IMG="$1"
if [[ ! -f "$IMG" ]]; then
  echo "No existe: $IMG" >&2
  exit 1
fi

TS=$(date +%Y%m%d-%H%M%S)
cp "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
   "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.bak-$TS" 2>/dev/null || true

plasma-apply-wallpaperimage "$IMG"

echo "Fondo aplicado: $IMG"
echo "Copia de seguridad: ~/.config/plasma-org.kde.plasma.desktop-appletsrc.bak-$TS"
echo
echo "Comprueba el color de acento en ~/.config/kdeglobals tras cambiar de fondo."
