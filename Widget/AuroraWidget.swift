import WidgetKit
import SwiftUI

// MARK: - Provider

/// Transfers a non-Sendable completion handler into a Task under Swift 6.
private struct Sendify<T>: @unchecked Sendable { let value: T }

struct AuroraProvider: TimelineProvider {
    func placeholder(in context: Context) -> AuroraEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (AuroraEntry) -> Void) {
        let sink = Sendify(value: completion)
        Task { sink.value(await fetchEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AuroraEntry>) -> Void) {
        let sink = Sendify(value: completion)
        Task {
            let entry = await fetchEntry()
            // Refresh about once an hour.
            let next = Calendar.current.date(byAdding: .minute, value: 60, to: .now) ?? .now
            sink.value(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func fetchEntry() async -> AuroraEntry {
        let stored = SharedStore.loadPlace()
        let place = Place(
            name: stored?.name ?? "New York",
            latitude: stored?.latitude ?? 40.7128,
            longitude: stored?.longitude ?? -74.0060
        )
        let unit = TemperatureUnit(rawValue: SharedStore.loadUnit()) ?? .fahrenheit

        guard let bundle = try? await WeatherService().fetch(for: place, unit: unit) else {
            return AuroraEntry.placeholder
        }
        let c = bundle.current
        return AuroraEntry(
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
            isPlaceholder: false
        )
    }
}

// MARK: - Widget definitions

struct AuroraWidget: Widget {
    let kind = "AuroraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AuroraProvider()) { entry in
            AuroraWidgetView(entry: entry)
        }
        .configurationDisplayName("Aurora Weather")
        .description("Your city's weather under its signature landmark.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

@main
struct AuroraWidgetBundle: WidgetBundle {
    var body: some Widget {
        AuroraWidget()
    }
}
