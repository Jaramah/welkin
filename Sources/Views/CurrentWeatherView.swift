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
                .foregroundStyle(Color.auroraPrimary)
                .contentTransition(.numericText())

            Text(current.code.label)
                .font(Theme.body(17))
                .foregroundStyle(Color.auroraSecondary)

            HStack(spacing: 16) {
                Text("H:\(tempString(current.high))")
                Text("L:\(tempString(current.low))")
                Text("Feels \(tempString(current.apparentTemperature))")
            }
            .font(Theme.body(15))
            .foregroundStyle(Color.auroraSecondary)
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
                .foregroundStyle(Color.auroraPrimary)
                .lineLimit(1)
                .padding(.top, 8)

            Label(landmark.name, systemImage: "mappin.and.ellipse")
                .font(Theme.label(11))
                .tracking(1)
                .foregroundStyle(Color.auroraTertiary)

            // Local delicacy to try — inline, no card.
            LocalFlavorView(place: place)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
    }

    private func tempString(_ v: Double) -> String {
        "\(Int(v.rounded()))°"
    }
}
