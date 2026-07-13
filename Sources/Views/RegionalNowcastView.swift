import SwiftUI

/// Two-column, area-by-area nowcast for Singapore (NEA 2-hour forecast).
struct RegionalNowcastView: View {
    let nowcast: RegionalNowcast
    /// Tapping an area opens its full forecast.
    var onSelect: (RegionalNowcast.AreaForecast) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        GlassCard(title: "Regional Nowcast", systemImage: "map") {
            VStack(alignment: .leading, spacing: 14) {
                if !nowcast.validPeriodText.isEmpty {
                    Text("NEA · \(nowcast.validPeriodText)")
                        .font(Theme.label(12))
                        .foregroundStyle(Color.welkinSecondary)
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ForEach(nowcast.areas) { area in
                        if area.place != nil {
                            Button { onSelect(area) } label: {
                                AreaRow(area: area, tappable: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens the forecast for \(area.name)")
                        } else {
                            AreaRow(area: area, tappable: false)
                        }
                    }
                }
            }
        }
    }
}

private struct AreaRow: View {
    let area: RegionalNowcast.AreaForecast
    let tappable: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: area.symbol)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 20))
                .frame(width: 26, height: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(area.name)
                    .font(Theme.body(14))
                    .foregroundStyle(Color.welkinPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(area.forecast)
                    .font(Theme.label(11))
                    .foregroundStyle(Color.welkinTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)

            if tappable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.welkinTertiary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
