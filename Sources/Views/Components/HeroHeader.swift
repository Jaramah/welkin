import SwiftUI

/// The floating header over the place photo: city, temperature, condition.
///
/// No card, no background — it rests straight on the photograph, carried by a soft
/// shadow so white type stays legible over a bright sky. Tapping the temperature flips
/// the unit, which is where people reach anyway.
struct HeroHeader: View {
    let place: Place
    let current: CurrentConditions
    let unit: TemperatureUnit
    let onToggleUnit: () -> Void

    var body: some View {
        VStack(spacing: 3) {
            Text(place.name)
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !place.subtitle.isEmpty {
                Text(place.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(1)
            }

            Text("\(Int(current.temperature.rounded()))°")
                .font(.system(size: 74, weight: .thin))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .onTapGesture(perform: onToggleUnit)
                .accessibilityLabel("\(Int(current.temperature.rounded())) degrees")
                .accessibilityHint("Double tap to switch units")

            Text(current.code.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.92))

            if let note = current.sourceNote {
                Text(note)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.62))
            }

            HStack(spacing: 14) {
                Text("H:\(Int(current.high.rounded()))°")
                Text("L:\(Int(current.low.rounded()))°")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white.opacity(0.82))
            .padding(.top, 2)
        }
        .multilineTextAlignment(.center)
        // Two shadows: a tight one for edge definition and a broad one that darkens the
        // sky right behind the type, so white stays readable even over bright cloud.
        .shadow(color: .black.opacity(0.5), radius: 4, y: 1)
        .shadow(color: .black.opacity(0.4), radius: 18, y: 2)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}
