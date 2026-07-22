import SwiftUI
import UIKit

/// The hero "living postcard": a real photograph of the place under the live sky.
///
/// Replaces the hand-drawn silhouette. The sky gradient sits underneath as the loading
/// state and the offline fallback, so there is never a blank frame; the weather effects
/// (rain, snow) ride over the photo so it still reads as *now*, not a travel brochure.
struct PhotoHeroView: View {
    let place: Place
    let code: WeatherCode
    let sky: SkyMood
    var height: CGFloat = 210
    var scrollOffset: CGFloat = 0

    @State private var image: UIImage?
    @State private var credit: String?
    @State private var loading = true

    var body: some View {
        ZStack {
            // The live sky: loading state, offline fallback, and the wash that keeps the
            // photo's edges dark enough for the temperature and city name to stay legible.
            LinearGradient(colors: sky.colors, startPoint: .top, endPoint: .bottom)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height + 24)         // slack for the parallax nudge
                    .offset(y: scrollOffset * 0.12)
                    .transition(.opacity)
            }

            WeatherEffects(code: code, sky: sky)
                .allowsHitTesting(false)

            // Legibility scrim: darker top and bottom, clear middle.
            LinearGradient(
                colors: [.black.opacity(0.30), .clear, .clear, .black.opacity(0.38)],
                startPoint: .top, endPoint: .bottom
            )

            if loading && image == nil {
                ProgressView().tint(.white.opacity(0.85))
            }

            if let credit {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(credit)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.75))
                            .shadow(color: .black.opacity(0.6), radius: 2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        // Re-fetch whenever the place changes; the store makes a repeat instant.
        .task(id: place) { await load() }
    }

    private func load() async {
        loading = true
        let photo = await LocationPhotoStore.shared.photo(for: place)
        let decoded: UIImage? = photo.flatMap { UIImage(data: $0.data) }
        withAnimation(.easeOut(duration: 0.4)) {
            image = decoded
            credit = decoded == nil ? nil : photo?.credit
            loading = false
        }
    }
}
