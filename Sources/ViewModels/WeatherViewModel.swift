import SwiftUI
import CoreLocation
import WidgetKit

@MainActor
@Observable
final class WeatherViewModel {
    enum Phase {
        case idle, loading, loaded(WeatherBundle), failed(String)
    }

    var phase: Phase = .idle
    var unit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(unit.rawValue, forKey: "unit")
            if oldValue != unit, let place = currentPlace {
                Task { await load(place: place) }
            }
        }
    }

    private(set) var currentPlace: Place?
    /// Singapore-only area nowcast (nil elsewhere or while unavailable).
    private(set) var regionalNowcast: RegionalNowcast?
    private let service = WeatherService()
    private let nea = NEAService()
    private let location = LocationManager()

    var bundle: WeatherBundle? {
        if case .loaded(let b) = phase { return b }
        return nil
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "unit")
        self.unit = saved.flatMap(TemperatureUnit.init) ?? .fahrenheit
    }

    func load(place: Place) async {
        currentPlace = place
        // Only show the full-screen loader on a cold start. On a refresh or unit
        // toggle, keep the current content visible so the screen doesn't flash
        // (pull-to-refresh shows its own spinner).
        if bundle == nil { phase = .loading }
        do {
            let bundle = try await service.fetch(for: place, unit: unit)
            phase = .loaded(bundle)
            loadRegionalNowcast(for: place)
            evaluateAlerts(for: bundle)
            // Hand the current location + unit to the widget and refresh it.
            SharedStore.save(place: StoredPlace(name: place.name,
                                                latitude: place.latitude,
                                                longitude: place.longitude))
            SharedStore.save(unit: unit.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// Best-effort area nowcast, only where NEA has coverage (Singapore).
    /// Keeps any existing data visible until fresh data arrives; clears it
    /// immediately when the new location is outside coverage.
    private func loadRegionalNowcast(for place: Place) {
        guard NEAService.covers(latitude: place.latitude, longitude: place.longitude) else {
            regionalNowcast = nil
            return
        }
        Task { [weak self] in
            guard let self else { return }
            if let nowcast = try? await self.nea.twoHourNowcast() {
                self.regionalNowcast = nowcast
                // Re-run alerts now that we have the area-level nowcast, which
                // gives a far better rain signal than the coarse hourly model.
                if let bundle = self.bundle { self.evaluateAlerts(for: bundle) }
            }
        }
    }

    /// Fire any due weather alerts. Cooldowns inside NotificationService stop
    /// this from notifying repeatedly on every refresh.
    private func evaluateAlerts(for bundle: WeatherBundle) {
        let settings = NotificationSettings.load()
        guard settings.anyEnabled else { return }
        let nowcast = regionalNowcast
        let unit = self.unit
        Task {
            await NotificationService.shared.process(bundle: bundle, nowcast: nowcast,
                                                     unit: unit, settings: settings)
        }
    }

    func loadCurrentLocation() async {
        if bundle == nil { phase = .loading }
        do {
            let coord = try await location.requestCurrentLocation()
            await load(place: namedPlace(for: coord))
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func search(_ query: String) async -> [Place] {
        (try? await service.search(query: query)) ?? []
    }

    /// Name the current position as precisely as the geocoder allows. `locality`
    /// alone is useless in a city-state — it just says "Singapore" — so prefer the
    /// neighbourhood ("Bedok", "Tampines") and keep the city as the subtitle.
    private func namedPlace(for coord: CLLocationCoordinate2D) async -> Place {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let mark = (try? await geocoder.reverseGeocodeLocation(location))?.first

        let name = mark?.subLocality
            ?? mark?.locality
            ?? mark?.subAdministrativeArea
            ?? mark?.name
            ?? "Current Location"
        let city = mark?.locality

        return Place(name: name,
                     admin: city == name ? nil : city,
                     country: mark?.country,
                     latitude: coord.latitude,
                     longitude: coord.longitude)
    }
}
