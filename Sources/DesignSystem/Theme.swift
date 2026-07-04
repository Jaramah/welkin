import SwiftUI

/// Central design tokens for Aurora's sleek, futuristic look.
enum Theme {
    // Typography
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .thin, design: .rounded)
    }
    static func title(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    static func label(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    // Spacing
    static let pad: CGFloat = 20
    static let cardRadius: CGFloat = 26
}

extension Color {
    static let auroraPrimary = Color.white
    static let auroraSecondary = Color.white.opacity(0.7)
    static let auroraTertiary = Color.white.opacity(0.45)
}
