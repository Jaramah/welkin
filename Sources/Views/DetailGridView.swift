import SwiftUI

struct DetailGridView: View {
    let current: CurrentConditions
    let unit: TemperatureUnit
    let timezone: TimeZone

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            DetailTile(icon: "sun.max.fill", title: "UV Index",
                       value: "\(Int(current.uvIndex.rounded()))",
                       caption: uvLabel(current.uvIndex))
            DetailTile(icon: "humidity.fill", title: "Humidity",
                       value: "\(current.humidity)%",
                       caption: "Cloud \(current.cloudCover)%")
            DetailTile(icon: "wind", title: "Wind",
                       value: "\(Int(current.windSpeed.rounded()))",
                       caption: "\(unit.windLabel) \(compass(current.windDirection))")
            DetailTile(icon: "gauge.medium", title: "Pressure",
                       value: "\(Int(current.pressure.rounded()))",
                       caption: "hPa")
            DetailTile(icon: "thermometer.medium", title: "Feels Like",
                       value: "\(Int(current.apparentTemperature.rounded()))°",
                       caption: "Actual \(Int(current.temperature.rounded()))°")
            SunTile(sunrise: current.sunrise, sunset: current.sunset, timezone: timezone)
        }
    }

    private func uvLabel(_ v: Double) -> String {
        switch v {
        case ..<3: return "Low"
        case 3..<6: return "Moderate"
        case 6..<8: return "High"
        case 8..<11: return "Very High"
        default: return "Extreme"
        }
    }

    private func compass(_ deg: Int) -> String {
        let dirs = ["N","NE","E","SE","S","SW","W","NW"]
        let i = Int((Double(deg) / 45.0).rounded()) % 8
        return dirs[i]
    }
}

private struct DetailTile: View {
    let icon: String
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title.uppercased(), systemImage: icon)
                .font(Theme.label(12))
                .tracking(1)
                .foregroundStyle(Color.welkinTertiary)
            Text(value)
                .font(Theme.display(40))
                .foregroundStyle(Color.welkinPrimary)
            Text(caption)
                .font(Theme.body(13))
                .foregroundStyle(Color.welkinSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .padding(16)
        .glassSurface(cornerRadius: 22)
    }
}

private struct SunTile: View {
    let sunrise: Date?
    let sunset: Date?
    let timezone: TimeZone

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("SUN", systemImage: "sunrise.fill")
                .font(Theme.label(12))
                .tracking(1)
                .foregroundStyle(Color.welkinTertiary)
            Text(time(sunrise))
                .font(Theme.display(30))
                .foregroundStyle(Color.welkinPrimary)
            Label(time(sunset), systemImage: "sunset.fill")
                .font(Theme.body(13))
                .foregroundStyle(Color.welkinSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .padding(16)
        .glassSurface(cornerRadius: 22)
    }

    private func time(_ date: Date?) -> String {
        guard let date else { return "--" }
        let f = DateFormatter()
        f.timeZone = timezone
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
