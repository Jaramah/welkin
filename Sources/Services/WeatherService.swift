import Foundation

enum WeatherError: LocalizedError {
    case badURL
    case offline
    case timedOut
    case rateLimited
    case server(Int)
    case badResponse
    case decoding

    var errorDescription: String? {
        switch self {
        case .badURL: return "Could not build the request."
        case .offline: return "You appear to be offline. Check your connection and try again."
        case .timedOut: return "The request timed out. Try again."
        case .rateLimited: return "Too many requests just now. Give it a minute and try again."
        case .server(let code): return "The weather service returned an error (\(code))."
        case .badResponse: return "The weather service is unavailable right now."
        case .decoding: return "Received an unexpected response."
        }
    }

    /// Worth retrying automatically; a 4xx or a decode failure is not.
    var isTransient: Bool {
        switch self {
        case .timedOut, .server(_): return true
        default: return false
        }
    }
}

enum TemperatureUnit: String, CaseIterable, Sendable {
    case celsius, fahrenheit
    var apiValue: String { self == .celsius ? "celsius" : "fahrenheit" }
    var symbol: String { self == .celsius ? "°C" : "°F" }
    var windUnit: String { self == .celsius ? "kmh" : "mph" }
    var windLabel: String { self == .celsius ? "km/h" : "mph" }
}

/// Fetches and composes weather + air quality from Open-Meteo (no API key).
struct WeatherService {

    func fetch(for place: Place, unit: TemperatureUnit) async throws -> WeatherBundle {
        async let forecast = fetchForecast(place: place, unit: unit)
        async let air = fetchAirQuality(place: place)
        // The forecast is essential; air quality is best-effort. AQI comes from a
        // different host with its own uptime/limits, so a failure there must not
        // wipe out an otherwise-healthy forecast — the AQI card degrades gracefully.
        let forecastResult = try await forecast
        let airResult = try? await air
        return compose(place: place, forecast: forecastResult, air: airResult)
    }

    // MARK: Forecast

    private func fetchForecast(place: Place, unit: TemperatureUnit) async throws -> ForecastResponse {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            .init(name: "latitude", value: String(place.latitude)),
            .init(name: "longitude", value: String(place.longitude)),
            .init(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m,pressure_msl,cloud_cover"),
            .init(name: "hourly", value: "temperature_2m,precipitation_probability,precipitation,weather_code,is_day"),
            .init(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max"),
            .init(name: "temperature_unit", value: unit.apiValue),
            .init(name: "wind_speed_unit", value: unit.windUnit),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: "7"),
        ]
        return try await get(comps, as: ForecastResponse.self)
    }

    // MARK: Air quality

