import SwiftUI

/// The signature "living postcard": the city's landmark silhouette under a sky
/// that reflects the real weather — sun/moon by time of day, stars, and precip.
struct LandmarkSceneView: View {
    let landmark: Landmark
    let code: WeatherCode
    let sky: SkyMood
    let sunrise: Date?
    let sunset: Date?
    var height: CGFloat = 210
    var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Parallax: background lags, foreground leads, as the page scrolls.
            let bg = scrollOffset * 0.35
            let fg = scrollOffset * -0.08
            ZStack {
                // Celestial glow (sun or moon) — deepest layer, moves most
                if let c = celestial {
                    Circle()
                        .fill(c.color)
                        .frame(width: c.radius * 2, height: c.radius * 2)
                        .position(x: c.x * w, y: c.y * h)
                        .shadow(color: c.color.opacity(0.9), radius: c.glow)
                        .blur(radius: c.isMoon ? 0.5 : 0)
                        .offset(y: bg)
                }

                // The landmark silhouette — foreground layer
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ZStack {
                        LandmarkShape(kind: landmark.kind, seed: landmark.seed)
                            .fill(silhouetteGradient, style: FillStyle(eoFill: true))
                        LandmarkShape(kind: landmark.kind, seed: landmark.seed)
                            .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
                    }
                    .frame(height: h * 0.82)
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
                }
                .offset(y: fg)
            }
        }
        .frame(height: height)
        .clipped()
    }

    // MARK: Silhouette styling

    private var silhouetteGradient: LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.7), .black.opacity(0.9)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var tint: Color {
        switch landmark.kind {
        case .tokyoTower:      return Color(red: 0.55, green: 0.14, blue: 0.12)   // red lattice
        case .statueOfLiberty: return Color(red: 0.16, green: 0.35, blue: 0.33)   // copper patina
        case .goldenGate:      return Color(red: 0.55, green: 0.22, blue: 0.12)   // international orange
        case .pyramids:        return Color(red: 0.35, green: 0.28, blue: 0.16)   // sandstone
        case .stBasils:        return Color(red: 0.45, green: 0.16, blue: 0.26)   // painted domes
        case .tableMountain:   return Color(red: 0.24, green: 0.20, blue: 0.16)   // rock
        case .palmTrees:       return Color(red: 0.08, green: 0.18, blue: 0.14)   // fronds
        case .parthenon, .colosseum: return Color(red: 0.28, green: 0.26, blue: 0.22) // marble/travertine
        case .superTrees:      return Color(red: 0.10, green: 0.20, blue: 0.16)   // canopy
        case .sugarloaf, .chichenItza: return Color(red: 0.20, green: 0.17, blue: 0.14) // rock/stone
        case .gatewayArch, .atomium, .petronasTowers, .singaporeFlyer: return Color(red: 0.14, green: 0.16, blue: 0.22) // steel
        case .taipei101, .orientalPearl, .bankOfChina, .skyTower, .namsanTower:
                               return Color(red: 0.13, green: 0.17, blue: 0.24)   // glass & steel
        case .templeOfHeaven:  return Color(red: 0.10, green: 0.22, blue: 0.30)   // blue roofs
        case .burjAlArab:      return Color(red: 0.10, green: 0.18, blue: 0.32)   // sail
        case .esplanade:       return Color(red: 0.30, green: 0.25, blue: 0.15)   // bronze sunshades
        case .torii:           return Color(red: 0.50, green: 0.13, blue: 0.11)   // vermillion
        case .watArun, .angkorWat, .gatewayOfIndia, .belemTower:
                               return Color(red: 0.30, green: 0.26, blue: 0.19)   // temple stone
        case .monas:           return Color(red: 0.32, green: 0.27, blue: 0.14)   // gilded flame
        default:               return Color(red: 0.05, green: 0.06, blue: 0.12)
        }
    }

    // MARK: Sun / moon placement

    private struct Celestial {
        let x: CGFloat, y: CGFloat, radius: CGFloat, glow: CGFloat
        let color: Color, isMoon: Bool
    }

    private var celestial: Celestial? {
        let isDay = code.isDay
        switch sky {
        case .clearDay, .partlyDay:
            let f = dayFraction()
            let x = 0.14 + 0.72 * f
            let y = 0.62 - sin(f * .pi) * 0.42          // arc: low at horizon, high at noon
            return Celestial(x: x, y: max(0.08, y), radius: 20, glow: 34,
                             color: Color(red: 1.0, green: 0.9, blue: 0.55), isMoon: false)
        case .clearNight, .partlyNight:
            return Celestial(x: 0.76, y: 0.24, radius: 16, glow: 20,
                             color: Color(red: 0.92, green: 0.94, blue: 1.0), isMoon: true)
        default:
            // Overcast/rain/snow/storm: a faint diffuse glow, if daytime.
            guard isDay else { return nil }
            return Celestial(x: 0.7, y: 0.24, radius: 26, glow: 30,
                             color: .white.opacity(0.12), isMoon: false)
        }
    }

    /// 0 at sunrise → 1 at sunset; 0.5 mid-day fallback if we lack sun times.
    private func dayFraction() -> CGFloat {
        guard let sunrise, let sunset, sunset > sunrise else { return 0.5 }
        let now = Date()
        let f = now.timeIntervalSince(sunrise) / sunset.timeIntervalSince(sunrise)
        return CGFloat(min(max(f, 0.02), 0.98))
    }
}
