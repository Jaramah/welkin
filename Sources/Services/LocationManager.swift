import CoreLocation

/// Thin async wrapper around CoreLocation for a one-shot current fix.
///
/// The subtlety here is that CoreLocation will happily answer with a *memory*.
/// `requestLocation()` hands back the cached last-known fix as soon as it satisfies
/// `desiredAccuracy`, and a fix taken in Geylang an hour ago has excellent accuracy —
/// it is precisely, confidently wrong. That is how the app could sit at Raffles Place
/// and report Geylang, five kilometres away. Accuracy says how tightly the position is
/// known; it says nothing about *when*. So every fix is checked for age as well, and a
/// stale one is refused rather than shown.
///
/// Refusing a fix means `requestLocation()` is no longer usable — it delivers exactly
/// once and gives up — so this takes a short `startUpdatingLocation` burst instead and
/// stops the moment a fix is good enough.
@MainActor
final class LocationManager: NSObject {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var timeoutTask: Task<Void, Never>?
    /// The best fresh-but-imprecise fix seen so far, kept only as a timeout fallback.
    private var bestSoFar: CLLocation?

    /// Older than this and it is a memory, not a position.
    private static let maxAge: TimeInterval = 120
    /// Beyond this a fix can't tell one neighbourhood from the next, which is the only
    /// thing we use it for.
    private static let maxAccuracy: CLLocationDistance = 500
    /// GPS can take a few seconds from cold. Wait — but not forever.
    private static let timeout: Duration = .seconds(8)

    enum LocationError: LocalizedError {
        case denied, unavailable
        var errorDescription: String? {
            switch self {
            case .denied: return "Location access is off. Enable it in Settings or search for a city."
            case .unavailable: return "Couldn't determine your location. Try searching for a city."
            }
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        // Kilometre accuracy is too coarse to resolve a neighbourhood (it can't
        // tell Bedok from Tampines), which is what we name the location by.
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            throw LocationError.denied
        }
        return try await withCheckedThrowingContinuation { cont in
            // If a request is already in flight, fail it before replacing it —
            // otherwise the old continuation leaks and its `await` hangs forever.
            // Its timeout has to go with it, or it fires against the new request.
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
            self.continuation?.resume(throwing: LocationError.unavailable)
            self.continuation = cont
            self.bestSoFar = nil
            if status == .notDetermined {
                // Don't start the clock while the permission dialog is up: the user may
                // take as long as they like to answer, and timing that out would report
                // "couldn't determine your location" for a question they hadn't answered.
                manager.requestWhenInUseAuthorization()
            } else {
                beginUpdates()
            }
        }
    }

    private func beginUpdates() {
        startTimeout()
        manager.startUpdatingLocation()
    }

    private func startTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: Self.timeout)
            guard !Task.isCancelled else { return }
            self?.finishWithBestEffort()
        }
    }

    /// Time's up. A recent-but-coarse fix still beats no answer, so fall back to one if
    /// we saw it — but never to a stale one. Naming the wrong neighbourhood is worse
    /// than admitting we don't know: the rest of the app is built on the assumption that
    /// the place on screen is where you are.
    private func finishWithBestEffort() {
        if let best = bestSoFar {
            resume(returning: best.coordinate)
        } else {
            resume(throwing: LocationError.unavailable)
        }
    }

    /// A fix has arrived. Take it, keep it, or ignore it.
    private func consider(_ location: CLLocation) {
        guard continuation != nil else { return }
        // Negative accuracy means the fix is invalid, not that it is extremely precise.
        guard location.horizontalAccuracy >= 0 else { return }

        let age = -location.timestamp.timeIntervalSinceNow
        guard age <= Self.maxAge else { return }

        if location.horizontalAccuracy <= Self.maxAccuracy {
            resume(returning: location.coordinate)
            return
        }

        // Fresh but too coarse to name. Hold it as a fallback and let CoreLocation keep
        // working — the first fix is often a wide cell-tower guess, with a real one a
        // moment behind it.
        if location.horizontalAccuracy < bestSoFar?.horizontalAccuracy ?? .greatestFiniteMagnitude {
            bestSoFar = location
        }
    }

    private func resume(returning value: CLLocationCoordinate2D) {
        finish()
        continuation?.resume(returning: value)
        continuation = nil
    }

    private func resume(throwing error: Error) {
        finish()
        continuation?.resume(throwing: error)
        continuation = nil
    }

    /// Stop the radio and clear the request's state. Leaving updates running after we
    /// have our answer is a battery leak with no upside.
    private func finish() {
        manager.stopUpdatingLocation()
        timeoutTask?.cancel()
        timeoutTask = nil
        bestSoFar = nil
    }
}

// CoreLocation delivers callbacks on the thread it was created on (main here),
// so it is safe to assume MainActor isolation.
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            switch self.manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                // This also fires at launch, so only start the radio if something is
                // actually waiting on a fix. The timeout starts here, not when the
                // request was made — the clock should measure the search, not the user
                // deciding whether to allow it.
                if continuation != nil { beginUpdates() }
            case .denied, .restricted:
                resume(throwing: LocationError.denied)
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Oldest first, newest last. Reading `first` took the stalest fix in the batch —
        // the exact opposite of what we want, and what LocationMonitor already gets right.
        let latest = locations.last
        MainActor.assumeIsolated {
            guard let latest else { return }
            consider(latest)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            // A transient error during a burst is not fatal — CoreLocation keeps trying,
            // and the timeout is what decides when to give up.
            guard (error as? CLError)?.code != .locationUnknown else { return }
            resume(throwing: LocationError.unavailable)
        }
    }
}
