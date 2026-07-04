import SwiftUI

/// Full-screen precipitation, lightning, and stars, driven by the WMO weather code.
struct WeatherEffects: View {
    let code: WeatherCode
    let sky: SkyMood

    enum Effect { case none, sunny, fog, drizzle, rain, heavyRain, storm, snow, stars }

    var body: some View {
        ZStack {
            switch resolvedEffect {
            case .sunny:     SunnyCanvas()
            case .fog:       FogCanvas()
            case .drizzle:   RainCanvas(spec: .drizzle)
            case .rain:      RainCanvas(spec: .rain)
            case .heavyRain: RainCanvas(spec: .heavy)
            case .storm:     RainCanvas(spec: .heavy); LightningFlash()
            case .snow:      SnowCanvas()
            case .stars:     StarCanvas()
            case .none:      EmptyView()
            }
        }
        .allowsHitTesting(false)
    }

    private var resolvedEffect: Effect {
        switch code.raw {
        case 45, 48:                        return .fog
        case 51, 53, 55, 56, 57:            return .drizzle
        case 61, 63, 80, 81:                return .rain
        case 65, 66, 67, 82:                return .heavyRain
        case 71, 73, 75, 77, 85, 86:        return .snow
        case 95, 96, 99:                    return .storm
        case 0, 1:                          return code.isDay ? .sunny : .stars
        default:
            return (sky == .clearNight || sky == .partlyNight) ? .stars : .none
        }
    }
}

// MARK: - Deterministic tiny RNG so particle layouts are stable across redraws.

private struct LCG {
    var state: UInt64
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(1 << 53)
    }
}

// MARK: - Rain

private struct RainSpec {
    let count: Int
    let width: CGFloat
    let minLen, lenVar, minSpeed, speedVar, minOp, opVar, slant: Double

    static let drizzle = RainSpec(count: 60, width: 0.8, minLen: 0.015, lenVar: 0.02,
                                  minSpeed: 0.45, speedVar: 0.25, minOp: 0.12, opVar: 0.22, slant: 0.015)
    static let rain = RainSpec(count: 100, width: 1.1, minLen: 0.035, lenVar: 0.05,
                               minSpeed: 0.8, speedVar: 0.5, minOp: 0.18, opVar: 0.32, slant: 0.05)
    static let heavy = RainSpec(count: 160, width: 1.5, minLen: 0.05, lenVar: 0.06,
                                minSpeed: 1.1, speedVar: 0.6, minOp: 0.22, opVar: 0.4, slant: 0.09)
}

private struct RainCanvas: View {
    let spec: RainSpec
    private let drops: [(x: Double, phase: Double, len: Double, speed: Double, op: Double)]

    init(spec: RainSpec) {
        self.spec = spec
        var rng = LCG(state: 88)
        drops = (0..<spec.count).map { _ in
            (rng.next(), rng.next(),
             spec.minLen + rng.next() * spec.lenVar,
             spec.minSpeed + rng.next() * spec.speedVar,
             spec.minOp + rng.next() * spec.opVar)
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let slant = size.width * spec.slant
                for d in drops {
                    let y = (d.phase + t * d.speed).truncatingRemainder(dividingBy: 1)
                    let x = d.x * size.width
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: y * size.height))
                    line.addLine(to: CGPoint(x: x - slant, y: (y + d.len) * size.height))
                    ctx.stroke(line, with: .color(.white.opacity(d.op)), lineWidth: spec.width)
                }
            }
        }
    }
}

// MARK: - Snow

private struct SnowCanvas: View {
    private let flakes: [(x: Double, phase: Double, size: Double, speed: Double, drift: Double)]

    init() {
        var rng = LCG(state: 1234)
        flakes = (0..<90).map { _ in
            (rng.next(), rng.next(), 1.5 + rng.next() * 3.0,
             0.12 + rng.next() * 0.18, 0.02 + rng.next() * 0.04)
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for f in flakes {
                    let y = (f.phase + t * f.speed).truncatingRemainder(dividingBy: 1)
                    let wobble = sin(t * 1.2 + f.phase * 6.28) * f.drift
                    let x = (f.x + wobble) * size.width
                    let r = f.size
                    let rectF = CGRect(x: x - r, y: y * size.height - r, width: r * 2, height: r * 2)
                    ctx.fill(Path(ellipseIn: rectF), with: .color(.white.opacity(0.85)))
                }
            }
        }
    }
}

// MARK: - Stars

private struct StarCanvas: View {
    private let stars: [(x: Double, y: Double, r: Double, phase: Double)]

