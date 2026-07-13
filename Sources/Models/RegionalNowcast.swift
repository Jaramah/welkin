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

        /// NEA's forecast expressed as a WMO code, so it can drive the same icon,
        /// label and background palette the rest of the app already understands.
        func weatherCode(isDay: Bool) -> WeatherCode {
            WeatherCode(raw: RegionalNowcast.wmoCode(for: forecast), isDay: isDay)
        }
    }

    /// The area nearest a coordinate. NEA's 47 towns blanket the island, so the
    /// closest one is the right nowcast for wherever you are standing.
    func nearest(toLatitude lat: Double, longitude lon: Double) -> AreaForecast? {
        areas
            .compactMap { area -> (AreaForecast, Double)? in
                guard let alat = area.latitude, let alon = area.longitude else { return nil }
                // Planar distance is fine at this scale (Singapore is ~50 km across);
                // scale longitude by cos(lat) so it isn't over-weighted.
                let dy = alat - lat
                let dx = (alon - lon) * cos(lat * .pi / 180)
                return (area, dy * dy + dx * dx)
            }
            .min { $0.1 < $1.1 }?
            .0
    }

    /// Fetch the local nowcast for a place, where one exists. Returns nil outside
    /// coverage or if the service is unreachable — callers then keep the model's
    /// own reading, so this can only ever improve the answer, never break it.
    static func fetch(for place: Place) async -> RegionalNowcast? {
        guard NEAService.covers(latitude: place.latitude, longitude: place.longitude) else {
            return nil
        }
        return try? await NEAService().twoHourNowcast()
    }

    /// Map NEA's vocabulary to the WMO codes Open-Meteo uses.
    /// Order matters: check the most specific conditions first.
    static func wmoCode(for forecast: String) -> Int {
        let f = forecast.lowercased()
        switch true {
        case f.contains("gusty"):                       return 99   // hail/severe storm
        case f.contains("heavy thunder"):               return 96
        case f.contains("thunder"):                     return 95
        case f.contains("heavy shower"):                return 81
        case f.contains("passing shower"), f.contains("light shower"):
                                                        return 80
        case f.contains("shower"):                      return 80
        case f.contains("heavy rain"):                  return 65
        case f.contains("moderate rain"):               return 63
        case f.contains("light rain"), f.contains("drizzle"):
                                                        return 51
        case f.contains("rain"):                        return 63
        case f.contains("fog"), f.contains("mist"):     return 45
        case f.contains("haz"):                         return 45
        case f.contains("overcast"):                    return 3
        case f.contains("partly cloudy"):               return 2
        case f.contains("cloudy"):                      return 3
        case f.contains("wind"):                        return 3
        case f.contains("fair"), f.contains("clear"), f.contains("sunny"):
                                                        return 0
        default:                                        return 2
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

extension WeatherBundle {
    /// Replace the global model's current condition with the local met service's
    /// reading for the nearest area (NEA in Singapore).
    ///
    /// The app, the tapped-area sheet and the widget all go through this one
    /// function. When only the app knew about NEA, the widget kept showing the
    /// model's "drizzle" beside an app that said "partly cloudy" — the same
    /// contradiction, one screen over. Keeping the rule in a single place is what
    /// stops the two from drifting apart again.
    func applyingLocalNowcast(_ nowcast: RegionalNowcast?) -> WeatherBundle {
        guard let nowcast,
              let area = nowcast.nearest(toLatitude: place.latitude,
                                         longitude: place.longitude)
        else { return self }

        var updated = self
        updated.current.code = area.weatherCode(isDay: current.code.isDay)
        updated.current.sourceNote = nowcast.validPeriodText.isEmpty
            ? "NEA nowcast"
            : "NEA nowcast · \(nowcast.validPeriodText)"
        return updated
    }
}
