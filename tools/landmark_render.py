"""Render every LandmarkShape silhouette straight from the Swift source.

Transpiles the switch cases in LandmarkShape.swift into the DSL in
landmark_preview.py and rasterizes each one, so the art can be reviewed without a
Mac. Run it after touching any landmark:

    python3 tools/landmark_render.py            # all kinds -> sheet_*.png
    python3 tools/landmark_render.py mosque     # just one

Watch for WHITE HOLES. Under even-odd fill any overlap between two subpaths is a
hole, so shapes must abut. That single rule accounts for nearly every landmark bug
found so far: domes sliced by their drums, naves punched through towers, terraces
turned into white stripes."""
import math, re, sys
from landmark_preview import Path, render, ASPECT, contact_sheet, W, H

import os
SRC = os.path.join(os.path.dirname(__file__), "..",
                   "Sources/Views/Components/LandmarkShape.swift")

# ---------------------------------------------------------------- helpers (ported)
def tower(p, cx):
    for a in [(cx-0.035, 0.79, cx-0.015, 0.13), (cx+0.015, 0.79, cx+0.035, 0.13),
              (cx-0.035, 0.16, cx+0.035, 0.13), (cx-0.035, 0.49, cx+0.035, 0.45)]:
        p.rect(*a)

def cable(p, frm, to, dip):
    ctrl = ((frm[0]+to[0])/2, max(frm[1], to[1]) + dip)
    th = 0.012
    p.move(frm[0], frm[1])
    p.quad(to[0], to[1], ctrl[0], ctrl[1])
    p.quad(frm[0], frm[1]+th, ctrl[0], ctrl[1]+th)
    p.close()

def sail(p, baseL, baseR, peakY):
    p.move(baseR, 0.80)
    p.quad(baseL+0.02, peakY, baseR, peakY+0.12)
    p.quad(baseL, 0.80, baseL-0.01, 0.80)
    p.close()

def onionTower(p, cx, baseY, domeTop, width, tall):
    half = width/2
    shaftTop = domeTop + (0.16 if tall else 0.13)
    p.poly([(cx-half, baseY), (cx+half, baseY), (cx+half, shaftTop), (cx-half, shaftTop)])
    p.move(cx-half, shaftTop)
    p.quad(cx, domeTop, cx-half-0.02, shaftTop-0.05)
    p.quad(cx+half, shaftTop, cx+half+0.02, shaftTop-0.05)
    p.close()
    p.poly([(cx-0.008, domeTop), (cx+0.008, domeTop), (cx, domeTop-0.06)])

def palm(p, baseX, topX, topY):
    p.move(baseX-0.012, 1.0)
    p.quad(topX-0.006, topY, baseX-0.05, 0.6)
    p.line(topX+0.006, topY)
    p.quad(baseX+0.012, 1.0, baseX-0.03, 0.6)
    p.close()
    for deg in [200, 235, 270, 305, 340, 160, 20]:
        a = deg*math.pi/180
        L = 0.16
        tip = (topX + math.cos(a)*L, topY - math.sin(a)*L*1.2)
        mid = (topX + math.cos(a)*L*0.5, topY - math.sin(a)*L*0.5 - 0.03)
        p.move(topX, topY)
        p.quad(tip[0], tip[1], mid[0], mid[1])
        p.quad(topX+0.012, topY, mid[0]+0.01, mid[1]+0.03)
        p.close()

def archHole(p, x0, x1, baseY, springY, apexY):
    mid = (x0+x1)/2
    p.move(x0, baseY); p.line(x0, springY)
    p.quad(x1, springY, mid, apexY)
    p.line(x1, baseY); p.close()

def domeHalf(p, cx, baseY, rx, height):
    p.move(cx-rx, baseY)
    p.quad(cx+rx, baseY, cx, baseY - height*2)
    p.close()

