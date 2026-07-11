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
            Dish(emoji: "🍰", name: "New York Cheesecake", note: "Dense, rich, and unapologetically tall."),
            Dish(emoji: "🌭", name: "Street Cart Hot Dog", note: "With mustard and onions, eaten standing up."),
            Dish(emoji: "🍗", name: "Halal Cart Chicken & Rice", note: "Late-night gold — go easy on the white sauce."),
            Dish(emoji: "🥟", name: "Chinatown Soup Dumplings", note: "Steamed baskets on Mott Street."),
            Dish(emoji: "🍪", name: "Black-and-White Cookie", note: "Half vanilla, half chocolate, all New York."),
        ]),
        .init(keywords: ["paris"], lat: 48.8566, lon: 2.3522, dishes: [
            Dish(emoji: "🥐", name: "Croissant", note: "Buttery and flaky, straight from a neighborhood boulangerie."),
            Dish(emoji: "🥩", name: "Steak-Frites", note: "The quintessential Parisian bistro plate."),
            Dish(emoji: "🧀", name: "Cheese Board", note: "A selection of French cheeses with a baguette."),
            Dish(emoji: "🥖", name: "Jambon-Beurre", note: "Ham and butter in a baguette — the city's true fast food."),
            Dish(emoji: "🍬", name: "Macarons", note: "Delicate almond shells in a dozen colors."),
            Dish(emoji: "🐌", name: "Escargots", note: "Swimming in garlic-parsley butter."),
            Dish(emoji: "🥞", name: "Crêpes", note: "Sweet or savory, folded from a street window."),
            Dish(emoji: "🧅", name: "Soupe à l'Oignon", note: "Caramelized onions under a lid of melted cheese."),
        ]),
        .init(keywords: ["london"], lat: 51.5074, lon: -0.1278, dishes: [
            Dish(emoji: "🍟", name: "Fish & Chips", note: "Crispy battered cod with chips and malt vinegar."),
            Dish(emoji: "🍮", name: "Sticky Toffee Pudding", note: "Warm sponge cake drenched in toffee sauce."),
            Dish(emoji: "🍛", name: "Chicken Tikka Masala", note: "Britain's beloved curry — try it on Brick Lane."),
            Dish(emoji: "🍳", name: "Full English Breakfast", note: "Eggs, beans, bacon, sausage — the whole plate."),
            Dish(emoji: "🥩", name: "Sunday Roast", note: "Roast beef and Yorkshire pudding at a proper pub."),
            Dish(emoji: "🥧", name: "Pie & Mash", note: "An old East End institution with liquor sauce."),
            Dish(emoji: "🥚", name: "Scotch Egg", note: "A soft egg wrapped in sausage and breadcrumbs."),
            Dish(emoji: "🫖", name: "Afternoon Tea", note: "Scones, clotted cream, and far too many sandwiches."),
        ]),
        .init(keywords: ["tokyo", "shibuya", "shinjuku", "suginami"], lat: 35.6762, lon: 139.6503, dishes: [
            Dish(emoji: "🍣", name: "Sushi", note: "Sit at the counter and let the chef guide you."),
            Dish(emoji: "🍜", name: "Ramen", note: "A steaming bowl — tonkotsu, shoyu, or miso."),
            Dish(emoji: "🍢", name: "Yakitori", note: "Grilled skewers at a tiny izakaya under the tracks."),
            Dish(emoji: "🍤", name: "Tempura", note: "Feather-light batter, fried to order."),
            Dish(emoji: "🐖", name: "Tonkatsu", note: "A thick, crisp-crumbed pork cutlet with shredded cabbage."),
            Dish(emoji: "🍲", name: "Soba", note: "Buckwheat noodles, hot in broth or cold with dipping sauce."),
            Dish(emoji: "🍱", name: "Unagi Don", note: "Grilled eel lacquered with sweet sauce over rice."),
            Dish(emoji: "🐟", name: "Taiyaki", note: "A fish-shaped cake filled with sweet red bean."),
        ]),
        .init(keywords: ["san francisco", "oakland"], lat: 37.7749, lon: -122.4194, dishes: [
            Dish(emoji: "🍞", name: "Sourdough Clam Chowder", note: "Served in a hollowed-out sourdough bread bowl."),
            Dish(emoji: "🌯", name: "Mission Burrito", note: "An overstuffed classic from the Mission District."),
            Dish(emoji: "🦀", name: "Dungeness Crab", note: "Fresh off the boats at Fisherman's Wharf."),
            Dish(emoji: "🥘", name: "Cioppino", note: "The city's own tomato-rich seafood stew."),
            Dish(emoji: "🥟", name: "Chinatown Dim Sum", note: "The oldest Chinatown in North America."),
            Dish(emoji: "🦪", name: "Oysters", note: "Shucked fresh from Tomales Bay."),
            Dish(emoji: "🍫", name: "Ghirardelli Sundae", note: "Unreasonably large, and that's the point."),
        ]),
        .init(keywords: ["sydney"], lat: -33.8688, lon: 151.2093, dishes: [
            Dish(emoji: "🍤", name: "Fresh Seafood", note: "Prawns and oysters at the Sydney Fish Market."),
            Dish(emoji: "🥧", name: "Meat Pie", note: "A flaky Aussie hand pie with tomato sauce."),
            Dish(emoji: "🥑", name: "Smashed Avo", note: "The brunch that Australia gave the world."),
            Dish(emoji: "🐟", name: "Barramundi", note: "Grilled, with a squeeze of lemon."),
            Dish(emoji: "🍰", name: "Lamington", note: "Sponge cake in chocolate and coconut."),
            Dish(emoji: "🍓", name: "Pavlova", note: "Crisp meringue, cream, and passionfruit."),
            Dish(emoji: "☕", name: "Flat White", note: "Order it like a local — no sugar."),
        ]),
        .init(keywords: ["dubai"], lat: 25.2048, lon: 55.2708, dishes: [
            Dish(emoji: "🌯", name: "Shawarma", note: "Spit-roasted meat wrapped with garlic sauce."),
            Dish(emoji: "🍚", name: "Machboos", note: "Fragrant spiced rice with meat or fish."),
            Dish(emoji: "🍮", name: "Luqaimat", note: "Golden dumplings drizzled with date syrup."),
            Dish(emoji: "🫓", name: "Manakish", note: "Flatbread baked with za'atar and olive oil."),
            Dish(emoji: "🥣", name: "Hummus & Mezze", note: "A spread of small plates to share."),
            Dish(emoji: "🍵", name: "Karak Chai", note: "Strong, sweet, milky tea — the local fuel."),
            Dish(emoji: "🧀", name: "Kunafa", note: "Shredded pastry over melted cheese in syrup."),
        ]),
        .init(keywords: ["berlin"], lat: 52.5200, lon: 13.4050, dishes: [
            Dish(emoji: "🌭", name: "Currywurst", note: "Sliced sausage with curried ketchup and fries."),
            Dish(emoji: "🥨", name: "Soft Pretzel", note: "Warm, salted, and best from a street cart."),
            Dish(emoji: "🥙", name: "Döner Kebab", note: "Berlin arguably perfected it — try one late night."),
            Dish(emoji: "🍖", name: "Schnitzel", note: "Pounded thin, breaded, and fried golden."),
            Dish(emoji: "🍩", name: "Berliner", note: "A jam-filled doughnut, no hole."),
            Dish(emoji: "🌭", name: "Bratwurst", note: "Grilled over coals with a smear of mustard."),
            Dish(emoji: "🥔", name: "Kartoffelsalat", note: "German potato salad — every family has a version."),
        ]),
        .init(keywords: ["washington", "district of columbia"], lat: 38.9072, lon: -77.0369, dishes: [
            Dish(emoji: "🦀", name: "Maryland Crab Cake", note: "Lump blue crab with minimal filler."),
            Dish(emoji: "🌭", name: "Half-Smoke", note: "A DC diner classic — spicier than a hot dog."),
            Dish(emoji: "🍽️", name: "Global Food Halls", note: "Taste the world at Union Market and beyond."),
            Dish(emoji: "🫓", name: "Ethiopian Injera", note: "Spongy flatbread and stews — DC does this best."),
            Dish(emoji: "🍕", name: "Jumbo Slice", note: "A late-night slice the size of your forearm."),
            Dish(emoji: "🍗", name: "Mumbo Sauce Wings", note: "Sweet-tangy red sauce, a DC original."),
        ]),
        .init(keywords: ["rio de janeiro", "rio"], lat: -22.9068, lon: -43.1729, dishes: [
            Dish(emoji: "🍖", name: "Churrasco", note: "Endless grilled meats, carved at your table."),
            Dish(emoji: "🥘", name: "Feijoada", note: "A hearty black-bean and pork stew."),
            Dish(emoji: "🧀", name: "Pão de Queijo", note: "Warm, chewy cheese bread."),
            Dish(emoji: "🍇", name: "Açaí Bowl", note: "Frozen and thick, topped with granola."),
            Dish(emoji: "🍗", name: "Coxinha", note: "A teardrop croquette stuffed with shredded chicken."),
            Dish(emoji: "🍫", name: "Brigadeiro", note: "Chocolate fudge balls rolled in sprinkles."),
            Dish(emoji: "🥤", name: "Caldo de Cana", note: "Fresh-pressed sugarcane juice from a street stand."),
        ]),
        .init(keywords: ["singapore"], lat: 1.3521, lon: 103.8198, dishes: [
            Dish(emoji: "🍚", name: "Hainanese Chicken Rice", note: "Singapore's unofficial national dish."),
            Dish(emoji: "🦀", name: "Chilli Crab", note: "Messy, sweet-spicy, and worth it — grab extra buns."),
            Dish(emoji: "🍢", name: "Satay", note: "Charcoal-grilled skewers with peanut sauce."),
            Dish(emoji: "🍜", name: "Laksa", note: "Coconut curry noodles — Katong style is the classic."),
            Dish(emoji: "🍳", name: "Char Kway Teow", note: "Smoky flat noodles with cockles and Chinese sausage."),
            Dish(emoji: "🍲", name: "Bak Kut Teh", note: "Peppery pork rib soup — a proper breakfast."),
            Dish(emoji: "🦐", name: "Hokkien Mee", note: "Noodles braised in a rich prawn stock."),
            Dish(emoji: "🍞", name: "Kaya Toast", note: "With soft-boiled eggs and a cup of kopi."),
            Dish(emoji: "🫓", name: "Roti Prata", note: "Flaky, flipped dough dipped in curry."),
            Dish(emoji: "🥗", name: "Rojak", note: "Fruit and dough fritters in a dark prawn-paste dressing."),
            Dish(emoji: "🐟", name: "Fish Head Curry", note: "A Singaporean invention — tangy, spicy, communal."),
            Dish(emoji: "🥘", name: "Nasi Lemak", note: "Coconut rice with sambal, ikan bilis, and egg."),
            Dish(emoji: "🍳", name: "Orh Luak", note: "Oyster omelette — crispy edges, gooey centre."),
            Dish(emoji: "🍧", name: "Ice Kacang", note: "Shaved ice piled with syrup, beans, and jelly."),
        ]),
        .init(keywords: ["seattle"], lat: 47.6062, lon: -122.3321, dishes: [
            Dish(emoji: "🐟", name: "Wild Salmon", note: "Cedar-planked and fresh from the Pacific."),
            Dish(emoji: "☕", name: "Specialty Coffee", note: "The birthplace of the modern coffeehouse."),
            Dish(emoji: "🍗", name: "Teriyaki", note: "Seattle's own fast-food obsession."),
            Dish(emoji: "🦪", name: "Oysters", note: "Cold-water and briny, from Puget Sound."),
            Dish(emoji: "🍲", name: "Pike Place Chowder", note: "Worth the queue at the market."),
            Dish(emoji: "🌭", name: "Seattle Dog", note: "A hot dog with cream cheese — trust the process."),
            Dish(emoji: "🦀", name: "Dungeness Crab", note: "Sweet, meaty, and local."),
        ]),
        .init(keywords: ["pisa"], lat: 43.7228, lon: 10.3966, dishes: [
            Dish(emoji: "🍝", name: "Fresh Pasta", note: "Handmade and simply sauced, Tuscan-style."),
            Dish(emoji: "🍨", name: "Gelato", note: "Denser and silkier than ice cream."),
            Dish(emoji: "🫓", name: "Cecina", note: "A thin chickpea-flour flatbread, hot from the oven."),
            Dish(emoji: "🍲", name: "Ribollita", note: "Twice-boiled Tuscan bread-and-bean soup."),
            Dish(emoji: "🥗", name: "Panzanella", note: "Bread salad with tomatoes and basil."),
            Dish(emoji: "🥩", name: "Bistecca alla Fiorentina", note: "A towering Tuscan steak, rare by law."),
        ]),
        .init(keywords: ["cairo", "giza"], lat: 30.0444, lon: 31.2357, dishes: [
            Dish(emoji: "🍚", name: "Koshari", note: "Rice, lentils, pasta, and crispy onions in tomato sauce."),
            Dish(emoji: "🥙", name: "Ful Medames", note: "Slow-cooked fava beans — Egypt's classic breakfast."),
            Dish(emoji: "🧆", name: "Taameya", note: "Egyptian falafel, made with fava beans not chickpeas."),
            Dish(emoji: "🥬", name: "Molokhia", note: "A green, garlicky stew served over rice."),
            Dish(emoji: "🥖", name: "Hawawshi", note: "Spiced minced meat baked inside pita."),
            Dish(emoji: "🍮", name: "Om Ali", note: "Egypt's warm bread-and-milk pudding."),
        ]),
        .init(keywords: ["agra"], lat: 27.1751, lon: 78.0421, dishes: [
            Dish(emoji: "🍛", name: "Mughlai Curry", note: "Rich, creamy curries fit for emperors."),
            Dish(emoji: "🍬", name: "Petha", note: "A translucent Agra sweet made from ash gourd."),
            Dish(emoji: "🫓", name: "Bedai & Jalebi", note: "The classic Agra breakfast — spicy and sweet."),
            Dish(emoji: "🍢", name: "Tandoori Kebabs", note: "Charred in a clay oven."),
            Dish(emoji: "🥜", name: "Dalmoth", note: "A crunchy, spiced lentil snack mix."),
            Dish(emoji: "🥘", name: "Mughlai Paratha", note: "Stuffed and fried, best eaten hot."),
        ]),
        .init(keywords: ["toronto"], lat: 43.6532, lon: -79.3832, dishes: [
            Dish(emoji: "🥓", name: "Peameal Bacon Sandwich", note: "A St. Lawrence Market institution."),
            Dish(emoji: "🍟", name: "Poutine", note: "Fries, cheese curds, and gravy."),
            Dish(emoji: "🥧", name: "Butter Tart", note: "Gooey, sweet, and fiercely debated (raisins or not)."),
            Dish(emoji: "🥟", name: "Jamaican Patty", note: "Flaky yellow pastry with spiced beef."),
            Dish(emoji: "🫓", name: "Roti", note: "Wrapped around curry — a Toronto staple."),
            Dish(emoji: "🥢", name: "Dim Sum", note: "One of the best Chinatowns in North America."),
        ]),
        .init(keywords: ["rome", "roma"], lat: 41.9028, lon: 12.4964, dishes: [
            Dish(emoji: "🍝", name: "Cacio e Pepe", note: "Pasta with pecorino and black pepper — deceptively simple."),
            Dish(emoji: "🍕", name: "Pizza al Taglio", note: "Roman pizza by the slice, sold by weight."),
            Dish(emoji: "🍨", name: "Gelato", note: "Skip the neon tubs; find the artigianale spots."),
            Dish(emoji: "🥓", name: "Carbonara", note: "Egg, pecorino, and guanciale — no cream, ever."),
            Dish(emoji: "🍚", name: "Supplì", note: "Fried rice balls with a molten mozzarella heart."),
            Dish(emoji: "🍅", name: "Amatriciana", note: "Tomato, guanciale, and a hit of chili."),
            Dish(emoji: "🥐", name: "Maritozzo", note: "A sweet bun split and packed with cream."),
        ]),
        .init(keywords: ["moscow"], lat: 55.7558, lon: 37.6173, dishes: [
            Dish(emoji: "🥟", name: "Pelmeni", note: "Meat dumplings served with sour cream."),
            Dish(emoji: "🍲", name: "Borscht", note: "A ruby-red beet soup, served hot."),
            Dish(emoji: "🥞", name: "Blini", note: "Thin pancakes with caviar, jam, or sour cream."),
            Dish(emoji: "🥩", name: "Beef Stroganoff", note: "Strips of beef in a sour-cream sauce."),
            Dish(emoji: "🥗", name: "Olivier Salad", note: "The potato salad at every Russian celebration."),
            Dish(emoji: "🧀", name: "Syrniki", note: "Fried curd-cheese pancakes for breakfast."),
        ]),
        .init(keywords: ["cape town"], lat: -33.9249, lon: 18.4241, dishes: [
            Dish(emoji: "🍖", name: "Braai", note: "A South African barbecue — a social event as much as a meal."),
            Dish(emoji: "🥧", name: "Bobotie", note: "Spiced minced meat baked under an egg custard."),
            Dish(emoji: "🍞", name: "Bunny Chow", note: "Curry served inside a hollowed loaf of bread."),
            Dish(emoji: "🥩", name: "Biltong", note: "Air-dried, spiced cured meat — the national snack."),
            Dish(emoji: "🍩", name: "Koeksisters", note: "Plaited dough, fried and drenched in syrup."),
            Dish(emoji: "🍮", name: "Malva Pudding", note: "Warm apricot sponge in a cream sauce."),
        ]),
        .init(keywords: ["chicago"], lat: 41.8781, lon: -87.6298, dishes: [
            Dish(emoji: "🍕", name: "Deep-Dish Pizza", note: "A buttery, tall pie — bring an appetite."),
            Dish(emoji: "🌭", name: "Chicago Dog", note: "Dragged through the garden — never ketchup."),
            Dish(emoji: "🥪", name: "Italian Beef", note: "Thin-sliced beef, dipped, with giardiniera."),
            Dish(emoji: "🍔", name: "Jibarito", note: "A sandwich using fried plantains instead of bread."),
            Dish(emoji: "🍿", name: "Garrett Popcorn", note: "Caramel and cheese mixed together — the 'Chicago Mix'."),
            Dish(emoji: "🍕", name: "Tavern-Style Pizza", note: "Thin, square-cut — what locals actually eat."),
            Dish(emoji: "🍦", name: "Rainbow Cone", note: "Five stacked flavors, sliced not scooped."),
        ]),
        .init(keywords: ["athens"], lat: 37.9838, lon: 23.7275, dishes: [
            Dish(emoji: "🥙", name: "Souvlaki", note: "Grilled meat in pita with tzatziki."),
            Dish(emoji: "🍯", name: "Baklava", note: "Layered filo with nuts and honey."),
            Dish(emoji: "🍆", name: "Moussaka", note: "Layers of eggplant, meat, and béchamel."),
            Dish(emoji: "🥗", name: "Greek Salad", note: "Tomatoes, cucumber, and a slab of feta — no lettuce."),
            Dish(emoji: "🥧", name: "Spanakopita", note: "Spinach and feta in crackling filo."),
            Dish(emoji: "🍩", name: "Loukoumades", note: "Honey-soaked dough balls, hot from the fryer."),
        ]),
        .init(keywords: ["barcelona"], lat: 41.3874, lon: 2.1686, dishes: [
            Dish(emoji: "🥘", name: "Paella", note: "Saffron rice with seafood, cooked in a wide pan."),
            Dish(emoji: "🍤", name: "Tapas", note: "Hop between bars, one small plate at a time."),
            Dish(emoji: "🍩", name: "Churros con Chocolate", note: "For dipping into thick hot chocolate."),
            Dish(emoji: "🍅", name: "Pan con Tomate", note: "Toasted bread rubbed with tomato and oil."),
            Dish(emoji: "🐷", name: "Jamón Ibérico", note: "Cured ham, sliced paper-thin."),
            Dish(emoji: "🥔", name: "Patatas Bravas", note: "Fried potatoes with a spicy sauce."),
            Dish(emoji: "🍮", name: "Crema Catalana", note: "Catalonia's answer to crème brûlée."),
        ]),
        .init(keywords: ["los angeles", "hollywood", "santa monica", "venice", "malibu"], lat: 34.0522, lon: -118.2437, dishes: [
            Dish(emoji: "🌮", name: "Street Tacos", note: "Al pastor from a taco truck, with lime and salsa."),
            Dish(emoji: "🍔", name: "In-N-Out Burger", note: "Order it 'Animal Style' from the secret menu."),
            Dish(emoji: "🥢", name: "Koreatown BBQ", note: "Grill your own at the table, late into the night."),
            Dish(emoji: "🥪", name: "French Dip", note: "Invented here — beef on a roll, dunked in jus."),
            Dish(emoji: "🌮", name: "Birria Tacos", note: "Stewed beef, crisped, with consommé for dipping."),
            Dish(emoji: "🍜", name: "Thai Town Boat Noodles", note: "The largest Thai community outside Thailand."),
            Dish(emoji: "🍩", name: "Donuts", note: "LA runs on independent donut shops."),
        ]),
        .init(keywords: ["st. louis", "st louis", "saint louis"], lat: 38.6270, lon: -90.1994, dishes: [
            Dish(emoji: "🍕", name: "St. Louis Pizza", note: "Cracker-thin crust with Provel cheese."),
            Dish(emoji: "🍰", name: "Gooey Butter Cake", note: "A dense, sweet local invention."),
            Dish(emoji: "🥟", name: "Toasted Ravioli", note: "Breaded, fried, and dunked in marinara."),
            Dish(emoji: "🍦", name: "Frozen Custard", note: "Order a 'concrete' — thick enough to hold upside down."),
            Dish(emoji: "🥩", name: "Pork Steak", note: "Grilled and simmered in barbecue sauce."),
            Dish(emoji: "🍔", name: "The Slinger", note: "Eggs, meat, hash browns, and chili — a diner monster."),
        ]),
        .init(keywords: ["kuala lumpur"], lat: 3.1390, lon: 101.6869, dishes: [
            Dish(emoji: "🍚", name: "Nasi Lemak", note: "Coconut rice with sambal — Malaysia's national dish."),
            Dish(emoji: "🍜", name: "Char Kway Teow", note: "Smoky stir-fried flat noodles."),
            Dish(emoji: "🫓", name: "Roti Canai", note: "Flaky flatbread with dhal and curry."),
            Dish(emoji: "🍢", name: "Satay", note: "Skewers grilled over charcoal, with peanut sauce."),
            Dish(emoji: "🍛", name: "Banana Leaf Rice", note: "Curries and sides heaped onto a leaf."),
            Dish(emoji: "🍧", name: "Cendol", note: "Shaved ice with coconut milk and palm sugar."),
            Dish(emoji: "🍵", name: "Teh Tarik", note: "'Pulled' milk tea, poured for a frothy top."),
        ]),
        .init(keywords: ["mexico city", "ciudad de m"], lat: 19.4326, lon: -99.1332, dishes: [
            Dish(emoji: "🌮", name: "Tacos al Pastor", note: "Spit-roasted pork with pineapple on corn tortillas."),
            Dish(emoji: "🌽", name: "Elote", note: "Grilled street corn with cheese, chili, and lime."),
            Dish(emoji: "🍫", name: "Mole", note: "A complex sauce of chilies, spices, and chocolate."),
            Dish(emoji: "🫔", name: "Tamales", note: "Steamed in corn husks — a morning ritual."),
            Dish(emoji: "🍩", name: "Churros", note: "Fried, sugared, and dipped in chocolate."),
            Dish(emoji: "🍲", name: "Pozole", note: "Hominy stew, garnished at the table."),
            Dish(emoji: "🍳", name: "Chilaquiles", note: "Tortilla chips simmered in salsa — the cure for anything."),
        ]),
        .init(keywords: ["brussels", "bruxelles"], lat: 50.8503, lon: 4.3517, dishes: [
            Dish(emoji: "🧇", name: "Belgian Waffle", note: "Get the caramelized Liège style from a stand."),
            Dish(emoji: "🍟", name: "Frites", note: "Twice-fried and served in a cone with mayo."),
            Dish(emoji: "🍫", name: "Belgian Chocolate", note: "A praline or two from a chocolatier."),
            Dish(emoji: "🦪", name: "Moules-Frites", note: "A steaming pot of mussels, with fries."),
            Dish(emoji: "🍲", name: "Carbonnade Flamande", note: "Beef slow-braised in dark beer."),
            Dish(emoji: "🍪", name: "Speculoos", note: "Spiced caramel biscuits with your coffee."),
        ]),
        .init(keywords: ["beijing", "peking"], lat: 39.9042, lon: 116.4074, dishes: [
            Dish(emoji: "🦆", name: "Peking Duck", note: "Crispy skin wrapped in thin pancakes."),
            Dish(emoji: "🥟", name: "Jianbing", note: "A savory breakfast crêpe from a street cart."),
            Dish(emoji: "🍜", name: "Zhajiangmian", note: "Noodles under a salty fermented-bean sauce."),
            Dish(emoji: "🍲", name: "Hot Pot", note: "Simmer it yourself, dip in sesame sauce."),
            Dish(emoji: "🥠", name: "Baozi", note: "Fluffy steamed buns, sold by the basket."),
            Dish(emoji: "🍢", name: "Lamb Skewers", note: "Cumin-dusted and grilled on the street."),
            Dish(emoji: "🍡", name: "Tanghulu", note: "Candied hawthorn on a stick."),
        ]),
        .init(keywords: ["istanbul"], lat: 41.0082, lon: 28.9784, dishes: [
            Dish(emoji: "🥙", name: "Döner Kebab", note: "Shaved off the vertical spit, in bread or on rice."),
            Dish(emoji: "🐟", name: "Balık Ekmek", note: "A grilled fish sandwich by the Bosphorus."),
            Dish(emoji: "🍮", name: "Baklava", note: "With a glass of Turkish tea."),
            Dish(emoji: "🥯", name: "Simit", note: "A sesame-crusted bread ring from a red cart."),
            Dish(emoji: "🍕", name: "Lahmacun", note: "Thin flatbread with minced meat — roll it up."),
            Dish(emoji: "🫒", name: "Meze", note: "A table of small cold plates, meant for lingering."),
            Dish(emoji: "🧀", name: "Künefe", note: "Melted cheese under crisp shredded pastry."),
        ]),
        .init(keywords: ["amsterdam", "rotterdam"], lat: 52.3676, lon: 4.9041, dishes: [
            Dish(emoji: "🧀", name: "Gouda Cheese", note: "Sample it aged at a cheese shop."),
            Dish(emoji: "🥞", name: "Stroopwafel", note: "Two thin waffles glued with caramel syrup."),
            Dish(emoji: "🐟", name: "Raw Herring", note: "Eaten with onions — a Dutch rite of passage."),
            Dish(emoji: "🧆", name: "Bitterballen", note: "Crunchy beef ragout balls, with mustard and a beer."),
            Dish(emoji: "🥞", name: "Poffertjes", note: "Puffy mini pancakes under powdered sugar."),
            Dish(emoji: "🍟", name: "Patat met Mayo", note: "Thick fries in a paper cone."),
        ]),
        .init(keywords: ["delhi", "new delhi"], lat: 28.6139, lon: 77.2090, dishes: [
            Dish(emoji: "🍛", name: "Butter Chicken", note: "Tandoori chicken in a rich tomato-butter gravy."),
            Dish(emoji: "🫓", name: "Chaat", note: "Tangy, crunchy street snacks in Old Delhi."),
            Dish(emoji: "🥘", name: "Chole Bhature", note: "Spiced chickpeas with fluffy fried bread."),
            Dish(emoji: "🍢", name: "Kebabs", note: "Seekh and galouti, grilled over coals."),
            Dish(emoji: "🍚", name: "Biryani", note: "Layered rice and meat, sealed and slow-cooked."),
            Dish(emoji: "🥟", name: "Momos", note: "Steamed dumplings with fiery red chutney."),
            Dish(emoji: "🍯", name: "Jalebi", note: "Coils of batter fried and soaked in syrup."),
        ]),
        .init(keywords: ["boston"], lat: 42.3601, lon: -71.0589, dishes: [
            Dish(emoji: "🦞", name: "Lobster Roll", note: "Chilled lobster in a buttered, toasted bun."),
            Dish(emoji: "🍲", name: "Clam Chowder", note: "Creamy New England 'chowdah'."),
            Dish(emoji: "🍰", name: "Boston Cream Pie", note: "Actually a cake — the state dessert."),
            Dish(emoji: "🫘", name: "Boston Baked Beans", note: "Slow-baked with molasses."),
            Dish(emoji: "🥐", name: "North End Cannoli", note: "Filled to order, shell still crisp."),
            Dish(emoji: "🥪", name: "Roast Beef Sandwich", note: "A North Shore specialty, rare and piled high."),
        ]),
        .init(keywords: ["miami"], lat: 25.7617, lon: -80.1918, dishes: [
            Dish(emoji: "🥪", name: "Cuban Sandwich", note: "Ham, roast pork, and pickles, pressed."),
            Dish(emoji: "🦀", name: "Stone Crab", note: "Sweet claws with mustard sauce, in season."),
            Dish(emoji: "🐟", name: "Ceviche", note: "Fish 'cooked' in citrus, bright and cold."),
            Dish(emoji: "🧆", name: "Croquetas", note: "Ham croquettes with a cortadito, standing at the window."),
            Dish(emoji: "🥧", name: "Key Lime Pie", note: "Tart, creamy, and pale yellow — never green."),
            Dish(emoji: "🫓", name: "Arepas", note: "Griddled corn cakes stuffed with cheese or meat."),
        ]),
        .init(keywords: ["hong kong", "kowloon"], lat: 22.3193, lon: 114.1694, dishes: [
            Dish(emoji: "🥟", name: "Dim Sum", note: "Steamed baskets with tea — 'yum cha'."),
            Dish(emoji: "🥚", name: "Egg Tarts", note: "Warm, wobbly custard in a flaky shell."),
            Dish(emoji: "🦆", name: "Roast Goose", note: "Lacquered, crisp-skinned, served over rice."),
            Dish(emoji: "🍜", name: "Wonton Noodles", note: "Springy noodles and shrimp wontons in clear broth."),
            Dish(emoji: "🍍", name: "Pineapple Bun", note: "No pineapple — just a sweet, crackly top."),
            Dish(emoji: "🍵", name: "Milk Tea", note: "Strong and silky, strained through a 'stocking'."),
            Dish(emoji: "🍚", name: "Claypot Rice", note: "Crispy at the bottom — that's the best part."),
        ]),
        .init(keywords: ["shanghai"], lat: 31.2304, lon: 121.4737, dishes: [
            Dish(emoji: "🥟", name: "Xiaolongbao", note: "Soup dumplings — bite carefully, they're hot."),
            Dish(emoji: "🍜", name: "Shengjianbao", note: "Pan-fried pork buns with crispy bottoms."),
            Dish(emoji: "🦀", name: "Hairy Crab", note: "A seasonal autumn obsession."),
            Dish(emoji: "🍝", name: "Scallion Oil Noodles", note: "Deceptively simple, deeply savory."),
            Dish(emoji: "🥩", name: "Hongshao Rou", note: "Red-braised pork belly, sweet and glossy."),
            Dish(emoji: "🥖", name: "Youtiao & Soy Milk", note: "The classic Shanghai breakfast pairing."),
        ]),
        .init(keywords: ["mumbai", "bombay"], lat: 19.0760, lon: 72.8777, dishes: [
            Dish(emoji: "🍞", name: "Vada Pav", note: "Mumbai's spicy potato-fritter burger."),
            Dish(emoji: "🫓", name: "Pav Bhaji", note: "Buttery mashed-vegetable curry with soft rolls."),
            Dish(emoji: "🥗", name: "Bhel Puri", note: "Puffed rice, chutneys, and crunch — eaten on the beach."),
            Dish(emoji: "🍲", name: "Misal Pav", note: "Fiery sprout curry topped with farsan."),
            Dish(emoji: "🥪", name: "Bombay Sandwich", note: "Layered with chutney and pressed on a griddle."),
            Dish(emoji: "🦐", name: "Koli Seafood", note: "The fishing community's masala-fried catch."),
            Dish(emoji: "🥤", name: "Falooda", note: "Rose syrup, noodles, and ice cream in a glass."),
        ]),
        .init(keywords: ["bangkok"], lat: 13.7563, lon: 100.5018, dishes: [
            Dish(emoji: "🍜", name: "Pad Thai", note: "Stir-fried noodles from a street wok."),
            Dish(emoji: "🥭", name: "Mango Sticky Rice", note: "Sweet coconut rice with ripe mango."),
            Dish(emoji: "🥘", name: "Green Curry", note: "Fragrant, coconut-rich, and spicy."),
            Dish(emoji: "🥗", name: "Som Tam", note: "Pounded green papaya salad — order it mild, honestly."),
            Dish(emoji: "🍲", name: "Tom Yum Goong", note: "Hot-and-sour prawn soup, lemongrass-forward."),
            Dish(emoji: "🍚", name: "Khao Man Gai", note: "Thailand's take on poached chicken rice."),
            Dish(emoji: "🍢", name: "Moo Ping", note: "Grilled pork skewers with sticky rice, for breakfast."),
        ]),
        .init(keywords: ["madrid"], lat: 40.4168, lon: -3.7038, dishes: [
            Dish(emoji: "🐷", name: "Jamón Ibérico", note: "Cured ham, sliced paper-thin."),
            Dish(emoji: "🍩", name: "Churros", note: "With thick chocolate, morning or night."),
            Dish(emoji: "🍲", name: "Cocido Madrileño", note: "A chickpea stew served in courses."),
            Dish(emoji: "🦑", name: "Bocadillo de Calamares", note: "A fried-squid sandwich, near Plaza Mayor."),
            Dish(emoji: "🍳", name: "Tortilla Española", note: "Potato omelette — runny in the middle if done right."),
            Dish(emoji: "🥔", name: "Patatas Bravas", note: "Crisp potatoes under a smoky, spicy sauce."),
        ]),
        .init(keywords: ["amman"], lat: 31.9539, lon: 35.9106, dishes: [
            Dish(emoji: "🍚", name: "Mansaf", note: "Jordan's national dish — lamb, rice, and jameed yogurt."),
            Dish(emoji: "🍮", name: "Kunafa", note: "Cheese pastry soaked in sweet syrup."),
            Dish(emoji: "🧆", name: "Falafel", note: "Fried fresh, eaten within the minute."),
            Dish(emoji: "🥣", name: "Hummus", note: "Warm, with olive oil pooled in the middle."),
            Dish(emoji: "🥘", name: "Maqluba", note: "'Upside-down' — the pot is flipped at the table."),
            Dish(emoji: "🌯", name: "Shawarma", note: "Carved thin, wrapped tight."),
        ]),
        .init(keywords: ["buenos aires"], lat: -34.6037, lon: -58.3816, dishes: [
            Dish(emoji: "🥩", name: "Asado", note: "Argentine barbecue — beef done slow over coals."),
            Dish(emoji: "🥟", name: "Empanadas", note: "Hand pies with countless fillings."),
            Dish(emoji: "🌭", name: "Choripán", note: "Grilled chorizo in bread with chimichurri."),
            Dish(emoji: "🍖", name: "Milanesa", note: "Breaded cutlet, often topped with ham and cheese."),
            Dish(emoji: "🍪", name: "Alfajores", note: "Two biscuits with dulce de leche between."),
            Dish(emoji: "🧀", name: "Provoleta", note: "A whole disc of provolone, grilled until bubbling."),
        ]),
        .init(keywords: ["são paulo", "sao paulo"], lat: -23.5505, lon: -46.6333, dishes: [
            Dish(emoji: "🥪", name: "Mortadella Sandwich", note: "Towering, at the Mercadão market."),
            Dish(emoji: "🧀", name: "Pão de Queijo", note: "Chewy cheese bread, all day long."),
            Dish(emoji: "🥘", name: "Feijoada", note: "The Saturday ritual — black beans and pork."),
            Dish(emoji: "🍗", name: "Coxinha", note: "Shredded chicken in a crisp teardrop shell."),
            Dish(emoji: "🥟", name: "Pastel de Feira", note: "Fried pastry pockets from the street market."),
            Dish(emoji: "🫓", name: "Esfiha", note: "The city's huge Levantine community, in one bite."),
        ]),
        .init(keywords: ["melbourne"], lat: -37.8136, lon: 144.9631, dishes: [
            Dish(emoji: "☕", name: "Flat White", note: "Melbourne takes its coffee seriously."),
            Dish(emoji: "🥑", name: "Brunch", note: "The city that made café brunch an art form."),
            Dish(emoji: "🍗", name: "Chicken Parma", note: "The pub classic — with chips and a beer."),
            Dish(emoji: "🥟", name: "Dim Sim", note: "A Melbourne invention — steamed or deep-fried."),
            Dish(emoji: "🥖", name: "Bánh Mì", note: "Head to Richmond or Footscray for the real thing."),
            Dish(emoji: "🍰", name: "Lamington", note: "Sponge in chocolate and coconut, with your tea."),
        ]),
        .init(keywords: ["seoul"], lat: 37.5665, lon: 126.9780, dishes: [
            Dish(emoji: "🍖", name: "Korean BBQ", note: "Grill marbled pork and beef at your table."),
            Dish(emoji: "🌶️", name: "Tteokbokki", note: "Chewy rice cakes in a sweet-spicy sauce."),
            Dish(emoji: "🍜", name: "Bibimbap", note: "Rice bowl with vegetables, egg, and gochujang."),
            Dish(emoji: "🍗", name: "Chimaek", note: "Korean fried chicken and beer — a national pastime."),
            Dish(emoji: "🍲", name: "Kimchi Jjigae", note: "A bubbling stew of aged kimchi and pork."),
            Dish(emoji: "🍝", name: "Naengmyeon", note: "Icy buckwheat noodles — a summer cure."),
            Dish(emoji: "🍙", name: "Gimbap", note: "Rolled rice and fillings, made for eating on the move."),
            Dish(emoji: "🥞", name: "Hotteok", note: "A griddled pancake oozing brown sugar syrup."),
        ]),
        .init(keywords: ["austin"], lat: 30.2672, lon: -97.7431, dishes: [
            Dish(emoji: "🍖", name: "Brisket", note: "Central Texas barbecue — smoked for 12+ hours."),
            Dish(emoji: "🌮", name: "Breakfast Tacos", note: "The Austin morning staple."),
            Dish(emoji: "🧀", name: "Queso", note: "Molten, with a basket of warm chips."),
            Dish(emoji: "🍳", name: "Migas", note: "Eggs scrambled with crisp tortilla strips."),
            Dish(emoji: "🥟", name: "Kolaches", note: "A Czech-Texan pastry, sweet or sausage-filled."),
            Dish(emoji: "🌭", name: "Smoked Sausage", note: "Coarse-ground, snappy, straight from the pit."),
        ]),
        .init(keywords: ["philadelphia"], lat: 39.9526, lon: -75.1652, dishes: [
            Dish(emoji: "🥪", name: "Cheesesteak", note: "Thin beef and melted cheese on a hoagie roll."),
            Dish(emoji: "🥨", name: "Soft Pretzel", note: "The Philly street-corner classic."),
            Dish(emoji: "🐖", name: "Roast Pork Sandwich", note: "With broccoli rabe and sharp provolone — the local pick."),
            Dish(emoji: "🍧", name: "Water Ice", note: "Say it 'wooder ice'."),
            Dish(emoji: "🍳", name: "Scrapple", note: "A Pennsylvania Dutch breakfast oddity, fried crisp."),
            Dish(emoji: "🥖", name: "Hoagie", note: "The Italian one, with oil and oregano."),
        ]),
        .init(keywords: ["atlanta"], lat: 33.7490, lon: -84.3880, dishes: [
            Dish(emoji: "🍗", name: "Fried Chicken", note: "Southern-style, crispy and juicy."),
            Dish(emoji: "🍤", name: "Shrimp & Grits", note: "Creamy grits with sautéed shrimp."),
            Dish(emoji: "🥧", name: "Peach Cobbler", note: "Georgia peaches, bubbling under a crust."),
            Dish(emoji: "🥐", name: "Buttermilk Biscuits", note: "Split, buttered, and drowned in gravy."),
            Dish(emoji: "🍖", name: "Southern BBQ", note: "Pulled pork with a vinegary sauce."),
            Dish(emoji: "🍽️", name: "Soul Food Plate", note: "Collards, mac and cheese, cornbread — pick three."),
        ]),
        .init(keywords: ["denver"], lat: 39.7392, lon: -104.9903, dishes: [
            Dish(emoji: "🌶️", name: "Green Chili", note: "Smothered over burritos, Colorado-style."),
            Dish(emoji: "🥩", name: "Rocky Mountain Steak", note: "Hearty cuts in the Mile High City."),
            Dish(emoji: "🍔", name: "Bison Burger", note: "Leaner than beef, and very Colorado."),
            Dish(emoji: "🍳", name: "Denver Omelette", note: "Ham, peppers, and onion — named for the city."),
            Dish(emoji: "🍑", name: "Palisade Peaches", note: "Worth the wait every August."),
            Dish(emoji: "🍺", name: "Craft Brewpub Fare", note: "The city has a brewery for every mood."),
        ]),
        .init(keywords: ["houston"], lat: 29.7604, lon: -95.3698, dishes: [
            Dish(emoji: "🌮", name: "Tex-Mex", note: "Fajitas, queso, and breakfast tacos."),
            Dish(emoji: "🦐", name: "Viet-Cajun Crawfish", note: "A Houston mash-up worth seeking out."),
            Dish(emoji: "🍖", name: "Texas Brisket", note: "Smoked over post oak, sold by the pound."),
            Dish(emoji: "🥖", name: "Bánh Mì", note: "Houston's Vietnamese community does it beautifully."),
            Dish(emoji: "🦪", name: "Gulf Oysters", note: "Straight from the coast, on ice."),
            Dish(emoji: "🥟", name: "Kolaches", note: "The Czech-Texan pastry, best before 9am."),
        ]),
        .init(keywords: ["las vegas"], lat: 36.1699, lon: -115.1398, dishes: [
            Dish(emoji: "🍽️", name: "Buffet Feast", note: "The over-the-top Vegas buffet experience."),
            Dish(emoji: "👨‍🍳", name: "Celebrity Chef Dining", note: "Nearly every big-name chef has a table here."),
            Dish(emoji: "🍤", name: "Shrimp Cocktail", note: "The old-school Vegas late-night bargain."),
            Dish(emoji: "🍳", name: "Steak & Eggs", note: "24-hour diner fuel at an unwise hour."),
            Dish(emoji: "🍜", name: "Chinatown Noodles", note: "Locals skip the Strip and come here."),
            Dish(emoji: "🍩", name: "Late-Night Donuts", note: "Because the city never quite closes."),
        ]),
        .init(keywords: ["vancouver"], lat: 49.2827, lon: -123.1207, dishes: [
            Dish(emoji: "🍣", name: "Sushi", note: "Some of the best outside Japan."),
            Dish(emoji: "🌭", name: "Japadog", note: "A Japanese-topped hot dog street cart."),
            Dish(emoji: "🐟", name: "Wild Pacific Salmon", note: "Grilled simply, as it should be."),
            Dish(emoji: "🥟", name: "Dim Sum", note: "Richmond's is world-class."),
            Dish(emoji: "🍟", name: "Poutine", note: "Fries, curds, gravy — the Canadian constant."),
            Dish(emoji: "🍫", name: "Nanaimo Bar", note: "A no-bake BC classic in three layers."),
            Dish(emoji: "🍜", name: "Ramen", note: "The city takes its noodle bars seriously."),
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
