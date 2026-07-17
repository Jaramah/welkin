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
                Task { await load(place: place, followingLocation: isFollowingLocation) }
            }
        }
    }

    private(set) var currentPlace: Place?
    /// True when `currentPlace` came from GPS rather than a search result. A refresh
    /// then has to re-acquire the position — otherwise the app stays pinned to
    /// wherever you were standing the first time it looked, even after you move.
    private(set) var isFollowingLocation = false
    /// A refresh that failed while usable data is already on screen. Surfaced as a
    /// banner instead of replacing the forecast with a full-screen error.
    var refreshError: String?
    /// Singapore-only area nowcast (nil elsewhere or while unavailable).
    private(set) var regionalNowcast: RegionalNowcast?
    /// When we last asked CoreLocation where we are.
    private var lastLocationRefresh: Date?
    /// Flicking between apps shouldn't re-fetch; coming back after a real absence should.
    private static let foregroundRefreshInterval: TimeInterval = 60
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

    func load(place: Place, followingLocation: Bool = false) async {
        currentPlace = place
        isFollowingLocation = followingLocation
        // Only show the full-screen loader on a cold start. On a refresh or unit
        // toggle, keep the current content visible so the screen doesn't flash
        // (pull-to-refresh shows its own spinner).
        if bundle == nil { phase = .loading }
        do {
            let bundle = try await service.fetch(for: place, unit: unit)
            phase = .loaded(bundle)
            refreshError = nil
            loadRegionalNowcast(for: place)
            evaluateAlerts(for: bundle)
            // Hand the current location + unit to the widget and refresh it.
            SharedStore.save(place: StoredPlace(name: place.name,
                                                latitude: place.latitude,
                                                longitude: place.longitude))
            SharedStore.save(unit: unit.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        } catch is CancellationError {
            // Superseded by a newer request — leave whatever is on screen alone.
        } catch {
            report(error)
        }
    }

    /// Never throw away a good forecast because a refresh failed: if there is
    /// already something on screen, degrade to a banner instead of an error page.
    private func report(_ error: Error) {
        if bundle != nil {
            refreshError = error.localizedDescription
        } else {
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
                self.applyNowcastToCurrent(nowcast)
                // Re-run alerts now that we have the area-level nowcast, which
                // gives a far better rain signal than the coarse hourly model.
                if let bundle = self.bundle { self.evaluateAlerts(for: bundle) }
            }
        }
    }

    /// Inside NEA's 2-hour window, NEA wins.
    ///
    /// Open-Meteo is a global model on a ~10km grid — for Bedok it resolves to a
    /// point several kilometres away, and it hedges with a light "drizzle" that the
    /// official radar-backed nowcast flatly contradicts. NEA is the local met
    /// service, is specific to your town, and updates every few minutes, so it is
    /// the better answer for what the sky is doing right now. Temperature, wind and
    /// the rest still come from the model; only the condition is replaced.
    private func applyNowcastToCurrent(_ nowcast: RegionalNowcast) {
        guard let bundle else { return }
        phase = .loaded(bundle.applyingLocalNowcast(nowcast))
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
            lastLocationRefresh = Date()
            await load(place: namedPlace(for: coord), followingLocation: true)
        } catch is CancellationError {
            // Superseded — keep the current screen.
        } catch {
            report(error)
        }
    }

    /// Re-check where we are when the app comes back to the foreground.
    ///
    /// The position used to be read once, on a cold launch, and never again unless you
    /// pulled to refresh. But travelling with Welkin in your pocket is exactly the case
    /// where the answer changes: cross town with the app backgrounded and it kept
    /// insisting you were still where you set off. Opening the app is the clearest
    /// statement of "tell me about here" there is, so it re-asks then.
    ///
    /// Only a GPS-followed place re-resolves. A city you searched for is a deliberate
    /// choice and must stay put.
    func refreshForForeground() async {
        guard isFollowingLocation else { return }
        if let lastLocationRefresh,
           Date().timeIntervalSince(lastLocationRefresh) < Self.foregroundRefreshInterval {
            return
        }
        await loadCurrentLocation()
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
