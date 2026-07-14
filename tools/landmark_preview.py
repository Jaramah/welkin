"""Preview LandmarkShape silhouettes without a Mac.

There is no simulator on the machine this app is largely developed from, so the
landmark vector art was being written blind and only checked when a screenshot
came back. That is how the Merlion shipped as an unrecognisable blob.

This is a faithful Python port of LandmarkShape's drawing DSL, so silhouettes can be
looked at before they ship. Even-odd fill, same normalized coordinate space,
same frame aspect the app uses (LandmarkSceneView: ~353pt wide x 172pt tall)."""
import math
import numpy as np
from PIL import Image

W_PT, H_PT = 353.0, 172.0          # the real frame
SCALE = 2.4
W, H = int(W_PT * SCALE), int(H_PT * SCALE)
ASPECT = H_PT / W_PT               # what the Swift `aspect` helper uses


class Path:
    def __init__(self):
        self.subpaths = []         # each: list of (x, y) in normalized units
        self._cur = None

    # --- primitives mirroring the Swift helpers -------------------------------
    def move(self, x, y):
        self._cur = [(x, y)]

    def line(self, x, y):
        self._cur.append((x, y))

    def quad(self, x, y, cx, cy, steps=24):
        x0, y0 = self._cur[-1]
        for i in range(1, steps + 1):
            t = i / steps
            mt = 1 - t
            self._cur.append((mt * mt * x0 + 2 * mt * t * cx + t * t * x,
                              mt * mt * y0 + 2 * mt * t * cy + t * t * y))

    def close(self):
        if self._cur:
            self.subpaths.append(self._cur)
            self._cur = None

    def poly(self, pts):
        self.move(*pts[0])
        for c in pts[1:]:
            self.line(*c)
        self.close()

    def rect(self, x0, y0, x1, y1):
        self.poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])

    def circle(self, cx, cy, r, steps=48):
        """Swift `circle`: scales r by W and H separately -> squashes in a wide frame."""
        pts = [(cx + r * math.cos(2 * math.pi * i / steps),
                cy + r * math.sin(2 * math.pi * i / steps)) for i in range(steps)]
        self.poly(pts)

    def round_circle(self, cx, cy, r, steps=48):
        """Swift `roundCircle`: x-radius compressed by aspect so it stays round."""
        rx = r * ASPECT
        pts = [(cx + rx * math.cos(2 * math.pi * i / steps),
                cy + r * math.sin(2 * math.pi * i / steps)) for i in range(steps)]
        self.poly(pts)

    def on_circle(self, cx, cy, r, angle):
        return (cx + r * math.cos(angle) * ASPECT, cy + r * math.sin(angle))

    def bar(self, a, b, w):
        """Swift `bar`: a thick line from a to b."""
        (ax, ay), (bx, by) = a, b
        dx, dy = bx - ax, by - ay
        L = math.hypot(dx / ASPECT, dy) or 1e-9
        nx, ny = -dy / L * w * ASPECT, dx / L * w / ASPECT * ASPECT
        nx, ny = -(dy / L) * w * ASPECT, (dx / L) * w
        self.poly([(ax + nx, ay + ny), (bx + nx, by + ny),
                   (bx - nx, by - ny), (ax - nx, ay - ny)])


def render(path, bg=(150, 170, 185), fg=(15, 18, 24), pad_note=None):
    """Rasterize with the EVEN-ODD rule: a pixel is filled if a ray to the right
    crosses an odd number of edges across all subpaths."""
    edges = []
    for sp in path.subpaths:
        n = len(sp)
        for i in range(n):
            x0, y0 = sp[i]
            x1, y1 = sp[(i + 1) % n]
            if y0 != y1:
                edges.append((x0, y0, x1, y1))
    if not edges:
        return Image.new("RGB", (W, H), bg)
    E = np.array(edges, dtype=np.float64)
    x0, y0, x1, y1 = E[:, 0], E[:, 1], E[:, 2], E[:, 3]

    px = (np.arange(W) + 0.5) / W
    py = (np.arange(H) + 0.5) / H
    PX = px[None, :, None]
    PY = py[:, None, None]

    cond = ((y0 <= PY) & (y1 > PY)) | ((y1 <= PY) & (y0 > PY))
    t = np.where(y1 != y0, (PY - y0) / np.where(y1 != y0, y1 - y0, 1), 0)
    xint = x0 + t * (x1 - x0)
    crossings = (cond & (xint > PX)).sum(axis=2)
    inside = (crossings % 2) == 1

    img = np.zeros((H, W, 3), dtype=np.uint8)
    img[:] = bg
    img[inside] = fg
    return Image.fromarray(img)


def contact_sheet(items, cols=2, label_h=26):
    """items: list of (title, PIL.Image)"""
    from PIL import ImageDraw
    rows = (len(items) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * W, rows * (H + label_h)), (30, 32, 38))
    d = ImageDraw.Draw(sheet)
    for i, (title, im) in enumerate(items):
        r, c = divmod(i, cols)
        y = r * (H + label_h)
        sheet.paste(im, (c * W, y + label_h))
        d.text((c * W + 8, y + 6), title, fill=(235, 235, 240))
    return sheet
