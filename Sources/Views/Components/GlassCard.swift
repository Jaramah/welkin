import SwiftUI

/// Frosted-glass container used throughout the app.
struct GlassCard<Content: View>: View {
    var title: String?
    var systemImage: String?
    @ViewBuilder var content: () -> Content

    init(title: String? = nil, systemImage: String? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Label {
                    Text(title.uppercased())
                        .font(Theme.label(12))
                        .tracking(1.5)
                } icon: {
                    if let systemImage {
                        Image(systemName: systemImage).font(.system(size: 12, weight: .bold))
                    }
                }
                .foregroundStyle(Color.welkinTertiary)
            }
            content()
        }
        .padding(Theme.pad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface()
    }
}

extension View {
    /// The signature translucent surface: ultra-thin material + gradient hairline border.
    func glassSurface(cornerRadius: CGFloat = Theme.cardRadius) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
    }
}
