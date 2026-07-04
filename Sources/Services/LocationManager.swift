import CoreLocation

/// Thin async wrapper around CoreLocation for a one-shot current fix.
@MainActor
final class LocationManager: NSObject {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

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
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            throw LocationError.denied
        }
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                manager.requestLocation()
            }
        }
    }

    private func resume(returning value: CLLocationCoordinate2D) {
        continuation?.resume(returning: value)
        continuation = nil
    }

    private func resume(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// CoreLocation delivers callbacks on the thread it was created on (main here),
// so it is safe to assume MainActor isolation.
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            switch self.manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            case .denied, .restricted:
                resume(throwing: LocationError.denied)
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = locations.first?.coordinate
        MainActor.assumeIsolated {
            guard let coord else {
                resume(throwing: LocationError.unavailable)
                return
            }
            resume(returning: coord)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            resume(throwing: LocationError.unavailable)
        }
    }
}