def bandArch(p, frm, to, peakY, thickness):
    ctrl = ((frm[0]+to[0])/2, peakY)
    p.move(frm[0], frm[1])
    p.quad(to[0], to[1], ctrl[0], ctrl[1])
    p.quad(frm[0], frm[1], ctrl[0], ctrl[1]+thickness)
    p.close()

def bar(p, a, b, th):
    dx, dy = b[0]-a[0], b[1]-a[1]
    L = max(0.0001, math.hypot(dx, dy))
    nx, ny = -dy/L*th, dx/L*th
    p.poly([(a[0]+nx, a[1]+ny), (b[0]+nx, b[1]+ny), (b[0]-nx, b[1]-ny), (a[0]-nx, a[1]-ny)])

def archY(x, frm, to, peak):
    mid = (frm+to)/2; half = (to-frm)/2
    t = (x-mid)/half
    base = 0.70
    return base - (base-peak)*(1 - t*t)

def superTree(p, cx, topY):
    p.poly([(cx-0.018, 1.0), (cx+0.018, 1.0), (cx+0.05, topY), (cx-0.05, topY)])
    for deg in [140.0, 115, 90, 65, 40]:
        a = deg*math.pi/180
        bar(p, (cx, topY), (cx + math.cos(a)*0.13, topY - math.sin(a)*0.15), 0.006)

def spikes(p, cx, cy, r, count):
    for i in range(count):
        a = math.pi * (0.15 + 0.7*i/(count-1))
        p.poly([(cx + math.cos(a)*r*1.6, cy - math.sin(a)*r*1.6),
                (cx + math.cos(a+0.16)*r*0.5, cy - math.sin(a+0.16)*r*0.5),
                (cx + math.cos(a-0.16)*r*0.5, cy - math.sin(a-0.16)*r*0.5)])

def domeCap(p, cx, baseY, halfW, apexY, flat=0.016):
    k = (baseY - apexY) * 0.78
    p.move(cx - halfW, baseY)
    p.quad(cx - flat, apexY, cx - halfW, baseY - k)
    p.line(cx + flat, apexY)
    p.quad(cx + halfW, baseY, cx + halfW, baseY - k)
    p.close()

def onionCap(p, cx, baseY, halfW, apexY, flat=0.013):
    k = (baseY - apexY) * 0.62
    p.move(cx - halfW, baseY)
    p.quad(cx - flat, apexY, cx - halfW - 0.035, baseY - k)
    p.line(cx + flat, apexY)
    p.quad(cx + halfW, baseY, cx + halfW + 0.035, baseY - k)
    p.close()

def needle(p, cx, baseY, halfW, tipY):
    p.poly([(cx - halfW, baseY), (cx + halfW, baseY), (cx, tipY)])

def spikyDome(p, cx, rx, base, height, spikes):
    p.move(cx - rx, base)
    for i in range(spikes):
        t0 = float(i) / float(spikes)
        t1 = (float(i) + 0.5) / float(spikes)
        a0 = math.pi * (1 - t0)
        a1 = math.pi * (1 - t1)
        vx = cx + rx * math.cos(a0)
        vy = base - height * math.sin(a0)
        p.line(vx, vy)
        sx = cx + rx * math.cos(a1)
        sy = base - height * math.sin(a1)
        sl = 0.010 + 0.026 * math.sin(a1)
        nx = math.cos(a1); ny = -math.sin(a1)
        p.line(sx + nx * sl, sy + ny * sl)
    p.line(cx + rx, base)
    p.close()

# ---------------------------------------------------------------- transpiler
def join_calls(lines):
    """Join continuation lines so each statement has balanced parens/brackets."""
    out, buf, depth, indent = [], "", 0, 0
    for ln in lines:
        code = re.sub(r'//.*$', '', ln).rstrip()
        if not code.strip():
            continue
        if not buf:
            indent = len(code) - len(code.lstrip())
        buf = (buf + " " + code.strip()) if buf else code
        depth += code.count("(") + code.count("[") - code.count(")") - code.count("]")
        if depth <= 0:
            out.append((indent, buf.strip()))
            buf, depth = "", 0
    return out

