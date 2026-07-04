import Foundation

/// A local dish to try, shown in the "Local Flavor" card.
struct Dish: Sendable {
    let emoji: String
    let name: String
    let note: String
}

/// Curated local delicacies per city, rotated daily (like the landmarks).
enum FlavorCatalog {
    private struct Entry {
        let keywords: [String]
        let lat: Double
        let lon: Double
        let dishes: [Dish]
    }

    private static let entries: [Entry] = [
        .init(keywords: ["new york", "nyc", "manhattan", "brooklyn"], lat: 40.7128, lon: -74.0060, dishes: [
            Dish(emoji: "🍕", name: "New York Slice", note: "Grab a wide, foldable slice from a corner pizzeria."),
            Dish(emoji: "🥯", name: "Bagel with Lox", note: "A fresh bagel with smoked salmon and cream cheese."),
            Dish(emoji: "🥪", name: "Pastrami on Rye", note: "Piled high at a classic Jewish deli."),
        ]),
        .init(keywords: ["paris"], lat: 48.8566, lon: 2.3522, dishes: [
            Dish(emoji: "🥐", name: "Croissant", note: "Buttery and flaky, straight from a neighborhood boulangerie."),
            Dish(emoji: "🥩", name: "Steak-Frites", note: "The quintessential Parisian bistro plate."),
            Dish(emoji: "🧀", name: "Cheese Board", note: "A selection of French cheeses with a baguette."),
        ]),
        .init(keywords: ["london"], lat: 51.5074, lon: -0.1278, dishes: [
            Dish(emoji: "🍟", name: "Fish & Chips", note: "Crispy battered cod with chips and malt vinegar."),
            Dish(emoji: "🍮", name: "Sticky Toffee Pudding", note: "Warm sponge cake drenched in toffee sauce."),
            Dish(emoji: "🍛", name: "Chicken Tikka Masala", note: "Britain's beloved curry — try it on Brick Lane."),
        ]),
        .init(keywords: ["tokyo", "shibuya", "shinjuku", "suginami"], lat: 35.6762, lon: 139.6503, dishes: [
            Dish(emoji: "🍣", name: "Sushi", note: "Sit at the counter and let the chef guide you."),
            Dish(emoji: "🍜", name: "Ramen", note: "A steaming bowl — tonkotsu, shoyu, or miso."),
            Dish(emoji: "🍢", name: "Yakitori", note: "Grilled skewers at a tiny izakaya under the tracks."),
        ]),
        .init(keywords: ["san francisco", "oakland"], lat: 37.7749, lon: -122.4194, dishes: [
            Dish(emoji: "🍞", name: "Sourdough Clam Chowder", note: "Served in a hollowed-out sourdough bread bowl."),
            Dish(emoji: "🌯", name: "Mission Burrito", note: "An overstuffed classic from the Mission District."),
            Dish(emoji: "🦀", name: "Dungeness Crab", note: "Fresh off the boats at Fisherman's Wharf."),
        ]),
        .init(keywords: ["sydney"], lat: -33.8688, lon: 151.2093, dishes: [
            Dish(emoji: "🍤", name: "Fresh Seafood", note: "Prawns and oysters at the Sydney Fish Market."),
            Dish(emoji: "🥧", name: "Meat Pie", note: "A flaky Aussie hand pie with tomato sauce."),
            Dish(emoji: "🥑", name: "Smashed Avo", note: "The brunch that Australia gave the world."),
        ]),
        .init(keywords: ["dubai"], lat: 25.2048, lon: 55.2708, dishes: [
            Dish(emoji: "🌯", name: "Shawarma", note: "Spit-roasted meat wrapped with garlic sauce."),
            Dish(emoji: "🍚", name: "Machboos", note: "Fragrant spiced rice with meat or fish."),
            Dish(emoji: "🍮", name: "Luqaimat", note: "Golden dumplings drizzled with date syrup."),
        ]),
        .init(keywords: ["berlin"], lat: 52.5200, lon: 13.4050, dishes: [
            Dish(emoji: "🌭", name: "Currywurst", note: "Sliced sausage with curried ketchup and fries."),
            Dish(emoji: "🥨", name: "Soft Pretzel", note: "Warm, salted, and best from a street cart."),
            Dish(emoji: "🥙", name: "Döner Kebab", note: "Berlin arguably perfected it — try one late night."),
        ]),
        .init(keywords: ["washington", "district of columbia"], lat: 38.9072, lon: -77.0369, dishes: [
            Dish(emoji: "🦀", name: "Maryland Crab Cake", note: "Lump blue crab with minimal filler."),
            Dish(emoji: "🌭", name: "Half-Smoke", note: "A DC diner classic — spicier than a hot dog."),
            Dish(emoji: "🍽️", name: "Global Food Halls", note: "Taste the world at Union Market and beyond."),
        ]),
        .init(keywords: ["rio de janeiro", "rio"], lat: -22.9068, lon: -43.1729, dishes: [
            Dish(emoji: "🍖", name: "Churrasco", note: "Endless grilled meats, carved at your table."),
            Dish(emoji: "🥘", name: "Feijoada", note: "A hearty black-bean and pork stew."),
            Dish(emoji: "🧀", name: "Pão de Queijo", note: "Warm, chewy cheese bread."),
        ]),
        .init(keywords: ["singapore"], lat: 1.3521, lon: 103.8198, dishes: [
            Dish(emoji: "🍜", name: "Hainanese Chicken Rice", note: "Singapore's unofficial national dish."),
            Dish(emoji: "🦀", name: "Chilli Crab", note: "Messy, sweet-spicy, and worth it — grab extra buns."),
            Dish(emoji: "🍢", name: "Satay", note: "Charcoal-grilled skewers at a hawker centre."),
        ]),
        .init(keywords: ["seattle"], lat: 47.6062, lon: -122.3321, dishes: [
            Dish(emoji: "🐟", name: "Wild Salmon", note: "Cedar-planked and fresh from the Pacific."),
            Dish(emoji: "☕", name: "Specialty Coffee", note: "The birthplace of the modern coffeehouse."),
        ]),
        .init(keywords: ["pisa"], lat: 43.7228, lon: 10.3966, dishes: [
            Dish(emoji: "🍝", name: "Fresh Pasta", note: "Handmade and simply sauced, Tuscan-style."),
            Dish(emoji: "🍨", name: "Gelato", note: "Denser and silkier than ice cream."),
        ]),
        .init(keywords: ["cairo", "giza"], lat: 30.0444, lon: 31.2357, dishes: [
            Dish(emoji: "🍚", name: "Koshari", note: "Rice, lentils, pasta, and crispy onions in tomato sauce."),
            Dish(emoji: "🥙", name: "Ful Medames", note: "Slow-cooked fava beans — Egypt's classic breakfast."),
        ]),
        .init(keywords: ["agra"], lat: 27.1751, lon: 78.0421, dishes: [
            Dish(emoji: "🍛", name: "Mughlai Curry", note: "Rich, creamy curries fit for emperors."),
            Dish(emoji: "🍬", name: "Petha", note: "A translucent Agra sweet made from ash gourd."),
        ]),
        .init(keywords: ["toronto"], lat: 43.6532, lon: -79.3832, dishes: [
            Dish(emoji: "🥓", name: "Peameal Bacon Sandwich", note: "A St. Lawrence Market institution."),
            Dish(emoji: "🍟", name: "Poutine", note: "Fries, cheese curds, and gravy."),
        ]),
        .init(keywords: ["rome", "roma"], lat: 41.9028, lon: 12.4964, dishes: [
            Dish(emoji: "🍝", name: "Cacio e Pepe", note: "Pasta with pecorino and black pepper — deceptively simple."),
            Dish(emoji: "🍕", name: "Pizza al Taglio", note: "Roman pizza by the slice, sold by weight."),
            Dish(emoji: "🍨", name: "Gelato", note: "Skip the neon tubs; find the artigianale spots."),
        ]),
        .init(keywords: ["moscow"], lat: 55.7558, lon: 37.6173, dishes: [
            Dish(emoji: "🥟", name: "Pelmeni", note: "Meat dumplings served with sour cream."),
            Dish(emoji: "🍲", name: "Borscht", note: "A ruby-red beet soup, served hot."),
        ]),
        .init(keywords: ["cape town"], lat: -33.9249, lon: 18.4241, dishes: [
            Dish(emoji: "🍖", name: "Braai", note: "A South African barbecue — a social event as much as a meal."),
            Dish(emoji: "🥧", name: "Bobotie", note: "Spiced minced meat baked under an egg custard."),
        ]),
        .init(keywords: ["chicago"], lat: 41.8781, lon: -87.6298, dishes: [
            Dish(emoji: "🍕", name: "Deep-Dish Pizza", note: "A buttery, tall pie — bring an appetite."),
            Dish(emoji: "🌭", name: "Chicago Dog", note: "Dragged through the garden — never ketchup."),
            Dish(emoji: "🥪", name: "Italian Beef", note: "Thin-sliced beef, dipped, with giardiniera."),
        ]),
        .init(keywords: ["athens"], lat: 37.9838, lon: 23.7275, dishes: [
            Dish(emoji: "🥙", name: "Souvlaki", note: "Grilled meat in pita with tzatziki."),
            Dish(emoji: "🍯", name: "Baklava", note: "Layered filo with nuts and honey."),
        ]),
        .init(keywords: ["barcelona"], lat: 41.3874, lon: 2.1686, dishes: [
            Dish(emoji: "🥘", name: "Paella", note: "Saffron rice with seafood, cooked in a wide pan."),
            Dish(emoji: "🍤", name: "Tapas", note: "Hop between bars, one small plate at a time."),
            Dish(emoji: "🍩", name: "Churros con Chocolate", note: "For dipping into thick hot chocolate."),
        ]),
        .init(keywords: ["los angeles", "hollywood", "santa monica", "venice", "malibu"], lat: 34.0522, lon: -118.2437, dishes: [
            Dish(emoji: "🌮", name: "Street Tacos", note: "Al pastor from a taco truck, with lime and salsa."),
            Dish(emoji: "🍔", name: "In-N-Out Burger", note: "Order it 'Animal Style' from the secret menu."),
            Dish(emoji: "🥢", name: "Koreatown BBQ", note: "Grill your own at the table, late into the night."),
        ]),
        .init(keywords: ["st. louis", "st louis", "saint louis"], lat: 38.6270, lon: -90.1994, dishes: [
            Dish(emoji: "🍕", name: "St. Louis Pizza", note: "Cracker-thin crust with Provel cheese."),
            Dish(emoji: "🍰", name: "Gooey Butter Cake", note: "A dense, sweet local invention."),
        ]),
        .init(keywords: ["kuala lumpur"], lat: 3.1390, lon: 101.6869, dishes: [
            Dish(emoji: "🍚", name: "Nasi Lemak", note: "Coconut rice with sambal — Malaysia's national dish."),
            Dish(emoji: "🍜", name: "Char Kway Teow", note: "Smoky stir-fried flat noodles."),
        ]),
        .init(keywords: ["mexico city", "ciudad de m"], lat: 19.4326, lon: -99.1332, dishes: [
            Dish(emoji: "🌮", name: "Tacos al Pastor", note: "Spit-roasted pork with pineapple on corn tortillas."),
            Dish(emoji: "🌽", name: "Elote", note: "Grilled street corn with cheese, chili, and lime."),
            Dish(emoji: "🍫", name: "Mole", note: "A complex sauce of chilies, spices, and chocolate."),
        ]),
        .init(keywords: ["brussels", "bruxelles"], lat: 50.8503, lon: 4.3517, dishes: [
            Dish(emoji: "🧇", name: "Belgian Waffle", note: "Get the caramelized Liège style from a stand."),
            Dish(emoji: "🍟", name: "Frites", note: "Twice-fried and served in a cone with mayo."),
            Dish(emoji: "🍫", name: "Belgian Chocolate", note: "A praline or two from a chocolatier."),
        ]),
        .init(keywords: ["beijing", "peking"], lat: 39.9042, lon: 116.4074, dishes: [
            Dish(emoji: "🦆", name: "Peking Duck", note: "Crispy skin wrapped in thin pancakes."),
            Dish(emoji: "🥟", name: "Jianbing", note: "A savory breakfast crêpe from a street cart."),
        ]),
        .init(keywords: ["istanbul"], lat: 41.0082, lon: 28.9784, dishes: [
            Dish(emoji: "🥙", name: "Döner Kebab", note: "Shaved off the vertical spit, in bread or on rice."),
            Dish(emoji: "🐟", name: "Balık Ekmek", note: "A grilled fish sandwich by the Bosphorus."),
            Dish(emoji: "🍮", name: "Baklava", note: "With a glass of Turkish tea."),
        ]),
        .init(keywords: ["amsterdam", "rotterdam"], lat: 52.3676, lon: 4.9041, dishes: [
            Dish(emoji: "🧀", name: "Gouda Cheese", note: "Sample it aged at a cheese shop."),
            Dish(emoji: "🥞", name: "Stroopwafel", note: "Two thin waffles glued with caramel syrup."),
            Dish(emoji: "🐟", name: "Raw Herring", note: "Eaten with onions — a Dutch rite of passage."),
        ]),
        .init(keywords: ["delhi", "new delhi"], lat: 28.6139, lon: 77.2090, dishes: [
            Dish(emoji: "🍛", name: "Butter Chicken", note: "Tandoori chicken in a rich tomato-butter gravy."),
            Dish(emoji: "🫓", name: "Chaat", note: "Tangy, crunchy street snacks in Old Delhi."),
            Dish(emoji: "🥘", name: "Chole Bhature", note: "Spiced chickpeas with fluffy fried bread."),
        ]),
        .init(keywords: ["boston"], lat: 42.3601, lon: -71.0589, dishes: [
            Dish(emoji: "🦞", name: "Lobster Roll", note: "Chilled lobster in a buttered, toasted bun."),
            Dish(emoji: "🍲", name: "Clam Chowder", note: "Creamy New England 'chowdah'."),
        ]),
        .init(keywords: ["miami"], lat: 25.7617, lon: -80.1918, dishes: [
            Dish(emoji: "🥪", name: "Cuban Sandwich", note: "Ham, roast pork, and pickles, pressed."),
            Dish(emoji: "🦀", name: "Stone Crab", note: "Sweet claws with mustard sauce, in season."),
        ]),
        .init(keywords: ["hong kong", "kowloon"], lat: 22.3193, lon: 114.1694, dishes: [
            Dish(emoji: "🥟", name: "Dim Sum", note: "Steamed baskets with tea — 'yum cha'."),
            Dish(emoji: "🥚", name: "Egg Tarts", note: "Warm, wobbly custard in a flaky shell."),
        ]),
        .init(keywords: ["shanghai"], lat: 31.2304, lon: 121.4737, dishes: [
            Dish(emoji: "🥟", name: "Xiaolongbao", note: "Soup dumplings — bite carefully, they're hot."),
            Dish(emoji: "🍜", name: "Shengjianbao", note: "Pan-fried pork buns with crispy bottoms."),
        ]),
        .init(keywords: ["mumbai", "bombay"], lat: 19.0760, lon: 72.8777, dishes: [
            Dish(emoji: "🍞", name: "Vada Pav", note: "Mumbai's spicy potato-fritter burger."),
            Dish(emoji: "🫓", name: "Pav Bhaji", note: "Buttery mashed-vegetable curry with soft rolls."),
        ]),
        .init(keywords: ["bangkok"], lat: 13.7563, lon: 100.5018, dishes: [
            Dish(emoji: "🍜", name: "Pad Thai", note: "Stir-fried noodles from a street wok."),
            Dish(emoji: "🥭", name: "Mango Sticky Rice", note: "Sweet coconut rice with ripe mango."),
            Dish(emoji: "🥘", name: "Green Curry", note: "Fragrant, coconut-rich, and spicy."),
        ]),
        .init(keywords: ["madrid"], lat: 40.4168, lon: -3.7038, dishes: [
            Dish(emoji: "🐷", name: "Jamón Ibérico", note: "Cured ham, sliced paper-thin."),
            Dish(emoji: "🍩", name: "Churros", note: "With thick chocolate, morning or night."),
        ]),
        .init(keywords: ["amman"], lat: 31.9539, lon: 35.9106, dishes: [
            Dish(emoji: "🍚", name: "Mansaf", note: "Jordan's national dish — lamb, rice, and jameed yogurt."),
            Dish(emoji: "🍮", name: "Kunafa", note: "Cheese pastry soaked in sweet syrup."),
        ]),
        .init(keywords: ["buenos aires"], lat: -34.6037, lon: -58.3816, dishes: [
            Dish(emoji: "🥩", name: "Asado", note: "Argentine barbecue — beef done slow over coals."),
            Dish(emoji: "🥟", name: "Empanadas", note: "Hand pies with countless fillings."),
        ]),
        .init(keywords: ["são paulo", "sao paulo"], lat: -23.5505, lon: -46.6333, dishes: [
            Dish(emoji: "🥪", name: "Mortadella Sandwich", note: "Towering, at the Mercadão market."),
            Dish(emoji: "🧀", name: "Pão de Queijo", note: "Chewy cheese bread, all day long."),
        ]),
        .init(keywords: ["melbourne"], lat: -37.8136, lon: 144.9631, dishes: [
            Dish(emoji: "☕", name: "Flat White", note: "Melbourne takes its coffee seriously."),
            Dish(emoji: "🥑", name: "Brunch", note: "The city that made café brunch an art form."),
        ]),
        .init(keywords: ["seoul"], lat: 37.5665, lon: 126.9780, dishes: [
            Dish(emoji: "🍖", name: "Korean BBQ", note: "Grill marbled pork and beef at your table."),
            Dish(emoji: "🌶️", name: "Tteokbokki", note: "Chewy rice cakes in a sweet-spicy sauce."),
            Dish(emoji: "🍜", name: "Bibimbap", note: "Rice bowl with vegetables, egg, and gochujang."),
        ]),
        .init(keywords: ["austin"], lat: 30.2672, lon: -97.7431, dishes: [
            Dish(emoji: "🍖", name: "Brisket", note: "Central Texas barbecue — smoked for 12+ hours."),
            Dish(emoji: "🌮", name: "Breakfast Tacos", note: "The Austin morning staple."),
        ]),
        .init(keywords: ["philadelphia"], lat: 39.9526, lon: -75.1652, dishes: [
            Dish(emoji: "🥪", name: "Cheesesteak", note: "Thin beef and melted cheese on a hoagie roll."),
            Dish(emoji: "🥨", name: "Soft Pretzel", note: "The Philly street-corner classic."),
        ]),
        .init(keywords: ["atlanta"], lat: 33.7490, lon: -84.3880, dishes: [
            Dish(emoji: "🍗", name: "Fried Chicken", note: "Southern-style, crispy and juicy."),
            Dish(emoji: "🍤", name: "Shrimp & Grits", note: "Creamy grits with sautéed shrimp."),
        ]),
        .init(keywords: ["denver"], lat: 39.7392, lon: -104.9903, dishes: [
            Dish(emoji: "🌶️", name: "Green Chili", note: "Smothered over burritos, Colorado-style."),
            Dish(emoji: "🥩", name: "Rocky Mountain Steak", note: "Hearty cuts in the Mile High City."),
        ]),
        .init(keywords: ["houston"], lat: 29.7604, lon: -95.3698, dishes: [
            Dish(emoji: "🌮", name: "Tex-Mex", note: "Fajitas, queso, and breakfast tacos."),
            Dish(emoji: "🦐", name: "Viet-Cajun Crawfish", note: "A Houston mash-up worth seeking out."),
        ]),
        .init(keywords: ["las vegas"], lat: 36.1699, lon: -115.1398, dishes: [
            Dish(emoji: "🍽️", name: "Buffet Feast", note: "The over-the-top Vegas buffet experience."),
            Dish(emoji: "👨‍🍳", name: "Celebrity Chef Dining", note: "Nearly every big-name chef has a table here."),
        ]),
        .init(keywords: ["vancouver"], lat: 49.2827, lon: -123.1207, dishes: [
            Dish(emoji: "🍣", name: "Sushi", note: "Some of the best outside Japan."),
            Dish(emoji: "🌭", name: "Japadog", note: "A Japanese-topped hot dog street cart."),
        ]),
    ]

    static func flavor(for place: Place, on date: Date = Date()) -> Dish {
        let name = place.name.lowercased()

        let matched: Entry? = entries.first(where: { entry in
            entry.keywords.contains(where: { name.contains($0) })
        }) ?? closest(to: place)

        guard let entry = matched, !entry.dishes.isEmpty else {
            return Dish(emoji: "🍽️", name: "Local Street Food",
                        note: "Seek out the markets and street stalls — that's where the real flavor is.")
        }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return entry.dishes[(day - 1) % entry.dishes.count]
    }

    private static func closest(to place: Place) -> Entry? {
        var best: (entry: Entry, dist: Double)?
        for entry in entries {
            let d = haversineKm(place.latitude, place.longitude, entry.lat, entry.lon)
            if best == nil || d < best!.dist { best = (entry, d) }
        }
        if let best, best.dist < 60 { return best.entry }
        return nil
    }

    private static func haversineKm(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        let r = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
