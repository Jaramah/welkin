import SwiftUI

/// The hours, along the bottom of the first screen — a glassy strip resting on the photo.
///
/// Each column is the one thing you scan for at a glance: when, what, how warm, and the
/// chance of rain if there is one. It scrolls sideways for the full day.
struct HourlyStrip: View {
    let hours: [HourPoint]
    let timezone: TimeZone

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(hours.prefix(24).enumerated()), id: \.element.id) { index, hour in
                    VStack(spacing: 6) {
                        Text(index == 0 ? "Now" : label(hour.date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))

                        Image(systemName: hour.code.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 20))
                            .frame(height: 24)

                        Text("\(Int(hour.temperature.rounded()))°")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)

                        if hour.precipitationProbability >= 10 {
                            Text("\(hour.precipitationProbability)%")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundStyle(Color(red: 0.56, green: 0.79, blue: 1.0))
                        } else {
                            Text(" ").font(.system(size: 10.5))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
    }

    private func label(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = timezone
        f.dateFormat = "ha"
        return f.string(from: date).lowercased()
    }
}