def to_py(stmt):
    s = stmt
    # rounded rects -> plain rects; close enough to review the silhouette
    s = re.sub(r'p\.addRoundedRect\(in:\s*CGRect\(x:\s*rect\.minX \+ (.+?) \* W,\s*y:\s*rect\.minY \+ (.+?) \* H,\s*width:\s*(.+?) \* W,\s*height:\s*(.+?) \* H\).*\)',
               r'p.rect(\1, \2, (\1)+(\3), (\2)+(\4))', s)
    s = re.sub(r'\s+as\s+\[[^\]]*\]', '', s)          # `[0.3, 0.7] as [CGFloat]`
    s = re.sub(r'\btrue\b', 'True', s)
    s = re.sub(r'\bfalse\b', 'False', s)
    s = s.replace("!(", "not (")
    s = s.replace("&p, pt: pt,", "p,").replace("&p, pt: pt", "p")
    s = re.sub(r'\bDouble\.pi\b', 'math.pi', s)
    s = re.sub(r'(?<![\w.])\.pi\b', 'math.pi', s)
    s = re.sub(r'\bCGFloat\(', 'float(', s)
    s = re.sub(r'\bDouble\(', 'float(', s)
    s = re.sub(r'\bInt\(', 'int(', s)
    # p.* path ops
    s = re.sub(r'p\.move\(to:\s*pt\(([^,]+),\s*([^)]+)\)\)', r'p.move(\1, \2)', s)
    s = re.sub(r'p\.addLine\(to:\s*pt\(([^,]+),\s*([^)]+)\)\)', r'p.line(\1, \2)', s)
    s = re.sub(r'p\.addQuadCurve\(to:\s*pt\(([^,]+),\s*([^)]+)\),\s*control:\s*pt\(([^,]+),\s*([^)]+)\)\)',
               r'p.quad(\1, \2, \3, \4)', s)
    s = s.replace("p.closeSubpath()", "p.close()")
    # shape helpers (placeholders so `circle(` doesn't clobber roundCircle/onCircle)
    s = s.replace("roundCircle(", "@RC@(").replace("onCircle(", "@OC@(")
    s = re.sub(r'(?<![\w.])circle\(', 'p.circle(', s)
    s = re.sub(r'(?<![\w.])rectShape\(', 'p.rect(', s)
    s = re.sub(r'(?<![\w.])poly\(', 'p.poly(', s)
    s = s.replace("@RC@(", "p.round_circle(").replace("@OC@(", "p.on_circle(")
    # Swift tuple access: c.0 -> c[0]
    s = re.sub(r'\b([a-zA-Z_]\w*)\.([01])\b', r'\1[\2]', s)
    # ranges BEFORE control flow, so the loop colon isn't swallowed
    s = re.sub(r'(\S+)\.\.<(\S+?)(\s*\{)', r'range(\1, \2)\3', s)
    s = re.sub(r'range\(0,\s*', 'range(', s)
    # let/var + type annotations
    s = re.sub(r'^\s*(let|var)\s+', '', s)
    # multi-declaration: `fx: CGFloat = 0.5, fy: CGFloat = 0.4` -> separate statements
    s = re.sub(r'(\w+)\s*:\s*CGFloat\s*=', r'\1 =', s)
    s = re.sub(r'^(\w+)\s*:\s*\[?[\w\s,()\[\]<>?]+\]?\s*=', r'\1 =', s)
    # ternary
    s = re.sub(r'=\s*(.+?)\s*\?\s*(.+?)\s*:\s*(.+)$', r'= (\2 if \1 else \3)', s)
    # remaining Swift arg labels  foo(a: 1, b: 2) -> foo(1, 2)
    s = re.sub(r'([(,]\s*)[a-zA-Z_]\w*:\s*(?!:)', r'\1', s)
    # control flow — single-line brace bodies and `where` clauses first
    s = re.sub(r'^for\s+(.+?)\s+in\s+(.+?)\s+where\s+(.+?)\s*\{\s*(.+?)\s*\}$',
               r'for \1 in \2:\n    if \3:\n        \4', s)
    s = re.sub(r'^(for|if|while)\s+(.+?)\s*\{\s*(.+?)\s*\}$', r'\1 \2:\n    \3', s)
    s = re.sub(r'^for\s+(.+?)\s+in\s+(.+?)\s*\{$', r'for \1 in \2:', s)
    s = re.sub(r'^while\s+(.+?)\s*\{$', r'while \1:', s)
    s = re.sub(r'^if\s+(.+?)\s*\{$', r'if \1:', s)
    s = re.sub(r'^\}\s*else\s+if\s+(.+?)\s*\{$', r'elif \1:', s)
    s = re.sub(r'^\}\s*else\s*\{$', 'else:', s)
    s = s.replace("&&", "and").replace("||", "or")
    s = re.sub(r'\.squareRoot\(\)', '**0.5', s)
    s = re.sub(r'\bcos\(', 'math.cos(', s).replace("math.math.", "math.")
    s = re.sub(r'\bsin\(', 'math.sin(', s).replace("math.math.", "math.")
    return s

