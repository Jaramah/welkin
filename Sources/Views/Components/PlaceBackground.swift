import SwiftUI
import UIKit

/// Full-screen backdrop: a photograph of the place itself — the city or country you're
/// looking at — with the live-weather effects layered on top so the sky over the picture
/// is the sky outside.
///
/// Three layers, in order of preference, so there is never a blank or a slow frame:
///   1. the mood gradient — the instant floor;
///   2. a bundled, public-domain condition photo (day, night, rain, snow, storm…) —
///      instant and offline, and already the right weather while the place photo loads;
///   3. the fetched place photo, faded in once it arrives, cropped to fill.
///
/// Offline, or where no picture of the place exists, it simply rests on the condition
/// photo — which still matches the weather, so the screen always looks deliberate.
struct PlaceBackground: View {
    let place: Place?
    let mood: SkyMood

    @State private var image: UIImage?
    @State private var credit: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: mood.colors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Bundled condition photo: instant, offline, and the right weather.
            Image(mood.backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .id(mood.backgroundImageName)

            // The place itself, once fetched.
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            // Legibility scrims. White type has to stay readable over a *bright* photo —
            // a noon sky is nearly white — so the top and bottom are darkened firmly, not
            // subtly. Two gradients, so the clear middle band stays generous.
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.62), location: 0.0),
                    .init(color: .black.opacity(0.22), location: 0.24),
                    .init(color: .clear, location: 0.44),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.5),
                    .init(color: .black.opacity(0.30), location: 0.78),
                    .init(color: .black.opacity(0.70), location: 1.0),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if let credit {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(credit)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                            .shadow(color: .black.opacity(0.7), radius: 2)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }
        }
        .animation(.easeInOut(duration: 0.7), value: mood.backgroundImageName)
        .task(id: place) { await load() }
    }

    private func load() async {
        // Drop the previous city's picture immediately so we never show the wrong place;
        // the condition photo underneath carries the moment until the new one arrives.
        image = nil
        credit = nil
        guard let place else { return }
        let photo = await LocationPhotoStore.shared.photo(for: place)
        let decoded = photo.flatMap { UIImage(data: $0.data) }
        withAnimation(.easeOut(duration: 0.5)) {
            image = decoded
            credit = decoded == nil ? nil : photo?.credit
        }
    }
}

extension SkyMood {
    /// The bundled portrait background for this mood — the fallback under the place photo,
    /// and the whole backdrop when offline or where no picture of the place exists. Six
    /// images cover the eight moods: a partly-cloudy day is still a day sky.
    var backgroundImageName: String {
        switch self {
        case .clearDay, .partlyDay:     return "BackgroundDay"
        case .clearNight, .partlyNight: return "BackgroundNight"
        case .cloudy:                   return "BackgroundCloudy"
        case .rain:                     return "BackgroundRain"
        case .snow:                     return "BackgroundSnow"
        case .storm:                    return "BackgroundStorm"
        }
    }
}