    private func fetchAirQuality(place: Place) async throws -> AirResponse {
        var comps = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        comps.queryItems = [
            .init(name: "latitude", value: String(place.latitude)),
            .init(name: "longitude", value: String(place.longitude)),
            .init(name: "current", value: "us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide"),
            .init(name: "hourly", value: "us_aqi"),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: "7"),
        ]
        return try await get(comps, as: AirResponse.self)
    }

    // MARK: Geocoding search

    func search(query: String) async throws -> [Place] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { return [] }
        var comps = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        comps.queryItems = [
            .init(name: "name", value: trimmed),
            .init(name: "count", value: "12"),
            .init(name: "language", value: "en"),
            .init(name: "format", value: "json"),
        ]
        let res = try await get(comps, as: GeoResponse.self)
        return (res.results ?? []).map {
            Place(id: String($0.id), name: $0.name, admin: $0.admin1,
                  country: $0.country, latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    // MARK: Networking

    /// One retry for genuinely transient failures (timeout, 5xx). A refresh that
    /// blips shouldn't put an error on screen when trying again would have worked.
    private func get<T: Decodable>(_ comps: URLComponents, as type: T.Type) async throws -> T {
        do {
            return try await attempt(comps, as: type)
        } catch let error as WeatherError where error.isTransient {
            try await Task.sleep(for: .milliseconds(600))
            return try await attempt(comps, as: type)
        }
    }

    private func attempt<T: Decodable>(_ comps: URLComponents, as: T.Type) async throws -> T {
        guard let url = comps.url else { throw WeatherError.badURL }
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch let error as URLError {
            // Cancellation is not a failure — it means a newer request superseded
            // this one (or the view went away). Reporting it as "the weather service
            // is unavailable" is a lie that puts a scary error on a healthy screen.
            switch error.code {
            case .cancelled: throw CancellationError()
            case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost:
                throw WeatherError.offline
            case .timedOut: throw WeatherError.timedOut
            default: throw WeatherError.badResponse
            }
        } catch is CancellationError {
            throw CancellationError()
        }
        guard let http = response as? HTTPURLResponse else { throw WeatherError.badResponse }
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 429 { throw WeatherError.rateLimited }
            throw WeatherError.server(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherError.decoding
        }
    }

    // MARK: Composition

    private func compose(place: Place, forecast: ForecastResponse, air: AirResponse?) -> WeatherBundle {
        let tz = TimeZone(identifier: forecast.timezone ?? "UTC") ?? .current

        let localParser = DateFormatter()
        localParser.locale = Locale(identifier: "en_US_POSIX")
        localParser.timeZone = tz
        localParser.dateFormat = "yyyy-MM-dd'T'HH:mm"

        func parse(_ s: String?) -> Date? { s.flatMap { localParser.date(from: $0) } }

        let isDay = (forecast.current.is_day ?? 1) == 1
        let code = WeatherCode(raw: forecast.current.weather_code, isDay: isDay)

        // Daily
        let d = forecast.daily
        var days: [DayPoint] = []
        let aqiDaily = dailyMaxAQI(from: air, timezone: tz)
        let rainWindows = rainWindows(from: forecast.hourly, parse: parse, timezone: tz)
        for i in d.time.indices {
            // Skip any day whose essential high/low is missing rather than crash
            // on a shorter-than-`time` sibling array or a null value.
            guard let high = d.temperature_2m_max[safe: i].flatMap({ $0 }),
                  let low = d.temperature_2m_min[safe: i].flatMap({ $0 }) else { continue }
            let dayDate = localParser.date(from: d.time[i] + "T00:00") ?? Date()
            let dCode = WeatherCode(raw: d.weather_code[safe: i].flatMap { $0 } ?? 0, isDay: true)
            let window = rainWindows[Self.dayKey(dayDate, tz: tz)]
            days.append(DayPoint(
                date: dayDate,
                high: high,
                low: low,
                precipitationProbability: d.precipitation_probability_max?[safe: i].flatMap { $0 } ?? 0,
                uvIndex: d.uv_index_max?[safe: i].flatMap { $0 } ?? 0,
                code: dCode,
                aqi: aqiDaily[Self.dayKey(dayDate, tz: tz)],
                rainStart: window?.start,
                rainEnd: window?.end
            ))
        }

        // Hourly — next 24 from current hour
        let h = forecast.hourly
        let now = parse(forecast.current.time) ?? Date()
        let startHour = Calendar.startOfHour(now, tz: tz)
        var hours: [HourPoint] = []
        for i in h.time.indices {
            guard let hd = parse(h.time[i]), hd >= startHour,
                  let temp = h.temperature_2m[safe: i].flatMap({ $0 }) else { continue }
            let hCode = WeatherCode(raw: h.weather_code[safe: i].flatMap { $0 } ?? 0, isDay: (h.is_day?[safe: i].flatMap { $0 } ?? 1) == 1)
            hours.append(HourPoint(
                date: hd,
                temperature: temp,
                precipitationProbability: h.precipitation_probability?[safe: i].flatMap { $0 } ?? 0,
                code: hCode
            ))
            if hours.count >= 24 { break }
        }

        let current = CurrentConditions(
            temperature: forecast.current.temperature_2m,
            apparentTemperature: forecast.current.apparent_temperature,
            humidity: Int(forecast.current.relative_humidity_2m.rounded()),
            windSpeed: forecast.current.wind_speed_10m,
            windDirection: forecast.current.wind_direction_10m,
            pressure: forecast.current.pressure_msl,
            cloudCover: Int(forecast.current.cloud_cover.rounded()),
            precipitation: forecast.current.precipitation,
            uvIndex: days.first?.uvIndex ?? 0,
            code: code,
            sunrise: parse(d.sunrise?.first ?? nil),
            sunset: parse(d.sunset?.first ?? nil),
            high: days.first?.high ?? forecast.current.temperature_2m,
            low: days.first?.low ?? forecast.current.temperature_2m
        )

        return WeatherBundle(
            place: place,
            timezone: tz,
            current: current,
            hourly: hours,
            daily: days,
            aqiNow: air?.current?.us_aqi.map { Int($0.rounded()) },
            pm25: air?.current?.pm2_5,
            pm10: air?.current?.pm10,
            ozone: air?.current?.ozone,
            no2: air?.current?.nitrogen_dioxide
        )
    }

    /// For each day, find the first and last hour with measurable precipitation.
    private func rainWindows(from hourly: ForecastResponse.Hourly,
                             parse: (String?) -> Date?,
                             timezone tz: TimeZone) -> [String: (start: Date, end: Date)] {
        guard let precip = hourly.precipitation else { return [:] }
        var result: [String: (start: Date, end: Date)] = [:]
        for i in hourly.time.indices {
            guard let mm = precip[safe: i].flatMap({ $0 }), mm >= 0.1,
                  let date = parse(hourly.time[i]) else { continue }
            let key = Self.dayKey(date, tz: tz)
            let hourEnd = date.addingTimeInterval(3600)
            if let existing = result[key] {
                result[key] = (min(existing.start, date), max(existing.end, hourEnd))
            } else {
                result[key] = (date, hourEnd)
            }
        }
        return result
    }

    /// Aggregate hourly US AQI into a per-day maximum keyed by yyyy-MM-dd.
    private func dailyMaxAQI(from air: AirResponse?, timezone tz: TimeZone) -> [String: Int] {
        guard let hourly = air?.hourly, let aqi = hourly.us_aqi else { return [:] }
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.timeZone = tz
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm"

        var result: [String: Int] = [:]
        for i in hourly.time.indices {
            guard let v = aqi[safe: i].flatMap({ $0 }),
                  let date = parser.date(from: hourly.time[i]) else { continue }
            let key = Self.dayKey(date, tz: tz)
            result[key] = max(result[key] ?? 0, Int(v.rounded()))
        }
        return result
    }

    private static func dayKey(_ date: Date, tz: TimeZone) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}

private extension Calendar {
    static func startOfHour(_ date: Date, tz: TimeZone) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
        return cal.date(from: comps) ?? date
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
