import SwiftUI

struct CurrentWeatherView: View {
    let place: Place
    let current: CurrentConditions
    let unit: TemperatureUnit
    var scrollOffset: CGFloat = 0

    private var landmark: Landmark { LandmarkCatalog.landmark(for: place) }

    var body: some View {
        VStack(spacing: 4) {
            // Temperature + condition sit above the landmark.
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

            // Signature landmark scene — the city's icon under live weather.
            LandmarkSceneView(
                landmark: landmark,
                code: current.code,
                sky: current.code.sky,
                sunrise: current.sunrise,
                sunset: current.sunset,
                scrollOffset: scrollOffset
            )

            // Location sits below the landmark.
            Text(place.name)
                .font(Theme.title(24))
                .foregroundStyle(Color.welkinPrimary)
                .lineLimit(1)
                .padding(.top, 8)

            Label(landmark.name, systemImage: "mappin.and.ellipse")
                .font(Theme.label(11))
                .tracking(1)
                .foregroundStyle(Color.welkinTertiary)

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
