#!/usr/bin/env bash
set -euo pipefail

# Instala el autostart con la ruta real de este repo, para que funcione en
# cualquier equipo aunque el directorio no sea el mismo.

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/autostart/kde-wallpaper-accent.desktop"
mkdir -p "$HOME/.config/autostart"

sed "s|/home/juanrueda/kde-wallpaper-accent|$ROOT|" \
  "$ROOT/kde-wallpaper-accent.desktop" > "$DEST"

chmod +x "$ROOT/autostart-wrapper.sh" "$ROOT/sync-video-color.sh"

echo "Autostart instalado: $DEST"
echo "Se aplicará el color del último vídeo al iniciar sesión."
echo
echo "Para quitarlo: rm '$DEST'"
