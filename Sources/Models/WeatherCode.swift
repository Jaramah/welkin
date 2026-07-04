import SwiftUI

/// WMO weather interpretation codes → symbol, label, and palette.
/// https://open-meteo.com/en/docs
struct WeatherCode: Equatable, Sendable {
    let raw: Int
    let isDay: Bool

    var label: String {
        switch raw {
        case 0: return "Clear"
        case 1: return "Mostly Clear"
        case 2: return "Partly Cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 56, 57: return "Freezing Drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing Rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow Grains"
        case 80, 81, 82: return "Rain Showers"
        case 85, 86: return "Snow Showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Hailstorm"
        default: return "Unknown"
        }
    }

    /// SF Symbol name, day/night aware.
    var symbol: String {
        switch raw {
        case 0: return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1: return isDay ? "sun.min.fill" : "moon.fill"
        case 2: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67: return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: return "cloud.snow.fill"
        case 80, 81, 82: return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 95: return "cloud.bolt.rain.fill"
        case 96, 99: return "cloud.bolt.fill"
        default: return "questionmark.circle"
        }
    }

    /// A weather "family" that drives the animated background palette.
    var sky: SkyMood {
        switch raw {
        case 0, 1: return isDay ? .clearDay : .clearNight
        case 2: return isDay ? .partlyDay : .partlyNight
        case 3, 45, 48: return .cloudy
        case 51...67, 80...82: return .rain
        case 71...77, 85, 86: return .snow
        case 95...99: return .storm
        default: return isDay ? .clearDay : .clearNight
        }
    }
}

/// Palettes for the MeshGradient background, tuned for a futuristic vibe.
enum SkyMood: Sendable {
    case clearDay, clearNight, partlyDay, partlyNight, cloudy, rain, snow, storm

    var colors: [Color] {
        func c(_ hex: UInt) -> Color {
            Color(
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255
            )
        }
        switch self {
        case .clearDay:    return [c(0x1E88E5), c(0x42A5F5), c(0x7E57C2), c(0x26C6DA)]
        case .clearNight:  return [c(0x0B1026), c(0x1A237E), c(0x311B92), c(0x0D253F)]
        case .partlyDay:   return [c(0x2979FF), c(0x5C6BC0), c(0x8E99F3), c(0x4DD0E1)]
        case .partlyNight: return [c(0x101B3B), c(0x283593), c(0x4527A0), c(0x122A4A)]
        case .cloudy:      return [c(0x37474F), c(0x546E7A), c(0x78909C), c(0x455A64)]
        case .rain:        return [c(0x1C2B4A), c(0x2C3E63), c(0x3F5C8C), c(0x1E3A5F)]
        case .snow:        return [c(0x4A6572), c(0x778CA3), c(0xA7BBC7), c(0x5C7A8C)]
        case .storm:       return [c(0x14121F), c(0x2A1B4D), c(0x4A148C), c(0x1A1030)]
        }
    }
}
