import Foundation

/// Fetches Singapore's NEA 2-hour weather nowcast (free, no API key).
/// https://data.gov.sg — v2 real-time API.
struct NEAService: Sendable {

    /// True when a coordinate falls within Singapore's rough bounding box.
    static func covers(latitude: Double, longitude: Double) -> Bool {
        (1.13...1.48).contains(latitude) && (103.55...104.15).contains(longitude)
    }

    func twoHourNowcast() async throws -> RegionalNowcast {
        let url = URL(string: "https://api-open.data.gov.sg/v2/real-time/api/two-hr-forecast")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard let item = decoded.data.items.first else {
            throw URLError(.zeroByteResource)
        }
        // area_metadata carries each area's coordinate — join it to the forecasts
        // so a tapped area can be opened as a place.
        let coords = Dictionary(
            decoded.data.area_metadata.map { ($0.name, $0.label_location) },
            uniquingKeysWith: { first, _ in first }
        )
        let areas = item.forecasts
            .map { f in
                RegionalNowcast.AreaForecast(
                    name: f.area,
                    forecast: f.forecast,
                    latitude: coords[f.area]?.latitude,
                    longitude: coords[f.area]?.longitude
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return RegionalNowcast(validPeriodText: item.valid_period.text ?? "", areas: areas)
    }

    // MARK: Wire models (match the v2 JSON exactly)

    private struct Response: Decodable {
        let data: DataBlock

        struct DataBlock: Decodable {
            let area_metadata: [AreaMeta]
            let items: [Item]
        }
        struct AreaMeta: Decodable {
            let name: String
            let label_location: LabelLocation
        }
        struct LabelLocation: Decodable {
            let latitude: Double
            let longitude: Double
        }
        struct Item: Decodable {
            let valid_period: ValidPeriod
            let forecasts: [Forecast]
        }
        struct ValidPeriod: Decodable {
            let text: String?
        }
        struct Forecast: Decodable {
            let area: String
            let forecast: String
        }
    }
}
