import SwiftUI

/// Inline "local delicacy to try" — just the emoji and a short description,
/// meant to sit within the hero (no card chrome).
struct LocalFlavorView: View {
    let place: Place

    private var dish: Dish { FlavorCatalog.flavor(for: place) }

    var body: some View {
        HStack(spacing: 12) {
            Text(dish.emoji)
                .font(.system(size: 34))

            VStack(alignment: .leading, spacing: 1) {
                Text("TASTE OF THE CITY")
                    .font(Theme.label(9))
                    .tracking(1.5)
                    .foregroundStyle(Color.auroraTertiary)
                Text(dish.name)
                    .font(Theme.title(16))
                    .foregroundStyle(Color.auroraPrimary)
                Text(dish.note)
                    .font(Theme.body(12))
                    .foregroundStyle(Color.auroraSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: 320, alignment: .leading)
    }
}
