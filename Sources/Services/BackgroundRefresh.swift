import Foundation
import BackgroundTasks

/// Wakes the app periodically to re-check the weather and fire any alerts.
///
/// iOS decides when (and whether) to run this — it is opportunistic, not a
/// guarantee. Without a push server that is the best we can do, so treat the
/// near-term alerts as best-effort.
enum BackgroundRefresh {
    static let taskIdentifier = "com.github.jaramah.Welkin.refresh"

    /// Must be called before the app finishes launching.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(refreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)   // ~hourly at the earliest
        try? BGTaskScheduler.shared.submit(request)
    }

    /// BGAppRefreshTask isn't Sendable, so ferry it into the Task in a box —
    /// the same trick the widget uses for its completion handler.
    private struct Sendify<T>: @unchecked Sendable { let value: T }

    private static func handle(_ task: BGAppRefreshTask) {
        schedule()   // always queue the next one first

        let boxed = Sendify(value: task)
        let work = Task {
            await runChecks()
            boxed.value.setTaskCompleted(success: true)
        }
        task.expirationHandler = { work.cancel() }
    }

    /// Fetch the latest weather for the saved place and let the alert engine decide.
    static func runChecks() async {
        let settings = NotificationSettings.load()
        guard settings.anyEnabled else { return }
        guard let stored = SharedStore.loadPlace() else { return }

        let place = Place(name: stored.name,
                          latitude: stored.latitude,
                          longitude: stored.longitude)
        let unit = TemperatureUnit(rawValue: SharedStore.loadUnit()) ?? .celsius

        guard let bundle = try? await WeatherService().fetch(for: place, unit: unit) else { return }

        var nowcast: RegionalNowcast?
        if NEAService.covers(latitude: place.latitude, longitude: place.longitude) {
            nowcast = try? await NEAService().twoHourNowcast()
        }

        await NotificationService.shared.process(bundle: bundle,
                                                 nowcast: nowcast,
                                                 unit: unit,
                                                 settings: settings)
    }
}
