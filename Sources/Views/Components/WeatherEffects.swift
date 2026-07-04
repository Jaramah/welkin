import SwiftUI

/// Animated precipitation + stars drawn with Canvas, driven by the weather code.
struct WeatherEffects: View {
    let code: WeatherCode
    let sky: SkyMood

    var body: some View {
        switch sky {
        case .rain, .storm:
            RainCanvas(heavy: sky == .storm)
        case .snow:
            SnowCanvas()
        case .clearNight, .partlyNight:
            StarCanvas()
        default:
            Color.clear
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

private struct RainCanvas: View {
    let heavy: Bool
    private let drops: [(x: Double, phase: Double, len: Double, speed: Double, op: Double)]

    init(heavy: Bool) {
        self.heavy = heavy
        var rng = LCG(state: 88)
        let count = heavy ? 120 : 70
        drops = (0..<count).map { _ in
            (rng.next(), rng.next(), 0.04 + rng.next() * 0.06,
             0.7 + rng.next() * 0.6, 0.25 + rng.next() * 0.45)
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let slant = size.width * 0.05
                for d in drops {
                    let y = (d.phase + t * d.speed).truncatingRemainder(dividingBy: 1)
                    let x = d.x * size.width
                    let top = CGPoint(x: x, y: y * size.height)
                    let bottom = CGPoint(x: x - slant, y: (y + d.len) * size.height)
                    var line = Path()
                    line.move(to: top)
                    line.addLine(to: bottom)
                    ctx.stroke(line, with: .color(.white.opacity(d.op)), lineWidth: heavy ? 1.6 : 1.1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SnowCanvas: View {
    private let flakes: [(x: Double, phase: Double, size: Double, speed: Double, drift: Double)]

    init() {
        var rng = LCG(state: 1234)
        flakes = (0..<70).map { _ in
            (rng.next(), rng.next(), 1.5 + rng.next() * 3.0,
             0.15 + rng.next() * 0.2, 0.02 + rng.next() * 0.04)
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
                    ctx.fill(Path(ellipseIn: rectF), with: .color(.white.opacity(0.8)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StarCanvas: View {
    private let stars: [(x: Double, y: Double, r: Double, phase: Double)]

    init() {
        var rng = LCG(state: 7)
        stars = (0..<50).map { _ in
            (rng.next(), rng.next() * 0.6, 0.6 + rng.next() * 1.4, rng.next() * 6.28)
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for s in stars {
                    let twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 1.5 + s.phase))
                    let rectF = CGRect(x: s.x * size.width - s.r, y: s.y * size.height - s.r,
                                       width: s.r * 2, height: s.r * 2)
                    ctx.fill(Path(ellipseIn: rectF), with: .color(.white.opacity(twinkle)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
