#!/usr/bin/env bash
set -euo pipefail

# Sincroniza el color de acento de Plasma con el vídeo que está usando
# Smart Video Wallpaper Reborn. Sin demonio: se ejecuta bajo demanda tras
# cambiar de vídeo en el panel del plugin.

ROOT="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
CACHE="$ROOT/.color-cache.tsv"
TMP="$(mktemp -d -p /tmp/opencode)"
trap 'rm -rf "$TMP"' EXIT

# El plugin guarda la ruta del vídeo activo en LastVideo (o LastVideoNight en
# modo nocturno). Tomamos la primera coincidencia del containment principal.
video=$(grep -m1 '^LastVideo=' "$CFG" 2>/dev/null | cut -d= -f2- || true)
if [[ -z "$video" ]]; then
  video=$(grep -m1 '^LastVideoNight=' "$CFG" 2>/dev/null | cut -d= -f2- || true)
fi

if [[ -z "$video" ]]; then
  echo "No se encontró vídeo activo en $CFG" >&2
  exit 1
fi

# Quitar el prefijo file:// y decodificar %20, %26, etc.
path=${video#file://}
path=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$path")

if [[ ! -f "$path" ]]; then
  echo "No existe el vídeo: $path" >&2
  exit 1
fi

echo "Vídeo: $path"

# La caché guarda 'ruta<TAB>r,g,b'. Usamos la ruta como clave y comprobamos
# que el archivo siga existiendo; si el vídeo cambió, recalculamos.
rgb=$(awk -F '\t' -v p="$path" '$1 == p { print $2; exit }' "$CACHE" 2>/dev/null || true)

if [[ -n "$rgb" ]]; then
  echo "Color (caché): $rgb"
else
  # Tres frames repartidos por el vídeo (uno cada 10 s) para no depender de una
  # sola escena oscura. Los vídeos cortos darán menos frames y eso es correcto.
  ffmpeg -nostdin -v error -i "$path" -vf "fps=1/10,scale=160:-1" \
    -frames:v 3 -y "$TMP/frame%02d.jpg" || true
  if ! ls "$TMP"/frame*.jpg >/dev/null 2>&1; then
    ffmpeg -nostdin -v error -i "$path" -frames:v 1 -y "$TMP/frame00.jpg"
  fi

  rgb=$(python3 "$ROOT/extract_color.py" "$TMP"/frame*.jpg)

  # Escribir de forma atómica para no corromper la caché si se corta el script.
  touch "$CACHE"
  if ! awk -F '\t' -v p="$path" '$1 == p { found = 1 } END { exit !found }' "$CACHE"; then
    printf '%s\t%s\n' "$path" "$rgb" >>"$CACHE"
  else
    awk -F '\t' -v p="$path" -v c="$rgb" \
      '$1 == p { print p "\t" c; next } { print }' "$CACHE" >"$TMP/cache.new"
    mv "$TMP/cache.new" "$CACHE"
  fi
  echo "Color extraído: $rgb"
fi

read -r r g b <<<"${rgb//,/ }"

# ARGB para el servicio DBus de Plasma (0xAARRGGBB).
argb=$(( (255 << 24) | (r << 16) | (g << 8) | b ))
python3 - "$argb" <<'PY'
import dbus, sys
bus = dbus.SessionBus()
obj = bus.get_object('org.kde.plasmashell.accentColor', '/AccentColor')
iface = dbus.Interface(obj, 'org.kde.plasmashell.accentColor')
iface.setAccentColor(dbus.UInt32(int(sys.argv[1])))
PY

echo "Acento aplicado: $rgb"
echo "Comprueba: grep AccentColor ~/.config/kdeglobals"
