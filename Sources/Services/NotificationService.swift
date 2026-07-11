import Foundation
import UserNotifications

/// Local weather alerts.
///
/// There is no push server, so the near-term alerts (rain, haze, storms) are
/// evaluated whenever the app refreshes or iOS grants a background refresh —
/// which the system schedules at its own discretion. The daily briefing is a
/// calendar-triggered notification, so it fires reliably.
struct NotificationService: Sendable {
    static let shared = NotificationService()

    private var center: UNUserNotificationCenter { .current() }

    // MARK: Authorization

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    // MARK: Entry point

    func process(bundle: WeatherBundle,
                 nowcast: RegionalNowcast?,
                 unit: TemperatureUnit,
                 settings: NotificationSettings) async {
        guard settings.anyEnabled, await isAuthorized() else { return }

        if settings.severeAlerts { await severeAlert(bundle) }
        if settings.rainAlerts { await rainAlert(bundle, nowcast: nowcast) }
        if settings.hazeAlerts { await hazeAlert(bundle) }
        if settings.dailyBriefing {
            await scheduleBriefings(bundle, unit: unit, hour: settings.briefingHour)
        } else {
            center.removePendingNotificationRequests(
                withIdentifiers: (0..<3).map { "briefing-\($0)" })
        }
    }

    // MARK: Individual alerts

    /// Thunderstorms now or in the next few hours.
    private func severeAlert(_ bundle: WeatherBundle) async {
        let codes = [bundle.current.code.raw] + bundle.hourly.prefix(3).map(\.code.raw)
        guard codes.contains(where: { [95, 96, 99].contains($0) }) else { return }
        guard consume("severe", cooldown: 3 * 3600) else { return }
        await post(id: "severe",
                   title: "Thunderstorm warning",
                   body: "Storms around \(bundle.place.name). Best to stay indoors.")
    }

    /// Rain within the next two hours — from the NEA nowcast for the user's own
    /// area when available, otherwise from the hourly precipitation probability.
    private func rainAlert(_ bundle: WeatherBundle, nowcast: RegionalNowcast?) async {
        if let area = nearestArea(in: nowcast, to: bundle.place), isWet(area.forecast) {
            guard consume("rain", cooldown: 3 * 3600) else { return }
            await post(id: "rain",
                       title: "Rain expected in \(area.name)",
                       body: "\(area.forecast) within the next 2 hours.")
            return
        }
        let soon = bundle.hourly.prefix(2).map(\.precipitationProbability)
        guard let peak = soon.max(), peak >= 60 else { return }
        guard consume("rain", cooldown: 3 * 3600) else { return }
        await post(id: "rain",
                   title: "Rain likely in \(bundle.place.name)",
                   body: "\(peak)% chance of rain in the next couple of hours.")
    }

    /// Haze / unhealthy air.
    private func hazeAlert(_ bundle: WeatherBundle) async {
        guard let aqi = bundle.aqiNow, aqi >= 101 else { return }
        guard consume("haze", cooldown: 6 * 3600) else { return }
        let category = AQICategory(value: aqi)
        await post(id: "haze",
                   title: "Air quality: \(category.label)",
                   body: "AQI \(aqi) in \(bundle.place.name). Consider limiting time outdoors.")
    }

    /// Pre-schedule the next few mornings from the 7-day forecast, so each one
    /// carries that day's real numbers rather than stale text.
    private func scheduleBriefings(_ bundle: WeatherBundle,
                                   unit: TemperatureUnit,
                                   hour: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: (0..<3).map { "briefing-\($0)" })

        let calendar = Calendar.current
        var scheduled = 0

        for day in bundle.daily where scheduled < 3 {
            guard let fire = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day.date),
                  fire > Date() else { continue }

            var body = "\(temp(day.high, unit)) / \(temp(day.low, unit)), \(day.code.label.lowercased())."
            if let start = day.rainStart, let end = day.rainEnd {
                body += " Rain \(clock(start, bundle.timezone))–\(clock(end, bundle.timezone))."
            } else if day.precipitationProbability >= 40 {
                body += " \(day.precipitationProbability)% chance of rain."
            }
            if let aqi = day.aqi { body += " AQI \(aqi)." }

            let content = UNMutableNotificationContent()
            content.title = "Today in \(bundle.place.name)"
            content.body = body
            content.sound = .default

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: "briefing-\(scheduled)",
                                                        content: content, trigger: trigger))
            scheduled += 1
        }
    }

    // MARK: Helpers

    private func post(id: String, title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        // nil trigger → deliver immediately
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: nil))
    }

    /// True at most once per `cooldown`, so a repeating background check can't spam.
    private func consume(_ key: String, cooldown: TimeInterval) -> Bool {
        let defaults = UserDefaults.standard
        let storageKey = "alert.lastSent.\(key)"
        let last = defaults.double(forKey: storageKey)
        let now = Date().timeIntervalSince1970
        guard now - last > cooldown else { return false }
        defaults.set(now, forKey: storageKey)
        return true
    }

    private func isWet(_ forecast: String) -> Bool {
        let f = forecast.lowercased()
        return f.contains("rain") || f.contains("shower")
            || f.contains("thunder") || f.contains("drizzle")
    }

    private func nearestArea(in nowcast: RegionalNowcast?,
                             to place: Place) -> RegionalNowcast.AreaForecast? {
        guard let areas = nowcast?.areas else { return nil }
        var best: (area: RegionalNowcast.AreaForecast, distance: Double)?
        for area in areas {
            guard let lat = area.latitude, let lon = area.longitude else { continue }
            let dLat = lat - place.latitude, dLon = lon - place.longitude
            let d = dLat * dLat + dLon * dLon           // squared degrees is enough to rank
            if best == nil || d < best!.distance { best = (area, d) }
        }
        return best?.area
    }

    private func temp(_ value: Double, _ unit: TemperatureUnit) -> String {
        "\(Int(value.rounded()))\(unit.symbol)"
    }

    private func clock(_ date: Date, _ timezone: TimeZone) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        f.setLocalizedDateFormatFromTemplate("j")
        return f.string(from: date)
    }
}
