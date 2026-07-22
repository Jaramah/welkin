import SwiftUI

/// "Forecast models" — the same few days as three major models see them.
///
/// Most apps quietly pick one model and present it as *the* forecast. When the models
/// disagree, that certainty is a fiction. This shows the disagreement plainly: three
/// columns, and a spread badge on any day they can't settle, so "less certain" is
/// something you can see rather than a number you have to trust.
struct ModelCompareView: View {
    let place: Place
    let unit: TemperatureUnit

    @State private var comparison: ModelComparison?

    /// A day's highs differing by more than this is worth flagging. Fahrenheit degrees
    /// are smaller, so the bar is higher there — same real-world disagreement.
    private var noticeableSpread: Double { unit == .celsius ? 3 : 5 }

    var body: some View {
        Group {
            if let comparison, !comparison.days.isEmpty {
                GlassCard(title: "Forecast Models", systemImage: "square.stack.3d.up") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Where the major models disagree, the day is less settled.")
                            .font(Theme.body(13))
                            .foregroundStyle(Color.welkinSecondary)

                        header(comparison.models)
                        Divider().overlay(Color.white.opacity(0.12))

                        ForEach(comparison.days) { day in
                            row(day)
                            if day.id != comparison.days.last?.id {
                                Divider().overlay(Color.white.opacity(0.06))
                            }
                        }
                    }
                }
            }
        }
        // Re-fetch on either the place OR the unit changing — the unit toggle rebuilds
        // the screen but keeps this view's identity, so a place-only key would go stale.
        .task(id: "\(place.id)-\(unit.rawValue)") {
            comparison = await ModelCompareService().compare(for: place, unit: unit)
        }
    }

    private func header(_ models: [ForecastModel]) -> some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 52, alignment: .leading)
            ForEach(models) { model in
                Text(model.label)
                    .font(Theme.label(11))
                    .tracking(0.5)
                    .foregroundStyle(Color.welkinTertiary)
                    .frame(maxWidth: .infinity)
            }
            // Room for the spread badge column.
            Color.clear.frame(width: 44)
        }
    }

    private func row(_ day: ModelComparison.Day) -> some View {
        HStack(spacing: 0) {
            Text(weekday(day.date))
                .font(Theme.body(14))
                .foregroundStyle(Color.welkinPrimary)
                .frame(width: 52, alignment: .leading)

            ForEach(day.values) { value in
                HStack(spacing: 4) {
                    Image(systemName: value.code.symbol)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.welkinSecondary)
                        .symbolRenderingMode(.hierarchical)
                    Text("\(Int(value.high.rounded()))°")
                        .font(Theme.body(15))
                        .foregroundStyle(Color.welkinPrimary)
                }
                .frame(maxWidth: .infinity)
            }

            // Spread badge, only when the models actually disagree.
            Group {
                if day.spread >= noticeableSpread {
                    Text("Δ\(Int(day.spread.rounded()))°")
                        .font(Theme.label(10))
                        .foregroundStyle(Color.welkinTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
            .frame(width: 44)
        }
    }

    private func weekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}
