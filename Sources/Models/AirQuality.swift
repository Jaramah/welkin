import SwiftUI

/// US AQI category with color + health guidance.
struct AQICategory: Sendable {
    let value: Int

    var label: String {
        switch value {
        case ..<51: return "Good"
        case 51..<101: return "Moderate"
        case 101..<151: return "Unhealthy for Sensitive"
        case 151..<201: return "Unhealthy"
        case 201..<301: return "Very Unhealthy"
        default: return "Hazardous"
        }
    }

    var shortLabel: String {
        switch value {
        case ..<51: return "Good"
        case 51..<101: return "Moderate"
        case 101..<151: return "Sensitive"
        case 151..<201: return "Unhealthy"
        case 201..<301: return "Very Bad"
        default: return "Hazardous"
        }
    }

    var color: Color {
        switch value {
        case ..<51: return Color(red: 0.20, green: 0.85, blue: 0.55)
        case 51..<101: return Color(red: 0.98, green: 0.82, blue: 0.25)
        case 101..<151: return Color(red: 0.98, green: 0.58, blue: 0.20)
        case 151..<201: return Color(red: 0.95, green: 0.30, blue: 0.35)
        case 201..<301: return Color(red: 0.66, green: 0.28, blue: 0.74)
        default: return Color(red: 0.55, green: 0.13, blue: 0.20)
        }
    }

    var guidance: String {
        switch value {
        case ..<51: return "Air quality is excellent. A perfect day to be outside."
        case 51..<101: return "Air quality is acceptable. Unusually sensitive people should take it easy."
        case 101..<151: return "Sensitive groups may feel effects. Consider limiting long outdoor exertion."
        case 151..<201: return "Everyone may begin to feel effects. Reduce prolonged outdoor activity."
        case 201..<301: return "Health alert. Avoid outdoor exertion and keep windows closed."
        default: return "Emergency conditions. Stay indoors with filtered air."
        }
    }

    /// 0...1 position on the AQI scale for gauges (capped at 300).
    var fraction: Double { min(Double(value) / 300.0, 1.0) }
}
