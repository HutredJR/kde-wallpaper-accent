#!/usr/bin/env python3
"""Extrae un color de acento representativo de una o varias imágenes.

Prioriza colores vibrantes y con brillo suficiente, parecido al algoritmo de
Plasma: no se limita al promedio, que casi siempre da grisáceo. Si el vídeo es
oscuro, aclara el resultado para que el acento siga siendo visible.

Imprime 'r,g,b' por stdout.
"""

import sys
from collections import Counter

from PIL import Image


def vibrancia(rgb):
    r, g, b = (c / 255 for c in rgb)
    mx, mn = max(r, g, b), min(r, g, b)
    value = mx
    saturation = 0 if mx == 0 else (mx - mn) / mx
    return saturation * value * (1 - abs(value - 0.65))


def main():
    if len(sys.argv) < 2:
        print("Uso: extract_color.py <imagen> [imagen...]", file=sys.stderr)
        sys.exit(1)

    buckets = Counter()
    for path in sys.argv[1:]:
        img = Image.open(path).convert("RGB")
        img.thumbnail((80, 80))
        for p in img.getdata():
            # Cuantizar a 16 niveles por canal para agrupar tonos similares.
            buckets[tuple((c // 16) * 16 + 8 for c in p)] += 1

    best, best_score = None, -1
    for color, count in buckets.items():
        if max(color) < 55 or min(color) > 235:
            continue
        score = count * (0.25 + vibrancia(color))
        if score > best_score:
            best, best_score = color, score

    if best is None:
        # Vídeo muy oscuro: elegir el bucket más brillante disponible.
        best = max(buckets, key=lambda c: sum(c)) if buckets else (100, 120, 160)

    # Aclarar si el tono es demasiado oscuro para servir de acento.
    if max(best) < 100:
        factor = 110 / max(best)
        best = tuple(min(255, int(c * factor)) for c in best)

    print(f"{best[0]},{best[1]},{best[2]}")


if __name__ == "__main__":
    main()
