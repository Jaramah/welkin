import Foundation

/// A lightweight snapshot of the user's selected location, shared with the widget.
struct StoredPlace: Codable, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
}

/// App-Group-backed storage bridging the app and the widget extension.
enum SharedStore {
    static let appGroup = "group.com.aurora.weather"

    private static let placeKey = "selectedPlace"
    private static let unitKey = "temperatureUnit"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    static func save(place: StoredPlace) {
        guard let data = try? JSONEncoder().encode(place) else { return }
        defaults?.set(data, forKey: placeKey)
    }

    static func loadPlace() -> StoredPlace? {
        guard let data = defaults?.data(forKey: placeKey),
              let place = try? JSONDecoder().decode(StoredPlace.self, from: data) else { return nil }
        return place
    }

    static func save(unit: String) { defaults?.set(unit, forKey: unitKey) }

    static func loadUnit() -> String { defaults?.string(forKey: unitKey) ?? "fahrenheit" }
}
