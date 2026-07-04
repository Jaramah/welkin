import Foundation

// MARK: - Open-Meteo wire models (Codable, match API JSON exactly)

struct ForecastResponse: Decodable, Sendable {
    let timezone: String?
    let current: Current
    let hourly: Hourly
    let daily: Daily

    struct Current: Decodable, Sendable {
        let time: String?
        let temperature_2m: Double
        let relative_humidity_2m: Double
        let apparent_temperature: Double
        let is_day: Int?
        let precipitation: Double
        let weather_code: Int
        let wind_speed_10m: Double
        let wind_direction_10m: Int
        let pressure_msl: Double
        let cloud_cover: Double
    }

    struct Hourly: Decodable, Sendable {
        let time: [String]
        let temperature_2m: [Double]
        let precipitation_probability: [Int?]?
        let weather_code: [Int]
        let is_day: [Int?]?
    }

    struct Daily: Decodable, Sendable {
        let time: [String]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let sunrise: [String?]?
        let sunset: [String?]?
        let uv_index_max: [Double?]?
        let precipitation_probability_max: [Int?]?
    }
}

struct AirResponse: Decodable, Sendable {
    let current: Current?
    let hourly: Hourly?

    struct Current: Decodable, Sendable {
        let us_aqi: Double?
        let pm2_5: Double?
        let pm10: Double?
        let ozone: Double?
        let nitrogen_dioxide: Double?
    }

    struct Hourly: Decodable, Sendable {
        let time: [String]
        let us_aqi: [Double?]?
    }
}

struct GeoResponse: Decodable, Sendable {
    let results: [Result]?

    struct Result: Decodable, Sendable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?
    }
}
