import SwiftUI

struct CurrentWeatherView: View {
    let place: Place
    let current: CurrentConditions
    let unit: TemperatureUnit
    var scrollOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 4) {
            // Temperature + condition sit above the photo.
            Text(tempString(current.temperature))
                .font(Theme.display(88))
                .foregroundStyle(Color.welkinPrimary)
                .contentTransition(.numericText())

            Text(current.code.label)
                .font(Theme.body(17))
                .foregroundStyle(Color.welkinSecondary)

            // Named only when a local met service overrode the global model, so it
            // is obvious why this can differ from the model-driven hourly strip.
            if let note = current.sourceNote {
                Text(note)
                    .font(Theme.label(11))
                    .foregroundStyle(Color.welkinTertiary)
            }

            HStack(spacing: 16) {
                Text("H:\(tempString(current.high))")
                Text("L:\(tempString(current.low))")
                Text("Feels \(tempString(current.apparentTemperature))")
            }
            .font(Theme.body(15))
            .foregroundStyle(Color.welkinSecondary)
            .padding(.bottom, 6)

            // The place name. The scene behind it is now the full-screen condition
            // photo, so the hero card is gone — the reading sits straight on the sky.
            Text(place.name)
                .font(Theme.title(24))
                .foregroundStyle(Color.welkinPrimary)
                .lineLimit(1)
                .padding(.top, 8)

            if !place.subtitle.isEmpty {
                Label(place.subtitle, systemImage: "mappin.and.ellipse")
                    .font(Theme.label(11))
                    .tracking(1)
                    .foregroundStyle(Color.welkinTertiary)
            }

            // A fact about this place — inline, no card. Tap for another.
            CityFactView(place: place)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
    }

    private func tempString(_ v: Double) -> String {
        "\(Int(v.rounded()))°"
    }
}
