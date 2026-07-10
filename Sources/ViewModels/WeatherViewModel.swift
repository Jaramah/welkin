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
            }
        }
    }

    func loadCurrentLocation() async {
        if bundle == nil { phase = .loading }
        do {
            let coord = try await location.requestCurrentLocation()
            // Try to name the place via reverse geocoding for a nicer title.
            let name = await reverseName(coord) ?? "Current Location"
            let place = Place(name: name, latitude: coord.latitude, longitude: coord.longitude)
            await load(place: place)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func search(_ query: String) async -> [Place] {
        (try? await service.search(query: query)) ?? []
    }

    private func reverseName(_ coord: CLLocationCoordinate2D) async -> String? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let placemarks = try? await geocoder.reverseGeocodeLocation(location)
        return placemarks?.first?.locality ?? placemarks?.first?.name
    }
}
