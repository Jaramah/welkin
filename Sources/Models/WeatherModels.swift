import Foundation

// MARK: - Domain models (clean, view-ready)

struct Place: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let admin: String?      // state / region
    let country: String?
    let latitude: Double
    let longitude: Double

    var subtitle: String {
        [admin, country].compactMap { $0 }.joined(separator: ", ")
    }

    init(id: String = UUID().uuidString, name: String, admin: String? = nil,
         country: String? = nil, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.admin = admin
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct CurrentConditions: Sendable {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let pressure: Double
    let cloudCover: Int
    let precipitation: Double
    let uvIndex: Double
    let code: WeatherCode
    let sunrise: Date?
    let sunset: Date?
    let high: Double
    let low: Double
}

struct HourPoint: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let precipitationProbability: Int
    let code: WeatherCode
}

struct DayPoint: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let high: Double
    let low: Double
    let precipitationProbability: Int
    let uvIndex: Double
    let code: WeatherCode
    let aqi: Int?
}

/// Everything the UI needs, composed by the service.
struct WeatherBundle: Sendable {
    let place: Place
    let timezone: TimeZone     // the location's timezone — used for all time display
    let current: CurrentConditions
    let hourly: [HourPoint]      // next 24h from now
    let daily: [DayPoint]        // 7 days
    let aqiNow: Int?
    let pm25: Double?
    let pm10: Double?
    let ozone: Double?
    let no2: Double?
}
