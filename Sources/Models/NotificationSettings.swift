import Foundation

/// Which weather alerts the user wants. Persisted locally.
struct NotificationSettings: Codable, Equatable, Sendable {
    var rainAlerts: Bool = true
    var hazeAlerts: Bool = true
    var severeAlerts: Bool = true
    var dailyBriefing: Bool = true
    var briefingHour: Int = 7          // 24-hour clock

    var anyEnabled: Bool { rainAlerts || hazeAlerts || severeAlerts || dailyBriefing }

    private static let key = "notificationSettings"

    static func load() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data)
        else { return NotificationSettings() }
        return decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}
