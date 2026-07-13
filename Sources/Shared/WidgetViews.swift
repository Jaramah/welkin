import WidgetKit
import SwiftUI

// MARK: - Timeline entry (shared so the app can preview widget layouts)

struct WelkinEntry: TimelineEntry {
    let date: Date
    let placeName: String
    let landmark: Landmark
    let temperature: Int
    let high: Int
    let low: Int
    let condition: String
    let code: WeatherCode
    let sky: SkyMood
    let aqi: Int?
    let unitSymbol: String
    let fact: Fact
    let isPlaceholder: Bool

    static let placeholder = WelkinEntry(
        date: .now,
        placeName: "New York",
        landmark: Landmark(kind: .statueOfLiberty, name: "Statue of Liberty"),
        temperature: 72, high: 78, low: 65,
        condition: "Clear",
        code: WeatherCode(raw: 0, isDay: true),
        sky: .clearDay,
        aqi: 42,
        unitSymbol: "°F",
        fact: Fact(emoji: "🌳", text: "Central Park is entirely man-made."),
        isPlaceholder: true
    )
}

/// The day's fact about this place, as a compact badge in the widgets. Widgets are
/// small, so this truncates — the full text lives in the app.
struct FactLine: View {
    let fact: Fact
    var size: CGFloat = 11
    var lineLimit: Int = 2

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text(fact.emoji)
                .font(.system(size: size))
            Text(fact.text)
                .font(.system(size: size, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(lineLimit)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Did you know: \(fact.text)")
    }
}

// MARK: - Presentational views

/// Sky gradient used as the widget's container background.
struct WidgetSky: View {
    let sky: SkyMood
    var body: some View {
        LinearGradient(colors: sky.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Static (non-animated) landmark scene for the widget.
struct StaticLandmark: View {
    let kind: LandmarkKind
    var seed: Int = 0
    let isDay: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Circle()
                    .fill(isDay ? Color(red: 1.0, green: 0.9, blue: 0.55)
                                : Color(red: 0.92, green: 0.94, blue: 1.0))
                    .frame(width: 26, height: 26)
                    .position(x: w * 0.74, y: h * 0.26)
                    .shadow(color: (isDay ? Color.yellow : Color.white).opacity(0.7), radius: 14)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ZStack {
                        LandmarkShape(kind: kind, seed: seed)
                            .fill(LinearGradient(colors: [.black.opacity(0.55), .black.opacity(0.9)],
                                                 startPoint: .top, endPoint: .bottom),
                                  style: FillStyle(eoFill: true))
                        LandmarkShape(kind: kind, seed: seed)
                            .stroke(Color.white.opacity(0.16), lineWidth: 0.7)
                    }
                    .frame(height: h * 0.78)
                }
            }
        }
    }
}

struct WelkinWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: WelkinEntry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidget(entry: entry).containerBackground(for: .widget) { WidgetSky(sky: entry.sky) }
        case .accessoryRectangular:
            RectangularAccessory(entry: entry).containerBackground(for: .widget) { Color.clear }
        case .accessoryCircular:
            CircularAccessory(entry: entry).containerBackground(for: .widget) { Color.clear }
        case .accessoryInline:
            Label("\(entry.placeName) \(entry.temperature)°", systemImage: entry.code.symbol)
        default:
            SmallWidget(entry: entry).containerBackground(for: .widget) { WidgetSky(sky: entry.sky) }
        }
    }
}

// MARK: - Lock Screen (accessory) widgets

struct RectangularAccessory: View {
    let entry: WelkinEntry
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.code.symbol)
                .font(.system(size: 22))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.placeName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Text("\(entry.temperature)°  \(entry.condition)")
                    .font(.system(size: 12, design: .rounded))
                Text("H:\(entry.high)°  L:\(entry.low)°"
                     + (entry.aqi.map { "  AQI \($0)" } ?? ""))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}

struct CircularAccessory: View {
    let entry: WelkinEntry
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -1) {
                Image(systemName: entry.code.symbol)
                    .font(.system(size: 15))
                    .widgetAccentable()
                Text("\(entry.temperature)°")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
            }
        }
    }
}

struct SmallWidget: View {
    let entry: WelkinEntry

    var body: some View {
        ZStack {
            StaticLandmark(kind: entry.landmark.kind, seed: entry.landmark.seed, isDay: entry.code.isDay)
                .opacity(0.9)
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.placeName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Text(entry.condition)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(entry.temperature)°")
                        .font(.system(size: 40, weight: .thin, design: .rounded))
                    Spacer()
                    Text("H:\(entry.high)° L:\(entry.low)°")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                FactLine(fact: entry.fact, size: 9, lineLimit: 2)
                    .padding(.top, 1)
            }
            .foregroundStyle(.white)
        }
    }
}

struct MediumWidget: View {
    let entry: WelkinEntry

    var body: some View {
        HStack(spacing: 14) {
            StaticLandmark(kind: entry.landmark.kind, seed: entry.landmark.seed, isDay: entry.code.isDay)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.placeName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Text(entry.landmark.name)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(entry.temperature)°")
                    .font(.system(size: 46, weight: .thin, design: .rounded))
                Text(entry.condition)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 10) {
                    Text("H:\(entry.high)°  L:\(entry.low)°")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                    if let aqi = entry.aqi {
                        AQIBadge(aqi: aqi)
                    }
                }
                FactLine(fact: entry.fact, size: 10, lineLimit: 2)
                    .padding(.top, 2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AQIBadge: View {
    let aqi: Int
    var body: some View {
        let cat = AQICategory(value: aqi)
        Text("AQI \(aqi)")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(.black.opacity(0.85))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(cat.color, in: Capsule())
    }
}
