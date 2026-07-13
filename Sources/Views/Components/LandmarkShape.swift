import SwiftUI

/// Hand-drawn vector silhouette for each landmark, normalized to its rect
/// (y = 0 top, y = 1 bottom, sitting on the baseline). Fill with `eoFill: true`
/// so inner cut-outs (arches, clock faces) read as holes.
struct LandmarkShape: Shape {
    let kind: LandmarkKind
    /// Seeds the procedural skyline. Same city, same skyline, every launch.
    var seed: Int = 0

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let W = rect.width, H = rect.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * W, y: rect.minY + y * H)
        }
        func poly(_ pts: [(CGFloat, CGFloat)]) {
            guard let f = pts.first else { return }
            p.move(to: pt(f.0, f.1))
            for c in pts.dropFirst() { p.addLine(to: pt(c.0, c.1)) }
            p.closeSubpath()
        }
        func rectShape(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat) {
            poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])
        }
        func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
            p.addEllipse(in: CGRect(x: rect.minX + (cx - r) * W, y: rect.minY + (cy - r) * H,
                                    width: 2 * r * W, height: 2 * r * H))
        }
        // The landmark frame is much wider than it is tall, so `circle` above comes
        // out as a flat oval. Wheels and spheres need to stay actually round, so
        // compress the x-radius by the frame's aspect ratio.
        let aspect = H / max(W, 0.0001)
        func roundCircle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
            let rx = r * aspect
            p.addEllipse(in: CGRect(x: rect.minX + (cx - rx) * W, y: rect.minY + (cy - r) * H,
                                    width: 2 * rx * W, height: 2 * r * H))
        }
        /// A point on a circle of radius `r` about (cx, cy), kept round via `aspect`.
        func onCircle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ angle: Double) -> (CGFloat, CGFloat) {
            (cx + r * CGFloat(cos(angle)) * aspect, cy + r * CGFloat(sin(angle)))
        }

        switch kind {
        case .pyramids:
            poly([(0.02, 1.0), (0.15, 0.66), (0.28, 1.0)])
            poly([(0.52, 1.0), (0.74, 0.46), (0.96, 1.0)])
            poly([(0.10, 1.0), (0.40, 0.28), (0.70, 1.0)])

        case .eiffelTower, .tokyoTower:
            // Outer hourglass silhouette
            poly([
                (0.30, 1.00), (0.405, 0.55), (0.385, 0.55), (0.45, 0.22), (0.435, 0.22),
                (0.475, 0.07), (0.50, 0.00),
                (0.525, 0.07), (0.565, 0.22), (0.55, 0.22), (0.615, 0.55), (0.595, 0.55), (0.70, 1.00),
            ])
            // Platform bars
            rectShape(0.375, 0.55, 0.625, 0.60)
            rectShape(0.44, 0.22, 0.56, 0.25)
            // Arch cut-out between the legs (hole via eoFill)
            p.move(to: pt(0.40, 1.0))
            p.addQuadCurve(to: pt(0.60, 1.0), control: pt(0.50, 0.60))
            p.closeSubpath()

        case .bigBen:
            rectShape(0.42, 1.0, 0.58, 0.30)      // column
            rectShape(0.40, 0.30, 0.60, 0.22)     // belfry
            poly([(0.43, 0.22), (0.57, 0.22), (0.50, 0.02)]) // spire
            circle(0.50, 0.42, 0.052)             // clock face (hole)

        case .goldenGate:
            rectShape(0.02, 0.74, 0.98, 0.79)     // deck
            tower(&p, pt: pt, cx: 0.29)
            tower(&p, pt: pt, cx: 0.71)
            cable(&p, pt: pt, from: (0.29, 0.13), to: (0.71, 0.13), dip: 0.34)   // main span
            cable(&p, pt: pt, from: (0.02, 0.66), to: (0.29, 0.13), dip: 0.02)   // left back-stay
            cable(&p, pt: pt, from: (0.71, 0.13), to: (0.98, 0.66), dip: 0.02)   // right back-stay

        case .spaceNeedle:
            poly([(0.40, 1.0), (0.445, 1.0), (0.505, 0.45), (0.485, 0.45)])  // left leg
            poly([(0.60, 1.0), (0.555, 1.0), (0.495, 0.45), (0.515, 0.45)])  // right leg
            rectShape(0.485, 0.45, 0.515, 0.30)                              // core
            poly([(0.40, 0.32), (0.44, 0.27), (0.56, 0.27), (0.60, 0.32), (0.56, 0.37), (0.44, 0.37)]) // saucer
            rectShape(0.495, 0.30, 0.505, 0.07)                              // spire
            poly([(0.492, 0.07), (0.508, 0.07), (0.50, 0.02)])

        case .sydneyOperaHouse:
            rectShape(0.08, 0.80, 0.92, 0.87)     // podium
            sail(&p, pt: pt, baseL: 0.30, baseR: 0.46, peakY: 0.30)
            sail(&p, pt: pt, baseL: 0.42, baseR: 0.58, peakY: 0.40)
            sail(&p, pt: pt, baseL: 0.54, baseR: 0.70, peakY: 0.33)
            sail(&p, pt: pt, baseL: 0.20, baseR: 0.32, peakY: 0.52)

        case .burjKhalifa:
            poly([
                (0.42, 1.0), (0.42, 0.70), (0.445, 0.70), (0.445, 0.46), (0.465, 0.46),
                (0.465, 0.24), (0.483, 0.24), (0.492, 0.05), (0.50, 0.0),
                (0.508, 0.05), (0.517, 0.24), (0.535, 0.24), (0.535, 0.46), (0.555, 0.46),
                (0.555, 0.70), (0.58, 0.70), (0.58, 1.0),
            ])
            rectShape(0.35, 1.0, 0.42, 0.62)      // left wing
            rectShape(0.58, 1.0, 0.65, 0.62)      // right wing

        case .leaningTower:
            var tower = Path()
            tower.addRect(CGRect(x: rect.minX + 0.44 * W, y: rect.minY + 0.10 * H,
                                 width: 0.12 * W, height: 0.90 * H))
            // tier lines as cut-outs
            for ty in stride(from: 0.22 as CGFloat, to: 0.98, by: 0.14) {
                tower.addRect(CGRect(x: rect.minX + 0.44 * W, y: rect.minY + ty * H,
                                     width: 0.12 * W, height: 0.015 * H))
            }
            let anchor = pt(0.50, 1.0)
            let tilt = CGAffineTransform(translationX: anchor.x, y: anchor.y)
                .rotated(by: -0.13)
                .translatedBy(x: -anchor.x, y: -anchor.y)
            p.addPath(tower.applying(tilt))

        case .tajMahal:
            rectShape(0.38, 0.86, 0.62, 0.55)     // main cube
            p.move(to: pt(0.42, 0.55))            // onion dome
            p.addQuadCurve(to: pt(0.50, 0.28), control: pt(0.40, 0.40))
            p.addQuadCurve(to: pt(0.58, 0.55), control: pt(0.60, 0.40))
            p.closeSubpath()
            poly([(0.49, 0.30), (0.51, 0.30), (0.50, 0.22)]) // finial
            rectShape(0.27, 0.86, 0.30, 0.44)     // minaret L
            rectShape(0.70, 0.86, 0.73, 0.44)     // minaret R
            circle(0.285, 0.42, 0.022)
            circle(0.715, 0.42, 0.022)

        case .christRedeemer:
            poly([(0.0, 1.0), (0.5, 0.55), (1.0, 1.0)])   // Corcovado mountain
            rectShape(0.46, 0.55, 0.54, 0.42)             // pedestal
            rectShape(0.475, 0.42, 0.525, 0.17)           // body
            rectShape(0.30, 0.205, 0.70, 0.245)           // outstretched arms
            circle(0.50, 0.145, 0.028)                    // head

        case .statueOfLiberty:
            rectShape(0.34, 1.0, 0.66, 0.88)              // base
            poly([(0.38, 0.88), (0.62, 0.88), (0.60, 0.66), (0.40, 0.66)]) // pedestal
            poly([(0.42, 0.66), (0.58, 0.66), (0.55, 0.30), (0.45, 0.30)]) // robe
            circle(0.50, 0.265, 0.033)                    // head
            spikes(&p, pt: pt, cx: 0.50, cy: 0.235, r: 0.055, count: 7)
            poly([(0.545, 0.35), (0.575, 0.34), (0.645, 0.13), (0.615, 0.13)]) // raised arm
            circle(0.632, 0.105, 0.028)                   // torch flame
            spikes(&p, pt: pt, cx: 0.632, cy: 0.09, r: 0.03, count: 5)
            poly([(0.40, 0.42), (0.455, 0.40), (0.465, 0.52), (0.41, 0.54)]) // tablet

        case .washingtonMonument:
            poly([(0.465, 1.0), (0.535, 1.0), (0.518, 0.09), (0.482, 0.09)]) // tapering obelisk
            poly([(0.482, 0.09), (0.518, 0.09), (0.50, 0.01)])               // pyramidion

        case .cnTower:
            poly([(0.47, 1.0), (0.53, 1.0), (0.518, 0.32), (0.482, 0.32)])   // main shaft
            poly([(0.44, 0.35), (0.47, 0.29), (0.53, 0.29), (0.56, 0.35), (0.53, 0.40), (0.47, 0.40)]) // SkyPod
            rectShape(0.489, 0.29, 0.511, 0.13)                              // upper shaft
            rectShape(0.496, 0.13, 0.504, 0.02)                              // antenna

        case .colosseum:
            // Domed amphitheatre body
            p.move(to: pt(0.10, 1.0))
            p.addLine(to: pt(0.12, 0.58))
            p.addQuadCurve(to: pt(0.88, 0.58), control: pt(0.50, 0.34))
            p.addLine(to: pt(0.90, 1.0))
            p.closeSubpath()
            // Two rows of arch cut-outs (holes via eoFill)
            for row in 0..<2 {
                let yTop = 0.66 + CGFloat(row) * 0.16
                let yBot = yTop + 0.11
                for i in 0..<8 {
                    let cx = 0.16 + CGFloat(i) * 0.092
                    p.addRoundedRect(in: CGRect(x: rect.minX + (cx - 0.022) * W, y: rect.minY + yTop * H,
                                                width: 0.044 * W, height: (yBot - yTop) * H),
                                     cornerSize: CGSize(width: 0.022 * W, height: 0.022 * W))
                }
            }

        case .stBasils:
            rectShape(0.24, 1.0, 0.76, 0.82)                     // shared base
            onionTower(&p, pt: pt, cx: 0.50, baseY: 0.82, domeTop: 0.20, width: 0.10, tall: true)
            onionTower(&p, pt: pt, cx: 0.30, baseY: 0.82, domeTop: 0.42, width: 0.09, tall: false)
            onionTower(&p, pt: pt, cx: 0.70, baseY: 0.82, domeTop: 0.42, width: 0.09, tall: false)
            onionTower(&p, pt: pt, cx: 0.385, baseY: 0.82, domeTop: 0.52, width: 0.075, tall: false)
            onionTower(&p, pt: pt, cx: 0.615, baseY: 0.82, domeTop: 0.52, width: 0.075, tall: false)

        case .marinaBaySands:
            rectShape(0.235, 1.0, 0.315, 0.30)   // tower 1
            rectShape(0.46, 1.0, 0.54, 0.30)     // tower 2
            rectShape(0.685, 1.0, 0.765, 0.30)   // tower 3
            poly([(0.16, 0.30), (0.84, 0.30), (0.80, 0.22), (0.90, 0.22), (0.20, 0.22)]) // sky boat

        case .tableMountain:
            poly([(0.02, 1.0), (0.14, 0.50), (0.28, 0.42), (0.72, 0.42), (0.86, 0.50), (0.98, 1.0)])
            poly([(0.62, 1.0), (0.74, 0.60), (0.86, 1.0)]) // Lion's Head foreground

        case .willisTower:
            rectShape(0.34, 1.0, 0.42, 0.50)     // outer left tube
            rectShape(0.58, 1.0, 0.66, 0.42)     // outer right tube
            rectShape(0.42, 1.0, 0.50, 0.18)     // tall tube
            rectShape(0.50, 1.0, 0.58, 0.30)     // second tube
            rectShape(0.455, 0.18, 0.465, 0.05)  // antenna 1
            rectShape(0.535, 0.30, 0.545, 0.14)  // antenna 2

        case .parthenon:
            rectShape(0.18, 1.0, 0.82, 0.90)     // stylobate
            for i in 0..<7 {
                let x0 = 0.22 + CGFloat(i) * 0.088
                rectShape(x0, 0.90, x0 + 0.045, 0.46)   // columns
            }
            rectShape(0.18, 0.46, 0.82, 0.38)    // entablature
            poly([(0.18, 0.38), (0.82, 0.38), (0.50, 0.20)]) // pediment

        case .sagradaFamilia:
            rectShape(0.22, 1.0, 0.78, 0.82)
            let spires: [(CGFloat, CGFloat)] = [(0.30, 0.30), (0.40, 0.18), (0.50, 0.08), (0.60, 0.18), (0.70, 0.30)]
            for (cx, top) in spires {
                poly([(cx - 0.05, 0.85), (cx - 0.018, top + 0.04), (cx, top), (cx + 0.018, top + 0.04), (cx + 0.05, 0.85)])
                circle(cx, top - 0.005, 0.012)   // finial
            }

        case .brandenburgGate:
            for i in 0..<5 {
                let x0 = 0.26 + CGFloat(i) * 0.10
                rectShape(x0, 1.0, x0 + 0.055, 0.40)   // Doric columns
            }
            rectShape(0.22, 0.40, 0.78, 0.30)    // entablature
            rectShape(0.44, 0.30, 0.56, 0.24)    // quadriga base
            rectShape(0.47, 0.24, 0.53, 0.19)    // chariot

        case .palmTrees:
            palm(&p, pt: pt, baseX: 0.34, topX: 0.30, topY: 0.30)
            palm(&p, pt: pt, baseX: 0.63, topX: 0.68, topY: 0.22)
            palm(&p, pt: pt, baseX: 0.48, topX: 0.47, topY: 0.42)

        case .empireState:
            rectShape(0.37, 1.0, 0.63, 0.70)
            rectShape(0.41, 0.70, 0.59, 0.30)
            rectShape(0.44, 0.30, 0.56, 0.22)
            rectShape(0.465, 0.22, 0.535, 0.12)
            rectShape(0.492, 0.12, 0.508, 0.02)

        case .brooklynBridge:
            rectShape(0.04, 0.72, 0.96, 0.78)
            for cx in [0.30, 0.70] as [CGFloat] {
                rectShape(cx - 0.055, 0.78, cx + 0.055, 0.26)
                archHole(&p, pt: pt, x0: cx - 0.046, x1: cx - 0.006, baseY: 0.78, springY: 0.55, apexY: 0.42)
                archHole(&p, pt: pt, x0: cx + 0.006, x1: cx + 0.046, baseY: 0.78, springY: 0.55, apexY: 0.42)
            }
            cable(&p, pt: pt, from: (0.30, 0.30), to: (0.70, 0.30), dip: 0.34)
            cable(&p, pt: pt, from: (0.04, 0.58), to: (0.30, 0.30), dip: 0.02)
            cable(&p, pt: pt, from: (0.70, 0.30), to: (0.96, 0.58), dip: 0.02)

        case .archDeTriomphe:
            rectShape(0.28, 1.0, 0.72, 0.28)
            rectShape(0.26, 0.28, 0.74, 0.20)
            archHole(&p, pt: pt, x0: 0.40, x1: 0.60, baseY: 1.0, springY: 0.55, apexY: 0.40)

        case .louvrePyramid:
            rectShape(0.24, 0.92, 0.76, 0.96)
            poly([(0.30, 0.92), (0.70, 0.92), (0.50, 0.36)])
            poly([(0.15, 0.92), (0.24, 0.92), (0.195, 0.78)])
            poly([(0.76, 0.92), (0.85, 0.92), (0.805, 0.78)])

        case .towerBridge:
            rectShape(0.05, 0.80, 0.95, 0.85)
            for cx in [0.32, 0.68] as [CGFloat] {
                rectShape(cx - 0.06, 0.85, cx + 0.06, 0.30)
                poly([(cx - 0.06, 0.30), (cx + 0.06, 0.30), (cx, 0.20)])
                archHole(&p, pt: pt, x0: cx - 0.04, x1: cx + 0.04, baseY: 0.85, springY: 0.60, apexY: 0.48)
            }
            rectShape(0.26, 0.44, 0.74, 0.38)

        case .londonEye:
            roundCircle(0.50, 0.36, 0.30)              // outer rim (kept round, not oval)
            roundCircle(0.50, 0.36, 0.265)             // rim hole
            for i in 0..<16 {
                let a = Double(i) / 16 * 2 * .pi
                bar(&p, pt: pt, a: (0.50, 0.36), b: onCircle(0.50, 0.36, 0.29, a), th: 0.004)
            }
            roundCircle(0.50, 0.36, 0.03)
            poly([(0.44, 1.0), (0.48, 1.0), (0.505, 0.36), (0.495, 0.36)])
            poly([(0.56, 1.0), (0.52, 1.0), (0.495, 0.36), (0.505, 0.36)])

        case .theShard:
            poly([(0.44, 1.0), (0.56, 1.0), (0.515, 0.10), (0.485, 0.10)])
            poly([(0.487, 0.16), (0.515, 0.16), (0.50, 0.02)])
            poly([(0.50, 0.34), (0.54, 0.30), (0.515, 0.13)])

        case .tokyoSkytree:
            poly([(0.44, 1.0), (0.47, 1.0), (0.505, 0.55), (0.495, 0.55)])
            poly([(0.56, 1.0), (0.53, 1.0), (0.495, 0.55), (0.505, 0.55)])
            rectShape(0.487, 0.55, 0.513, 0.34)
            poly([(0.45, 0.37), (0.48, 0.30), (0.52, 0.30), (0.55, 0.37), (0.52, 0.41), (0.48, 0.41)])
            rectShape(0.492, 0.30, 0.508, 0.16)
            poly([(0.475, 0.17), (0.525, 0.17), (0.51, 0.12), (0.49, 0.12)])
            rectShape(0.497, 0.12, 0.503, 0.02)

        case .transamerica:
            poly([(0.42, 1.0), (0.58, 1.0), (0.512, 0.10), (0.488, 0.10)])
            poly([(0.488, 0.10), (0.512, 0.10), (0.50, 0.02)])
            rectShape(0.435, 0.42, 0.452, 0.22)
            rectShape(0.548, 0.42, 0.565, 0.22)

        case .sydneyHarbourBridge:
            rectShape(0.04, 0.70, 0.96, 0.75)
            rectShape(0.15, 0.75, 0.21, 0.55)
            rectShape(0.79, 0.75, 0.85, 0.55)
            bandArch(&p, pt: pt, from: (0.10, 0.70), to: (0.90, 0.70), peakY: 0.28, thickness: 0.055)
            for x in stride(from: 0.22 as CGFloat, through: 0.78, by: 0.08) {
                bar(&p, pt: pt, a: (x, 0.70), b: (x, archY(x, from: 0.10, to: 0.90, peak: 0.315)), th: 0.004)
            }

        case .burjAlArab:
            p.move(to: pt(0.42, 1.0))
            p.addLine(to: pt(0.42, 0.08))
            p.addQuadCurve(to: pt(0.66, 1.0), control: pt(0.80, 0.45))
            p.closeSubpath()
            rectShape(0.408, 0.10, 0.432, 0.02)

        case .reichstag:
            rectShape(0.22, 1.0, 0.78, 0.55)
            poly([(0.40, 0.55), (0.60, 0.55), (0.50, 0.44)])
            rectShape(0.22, 0.55, 0.30, 0.42)
            rectShape(0.70, 0.55, 0.78, 0.42)
            domeHalf(&p, pt: pt, cx: 0.50, baseY: 0.44, rx: 0.10, height: 0.16)
            rectShape(0.492, 0.30, 0.508, 0.26)

        case .capitolBuilding:
            rectShape(0.14, 1.0, 0.86, 0.62)
            poly([(0.40, 0.62), (0.60, 0.62), (0.50, 0.54)])
            rectShape(0.42, 0.62, 0.58, 0.40)
            domeHalf(&p, pt: pt, cx: 0.50, baseY: 0.40, rx: 0.09, height: 0.15)
            rectShape(0.492, 0.26, 0.508, 0.22)
            circle(0.50, 0.205, 0.013)

        case .sugarloaf:
            p.move(to: pt(0.50, 1.0)); p.addQuadCurve(to: pt(0.96, 1.0), control: pt(0.79, 0.22)); p.closeSubpath()
            p.move(to: pt(0.04, 1.0)); p.addQuadCurve(to: pt(0.46, 1.0), control: pt(0.24, 0.55)); p.closeSubpath()
            poly([(0.24, 0.53), (0.79, 0.27), (0.79, 0.285), (0.24, 0.545)]) // cable car line

        case .superTrees:
            superTree(&p, pt: pt, cx: 0.28, topY: 0.36)
            superTree(&p, pt: pt, cx: 0.52, topY: 0.22)
            superTree(&p, pt: pt, cx: 0.73, topY: 0.42)

        case .taipei101:
            rectShape(0.28, 1.00, 0.72, 0.88)          // podium
            rectShape(0.41, 0.88, 0.59, 0.18)          // core shaft
            // Tier wings, abutting the shaft on each side (never overlapping it).
            for y in [CGFloat(0.80), 0.68, 0.56, 0.44, 0.32] {
                rectShape(0.355, y, 0.41, y - 0.045)
                rectShape(0.59, y, 0.645, y - 0.045)
            }
            rectShape(0.487, 0.18, 0.513, 0.03)        // spire

        case .orientalPearl:
            rectShape(0.47, 1.00, 0.53, 0.73)          // column below the lower sphere
            rectShape(0.47, 0.51, 0.53, 0.385)         // column between the spheres
            rectShape(0.478, 0.215, 0.522, 0.175)      // column below the top sphere
            rectShape(0.492, 0.085, 0.508, 0.02)       // antenna
            roundCircle(0.50, 0.62, 0.11)              // lower sphere
            roundCircle(0.50, 0.30, 0.085)             // upper sphere
            roundCircle(0.50, 0.13, 0.045)             // top sphere
            poly([(0.30, 1.00), (0.455, 0.76), (0.505, 0.76), (0.385, 1.00)])   // splayed legs
            poly([(0.70, 1.00), (0.545, 0.76), (0.495, 0.76), (0.615, 1.00)])

        case .gatewayOfIndia:
            rectShape(0.18, 1.00, 0.82, 0.30)          // main block
            poly([(0.41, 1.00), (0.41, 0.62), (0.45, 0.53), (0.50, 0.50),
                  (0.55, 0.53), (0.59, 0.62), (0.59, 1.00)])          // central arch (hole)
            poly([(0.39, 0.30), (0.41, 0.23), (0.45, 0.19), (0.50, 0.18),
                  (0.55, 0.19), (0.59, 0.23), (0.61, 0.30)])          // central dome
            rectShape(0.20, 0.30, 0.28, 0.20)          // turrets, sitting on the block
            rectShape(0.72, 0.30, 0.80, 0.20)
            poly([(0.20, 0.20), (0.24, 0.14), (0.28, 0.20)])          // turret caps
            poly([(0.72, 0.20), (0.76, 0.14), (0.80, 0.20)])

        case .watArun:
            rectShape(0.08, 1.00, 0.92, 0.88)          // terrace
            poly([(0.36, 0.88), (0.44, 0.30), (0.50, 0.06), (0.56, 0.30), (0.64, 0.88)])  // central prang
            poly([(0.12, 0.88), (0.17, 0.55), (0.22, 0.88)])          // satellite prangs
            poly([(0.24, 0.88), (0.29, 0.62), (0.34, 0.88)])
            poly([(0.66, 0.88), (0.71, 0.62), (0.76, 0.88)])
            poly([(0.78, 0.88), (0.83, 0.55), (0.88, 0.88)])

        case .namsanTower:
            poly([(0.00, 1.00), (0.22, 0.78), (0.50, 0.70), (0.78, 0.78), (1.00, 1.00)])  // Namsan hill
            rectShape(0.465, 0.72, 0.535, 0.34)        // shaft, embedded in the hill
            poly([(0.42, 0.34), (0.58, 0.34), (0.555, 0.24), (0.445, 0.24)])  // observation deck
            rectShape(0.487, 0.24, 0.513, 0.06)        // antenna

        case .bankOfChina:
            poly([(0.32, 1.00), (0.32, 0.42), (0.50, 0.10), (0.50, 1.00)])    // left prism
            poly([(0.50, 1.00), (0.50, 0.10), (0.68, 0.42), (0.68, 1.00)])    // right prism
            rectShape(0.495, 0.10, 0.505, 0.02)        // mast
            rectShape(0.06, 1.00, 0.20, 0.72)          // harbour-front skyline
            rectShape(0.72, 1.00, 0.86, 0.66)
            rectShape(0.86, 1.00, 0.94, 0.80)

        case .torii:
            rectShape(0.24, 1.00, 0.31, 0.22)          // pillars
            rectShape(0.69, 1.00, 0.76, 0.22)
            rectShape(0.18, 0.34, 0.82, 0.27)          // nuki (lower beam) crossing the pillars
            poly([(0.10, 0.22), (0.90, 0.22), (0.86, 0.12), (0.14, 0.12)])    // kasagi (top beam)

        case .monas:
            rectShape(0.30, 1.00, 0.70, 0.90)          // base
            poly([(0.40, 0.90), (0.60, 0.90), (0.545, 0.22), (0.455, 0.22)])  // tapering column
            poly([(0.455, 0.22), (0.545, 0.22), (0.52, 0.10), (0.50, 0.04), (0.48, 0.10)])  // flame

        case .skyTower:
            poly([(0.40, 1.00), (0.47, 0.46), (0.53, 0.46), (0.60, 1.00)])    // splayed shaft
            poly([(0.38, 0.46), (0.62, 0.46), (0.575, 0.32), (0.425, 0.32)])  // main pod
            rectShape(0.47, 0.32, 0.53, 0.24)          // upper shaft
            poly([(0.44, 0.24), (0.56, 0.24), (0.53, 0.17), (0.47, 0.17)])    // upper pod
            rectShape(0.492, 0.17, 0.508, 0.02)        // mast
            rectShape(0.14, 1.00, 0.30, 0.80)          // low buildings
            rectShape(0.70, 1.00, 0.84, 0.76)

        case .belemTower:
            rectShape(0.30, 1.00, 0.70, 0.62)          // bastion
            rectShape(0.40, 0.62, 0.66, 0.20)          // tower
            rectShape(0.405, 0.20, 0.45, 0.14)         // tower battlements
            rectShape(0.465, 0.20, 0.51, 0.14)
            rectShape(0.525, 0.20, 0.57, 0.14)
            rectShape(0.585, 0.20, 0.63, 0.14)
            rectShape(0.305, 0.62, 0.345, 0.56)        // bastion battlements
            rectShape(0.355, 0.62, 0.395, 0.56)
            rectShape(0.665, 0.62, 0.695, 0.56)

        case .angkorWat:
            rectShape(0.04, 1.00, 0.96, 0.84)          // long terrace
            poly([(0.42, 0.84), (0.50, 0.16), (0.58, 0.84)])          // central tower
            poly([(0.20, 0.84), (0.26, 0.44), (0.32, 0.84)])
            poly([(0.68, 0.84), (0.74, 0.44), (0.80, 0.84)])
            poly([(0.06, 0.84), (0.11, 0.56), (0.16, 0.84)])
            poly([(0.84, 0.84), (0.89, 0.56), (0.94, 0.84)])

        case .merlion:
            rectShape(0.20, 1.00, 0.80, 0.90)          // plinth
            // Lion head, mane, body and curling tail as one closed silhouette.
            poly([
                (0.32, 0.90), (0.32, 0.62), (0.27, 0.57),   // chest up to the jaw
                (0.35, 0.50), (0.36, 0.41),                 // snout, then up the mane
                (0.44, 0.32), (0.54, 0.31), (0.61, 0.39),   // mane over the head
                (0.59, 0.51), (0.67, 0.59),                 // neck down to the shoulder
                (0.77, 0.63), (0.87, 0.55), (0.93, 0.41),   // back, tail sweeping up
                (0.87, 0.38), (0.84, 0.53),                 // tail tip and inner edge
                (0.74, 0.71), (0.68, 0.90),                 // back down to the plinth
            ])
            rectShape(0.05, 0.60, 0.29, 0.555)         // the water jet from its mouth

        case .singaporeFlyer:
            let fx: CGFloat = 0.50, fy: CGFloat = 0.40, fr: CGFloat = 0.32
            roundCircle(fx, fy, fr)                    // outer rim
            roundCircle(fx, fy, fr - 0.030)            // inner rim → a ring via eoFill
            // 16 spokes, hub out to the inner rim
            for i in 0..<16 {
                let a = Double(i) / 16 * 2 * .pi
                bar(&p, pt: pt,
                    a: onCircle(fx, fy, 0.055, a),
                    b: onCircle(fx, fy, fr - 0.030, a), th: 0.005)
            }
            roundCircle(fx, fy, 0.055)                 // hub
            // 16 capsules riding just outside the rim
            for i in 0..<16 {
                let a = (Double(i) + 0.5) / 16 * 2 * .pi
                let c = onCircle(fx, fy, fr + 0.022, a)
                roundCircle(c.0, c.1, 0.021)
            }
            rectShape(0.18, 1.00, 0.82, 0.955)         // terminal building
            bar(&p, pt: pt, a: (0.31, 0.955), b: (0.47, 0.72), th: 0.013)   // A-frame legs
            bar(&p, pt: pt, a: (0.69, 0.955), b: (0.53, 0.72), th: 0.013)

        case .gatewayArch:
            bandArch(&p, pt: pt, from: (0.28, 1.0), to: (0.72, 1.0), peakY: 0.05, thickness: 0.03)

        case .petronasTowers:
            for cx in [0.36, 0.64] as [CGFloat] {
                rectShape(cx - 0.06, 1.0, cx + 0.06, 0.34)
                rectShape(cx - 0.045, 0.34, cx + 0.045, 0.22)
                rectShape(cx - 0.028, 0.22, cx + 0.028, 0.14)
                rectShape(cx - 0.006, 0.14, cx + 0.006, 0.04)
            }
            rectShape(0.42, 0.52, 0.58, 0.55)
            bar(&p, pt: pt, a: (0.42, 0.535), b: (0.36, 0.42), th: 0.006)
            bar(&p, pt: pt, a: (0.58, 0.535), b: (0.64, 0.42), th: 0.006)

        case .chichenItza:
            rectShape(0.18, 1.0, 0.82, 0.86)
            rectShape(0.24, 0.86, 0.76, 0.72)
            rectShape(0.30, 0.72, 0.70, 0.58)
            rectShape(0.36, 0.58, 0.64, 0.44)
            rectShape(0.42, 0.44, 0.58, 0.34)

        case .atomium:
            let nodes: [(CGFloat, CGFloat)] = [
                (0.50, 0.14), (0.31, 0.36), (0.69, 0.36), (0.50, 0.50),
                (0.31, 0.66), (0.69, 0.66), (0.50, 0.88),
            ]
            let center = nodes[3]
            for n in nodes where !(n == center) { bar(&p, pt: pt, a: center, b: n, th: 0.01) }
            bar(&p, pt: pt, a: nodes[0], b: nodes[6], th: 0.008)
            for n in nodes { circle(n.0, n.1, 0.058) }

        case .templeOfHeaven:
            rectShape(0.30, 1.0, 0.70, 0.86)
            poly([(0.26, 0.86), (0.74, 0.86), (0.50, 0.70)])
            rectShape(0.38, 0.70, 0.62, 0.62)
            poly([(0.30, 0.62), (0.70, 0.62), (0.50, 0.48)])
            rectShape(0.40, 0.48, 0.60, 0.42)
            poly([(0.34, 0.42), (0.66, 0.42), (0.50, 0.28)])
            circle(0.50, 0.25, 0.02)

        case .hagiaSophia:
            rectShape(0.30, 1.0, 0.70, 0.58)
            domeHalf(&p, pt: pt, cx: 0.50, baseY: 0.58, rx: 0.17, height: 0.20)
            domeHalf(&p, pt: pt, cx: 0.37, baseY: 0.62, rx: 0.09, height: 0.10)
            domeHalf(&p, pt: pt, cx: 0.63, baseY: 0.62, rx: 0.09, height: 0.10)
            for cx in [0.20, 0.28, 0.72, 0.80] as [CGFloat] {
                rectShape(cx - 0.012, 1.0, cx + 0.012, 0.42)
                poly([(cx - 0.012, 0.42), (cx + 0.012, 0.42), (cx, 0.34)])
            }

        case .windmill:
            poly([(0.42, 1.0), (0.58, 1.0), (0.545, 0.40), (0.455, 0.40)])
            poly([(0.45, 0.40), (0.55, 0.40), (0.50, 0.32)])
            circle(0.50, 0.34, 0.02)
            for tip in [(0.30, 0.18), (0.70, 0.18), (0.30, 0.50), (0.70, 0.50)] as [(CGFloat, CGFloat)] {
                bar(&p, pt: pt, a: (0.50, 0.34), b: tip, th: 0.012)
            }

        case .indiaGate:
            rectShape(0.34, 1.0, 0.66, 0.30)
            rectShape(0.32, 0.30, 0.68, 0.22)
            archHole(&p, pt: pt, x0: 0.44, x1: 0.56, baseY: 1.0, springY: 0.52, apexY: 0.34)
            domeHalf(&p, pt: pt, cx: 0.50, baseY: 0.22, rx: 0.04, height: 0.05)


        // MARK: - Icons for cities that were stuck on the generic skyline

        case .stStephens:
            // Vienna: one soaring south tower, steep patterned roof, stubby north tower.
            rectShape(0.30, 1.0, 0.72, 0.66)              // nave
            poly([(0.28, 0.66), (0.74, 0.66), (0.51, 0.34)])  // steep roof
            rectShape(0.60, 0.66, 0.72, 0.30)             // south tower shaft
            poly([(0.585, 0.30), (0.735, 0.30), (0.66, 0.02)]) // spire
            rectShape(0.30, 0.66, 0.40, 0.44)             // north tower
            poly([(0.29, 0.44), (0.41, 0.44), (0.35, 0.34)])
            circle(0.66, 0.20, 0.018)                     // spire window (hole)

        case .charlesBridge:
            // Prague: arched span between two gate towers.
            rectShape(0.0, 0.62, 1.0, 0.70)               // deck
            for i in 0..<4 {                              // arches (holes)
                let cx = 0.26 + CGFloat(i) * 0.17
                p.move(to: pt(cx - 0.06, 1.0))
                p.addQuadCurve(to: pt(cx + 0.06, 1.0), control: pt(cx, 0.62))
                p.closeSubpath()
            }
            rectShape(0.0, 0.70, 1.0, 1.0)                // pier wall below deck
            rectShape(0.09, 0.62, 0.21, 0.24)             // west tower
            poly([(0.075, 0.24), (0.225, 0.24), (0.15, 0.06)])
            rectShape(0.79, 0.62, 0.91, 0.30)             // east tower
            poly([(0.775, 0.30), (0.925, 0.30), (0.85, 0.14)])

        case .duomoMilano:
            // Milan: a forest of gothic pinnacles over a wide facade.
            rectShape(0.14, 1.0, 0.86, 0.58)
            for i in 0..<9 {                              // pinnacles, tallest at centre
                let x = 0.18 + CGFloat(i) * 0.08
                let d = abs(CGFloat(i) - 4) / 4
                let top = 0.14 + d * 0.30
                rectShape(x - 0.014, 0.58, x + 0.014, top + 0.06)
                poly([(x - 0.022, top + 0.06), (x + 0.022, top + 0.06), (x, top)])
            }
            for i in 0..<3 {                              // doorways (holes)
                let cx = 0.34 + CGFloat(i) * 0.16
                p.move(to: pt(cx - 0.035, 1.0))
                p.addQuadCurve(to: pt(cx + 0.035, 1.0), control: pt(cx, 0.74))
                p.closeSubpath()
            }

        case .frauenkirche:
            // Munich: twin brick towers under copper onion domes.
            rectShape(0.30, 1.0, 0.70, 0.70)              // nave
            for cx in [CGFloat(0.36), CGFloat(0.64)] {
                rectShape(cx - 0.075, 1.0, cx + 0.075, 0.34)   // tower
                roundCircle(cx, 0.28, 0.075)                   // onion dome
                poly([(cx - 0.012, 0.24), (cx + 0.012, 0.24), (cx, 0.10)])  // finial
            }

        case .puertaAlcala:
            // Madrid: a triumphal gate — three arches, two lintels.
            rectShape(0.06, 1.0, 0.94, 0.30)
            rectShape(0.02, 0.30, 0.98, 0.22)             // cornice
            poly([(0.36, 0.22), (0.64, 0.22), (0.64, 0.12), (0.36, 0.12)])  // attic
            p.move(to: pt(0.34, 1.0))                     // central arch (hole)
            p.addQuadCurve(to: pt(0.66, 1.0), control: pt(0.50, 0.34))
            p.closeSubpath()
            for cx in [CGFloat(0.18), CGFloat(0.82)] {    // side arches (holes)
                p.move(to: pt(cx - 0.07, 1.0))
                p.addQuadCurve(to: pt(cx + 0.07, 1.0), control: pt(cx, 0.52))
                p.closeSubpath()
            }

        case .hapennyBridge:
            // Dublin: a single cast-iron arch with lamp posts.
            p.move(to: pt(0.08, 0.86))                    // arch band
            p.addQuadCurve(to: pt(0.92, 0.86), control: pt(0.50, 0.30))
            p.addLine(to: pt(0.92, 0.94))
            p.addQuadCurve(to: pt(0.08, 0.94), control: pt(0.50, 0.40))
            p.closeSubpath()
            rectShape(0.04, 1.0, 0.12, 0.84)              // abutments
            rectShape(0.88, 1.0, 0.96, 0.84)
            for cx in [CGFloat(0.20), CGFloat(0.50), CGFloat(0.80)] {   // lamps
                let y: CGFloat = cx == 0.50 ? 0.42 : 0.60
                rectShape(cx - 0.007, y, cx + 0.007, y - 0.12)
                circle(cx, y - 0.15, 0.022)
            }

        case .obelisco:
            // Buenos Aires: a plain white needle on a plaza.
            poly([(0.44, 0.94), (0.56, 0.94), (0.535, 0.06), (0.465, 0.06)])
            poly([(0.465, 0.06), (0.535, 0.06), (0.50, 0.0)])   // capstone
            rectShape(0.40, 1.0, 0.60, 0.94)                    // base
            rectShape(0.30, 1.0, 0.70, 0.985)                   // plaza

        case .elCapitolio:
            // Havana: dome and colonnade.
            rectShape(0.10, 1.0, 0.90, 0.72)              // podium
            for i in 0..<8 {                              // columns
                let x0 = 0.16 + CGFloat(i) * 0.09
                rectShape(x0, 0.72, x0 + 0.035, 0.52)
            }
            rectShape(0.10, 0.52, 0.90, 0.46)             // entablature
            poly([(0.30, 0.46), (0.70, 0.46), (0.50, 0.36)])    // pediment
            roundCircle(0.50, 0.30, 0.13)                 // dome
            rectShape(0.37, 0.36, 0.63, 0.30)             // drum
            poly([(0.485, 0.17), (0.515, 0.17), (0.50, 0.06)])  // lantern

        case .parliamentHungary:
            // Budapest: central dome flanked by a long spiky Gothic Revival wing.
            rectShape(0.02, 1.0, 0.98, 0.74)
            for i in 0..<10 {                             // spires along the roof
                let x = 0.07 + CGFloat(i) * 0.093
                if abs(x - 0.50) < 0.10 { continue }      // leave room for the dome
                rectShape(x - 0.012, 0.74, x + 0.012, 0.58)
                poly([(x - 0.02, 0.58), (x + 0.02, 0.58), (x, 0.46)])
            }
            rectShape(0.40, 0.74, 0.60, 0.44)             // drum
            roundCircle(0.50, 0.36, 0.10)                 // dome
            poly([(0.487, 0.28), (0.513, 0.28), (0.50, 0.14)])  // spire

        case .bayterek:
            // Astana: a golden sphere cradled in a splayed white lattice.
            poly([(0.34, 1.0), (0.40, 1.0), (0.485, 0.36), (0.455, 0.36)])   // left leg
            poly([(0.66, 1.0), (0.60, 1.0), (0.515, 0.36), (0.545, 0.36)])   // right leg
            rectShape(0.478, 1.0, 0.522, 0.36)            // core
            roundCircle(0.50, 0.28, 0.115)                // sphere
            poly([(0.492, 0.17), (0.508, 0.17), (0.50, 0.06)])   // mast

        case .minarEPakistan:
            // Lahore: a tapering minaret on a tiered platform.
            rectShape(0.22, 1.0, 0.78, 0.94)              // platform
            rectShape(0.30, 0.94, 0.70, 0.88)
            poly([(0.435, 0.88), (0.565, 0.88), (0.535, 0.20), (0.465, 0.20)])  // shaft
            rectShape(0.44, 0.24, 0.56, 0.20)             // balcony
            poly([(0.465, 0.20), (0.535, 0.20), (0.50, 0.04)])  // crown
            circle(0.50, 0.02, 0.016)

        case .machuPicchu:
            // Cusco: terraced ridge under Huayna Picchu's peak.
            poly([(0.60, 1.0), (0.80, 0.14), (1.0, 1.0)])       // the peak behind
            poly([(0.0, 1.0), (0.18, 0.50), (0.40, 1.0)])       // smaller peak
            for i in 0..<5 {                                    // terraces
                let y = 0.62 + CGFloat(i) * 0.075
                rectShape(0.16 + CGFloat(i) * 0.03, y, 0.68 - CGFloat(i) * 0.02, y + 0.045)
            }
            rectShape(0.30, 0.62, 0.36, 0.55)                   // ruined walls
            rectShape(0.44, 0.62, 0.50, 0.57)
            rectShape(0.56, 0.62, 0.61, 0.56)

        case .libertyBell:
            // Philadelphia: the bell, crack and all.
            rectShape(0.46, 0.06, 0.54, 0.16)             // yoke pin
            rectShape(0.34, 0.16, 0.66, 0.22)             // headstock
            poly([(0.30, 0.86), (0.36, 0.30), (0.64, 0.30), (0.70, 0.86)])   // body
            rectShape(0.26, 0.86, 0.74, 0.94)             // lip
            poly([(0.50, 0.86), (0.545, 0.60), (0.515, 0.60), (0.535, 0.36)])   // crack (hole)

        // MARK: - Regional archetypes

        case .mosque:
            // Central dome, two minarets, arched arcade.
            rectShape(0.20, 1.0, 0.80, 0.62)
            roundCircle(0.50, 0.50, 0.155)                // main dome
            poly([(0.487, 0.36), (0.513, 0.36), (0.50, 0.24)])  // finial
            for cx in [CGFloat(0.10), CGFloat(0.90)] {    // minarets
                rectShape(cx - 0.028, 1.0, cx + 0.028, 0.26)
                rectShape(cx - 0.042, 0.34, cx + 0.042, 0.30)   // balcony
                poly([(cx - 0.028, 0.26), (cx + 0.028, 0.26), (cx, 0.12)])
            }
            for i in 0..<3 {                              // arcade (holes)
                let cx = 0.34 + CGFloat(i) * 0.16
                p.move(to: pt(cx - 0.05, 1.0))
                p.addQuadCurve(to: pt(cx + 0.05, 1.0), control: pt(cx, 0.72))
                p.closeSubpath()
            }

        case .stupa:
            // Buddhist stupa: hemispherical dome, square harmika, tapering spire.
            rectShape(0.16, 1.0, 0.84, 0.88)              // plinth
            rectShape(0.24, 0.88, 0.76, 0.80)
            roundCircle(0.50, 0.66, 0.20)                 // dome
            rectShape(0.42, 0.52, 0.58, 0.44)             // harmika
            poly([(0.455, 0.44), (0.545, 0.44), (0.515, 0.14), (0.485, 0.14)])   // spire
            for i in 0..<3 {                              // rings
                let y = 0.40 - CGFloat(i) * 0.07
                rectShape(0.44 + CGFloat(i) * 0.008, y, 0.56 - CGFloat(i) * 0.008, y - 0.018)
            }
            circle(0.50, 0.10, 0.022)                     // crowning jewel

        case .pagoda:
            // Tiered pagoda with upswept eaves.
            rectShape(0.34, 1.0, 0.66, 0.92)
            for i in 0..<4 {
                let y = 0.92 - CGFloat(i) * 0.19          // storey floor
                let half = 0.30 - CGFloat(i) * 0.055      // narrows as it rises
                rectShape(0.50 - half * 0.62, y, 0.50 + half * 0.62, y - 0.115)   // storey
                poly([(0.50 - half, y - 0.115),           // flared roof
                      (0.50 + half, y - 0.115),
                      (0.50 + half * 0.55, y - 0.175),
                      (0.50 - half * 0.55, y - 0.175)])
            }
            poly([(0.487, 0.20), (0.513, 0.20), (0.50, 0.04)])   // finial

        case .onionDomes:
            // Orthodox church: three onion domes on drums.
            rectShape(0.18, 1.0, 0.82, 0.66)
            for (cx, r, dy) in [(CGFloat(0.28), CGFloat(0.075), CGFloat(0.50)),
                                (CGFloat(0.50), CGFloat(0.105), CGFloat(0.38)),
                                (CGFloat(0.72), CGFloat(0.075), CGFloat(0.50))] {
                rectShape(cx - r * 0.7, 0.66, cx + r * 0.7, dy + r * 0.5)   // drum
                roundCircle(cx, dy, r)                                       // dome
                poly([(cx - 0.010, dy - r), (cx + 0.010, dy - r), (cx, dy - r - 0.10)])  // cross
                rectShape(cx - 0.03, dy - r - 0.055, cx + 0.03, dy - r - 0.072)
            }

        case .gothicCathedral:
            // Twin-spired cathedral with a rose window.
            rectShape(0.24, 1.0, 0.76, 0.56)
            for cx in [CGFloat(0.32), CGFloat(0.68)] {
                rectShape(cx - 0.07, 1.0, cx + 0.07, 0.34)
                poly([(cx - 0.078, 0.34), (cx + 0.078, 0.34), (cx, 0.06)])
            }
            circle(0.50, 0.70, 0.062)                     // rose window (hole)
            p.move(to: pt(0.44, 1.0))                     // portal (hole)
            p.addQuadCurve(to: pt(0.56, 1.0), control: pt(0.50, 0.82))
            p.closeSubpath()

        case .alpinePeaks:
            // Snow-capped range with a small town at the foot.
            poly([(0.0, 1.0), (0.24, 0.22), (0.48, 1.0)])
            poly([(0.34, 1.0), (0.62, 0.06), (0.90, 1.0)])
            poly([(0.72, 1.0), (0.90, 0.40), (1.0, 1.0)])
            poly([(0.545, 0.24), (0.62, 0.06), (0.695, 0.24),      // snow cap (hole)
                  (0.655, 0.20), (0.615, 0.26), (0.585, 0.20)])
            for i in 0..<5 {                                       // chalets
                let x0 = 0.16 + CGFloat(i) * 0.15
                rectShape(x0, 1.0, x0 + 0.075, 0.90)
                poly([(x0 - 0.012, 0.90), (x0 + 0.087, 0.90), (x0 + 0.037, 0.84)])
            }

        case .colonialCathedral:
            // Spanish colonial baroque: twin bell towers, central pediment.
            rectShape(0.20, 1.0, 0.80, 0.58)
            for cx in [CGFloat(0.28), CGFloat(0.72)] {
                rectShape(cx - 0.085, 1.0, cx + 0.085, 0.40)       // tower
                rectShape(cx - 0.10, 0.40, cx + 0.10, 0.35)        // cornice
                roundCircle(cx, 0.29, 0.062)                       // cupola
                poly([(cx - 0.008, 0.24), (cx + 0.008, 0.24), (cx, 0.14)])
                p.move(to: pt(cx - 0.04, 0.68))                    // belfry opening (hole)
                p.addQuadCurve(to: pt(cx + 0.04, 0.68), control: pt(cx, 0.50))
                p.addLine(to: pt(cx + 0.04, 0.52))
                p.addQuadCurve(to: pt(cx - 0.04, 0.52), control: pt(cx, 0.44))
                p.closeSubpath()
            }
            poly([(0.36, 0.58), (0.64, 0.58), (0.50, 0.44)])       // pediment
            p.move(to: pt(0.44, 1.0))                              // door (hole)
            p.addQuadCurve(to: pt(0.56, 1.0), control: pt(0.50, 0.78))
            p.closeSubpath()

        case .acaciaSavanna:
            // Flat-topped acacia over the plain, with a low skyline behind.
            for (x0, h) in [(CGFloat(0.60), CGFloat(0.66)), (CGFloat(0.72), CGFloat(0.58)),
                            (CGFloat(0.84), CGFloat(0.70))] {
                rectShape(x0, 0.94, x0 + 0.08, h)                  // distant buildings
            }
            rectShape(0.0, 0.94, 1.0, 1.0)                         // ground
            rectShape(0.20, 0.94, 0.245, 0.52)                     // trunk
            poly([(0.222, 0.62), (0.10, 0.50), (0.13, 0.46)])      // branches
            poly([(0.222, 0.62), (0.35, 0.50), (0.32, 0.46)])
            poly([(0.06, 0.46), (0.40, 0.46), (0.34, 0.36), (0.12, 0.36)])   // flat canopy
            circle(0.80, 0.30, 0.075)                              // low sun

        case .gabledHouses:
            // Nordic / Dutch waterfront: stepped and pointed gables, mast behind.
            rectShape(0.86, 0.94, 0.895, 0.16)                     // mast
            poly([(0.895, 0.22), (0.895, 0.50), (0.99, 0.50)])     // sail
            rectShape(0.0, 0.96, 1.0, 1.0)                         // quay
            var x: CGFloat = 0.02
            for i in 0..<6 {
                let w: CGFloat = i % 2 == 0 ? 0.15 : 0.13
                let top: CGFloat = 0.52 + CGFloat((i * 7) % 3) * 0.06
                rectShape(x, 0.96, x + w, top)
                if i % 2 == 0 {                                    // pointed gable
                    poly([(x - 0.008, top), (x + w + 0.008, top), (x + w / 2, top - 0.12)])
                } else {                                           // stepped gable
                    rectShape(x + 0.02, top, x + w - 0.02, top - 0.04)
                    rectShape(x + 0.045, top - 0.04, x + w - 0.045, top - 0.08)
                }
                for r in 0..<2 {                                   // windows (holes)
                    for c in 0..<2 {
                        let wx = x + 0.03 + CGFloat(c) * 0.06
                        let wy = top + 0.10 + CGFloat(r) * 0.13
                        rectShape(wx, wy, wx + 0.032, wy + 0.07)
                    }
                }
                x += w + 0.015
            }

        case .skyline:
            // Every unnamed city used to get this exact row of eleven boxes, which
            // made Boston, Houston and Melbourne pixel-identical. Grow the skyline
            // from the city's seed instead: same city, same skyline, but its own.
            var rng = UInt64(truncatingIfNeeded: seed) &* 2 &+ 1     // never zero
            func rand() -> CGFloat {
                rng = rng &* 6364136223846793005 &+ 1442695040888963407
                return CGFloat((rng >> 33) % 10_000) / 10_000
            }

            var x: CGFloat = 0.005
            var tallest: CGFloat = 1.0
            var tallestX: CGFloat = 0.5

            while x < 0.985 {
                let w = 0.055 + rand() * 0.055
                let x1 = min(x + w, 0.985)
                // Height rises toward the middle of the frame, like a real downtown.
                let centrality = 1.0 - abs((x + x1) / 2 - 0.5) * 1.6
                let top = 0.72 - (0.16 + rand() * 0.34) * max(centrality, 0.15) - rand() * 0.10
                rectShape(x, 1.0, x1, top)

                let cx = (x + x1) / 2
                if top < tallest { tallest = top; tallestX = cx }

                let roof = rand()
                if roof > 0.80 {                       // spire
                    rectShape(cx - 0.005, top, cx + 0.005, max(top - 0.10 - rand() * 0.08, 0.02))
                } else if roof > 0.62 {                // stepped setback
                    rectShape(x + w * 0.22, top, x1 - w * 0.22, top - 0.05)
                } else if roof > 0.50 {                // pitched roof
                    poly([(x, top), (x1, top), (cx, top - 0.06)])
                }

                // Sparse lit windows, punched through as holes by the even-odd fill.
                let cols = w > 0.085 ? 3 : 2
                var wy = top + 0.075
                while wy < 0.93 {
                    for c in 0..<cols {
                        if rand() > 0.45 { continue }
                        let wx = x + w * (0.20 + CGFloat(c) * 0.28)
                        rectShape(wx, wy, wx + 0.014, wy + 0.030)
                    }
                    wy += 0.075
                }
                x = x1 + 0.006 + rand() * 0.008
            }

            // A single mast on the tallest tower, so the skyline has a peak.
            rectShape(tallestX - 0.0035, tallest, tallestX + 0.0035, max(tallest - 0.13, 0.015))

        }
        return p
    }

    // MARK: Reusable pieces

    private func tower(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint, cx: CGFloat) {
        func rectS(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat) {
            p.move(to: pt(x0, y0)); p.addLine(to: pt(x1, y0))
            p.addLine(to: pt(x1, y1)); p.addLine(to: pt(x0, y1)); p.closeSubpath()
        }
        rectS(cx - 0.035, 0.79, cx - 0.015, 0.13)   // left leg
        rectS(cx + 0.015, 0.79, cx + 0.035, 0.13)   // right leg
        rectS(cx - 0.035, 0.16, cx + 0.035, 0.13)   // top brace
        rectS(cx - 0.035, 0.49, cx + 0.035, 0.45)   // mid brace
    }

    private func cable(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                       from: (CGFloat, CGFloat), to: (CGFloat, CGFloat), dip: CGFloat) {
        let control = ((from.0 + to.0) / 2, max(from.1, to.1) + dip)
        let th: CGFloat = 0.012
        p.move(to: pt(from.0, from.1))
        p.addQuadCurve(to: pt(to.0, to.1), control: pt(control.0, control.1))
        p.addQuadCurve(to: pt(from.0, from.1 + th), control: pt(control.0, control.1 + th))
        p.closeSubpath()
    }

    private func sail(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                      baseL: CGFloat, baseR: CGFloat, peakY: CGFloat) {
        p.move(to: pt(baseR, 0.80))
        p.addQuadCurve(to: pt(baseL + 0.02, peakY), control: pt(baseR, peakY + 0.12))
        p.addQuadCurve(to: pt(baseL, 0.80), control: pt(baseL - 0.01, 0.80))
        p.closeSubpath()
    }

    private func onionTower(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                            cx: CGFloat, baseY: CGFloat, domeTop: CGFloat, width: CGFloat, tall: Bool) {
        let half = width / 2
        let shaftTop = domeTop + (tall ? 0.16 : 0.13)
        // shaft
        p.move(to: pt(cx - half, baseY)); p.addLine(to: pt(cx + half, baseY))
        p.addLine(to: pt(cx + half, shaftTop)); p.addLine(to: pt(cx - half, shaftTop)); p.closeSubpath()
        // onion dome
        p.move(to: pt(cx - half, shaftTop))
        p.addQuadCurve(to: pt(cx, domeTop), control: pt(cx - half - 0.02, shaftTop - 0.05))
        p.addQuadCurve(to: pt(cx + half, shaftTop), control: pt(cx + half + 0.02, shaftTop - 0.05))
        p.closeSubpath()
        // spike + cross finial
        p.move(to: pt(cx - 0.008, domeTop)); p.addLine(to: pt(cx + 0.008, domeTop))
        p.addLine(to: pt(cx, domeTop - 0.06)); p.closeSubpath()
    }

    private func palm(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                      baseX: CGFloat, topX: CGFloat, topY: CGFloat) {
        // curved trunk
        p.move(to: pt(baseX - 0.012, 1.0))
        p.addQuadCurve(to: pt(topX - 0.006, topY), control: pt(baseX - 0.05, 0.6))
        p.addLine(to: pt(topX + 0.006, topY))
        p.addQuadCurve(to: pt(baseX + 0.012, 1.0), control: pt(baseX - 0.03, 0.6))
        p.closeSubpath()
        // fronds fanning from the crown
        let crown = (topX, topY)
        let angles: [Double] = [200, 235, 270, 305, 340, 160, 20]
        for deg in angles {
            let a = deg * .pi / 180
            let len = 0.16
            let tip = (crown.0 + CGFloat(cos(a)) * len, crown.1 - CGFloat(sin(a)) * len * 1.2)
            let mid = (crown.0 + CGFloat(cos(a)) * len * 0.5, crown.1 - CGFloat(sin(a)) * len * 0.5 - 0.03)
            p.move(to: pt(crown.0, crown.1))
            p.addQuadCurve(to: pt(tip.0, tip.1), control: pt(mid.0, mid.1))
            p.addQuadCurve(to: pt(crown.0 + 0.012, crown.1), control: pt(mid.0 + 0.01, mid.1 + 0.03))
            p.closeSubpath()
        }
    }

    /// A rounded arch-shaped hole (cut via eoFill).
    private func archHole(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                          x0: CGFloat, x1: CGFloat, baseY: CGFloat, springY: CGFloat, apexY: CGFloat) {
        let mid = (x0 + x1) / 2
        p.move(to: pt(x0, baseY))
        p.addLine(to: pt(x0, springY))
        p.addQuadCurve(to: pt(x1, springY), control: pt(mid, apexY))
        p.addLine(to: pt(x1, baseY))
        p.closeSubpath()
    }

    /// A filled half-dome sitting on `baseY`.
    private func domeHalf(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                          cx: CGFloat, baseY: CGFloat, rx: CGFloat, height: CGFloat) {
        p.move(to: pt(cx - rx, baseY))
        p.addQuadCurve(to: pt(cx + rx, baseY), control: pt(cx, baseY - height * 2))
        p.closeSubpath()
    }

    /// A curved arch "band" (two nested quad curves) for suspension/steel arches.
    private func bandArch(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                          from: (CGFloat, CGFloat), to: (CGFloat, CGFloat), peakY: CGFloat, thickness: CGFloat) {
        let ctrl = ((from.0 + to.0) / 2, peakY)
        p.move(to: pt(from.0, from.1))
        p.addQuadCurve(to: pt(to.0, to.1), control: pt(ctrl.0, ctrl.1))
        p.addQuadCurve(to: pt(from.0, from.1), control: pt(ctrl.0, ctrl.1 + thickness))
        p.closeSubpath()
    }

    /// A thin rectangular strut between two normalized points.
    private func bar(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                     a: (CGFloat, CGFloat), b: (CGFloat, CGFloat), th: CGFloat) {
        let dx = b.0 - a.0, dy = b.1 - a.1
        let len = max(0.0001, (dx * dx + dy * dy).squareRoot())
        let nx = -dy / len * th, ny = dx / len * th
        p.move(to: pt(a.0 + nx, a.1 + ny)); p.addLine(to: pt(b.0 + nx, b.1 + ny))
        p.addLine(to: pt(b.0 - nx, b.1 - ny)); p.addLine(to: pt(a.0 - nx, a.1 - ny)); p.closeSubpath()
    }

    /// Approximate y of a parabolic arch at x (for bridge hangers).
    private func archY(_ x: CGFloat, from: CGFloat, to: CGFloat, peak: CGFloat) -> CGFloat {
        let mid = (from + to) / 2, half = (to - from) / 2
        let t = (x - mid) / half
        let base: CGFloat = 0.70
        return base - (base - peak) * (1 - t * t)
    }

    private func superTree(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint, cx: CGFloat, topY: CGFloat) {
        p.move(to: pt(cx - 0.018, 1.0)); p.addLine(to: pt(cx + 0.018, 1.0))
        p.addLine(to: pt(cx + 0.05, topY)); p.addLine(to: pt(cx - 0.05, topY)); p.closeSubpath()
        for deg in [140.0, 115, 90, 65, 40] {
            let a = deg * .pi / 180
            let tip = (cx + CGFloat(cos(a)) * 0.13, topY - CGFloat(sin(a)) * 0.15)
            bar(&p, pt: pt, a: (cx, topY), b: tip, th: 0.006)
        }
    }

    private func spikes(_ p: inout Path, pt: (CGFloat, CGFloat) -> CGPoint,
                        cx: CGFloat, cy: CGFloat, r: CGFloat, count: Int) {
        for i in 0..<count {
            let a = Double.pi * (0.15 + 0.7 * Double(i) / Double(count - 1)) // fan across the top
            let tip = (cx + CGFloat(cos(a)) * r * 1.6, cy - CGFloat(sin(a)) * r * 1.6)
            let bl = (cx + CGFloat(cos(a + 0.16)) * r * 0.5, cy - CGFloat(sin(a + 0.16)) * r * 0.5)
            let br = (cx + CGFloat(cos(a - 0.16)) * r * 0.5, cy - CGFloat(sin(a - 0.16)) * r * 0.5)
            p.move(to: pt(tip.0, tip.1))
            p.addLine(to: pt(bl.0, bl.1))
            p.addLine(to: pt(br.0, br.1))
            p.closeSubpath()
        }
    }
}
