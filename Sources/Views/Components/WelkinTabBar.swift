import SwiftUI

enum WelkinTab: String { case weather, rain, photos }

/// The floating bottom bar: Weather / Rain / Photos, plus a search button.
///
/// Only Weather is wired up for now — Rain and Photos are shown because they're part of
/// the shape of the app, and tapping them says so plainly rather than doing nothing.
struct WelkinTabBar: View {
    let active: WelkinTab
    let onSelect: (WelkinTab) -> Void
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                tab(.weather, icon: "cloud.sun.fill", title: "Weather")
                tab(.rain, icon: "cloud.rain.fill", title: "Rain")
                tab(.photos, icon: "photo.fill", title: "Photos")
            }
            .padding(5)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.12), lineWidth: 0.5))

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 0.5))
            }
            .accessibilityLabel("Search locations")
        }
    }

    private func tab(_ t: WelkinTab, icon: String, title: String) -> some View {
        Button { onSelect(t) } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .symbolRenderingMode(t == active ? .multicolor : .monochrome)
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(t == active ? Color.white : Color.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(t == active ? Color.white.opacity(0.16) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 17))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
