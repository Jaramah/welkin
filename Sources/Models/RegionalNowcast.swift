import Foundation

/// Singapore-wide area-by-area 2-hour nowcast (from NEA via data.gov.sg).
struct RegionalNowcast: Sendable {
    let validPeriodText: String          // e.g. "4.00 am to 6.00 am"
    let areas: [AreaForecast]

    struct AreaForecast: Identifiable, Sendable {
        let name: String                 // e.g. "Ang Mo Kio"
        let forecast: String             // e.g. "Partly Cloudy (Night)"
        let latitude: Double?            // from NEA's area_metadata
        let longitude: Double?

        var id: String { name }
        var symbol: String { RegionalNowcast.symbol(for: forecast) }

        /// Tapping an area loads its full forecast — only possible if NEA gave us
        /// a coordinate for it.
        var place: Place? {
            guard let latitude, let longitude else { return nil }
            return Place(name: name, country: "Singapore",
                         latitude: latitude, longitude: longitude)
        }
    }

    /// Map NEA's forecast vocabulary to an SF Symbol, day/night aware.
    /// Order matters: check the most specific conditions first.
    static func symbol(for forecast: String) -> String {
        let f = forecast.lowercased()
        let night = f.contains("night")
        switch true {
        case f.contains("thunder"):
            return "cloud.bolt.rain.fill"
        case f.contains("drizzle"), f.contains("light rain"),
             f.contains("light shower"), f.contains("passing shower"):
            return "cloud.drizzle.fill"
        case f.contains("rain"), f.contains("shower"):
            return "cloud.rain.fill"
        case f.contains("fog"), f.contains("mist"):
            return "cloud.fog.fill"
        case f.contains("haz"):
            return "sun.haze.fill"
        case f.contains("wind"):
            return "wind"
        case f.contains("partly cloudy"):
            return night ? "cloud.moon.fill" : "cloud.sun.fill"
        case f.contains("cloudy"), f.contains("overcast"):
            return "cloud.fill"
        case f.contains("fair"), f.contains("clear"), f.contains("sunny"):
            return night ? "moon.stars.fill" : "sun.max.fill"
        default:
            return "cloud.fill"
        }
    }
}
