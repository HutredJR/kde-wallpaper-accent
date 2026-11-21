# kde-wallpaper-accent

Haz que el acento de color de **KDE Plasma 6** —selección de archivos y carpetas,
resaltado al pasar el ratón, sliders y barras de título— siga automáticamente el
color del fondo de pantalla, al estilo de Omarchy.

Inspirado en la idea de "pick a theme, change everything", pero sin cambiar de
distribución ni de compositor: funciona sobre Plasma 6 (KDE neon, Ubuntu, etc.).

## Qué hace

1. Crea una **copia local** del esquema de color activo con `TintFactor` y
   `accentActiveTitlebar`, para que el color del fondo se mezcle en la interfaz.
2. Activa `accentColorFromWallpaper=true` para que Plasma extraiga el color del
   fondo tras cada cambio.
3. (Opcional) Cambia el fondo a una imagen nativa, necesaria porque los plugins
   de wallpaper de terceros —por ejemplo reproductores de vídeo— **no exponen
   el acento a Plasma** y hacen que el color nunca se actualice.

Coste: cero procesos añadidos. Es solo un esquema de colores, sin demonios ni sondeo.

## Requisitos

- KDE Plasma 6.x (probado en 6.8.2, KDE neon 24.04).
- Sesión Wayland o X11.
- No se instala nada globalmente: todo queda en `~/.config` y `~/.local/share`.

## Uso

```bash
git clone https://github.com/TU_USUARIO/kde-wallpaper-accent.git
cd kde-wallpaper-accent
./install.sh
```

El instalador pide confirmación antes de tocar nada y hace copia de seguridad
de `kdeglobals` y de la configuración de fondos. Para desinstalar:

```bash
./uninstall.sh
```

## Archivos afectados

- `~/.config/kdeglobals` — acento y esquema activo.
- `~/.local/share/color-schemes/<Esquema>Acento.colors` — esquema derivado.
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` — solo si se elige la opción
  de fondo nativo.

## Vídeos: `sync-video-color.sh`

Plasma **no extrae el acento** de plugins de wallpaper de terceros, incluido
`Smart Video Wallpaper Reborn`. Para que el color siga a tus vídeos sin instalar
nada ni dejar un demonio capturando la pantalla:

```bash
./sync-video-color.sh
```

El script lee el vídeo activo del config del plugin, extrae un frame con
`ffmpeg`, calcula un color vibrante representativo y lo aplica como acento
mediante el servicio DBus de Plasma. Se ejecuta **bajo demanda**, justo después
de cambiar de vídeo en el panel del plugin. Coste cero entre cambios.

Requisitos: `ffmpeg` y `python3-pil` (ya presentes en muchas instalaciones).

Si prefieres automatizarlo sin demonio de captura, el watcher opcional solo
reacciona cuando el plugin escribe `LastVideo` (usa `inotifywait`, que duerme
hasta que hay un evento real):

```bash
./watch-video-changes.sh   # Ctrl+C para detener
```

Para arrancarlo con la sesión, añade una entrada en
`~/.config/autostart/` apuntando a ese script.

## Notas

- La paleta sigue siendo la del esquema original: el tinte mezcla el color del
  fondo, no genera una paleta Material You nueva. Para eso existe
  `kde-material-you-colors`, que añade un demonio y parpadeo al cambiar de fondo.
- El acento solo se extrae de la **pantalla principal**.
- Algunas aplicaciones GTK no siguen el acento del sistema y puede que haya que
  reiniciarlas para ver los colores nuevos.
