#!/usr/bin/env bash
set -euo pipefail

# Espera a que el servicio de acento de Plasma esté disponible y aplica el
# color del último vídeo. Se usa desde el archivo .desktop de autostart.

ROOT="$(cd "$(dirname "$0")" && pwd)"

for i in $(seq 1 30); do
  if qdbus6 org.kde.plasmashell.accentColor /AccentColor >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Espera además a que el plugin de vídeo haya escrito LastVideo.
for i in $(seq 1 30); do
  if grep -q '^LastVideo=' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" 2>/dev/null; then
    break
  fi
  sleep 1
done

"$ROOT/sync-video-color.sh" >/dev/null 2>&1 || true
