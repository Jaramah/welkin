import SwiftUI

struct LocalFlavorView: View {
    let place: Place

    private var dish: Dish { FlavorCatalog.flavor(for: place) }

    var body: some View {
        GlassCard(title: "Local Flavor", systemImage: "fork.knife") {
            HStack(alignment: .center, spacing: 16) {
                Text(dish.emoji)
                    .font(.system(size: 40))
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(dish.name)
                        .font(Theme.title(18))
                        .foregroundStyle(Color.auroraPrimary)
                    Text(dish.note)
                        .font(Theme.body(13))
                        .foregroundStyle(Color.auroraSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
