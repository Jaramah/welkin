import SwiftUI

/// A "did you know" about the place on screen. Rotates daily, and a tap cycles to
/// the next one — the facts are the reason to keep looking at the app once you
/// already know the temperature.
struct CityFactView: View {
    let place: Place

    @State private var offset = 0

    private var fact: Fact { FactCatalog.fact(for: place, offset: offset) }

    var body: some View {
        Button {
            withAnimation(.snappy) { offset += 1 }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Text(fact.emoji)
                    .font(.system(size: 30))

                VStack(alignment: .leading, spacing: 3) {
                    Text("DID YOU KNOW")
                        .font(Theme.label(9))
                        .tracking(1.5)
                        .foregroundStyle(Color.welkinTertiary)
                    Text(fact.text)
                        .font(Theme.body(13))
                        .foregroundStyle(Color.welkinSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 320, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // The fact changes with the place, so a stale one never lingers after you
        // switch cities.
        .onChange(of: place.id) { offset = 0 }
        .id(fact.id)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Did you know: \(fact.text)")
        .accessibilityHint("Double tap for another fact")
    }
}
