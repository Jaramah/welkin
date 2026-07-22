import Foundation

/// The forecast models Welkin compares. Three of the majors, run by different
/// national services on different physics — where they diverge is the honest
/// measure of how settled the forecast is.
enum ForecastModel: String, CaseIterable, Sendable, Identifiable {
    case ecmwf, gfs, icon

    var id: String { rawValue }

    /// Open-Meteo model id.
    var apiID: String {
        switch self {
        case .ecmwf: return "ecmwf_ifs025"
        case .gfs:   return "gfs_seamless"
        case .icon:  return "icon_seamless"
        }
    }

    /// Short label for the column header.
    var label: String {
        switch self {
        case .ecmwf: return "ECMWF"
        case .gfs:   return "GFS"
        case .icon:  return "ICON"
        }
    }
}

/// Several models' take on the same few days.
struct ModelComparison: Sendable {
    struct Value: Sendable, Identifiable {
        let model: ForecastModel
        let high: Double
        let code: WeatherCode
        var id: String { model.id }
    }

    struct Day: Sendable, Identifiable {
        let date: Date
        let values: [Value]
        var id: Date { date }

        /// The spread in the day's high across models, in degrees — the disagreement.
        var spread: Double {
            let highs = values.map(\.high)
            guard let lo = highs.min(), let hi = highs.max() else { return 0 }
            return hi - lo
        }
    }

    let days: [Day]
    /// The models that actually returned data, in display order.
    let models: [ForecastModel]
}

/// Best-effort multi-model fetch. Each model is a separate Open-Meteo request (a single
/// `models=` value keeps the response under the standard keys, so no dynamic decoding),
/// run concurrently; a model that fails simply drops out of the comparison.
struct ModelCompareService {
    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 12
        c.waitsForConnectivity = false
        return URLSession(configuration: c)
    }()

    func compare(for place: Place, unit: TemperatureUnit, days: Int = 3) async -> ModelComparison? {
        async let e = fetch(.ecmwf, place: place, unit: unit, days: days)
        async let g = fetch(.gfs, place: place, unit: unit, days: days)
        async let i = fetch(.icon, place: place, unit: unit, days: days)
        let fetched = [await e, await g, await i].compactMap { $0 }

        // Fewer than two models agreeing on nothing to compare — hide the card rather
        // than show a single column dressed up as a comparison.
        guard fetched.count >= 2 else { return nil }

        // Regroup per-model rows into per-day rows, keyed by calendar day, keeping only
        // days every returned model covers so no column is silently blank.
        let models = fetched.map(\.model)
        let calendar = Calendar(identifier: .gregorian)
        var byDay: [Date: [ModelComparison.Value]] = [:]
        for series in fetched {
            for row in series.rows {
                let day = calendar.startOfDay(for: row.date)
                byDay[day, default: []].append(
                    .init(model: series.model, high: row.high, code: row.code))
            }
        }

        let complete = byDay
            .filter { $0.value.count == models.count }
            .sorted { $0.key < $1.key }
            .prefix(days)
            .map { ModelComparison.Day(date: $0.key, values: order($0.value, by: models)) }

        guard !complete.isEmpty else { return nil }
        return ModelComparison(days: Array(complete), models: models)
    }

    /// Keep the values in the header's column order.
    private func order(_ values: [ModelComparison.Value],
                       by models: [ForecastModel]) -> [ModelComparison.Value] {
        models.compactMap { m in values.first { $0.model == m } }
    }

    private struct Series { let model: ForecastModel; let rows: [Row] }
    private struct Row { let date: Date; let high: Double; let code: WeatherCode }

    private func fetch(_ model: ForecastModel, place: Place,
                       unit: TemperatureUnit, days: Int) async -> Series? {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            .init(name: "latitude", value: String(place.latitude)),
            .init(name: "longitude", value: String(place.longitude)),
            .init(name: "daily", value: "weather_code,temperature_2m_max"),
            .init(name: "models", value: model.apiID),
            .init(name: "temperature_unit", value: unit.apiValue),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: String(days)),
        ]
        guard let url = comps.url,
              let (data, response) = try? await session.data(from: url),
              let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode,
              let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let daily = decoded.daily else { return nil }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: decoded.timezone ?? "UTC") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"

        // Parallel arrays; walk only the length they all share so an index is always valid.
        let count = min(daily.time.count, daily.temperature_2m_max.count, daily.weather_code.count)
        var rows: [Row] = []
        for index in 0..<count {
            guard let date = formatter.date(from: daily.time[index]),
                  let high = daily.temperature_2m_max[index],
                  let raw = daily.weather_code[index] else { continue }
            rows.append(Row(date: date, high: high, code: WeatherCode(raw: raw, isDay: true)))
        }
        guard !rows.isEmpty else { return nil }
        return Series(model: model, rows: rows)
    }

    private struct Response: Decodable {
        let timezone: String?
        let daily: Daily?
        struct Daily: Decodable {
            let time: [String]
            let temperature_2m_max: [Double?]
            let weather_code: [Int?]
        }
    }
}
