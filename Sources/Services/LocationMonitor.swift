import CoreLocation

/// Keeps near-term alerts pinned to where you actually are.
///
/// The one-shot `LocationManager` only knows your position while the app is open,
/// so a background alert fired against the last place you happened to save — walk
/// from Tampines to Bedok without opening Welkin and the rain alert kept naming
/// Tampines. This watches for significant location changes (~500 m) using the
/// low-power radio, which iOS delivers even when the app is suspended or was
/// terminated, and re-runs the alert checks against the new area.
///
/// Opt-in: it does nothing until the user turns on "Follow my location", which is
/// what asks for Always authorization.
@MainActor
final class LocationMonitor: NSObject {
    static let shared = LocationMonitor()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
    }

    /// Ask for Always permission and begin watching. Safe to call repeatedly —
    /// starting an already-started monitor is a no-op, and calling it on every
    /// launch is what re-arms delivery after iOS relaunches the app.
    func start() {
        manager.requestAlwaysAuthorization()
        manager.startMonitoringSignificantLocationChanges()
    }

    func stop() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    private func handle(_ coord: CLLocationCoordinate2D) {
        Task { await process(coord) }
    }

    private func process(_ coord: CLLocationCoordinate2D) async {
        let settings = NotificationSettings.load()
        // Only the near-term alerts care about position; the daily briefing doesn't.
        guard settings.followLocation, settings.nearTermAlertsEnabled else { return }

        // Name the area so the nowcast can be matched by name, not just coordinates
        // — the whole point of this is that "Bedok" resolves to NEA's Bedok.
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let mark = (try? await geocoder.reverseGeocodeLocation(location))?.first
        let name = mark?.subLocality
            ?? mark?.locality
            ?? mark?.subAdministrativeArea
            ?? mark?.name
            ?? "Current Location"

        SharedStore.save(place: StoredPlace(name: name,
                                            latitude: coord.latitude,
                                            longitude: coord.longitude))

        // Reuse the shared alert path, which now reads the place we just saved.
        await BackgroundRefresh.runChecks()
    }
}

// CoreLocation calls back on the thread the manager was created on (main here).
extension LocationMonitor: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        MainActor.assumeIsolated { handle(coord) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        // Significant-change failures are transient; the next movement retries.
    }
}
