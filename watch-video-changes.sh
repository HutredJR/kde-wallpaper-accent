#!/usr/bin/env bash
set -euo pipefail

# Opcional: vigila el config del plugin de vídeo y aplica el color solo cuando
# cambia LastVideo. No captura la pantalla ni hace polling de imagen: inotify
# duerme hasta que hay un evento real. Coste prácticamente nulo.

ROOT="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

if ! command -v inotifywait >/dev/null; then
  echo "Se necesita inotify-tools (inotifywait)." >&2
  echo "  sudo apt install inotify-tools" >&2
  exit 1
fi

echo "Vigilando cambios de vídeo en $CFG"
echo "Ctrl+C para detener."

while true; do
  inotifywait -q -e close_write,move_self "$CFG" >/dev/null 2>&1 || continue
  sleep 1
  "$ROOT/sync-video-color.sh" || echo "No se pudo sincronizar; reintentaré en el próximo cambio."
done
