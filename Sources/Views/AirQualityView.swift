import SwiftUI

struct AirQualityView: View {
    let aqi: Int
    let pm25: Double?
    let pm10: Double?
    let ozone: Double?
    let no2: Double?

    var body: some View {
        let cat = AQICategory(value: aqi)
        GlassCard(title: "Air Quality", systemImage: "aqi.medium") {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 18) {
                    AQIGauge(category: cat)
                        .frame(width: 92, height: 92)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(cat.label)
                            .font(Theme.title(20))
                            .foregroundStyle(cat.color)
                        Text("US AQI")
                            .font(Theme.label(11))
                            .foregroundStyle(Color.auroraTertiary)
                        Text(cat.guidance)
                            .font(Theme.body(13))
                            .foregroundStyle(Color.auroraSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                let pollutants = [
                    ("PM2.5", pm25, "µg/m³"),
                    ("PM10", pm10, "µg/m³"),
                    ("Ozone", ozone, "µg/m³"),
                    ("NO₂", no2, "µg/m³"),
                ].compactMap { name, value, unit -> (String, String)? in
                    guard let value else { return nil }
                    return (name, "\(Int(value.rounded())) \(unit)")
                }

                if !pollutants.isEmpty {
                    Divider().overlay(Color.white.opacity(0.12))
                    HStack {
                        ForEach(pollutants, id: \.0) { name, value in
                            VStack(spacing: 4) {
                                Text(name)
                                    .font(Theme.label(11))
                                    .foregroundStyle(Color.auroraTertiary)
                                Text(value)
                                    .font(Theme.body(13))
                                    .foregroundStyle(Color.auroraPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

private struct AQIGauge: View {
    let category: AQICategory

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 9)
            Circle()
                .trim(from: 0, to: category.fraction)
                .stroke(
                    AngularGradient(
                        colors: [category.color.opacity(0.6), category.color],
                        center: .center),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: category.color.opacity(0.6), radius: 6)
            VStack(spacing: 0) {
                Text("\(category.value)")
                    .font(Theme.display(30))
                    .foregroundStyle(Color.auroraPrimary)
                Text("AQI")
                    .font(Theme.label(10))
                    .foregroundStyle(Color.auroraTertiary)
            }
        }
    }
}
