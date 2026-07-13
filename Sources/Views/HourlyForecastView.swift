import SwiftUI

struct HourlyForecastView: View {
    let hours: [HourPoint]
    let timezone: TimeZone

    var body: some View {
        GlassCard(title: "Hourly Forecast", systemImage: "clock") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 22) {
                    ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
                        VStack(spacing: 10) {
                            Text(index == 0 ? "Now" : hourLabel(hour.date))
                                .font(Theme.label(13))
                                .foregroundStyle(Color.welkinSecondary)

                            Image(systemName: hour.code.symbol)
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 22))
                                .frame(height: 26)

                            if hour.precipitationProbability >= 10 {
                                Text("\(hour.precipitationProbability)%")
                                    .font(Theme.label(11))
                                    .foregroundStyle(Color(red: 0.5, green: 0.8, blue: 1.0))
                            } else {
                                Text(" ").font(Theme.label(11))
                            }

                            Text("\(Int(hour.temperature.rounded()))°")
                                .font(Theme.title(18))
                                .foregroundStyle(Color.welkinPrimary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // The headline condition can come from a local met service (NEA in
            // Singapore) while these hours come from the global model. Saying so
            // turns a baffling contradiction into two clearly-sourced opinions.
            Text("Open-Meteo model · next 24 hours")
                .font(Theme.label(11))
                .foregroundStyle(Color.welkinTertiary)
        }
    }

    private func hourLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        f.dateFormat = "ha"
        return f.string(from: date).lowercased()
    }
}
