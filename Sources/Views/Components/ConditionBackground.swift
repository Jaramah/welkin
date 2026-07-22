import SwiftUI

/// Full-screen backdrop: a portrait photograph chosen to match the current sky.
///
/// The photos are bundled and public-domain, so this is instant, offline and keyless —
/// no per-launch fetch, no pop-in. It only sets the scene; the live-weather effects
/// (rain, snow, stars) are a separate layer on top, so the backdrop is a photo but the
/// weather on it is still the weather outside.
struct ConditionBackground: View {
    let mood: SkyMood

    var body: some View {
        ZStack {
            // The mood gradient underneath: a safety net if an asset is ever missing,
            // and a tint under the photo's lighter regions.
            LinearGradient(colors: mood.colors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            Image(mood.backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .transition(.opacity)
                .id(mood.backgroundImageName)      // cross-fade when the mood changes

            // Legibility scrim: darken the top (temperature) and bottom (cards) a little,
            // leave the middle of the picture alone.
            LinearGradient(
                colors: [.black.opacity(0.38), .black.opacity(0.10), .black.opacity(0.48)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.8), value: mood.backgroundImageName)
    }
}

extension SkyMood {
    /// The bundled portrait background for this mood. Several moods share a photo — a
    /// partly-cloudy day is still a day sky — so six images cover the eight moods.
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
