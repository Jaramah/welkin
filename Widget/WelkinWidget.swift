import WidgetKit
import SwiftUI

// MARK: - Provider

/// Transfers a non-Sendable completion handler into a Task under Swift 6.
private struct Sendify<T>: @unchecked Sendable { let value: T }

struct WelkinProvider: TimelineProvider {
    func placeholder(in context: Context) -> WelkinEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (WelkinEntry) -> Void) {
        let sink = Sendify(value: completion)
        Task { sink.value(await fetchEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WelkinEntry>) -> Void) {
        let sink = Sendify(value: completion)
        Task {
            let entry = await fetchEntry()
            // Refresh about once an hour.
            let next = Calendar.current.date(byAdding: .minute, value: 60, to: .now) ?? .now
            sink.value(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func fetchEntry() async -> WelkinEntry {
        let stored = SharedStore.loadPlace()
        let place = Place(
            name: stored?.name ?? "New York",
            latitude: stored?.latitude ?? 40.7128,
            longitude: stored?.longitude ?? -74.0060
        )
        let unit = TemperatureUnit(rawValue: SharedStore.loadUnit()) ?? .fahrenheit

        guard let fetched = try? await WeatherService().fetch(for: place, unit: unit) else {
            return WelkinEntry.placeholder
        }
        // Same rule as the app: where a local met service covers this place, its
        // reading beats the global model. Without this the widget contradicts the
        // app it sits next to on the home screen.
        let bundle = fetched.applyingLocalNowcast(await RegionalNowcast.fetch(for: place))
        let c = bundle.current
        return WelkinEntry(
            date: .now,
            placeName: bundle.place.name,
            landmark: LandmarkCatalog.landmark(for: bundle.place),
            temperature: Int(c.temperature.rounded()),
            high: Int(c.high.rounded()),
            low: Int(c.low.rounded()),
            condition: c.code.label,
            code: c.code,
            sky: c.code.sky,
            aqi: bundle.aqiNow,
            unitSymbol: unit.symbol,
            dish: FlavorCatalog.flavor(for: bundle.place),
            isPlaceholder: false
        )
    }
}

// MARK: - Widget definitions

struct WelkinWidget: Widget {
    let kind = "WelkinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WelkinProvider()) { entry in
            WelkinWidgetView(entry: entry)
        }
        .configurationDisplayName("Welkin Weather")
        .description("Your city's weather under its signature landmark.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

@main
struct WelkinWidgetBundle: WidgetBundle {
    var body: some Widget {
        WelkinWidget()
    }
}
