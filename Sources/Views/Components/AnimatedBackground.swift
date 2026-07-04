import SwiftUI

/// A slowly drifting MeshGradient whose palette is driven by the current sky mood.
/// This is the core of Aurora's futuristic feel.
struct AnimatedBackground: View {
    let mood: SkyMood
    @State private var t: CGFloat = 0

    var body: some View {
        let colors = mood.colors
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints(time),
                colors: [
                    colors[0], colors[1], colors[0],
                    colors[2], colors[3], colors[2],
                    colors[1], colors[0], colors[3],
                ]
            )
            .ignoresSafeArea()
        }
        .overlay(
            // subtle vignette for depth
            RadialGradient(
                colors: [.clear, .black.opacity(0.35)],
                center: .center, startRadius: 200, endRadius: 620
            )
            .ignoresSafeArea()
            .blendMode(.multiply)
        )
        .animation(.easeInOut(duration: 1.2), value: mood)
    }

    private func meshPoints(_ time: Double) -> [SIMD2<Float>] {
        func wobble(_ base: SIMD2<Float>, _ ax: Double, _ ay: Double, _ phase: Double) -> SIMD2<Float> {
            let dx = Float(sin(time * ax + phase) * 0.06)
            let dy = Float(cos(time * ay + phase) * 0.06)
            return SIMD2(base.x + dx, base.y + dy)
        }
        return [
            SIMD2(0, 0), wobble(SIMD2(0.5, 0), 0.35, 0.5, 1.0), SIMD2(1, 0),
            wobble(SIMD2(0, 0.5), 0.4, 0.3, 2.0), wobble(SIMD2(0.5, 0.5), 0.5, 0.45, 0.0), wobble(SIMD2(1, 0.5), 0.3, 0.4, 3.0),
            SIMD2(0, 1), wobble(SIMD2(0.5, 1), 0.45, 0.35, 4.0), SIMD2(1, 1),
        ]
    }
}
