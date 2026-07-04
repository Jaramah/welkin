import SwiftUI

struct DailyForecastView: View {
    let days: [DayPoint]
    let timezone: TimeZone

    private var globalLow: Double { days.map(\.low).min() ?? 0 }
    private var globalHigh: Double { days.map(\.high).max() ?? 1 }

    var body: some View {
        GlassCard(title: "7-Day Forecast", systemImage: "calendar") {
            VStack(spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    DayRow(
                        day: day,
                        isToday: index == 0,
                        timezone: timezone,
                        globalLow: globalLow,
                        globalHigh: globalHigh
                    )
                    if index < days.count - 1 {
                        Divider().overlay(Color.white.opacity(0.12))
                    }
                }
            }
        }
    }
}

private struct DayRow: View {
    let day: DayPoint
    let isToday: Bool
    let timezone: TimeZone
    let globalLow: Double
    let globalHigh: Double

    private var showsRain: Bool {
        day.precipitationProbability >= 20 || day.rainStart != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 12) {
                Text(isToday ? "Today" : dayName(day.date))
                    .font(Theme.body(16))
                    .foregroundStyle(Color.welkinPrimary)
                    .frame(width: 58, alignment: .leading)

                Image(systemName: day.code.symbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 20))
                    .frame(width: 30)

                if let aqi = day.aqi {
                    AQIPill(aqi: aqi)
                } else {
                    Spacer().frame(width: 44)
                }

                Spacer(minLength: 6)

                Text("\(Int(day.low.rounded()))°")
                    .font(Theme.body(16))
                    .foregroundStyle(Color.welkinTertiary)
                    .lineLimit(1)
                    .frame(width: 38, alignment: .trailing)

                TemperatureBar(low: day.low, high: day.high,
                               globalLow: globalLow, globalHigh: globalHigh)
                    .frame(width: 62, height: 5)

                Text("\(Int(day.high.rounded()))°")
                    .font(Theme.body(16))
                    .foregroundStyle(Color.welkinPrimary)
                    .lineLimit(1)
                    .frame(width: 38, alignment: .leading)
            }

            if showsRain {
                HStack(spacing: 6) {
                    Image(systemName: "drop.fill").font(.system(size: 10))
                    Text("\(day.precipitationProbability)%")
                    if let start = day.rainStart, let end = day.rainEnd {
                        Text("· rain \(hour(start))–\(hour(end))")
                    }
                }
                .font(Theme.label(11))
                .foregroundStyle(Color(red: 0.5, green: 0.8, blue: 1.0))
                .padding(.leading, 58)
            }
        }
        .padding(.vertical, 6)
    }

    private func dayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func hour(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        f.dateFormat = "ha"
        return f.string(from: date).lowercased()
    }
}

private struct AQIPill: View {
    let aqi: Int
    var body: some View {
        let cat = AQICategory(value: aqi)
        Text("\(aqi)")
            .font(Theme.label(11))
            .foregroundStyle(.black.opacity(0.85))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(cat.color, in: Capsule())
            .frame(width: 44)
    }
}

/// A gradient bar showing where this day's low–high sits within the week's range.
private struct TemperatureBar: View {
    let low: Double
    let high: Double
    let globalLow: Double
    let globalHigh: Double

    var body: some View {
        GeometryReader { geo in
            let span = max(globalHigh - globalLow, 1)
            let x1 = CGFloat((low - globalLow) / span) * geo.size.width
            let x2 = CGFloat((high - globalLow) / span) * geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.15))
                Capsule()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.3, green: 0.7, blue: 1.0),
                                 Color(red: 1.0, green: 0.75, blue: 0.3)],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(x2 - x1, 6))
                    .offset(x: x1)
            }
        }
    }
}