    init() {
        var rng = LCG(state: 7)
        stars = (0..<90).map { _ in
            (rng.next(), rng.next() * 0.9, 0.6 + rng.next() * 1.6, rng.next() * 6.28)
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for s in stars {
                    let twinkle = 0.35 + 0.6 * (0.5 + 0.5 * sin(t * 1.5 + s.phase))
                    let rectF = CGRect(x: s.x * size.width - s.r, y: s.y * size.height - s.r,
                                       width: s.r * 2, height: s.r * 2)
                    ctx.fill(Path(ellipseIn: rectF), with: .color(.white.opacity(twinkle)))
                }
            }
        }
    }
}

// MARK: - Sun (soft light motes drifting up through bright air)

private struct SunnyCanvas: View {
    private let motes: [(x: Double, y: Double, r: Double, phase: Double, speed: Double)]

    init() {
        var rng = LCG(state: 314)
        motes = (0..<20).map { _ in
            (rng.next(), rng.next(), 8 + rng.next() * 20, rng.next() * 6.28, 0.015 + rng.next() * 0.025)
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let warm = Color(red: 1.0, green: 0.95, blue: 0.78)
                for m in motes {
                    let yy = ((m.y - t * m.speed).truncatingRemainder(dividingBy: 1) + 1)
                        .truncatingRemainder(dividingBy: 1)
                    let x = (m.x + sin(t * 0.3 + m.phase) * 0.02) * size.width
                    let y = yy * size.height
                    let op = 0.05 + 0.09 * (0.5 + 0.5 * sin(t * 0.9 + m.phase))
                    let rect = CGRect(x: x - m.r, y: y - m.r, width: m.r * 2, height: m.r * 2)
                    ctx.fill(Path(ellipseIn: rect),
                             with: .radialGradient(Gradient(colors: [warm.opacity(op), warm.opacity(0)]),
                                                   center: CGPoint(x: x, y: y), startRadius: 0, endRadius: m.r))
                }
            }
        }
    }
}

// MARK: - Fog (soft mist banks drifting horizontally)

private struct FogCanvas: View {
    private let banks: [(y: Double, r: Double, phase: Double, speed: Double, op: Double)]

    init() {
        var rng = LCG(state: 99)
        banks = (0..<6).map { _ in
            (0.12 + rng.next() * 0.76, 0.36 + rng.next() * 0.26, rng.next(),
             (rng.next() < 0.5 ? -1 : 1) * (0.012 + rng.next() * 0.02), 0.10 + rng.next() * 0.12)
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for b in banks {
                    let raw = (b.phase + t * b.speed).truncatingRemainder(dividingBy: 1)
                    let frac = (raw + 1).truncatingRemainder(dividingBy: 1)
                    let cx = (frac * 1.5 - 0.25) * size.width
                    let cy = b.y * size.height
                    let rx = b.r * size.width
                    let ry = rx * 0.42
                    let rect = CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2)
                    ctx.fill(Path(ellipseIn: rect),
                             with: .radialGradient(Gradient(colors: [Color.white.opacity(b.op), Color.white.opacity(0)]),
                                                   center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: rx))
                }
            }
        }
    }
}

// MARK: - Lightning

private struct LightningFlash: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let period = 5.0
            let p = t.truncatingRemainder(dividingBy: period)
            let intensity = flash(p)
            let strike = Int(t / period)
            ZStack {
                Rectangle().fill(Color.white.opacity(intensity * 0.45))
                if intensity > 0.25 {
                    Bolt(seed: strike)
                        .stroke(Color.white.opacity(min(1, intensity * 1.4)),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .shadow(color: .white.opacity(0.8), radius: 6)
                }
            }
        }
    }

    /// Two quick flashes at the start of each period, then dark.
    private func flash(_ p: Double) -> Double {
        if p < 0.10 { return 1.0 - p / 0.10 }
        if p >= 0.16 && p < 0.24 { return 0.6 * (1 - (p - 0.16) / 0.08) }
        return 0
    }
}

private struct Bolt: Shape {
    let seed: Int
    func path(in rect: CGRect) -> Path {
        var rng = LCG(state: UInt64(bitPattern: Int64(seed &* 2_654_435_761 &+ 1)))
        var p = Path()
        var x = rect.width * (0.25 + rng.next() * 0.5)
        var y = rect.minY
        p.move(to: CGPoint(x: x, y: y))
        let segments = 6
        let segH = rect.height * 0.55 / Double(segments)
        for _ in 0..<segments {
            x += (rng.next() - 0.5) * rect.width * 0.16
            y += segH
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }
}
