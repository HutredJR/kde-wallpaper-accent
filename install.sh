#!/usr/bin/env bash
set -euo pipefail

# Instalador interactivo: aplica acento desde el wallpaper + tinte suave en Plasma 6.
# Solo escribe en ~/.config y ~/.local/share. No usa sudo.

TS=$(date +%Y%m%d-%H%M%S)
TINT="${TINT:-0.30}"

echo "== kde-wallpaper-accent =="
echo " Plasma: $(plasmashell --version 2>/dev/null || echo 'no detectado')"
echo " Sesión: ${XDG_SESSION_TYPE:-desconocida}"
echo

current_scheme=$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || echo "Darkly")
if [[ -z "$current_scheme" ]]; then
  current_scheme="Darkly"
fi

src=""
for candidate in \
  "/usr/share/color-schemes/${current_scheme}.colors" \
  "$HOME/.local/share/color-schemes/${current_scheme}.colors" \
  /usr/share/color-schemes/Darkly.colors; do
  if [[ -f "$candidate" ]]; then
    src="$candidate"
    break
  fi
done

if [[ -z "$src" ]]; then
  echo "No se encontró el esquema base '$current_scheme'. Abortando." >&2
  exit 1
fi

new_scheme="${current_scheme}Acento"
dest="$HOME/.local/share/color-schemes/${new_scheme}.colors"

echo "Esquema base : $src"
echo "Esquema nuevo: $dest"
echo "Tinte        : $TINT"
echo

read -r -p "¿Continuar? [s/N] " answer
[[ "$answer" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }

mkdir -p "$HOME/.local/share/color-schemes"
cp "$HOME/.config/kdeglobals" "$HOME/.config/kdeglobals.bak-$TS" 2>/dev/null || true
[[ -f "$dest" ]] && cp "$dest" "$dest.bak-$TS"

cp "$src" "$dest"
sed -i "s/^ColorScheme=.*/ColorScheme=$new_scheme/" "$dest"
sed -i "s/^Name=.*/Name=${current_scheme} Acento/" "$dest"
sed -i "/^shadeSortColumn=.*/a TintFactor=$TINT\naccentActiveTitlebar=true" "$dest"

kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper true
plasma-apply-colorscheme "$new_scheme"

echo
echo "Listo. Esquema activo: $new_scheme"
echo

# Plasma solo extrae el acento de los plugins nativos de imagen. Un plugin de
# terceros (por ejemplo un reproductor de vídeo) calla ese aviso y el color
# nunca cambia. Detectar el caso y ofrecer la corrección.
active_plugin=$(grep -m1 '^wallpaperplugin=' \
  "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" 2>/dev/null \
  | cut -d= -f2 || true)

if [[ -n "$active_plugin" && "$active_plugin" != org.kde.image && \
      "$active_plugin" != org.kde.slideshow && "$active_plugin" != org.kde.color && \
      "$active_plugin" != org.kde.potd ]]; then
  echo "AVISO: tu fondo usa el plugin '$active_plugin'."
  echo "Plasma NO puede extraer el color de acento de plugins de terceros."
  echo "Por eso el color no cambiará aunque todo esté bien configurado."
  echo
  read -r -p "¿Cambiar ahora a una imagen nativa? Necesito la ruta de una imagen [s/N] " fix
  if [[ "$fix" =~ ^[sS]$ ]]; then
    read -r -p "Ruta de la imagen: " img
    if [[ -f "$img" ]]; then
      cp "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
         "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.bak-$TS"
      plasma-apply-wallpaperimage "$img"
      echo "Fondo nativo aplicado: $img"
    else
      echo "No existe '$img'. Puedes ejecutar install-native-wallpaper.sh más tarde."
    fi
  else
    echo "Puedes ejecutar install-native-wallpaper.sh <imagen> cuando quieras."
  fi
fi

echo
echo "Abre Ajustes del sistema → Colores y comprueba que está seleccionado '$current_scheme Acento'."
echo "Copia de seguridad: ~/.config/kdeglobals.bak-$TS"
