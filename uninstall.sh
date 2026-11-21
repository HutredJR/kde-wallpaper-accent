#!/usr/bin/env bash
set -euo pipefail

echo "== Desinstalar kde-wallpaper-accent =="

read -r -p "¿Restaurar el esquema y quitar el tinte? [s/N] " answer
[[ "$answer" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }

# Buscar copias de seguridad y usar la más reciente.
backup=$(ls -1t "$HOME"/.config/kdeglobals.bak-* 2>/dev/null | head -1 || true)
if [[ -n "$backup" ]]; then
  cp "$backup" "$HOME/.config/kdeglobals"
  echo "Restaurado: $backup"
else
  kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
  echo "No se encontró copia; se desactivó el acento desde el fondo."
fi

# Borrar esquemas generados por este instalador.
find "$HOME/.local/share/color-schemes" -maxdepth 1 -name '*Acento.colors' -print -delete 2>/dev/null || true

# Volver a aplicar un esquema estándar para refrescar la sesión.
plasma-apply-colorscheme Darkly 2>/dev/null || true

echo "Hecho. Puede que haya que cerrar y abrir las aplicaciones para ver los colores."