def build_cases():
    src = open(SRC).read()
    body = src[src.index("switch kind {"):]
    lines = body.splitlines()[1:]
    cases, cur, curbody = {}, None, []
    for ln in lines:
        m = re.match(r'\s*case (\.[\w, .]+):\s*$', ln)
        if m:
            if cur: cases[tuple(cur)] = curbody
            names = [n.strip()[1:] for n in m.group(1).split(",")]
            cur, curbody = names, []
            continue
        if re.match(r'^        \}\s*$', ln):
            break
        if cur is not None:
            curbody.append(ln)
    if cur: cases[tuple(cur)] = curbody
    return cases

SKIP = {"leaningTower", "skyline"}     # hand-handled: rotated path / validated PRNG

def render_kind(names, body):
    p = Path()
    stmts = join_calls(body)
    if not stmts:
        return p
    base = min(i for i, _ in stmts)
    pysrc, stack = [], []
    for indent, stmt in stmts:
        py = to_py(stmt)
        if py.strip() in ("}", ""):
            continue
        lvl = (indent - base) // 4
        # `a = 1, b = 2, c = 3` (Swift multi-let) -> one statement per line
        if "\n" in py:
            for sub in py.split("\n"):
                pysrc.append("    " * lvl + sub)
        elif py.count(" = ") > 1 and "(" not in py.split("=")[0]:
            for part in re.split(r',\s*(?=\w+\s*=)', py):
                pysrc.append("    " * lvl + part.strip())
        else:
            pysrc.append("    " * lvl + py)
    code = "\n".join(pysrc)
    env = dict(p=p, math=math, ASPECT=ASPECT, bar=bar, bandArch=bandArch, tower=tower,
               cable=cable, sail=sail, onionTower=onionTower, palm=palm, archHole=archHole,
               domeHalf=domeHalf, domeCap=domeCap, onionCap=onionCap, needle=needle, spikyDome=spikyDome, superTree=superTree, spikes=spikes, archY=archY,
               abs=abs, min=min, max=max, range=range, float=float, int=int, len=len)
    exec(code, env)
    return p

if __name__ == "__main__":
    cases = build_cases()
    want = sys.argv[1:] if len(sys.argv) > 1 else None
    items, failed = [], []
    for names, body in cases.items():
        for n in names:
            if want and n not in want:
                continue
            if n in SKIP:
                continue
            try:
                items.append((n, render(render_kind(names, body))))
            except Exception as e:
                failed.append((n, f"{type(e).__name__}: {e}"))
    print("rendered:", len(items), "failed:", len(failed))
    for n, e in failed:
        print("  FAIL", n, "-", e)
    for i in range(0, len(items), 6):
        contact_sheet(items[i:i+6], cols=3).save(f"sheet_{i//6}.png")
    print("sheets:", (len(items) + 5) // 6)
