import Foundation

/// A single "did you know" about the place you're looking at.
struct Fact: Sendable, Equatable, Identifiable {
    let emoji: String
    let text: String
    var id: String { text }
}

/// Facts for the place on screen, matched city-first then country, so a town we
/// have never heard of still gets something true about the country it sits in.
enum FactCatalog {
    private struct Entry: Sendable {
        let keywords: [String]
        let facts: [Fact]
    }

    /// All facts for a place, best match first.
    static func facts(for place: Place) -> [Fact] {
        let haystack = [place.name, place.admin, place.country]
            .compactMap { $0?.lowercased() }

        if let city = cities.first(where: { entry in
            entry.keywords.contains { key in haystack.contains { $0.contains(key) } }
        }) {
            return city.facts
        }
        if let country = countries.first(where: { entry in
            entry.keywords.contains { key in haystack.contains { $0.contains(key) } }
        }) {
            return country.facts
        }
        return universal
    }

    /// One fact, rotating daily so the app has something new to say each morning.
    static func fact(for place: Place, on date: Date = Date()) -> Fact {
        let pool = facts(for: place)
        let day = Calendar(identifier: .gregorian).ordinality(of: .day, in: .era, for: date) ?? 0
        return pool[abs(day) % pool.count]
    }

    /// Next fact in the rotation — lets a tap cycle through them.
    static func fact(for place: Place, on date: Date = Date(), offset: Int) -> Fact {
        let pool = facts(for: place)
        let day = Calendar(identifier: .gregorian).ordinality(of: .day, in: .era, for: date) ?? 0
        return pool[abs(day &+ offset) % pool.count]
    }

    // MARK: - Cities

    private static let cities: [Entry] = [
        .init(keywords: ["singapore", "bedok", "tampines", "jurong", "woodlands", "punggol"], facts: [
            .init(emoji: "🦁", text: "The name comes from the Sanskrit Singapura, “Lion City” — though lions never lived here. The beast Sang Nila Utama saw was almost certainly a tiger."),
            .init(emoji: "🌏", text: "Sitting about 1° north of the equator, day length barely changes: sunrise and sunset shift by only minutes across the whole year."),
            .init(emoji: "🏝️", text: "Singapore is roughly a quarter larger than it was at independence, having reclaimed land from the sea for decades."),
            .init(emoji: "🌳", text: "Bukit Timah holds a patch of primary rainforest inside the city limits — something almost no other city on earth can claim."),
            .init(emoji: "✈️", text: "Changi has been named the world's best airport more often than any other, and it keeps a butterfly garden inside a terminal."),
            .init(emoji: "💧", text: "Rain falls on around 170 days a year, and the island recycles used water into drinking-grade NEWater to stretch every drop."),
            .init(emoji: "🌡️", text: "There are no seasons to speak of — the average monthly temperature varies by barely 2°C from January to July."),
        ]),
        .init(keywords: ["new york", "nyc", "manhattan", "brooklyn"], facts: [
            .init(emoji: "🗣️", text: "More than 700 languages are spoken here, making New York the most linguistically diverse city in the world."),
            .init(emoji: "🌳", text: "Central Park is entirely man-made. Every lake, hill and meadow in it was designed and built."),
            .init(emoji: "🚇", text: "The subway runs 24 hours a day, every day — one of the very few metro systems on earth that never closes."),
            .init(emoji: "🗽", text: "The Statue of Liberty was a gift from France, shipped across the Atlantic in 350 pieces packed into 214 crates."),
            .init(emoji: "🏢", text: "The Empire State Building is big enough to have its own ZIP code: 10118."),
            .init(emoji: "🤫", text: "Outside the Oyster Bar in Grand Central, a whispering gallery carries your voice across the arch to someone standing in the opposite corner."),
        ]),
        .init(keywords: ["london"], facts: [
            .init(emoji: "🚇", text: "The Underground is the oldest metro in the world — it has been running since 1863."),
            .init(emoji: "🌧️", text: "London is drier than Rome, Sydney and New York. It simply rains more often, in smaller amounts."),
            .init(emoji: "🔔", text: "Big Ben is the bell, not the tower. The tower is the Elizabeth Tower."),
            .init(emoji: "🦊", text: "Thousands of red foxes live inside the city, and they are seen more often in London than in most of the countryside."),
            .init(emoji: "🌉", text: "Tower Bridge still lifts for river traffic around 800 times a year, and it's free to watch."),
            .init(emoji: "🏛️", text: "Nowhere in London is more than a few miles from the Thames, which is tidal all the way through the city."),
        ]),
        .init(keywords: ["paris"], facts: [
            .init(emoji: "🗼", text: "The Eiffel Tower grows about 15 cm taller in summer — its iron expands in the heat."),
            .init(emoji: "🏛️", text: "The Louvre is the most-visited museum on earth, and you could not see every work in it in a single day."),
            .init(emoji: "💀", text: "The Catacombs beneath the streets hold the remains of roughly six million people."),
            .init(emoji: "🥖", text: "French law defines the baguette de tradition: flour, water, salt and yeast, and nothing else."),
            .init(emoji: "🌉", text: "Thirty-seven bridges cross the Seine within the city."),
            .init(emoji: "🎨", text: "The Eiffel Tower was meant to be temporary — built for the 1889 World's Fair and slated for demolition twenty years later."),
        ]),
        .init(keywords: ["tokyo", "shibuya", "shinjuku"], facts: [
            .init(emoji: "🚉", text: "Shinjuku is the busiest railway station in the world, moving around 3.5 million people a day."),
            .init(emoji: "⭐", text: "Tokyo holds more Michelin stars than any other city on the planet."),
            .init(emoji: "🗼", text: "Tokyo Tower stands 333 m — taller than the Eiffel Tower that inspired it, and much lighter."),
            .init(emoji: "🏙️", text: "Greater Tokyo is the most populous metropolitan area on earth, home to some 37 million people."),
            .init(emoji: "🌸", text: "The cherry blossom front is forecast nationally, tracked north across the country like a weather system."),
            .init(emoji: "🐟", text: "The fish market moved to Toyosu in 2018, but tuna there still sells at auction for eye-watering sums."),
        ]),
        .init(keywords: ["hong kong", "kowloon"], facts: [
            .init(emoji: "🏙️", text: "Hong Kong has more skyscrapers than any other city in the world — comfortably more than New York."),
            .init(emoji: "🌲", text: "Despite the density, roughly three-quarters of the territory is countryside, and about 40% is protected park."),
            .init(emoji: "🚋", text: "The double-decker trams have run on Hong Kong Island since 1904 and are still one of the cheapest rides anywhere."),
            .init(emoji: "🐉", text: "Some buildings have large square holes through them — “dragon gates”, left so the dragons can reach the sea."),
            .init(emoji: "🚡", text: "The Peak Tram climbs so steeply that the towers outside appear to lean backwards as you ride."),
        ]),
        .init(keywords: ["sydney"], facts: [
            .init(emoji: "🎭", text: "The Opera House is clad in over a million tiles, made in Sweden and self-cleaning in the rain."),
            .init(emoji: "🌉", text: "Locals call the Harbour Bridge “the Coathanger”, and you can climb right over its arch."),
            .init(emoji: "🏖️", text: "The city has more than 100 beaches within its limits."),
            .init(emoji: "🦇", text: "Flying foxes — bats with a metre-wide wingspan — stream across the sky at dusk."),
            .init(emoji: "⛵", text: "Sydney Harbour is one of the world's largest natural harbours, with over 240 km of shoreline."),
        ]),
        .init(keywords: ["dubai"], facts: [
            .init(emoji: "🏗️", text: "The Burj Khalifa is so tall that people on the ground floor break their Ramadan fast a couple of minutes before those at the top — the sun sets later up there."),
            .init(emoji: "🏜️", text: "Half a century ago this was a modest pearling and trading port; almost everything you see is younger than that."),
            .init(emoji: "🚇", text: "The metro is fully driverless — there is no cab at the front, so you can sit and watch the track ahead."),
            .init(emoji: "👮", text: "Dubai's police fleet has included a Bugatti and a Lamborghini, mostly for show."),
            .init(emoji: "❄️", text: "There is an indoor ski slope with real snow, in a country where summer routinely passes 45°C."),
        ]),
        .init(keywords: ["san francisco", "oakland"], facts: [
            .init(emoji: "🌉", text: "The Golden Gate Bridge isn't golden — the colour is “International Orange”, chosen so it stands out in the fog."),
            .init(emoji: "🌫️", text: "The summer fog is so reliably part of the city that locals have named it Karl."),
            .init(emoji: "🚋", text: "The cable cars are the only moving National Historic Landmark in the United States."),
            .init(emoji: "🏔️", text: "The city is built across more than 40 hills, and some streets are too steep to drive."),
            .init(emoji: "🦅", text: "Wild parrots — escaped pets and their descendants — live on Telegraph Hill."),
        ]),
        .init(keywords: ["rome", "roma"], facts: [
            .init(emoji: "🪙", text: "Around €1.5 million is thrown into the Trevi Fountain each year, and it's collected for charity."),
            .init(emoji: "🏛️", text: "The Pantheon's unreinforced concrete dome is still the largest of its kind on earth, nearly 1,900 years on."),
            .init(emoji: "🐱", text: "Rome's stray cats are legally protected, and colonies live openly among the ruins."),
            .init(emoji: "⛲", text: "The city has thousands of free drinking fountains, the nasoni, running cold and clean day and night."),
            .init(emoji: "🗺️", text: "An entire country sits inside the city: Vatican City, the smallest sovereign state in the world."),
        ]),
        .init(keywords: ["istanbul"], facts: [
            .init(emoji: "🌍", text: "Istanbul straddles two continents — you can eat breakfast in Europe and lunch in Asia without leaving the city."),
            .init(emoji: "🕌", text: "Hagia Sophia has been a cathedral, a mosque, a museum, and a mosque again across some 1,500 years."),
            .init(emoji: "🛍️", text: "The Grand Bazaar is one of the oldest covered markets in the world, with around 4,000 shops."),
            .init(emoji: "🐈", text: "The city's street cats are fed and sheltered by whole neighbourhoods; they are practically civic institutions."),
            .init(emoji: "☕", text: "Turkish coffee is brewed unfiltered in a cezve, and the grounds left in the cup are read as fortunes."),
        ]),
        .init(keywords: ["bangkok"], facts: [
            .init(emoji: "📜", text: "Bangkok's full ceremonial name is the longest place name in the world — locals just say Krung Thep."),
            .init(emoji: "🛺", text: "The tuk-tuk gets its name from the sound of its two-stroke engine."),
            .init(emoji: "🍜", text: "Street food is so much a part of the city that Bangkok is regularly called the world's best place to eat outdoors."),
            .init(emoji: "🐉", text: "Wat Arun is named for Aruna, the god of dawn — but it's most striking lit up at night."),
            .init(emoji: "🏙️", text: "The city sits barely 1.5 m above sea level, and is slowly sinking."),
        ]),
        .init(keywords: ["seoul"], facts: [
            .init(emoji: "📶", text: "South Korea has some of the fastest internet on earth, and Seoul is wired end to end — even the subway tunnels."),
            .init(emoji: "🏞️", text: "Cheonggyecheon was a covered-over motorway until 2005, when the city tore it down and brought the stream back."),
            .init(emoji: "🌃", text: "Seoul is one of the few megacities with a mountain — Bukhansan — as a national park inside its limits."),
            .init(emoji: "🍗", text: "Fried chicken and beer together are so beloved they have their own portmanteau: chimaek."),
            .init(emoji: "🚇", text: "The metro is among the world's busiest, and nearly every station has platform screen doors."),
        ]),
        .init(keywords: ["berlin"], facts: [
            .init(emoji: "🌉", text: "Berlin has more bridges than Venice — around 900 of them."),
            .init(emoji: "🧱", text: "A double row of cobblestones traces the line of the Wall through the streets, so you can still follow it on foot."),
            .init(emoji: "🚦", text: "The Ampelmännchen, the little hatted man on East German pedestrian lights, survived reunification and became a mascot."),
            .init(emoji: "🌳", text: "About a third of the city is green space, forest or water."),
            .init(emoji: "🎶", text: "The city has three opera houses, the legacy of having been divided between two states."),
        ]),
        .init(keywords: ["amsterdam", "rotterdam"], facts: [
            .init(emoji: "🚲", text: "There are more bicycles in Amsterdam than people — and thousands are fished out of the canals each year."),
            .init(emoji: "🏠", text: "Houses were taxed on their width, which is why they are so narrow and so tall."),
            .init(emoji: "🪝", text: "The hooks on the gables aren't decoration — furniture is still hoisted through the windows, because the stairs are impossible."),
            .init(emoji: "🌊", text: "Much of the city sits below sea level, kept dry by centuries of engineering."),
            .init(emoji: "🌉", text: "The canal ring is a UNESCO World Heritage Site, dug in the 17th century."),
        ]),
        .init(keywords: ["barcelona"], facts: [
            .init(emoji: "⛪", text: "The Sagrada Família has been under construction since 1882 — longer than most countries have existed in their current form."),
            .init(emoji: "🏖️", text: "Barcelona had no city beach until it built one for the 1992 Olympics."),
            .init(emoji: "🟦", text: "The Eixample's octagonal street corners were designed so carriages — and later trams — could turn."),
            .init(emoji: "🦎", text: "Gaudí covered Park Güell in trencadís: mosaics made from broken tiles and discarded crockery."),
            .init(emoji: "🥘", text: "Paella is Valencian, not Catalan — order fideuà instead and you'll be eating like a local."),
        ]),
        .init(keywords: ["cairo", "giza"], facts: [
            .init(emoji: "🔺", text: "The Great Pyramid was the tallest structure made by humans for around 3,800 years."),
            .init(emoji: "🏙️", text: "Cairo's Arabic name, al-Qāhira, means “the Victorious”."),
            .init(emoji: "🌊", text: "The Nile flows north, which is why Upper Egypt is in the south and Lower Egypt is in the north."),
            .init(emoji: "🐫", text: "The pyramids are not remote — the city's suburbs now reach almost to their feet."),
            .init(emoji: "📚", text: "Al-Azhar, founded in the 10th century, is among the oldest continuously operating universities anywhere."),
        ]),
        .init(keywords: ["moscow"], facts: [
            .init(emoji: "🚇", text: "Moscow's metro stations were built as “palaces for the people”, with chandeliers, mosaics and marble."),
            .init(emoji: "🧅", text: "St Basil's isn't one church but ten, clustered together, each with its own dome."),
            .init(emoji: "❄️", text: "Winter temperatures routinely drop below −10°C, and the city keeps running regardless."),
            .init(emoji: "🏰", text: "“Kremlin” simply means fortress — many Russian cities have one; this is just the most famous."),
            .init(emoji: "🌳", text: "Moscow is one of the greenest big cities in Europe, with parkland covering a large share of its area."),
        ]),
        .init(keywords: ["rio de janeiro", "rio"], facts: [
            .init(emoji: "⛰️", text: "Tijuca, inside the city, is one of the largest urban forests in the world — and it was replanted by hand in the 1860s."),
            .init(emoji: "🙌", text: "Christ the Redeemer is struck by lightning several times a year; a stock of matching stone is kept for repairs."),
            .init(emoji: "🏖️", text: "Copacabana's wave-patterned promenade is a Portuguese design, laid in black and white stone."),
            .init(emoji: "🎭", text: "Carnival fills the Sambadrome with tens of thousands of spectators, and samba schools prepare all year."),
            .init(emoji: "🌆", text: "The name means “River of January” — the Portuguese arrived in January and mistook the bay for a river mouth."),
        ]),
        .init(keywords: ["mexico city", "ciudad de m"], facts: [
            .init(emoji: "🏙️", text: "The city is sinking — it was built on a drained lakebed, and parts drop several centimetres a year."),
            .init(emoji: "🌮", text: "Mexico City has one of the highest concentrations of museums of any city in the world."),
            .init(emoji: "🦋", text: "It sits at 2,240 m, high enough that water boils noticeably below 100°C."),
            .init(emoji: "🏛️", text: "The Templo Mayor of the Aztecs was found by accident in 1978 by electrical workers digging downtown."),
            .init(emoji: "🚲", text: "Every Sunday the city closes major avenues to cars and gives them over to cyclists."),
        ]),
        .init(keywords: ["toronto"], facts: [
            .init(emoji: "🗼", text: "The CN Tower was the tallest free-standing structure in the world for over 30 years."),
            .init(emoji: "🗣️", text: "More than half of Toronto's residents were born outside Canada."),
            .init(emoji: "🦝", text: "The city's raccoons are so adept at opening bins that Toronto designed a “raccoon-proof” one — and they cracked it."),
            .init(emoji: "🚇", text: "An underground network, the PATH, lets you walk 30 km through downtown without going outside in winter."),
            .init(emoji: "🏝️", text: "The Toronto Islands are car-free, and people actually live there."),
        ]),
        .init(keywords: ["chicago"], facts: [
            .init(emoji: "🏢", text: "The world's first skyscraper went up here in 1885 — ten storeys, which felt impossibly tall at the time."),
            .init(emoji: "🌊", text: "Engineers reversed the flow of the Chicago River in 1900 so the city's sewage would stop flowing into its drinking water."),
            .init(emoji: "💨", text: "“The Windy City” may have been a jab at its boastful politicians, not its weather."),
            .init(emoji: "🍕", text: "Deep-dish is a knife-and-fork affair, and locals will tell you it is not really pizza's rival but its own thing."),
            .init(emoji: "🟩", text: "The river is dyed bright green every St Patrick's Day."),
        ]),
        .init(keywords: ["los angeles", "hollywood", "santa monica"], facts: [
            .init(emoji: "🪧", text: "The Hollywood sign originally read HOLLYWOODLAND and was an advert for a housing development."),
            .init(emoji: "🦴", text: "The La Brea Tar Pits are still actively bubbling, and still yielding Ice Age fossils, in the middle of the city."),
            .init(emoji: "🚗", text: "LA once had the largest electric railway system in the world; it was dismantled by the 1960s."),
            .init(emoji: "🌴", text: "Most of the palm trees aren't native — they were planted en masse for the 1932 Olympics."),
            .init(emoji: "🎬", text: "Filmmakers came west partly for the reliable sunlight, long before studios had artificial lighting."),
        ]),
        .init(keywords: ["kuala lumpur"], facts: [
            .init(emoji: "🏗️", text: "The Petronas Towers were the tallest buildings in the world until 2004, and are still the tallest twin towers."),
            .init(emoji: "🌉", text: "The skybridge between them isn't bolted rigid — it slides, so the towers can sway independently in the wind."),
            .init(emoji: "🪨", text: "The Batu Caves are limestone formations some 400 million years old, reached by 272 steps."),
            .init(emoji: "🍜", text: "The name means “muddy confluence” — the city grew where two rivers meet."),
            .init(emoji: "🌧️", text: "Afternoon thunderstorms are so regular you can nearly set a watch by them."),
        ]),
        .init(keywords: ["jakarta"], facts: [
            .init(emoji: "🏙️", text: "Indonesia is moving its capital: a new city, Nusantara, is being built on Borneo."),
            .init(emoji: "🌊", text: "Jakarta is one of the fastest-sinking cities on earth — parts of the north have dropped several metres."),
            .init(emoji: "🛵", text: "Motorbike ride-hailing is so embedded here that the apps also deliver food, groceries and massages."),
            .init(emoji: "🗣️", text: "Indonesia has over 700 living languages; Jakarta hears a great many of them."),
            .init(emoji: "☕", text: "Kopi tubruk is coffee with the grounds left in — you wait for them to settle before drinking."),
        ]),
        .init(keywords: ["taipei"], facts: [
            .init(emoji: "🏗️", text: "Taipei 101 hangs a 660-tonne steel pendulum near its top to counter typhoon winds — and you can go and look at it."),
            .init(emoji: "🌋", text: "Hot springs bubble up in Beitou, right at the edge of the city, heated by nearby volcanic activity."),
            .init(emoji: "🍢", text: "The night markets are institutions, and stinky tofu smells far worse than it tastes."),
            .init(emoji: "🚇", text: "Eating and drinking on the metro is banned — and the rule is genuinely observed."),
            .init(emoji: "🧋", text: "Bubble tea was invented in Taiwan in the 1980s and went on to conquer the world."),
        ]),
        .init(keywords: ["shanghai"], facts: [
            .init(emoji: "🚄", text: "The maglev to the airport hits 431 km/h, making it the fastest commercial train in the world."),
            .init(emoji: "🏙️", text: "Pudong was farmland and warehouses as recently as 1990; the whole skyline is younger than many of the people looking at it."),
            .init(emoji: "🌊", text: "The name means “upon the sea”."),
            .init(emoji: "🏛️", text: "The Bund's grand facades were built by foreign banks and trading houses in the early 20th century."),
            .init(emoji: "🥟", text: "Xiaolongbao are eaten carefully — the soup inside is hot enough to catch you out."),
        ]),
        .init(keywords: ["beijing", "peking"], facts: [
            .init(emoji: "🏯", text: "The Forbidden City has around 9,000 rooms and was off-limits to ordinary people for nearly 500 years."),
            .init(emoji: "🧱", text: "You cannot see the Great Wall from space with the naked eye — that story simply isn't true."),
            .init(emoji: "🚲", text: "Beijing was once a city of bicycles above all else; the bike lanes are still enormous."),
            .init(emoji: "🥟", text: "Peking duck is carved at the table and eaten wrapped in thin pancakes."),
            .init(emoji: "🏛️", text: "The Temple of Heaven was where emperors prayed for a good harvest — a weather ritual, of a kind."),
        ]),
        .init(keywords: ["mumbai", "bombay"], facts: [
            .init(emoji: "🍱", text: "The dabbawalas deliver some 200,000 home-cooked lunches a day, largely without computers, and almost never lose one."),
            .init(emoji: "🎬", text: "Bollywood releases more films each year than Hollywood."),
            .init(emoji: "🏝️", text: "Mumbai was originally seven separate islands, joined together by land reclamation."),
            .init(emoji: "🚆", text: "The suburban railway carries over seven million people a day."),
            .init(emoji: "🌧️", text: "The monsoon arrives in June and dumps most of the year's rain in a few months."),
        ]),
        .init(keywords: ["delhi"], facts: [
            .init(emoji: "🏛️", text: "Delhi has been built and rebuilt many times — historians often count seven distinct cities on the site."),
            .init(emoji: "⚙️", text: "The Iron Pillar has stood for over 1,600 years with barely any rust, and metallurgists still study why."),
            .init(emoji: "🚇", text: "The metro is one of the largest in the world and runs on a network that barely existed in 2002."),
            .init(emoji: "🌡️", text: "Summer can pass 45°C before the monsoon finally breaks the heat."),
            .init(emoji: "🕌", text: "Humayun's Tomb was a template for the Taj Mahal, built decades before it."),
        ]),
        .init(keywords: ["vienna", "wien"], facts: [
            .init(emoji: "🚰", text: "Vienna's tap water arrives by gravity from Alpine springs, through pipelines built in the 1800s."),
            .init(emoji: "☕", text: "Viennese coffee house culture is on UNESCO's list of intangible cultural heritage — lingering for hours is the point."),
            .init(emoji: "🎼", text: "Mozart, Beethoven, Haydn, Schubert and Brahms all worked in this one city."),
            .init(emoji: "🎡", text: "The Riesenrad ferris wheel has been turning since 1897."),
            .init(emoji: "🏙️", text: "Vienna is repeatedly ranked the most liveable city in the world."),
        ]),
        .init(keywords: ["prague", "praha"], facts: [
            .init(emoji: "🕰️", text: "The astronomical clock has been keeping time since 1410 and is the oldest of its kind still working."),
            .init(emoji: "🍺", text: "Czechs drink more beer per head than any other nation on earth."),
            .init(emoji: "🌉", text: "Charles Bridge was begun in 1357 and, for centuries, was the only way across the Vltava."),
            .init(emoji: "🏰", text: "Prague Castle is the largest ancient castle complex in the world."),
            .init(emoji: "🎭", text: "The city came through both world wars with its old centre largely intact — which is why it looks the way it does."),
        ]),
        .init(keywords: ["athens"], facts: [
            .init(emoji: "🏛️", text: "The Parthenon has almost no straight lines — its columns bulge slightly so that they look straight to the eye."),
            .init(emoji: "🗳️", text: "Athens is where democracy was invented, though only a small fraction of residents could vote."),
            .init(emoji: "🚇", text: "Digging the metro turned up so many antiquities that some stations double as museums."),
            .init(emoji: "🌡️", text: "It is one of the hottest capitals in Europe; summer afternoons regularly pass 35°C."),
            .init(emoji: "🦉", text: "The owl was the city's emblem and appeared on its silver coins."),
        ]),
        .init(keywords: ["lisbon", "lisboa"], facts: [
            .init(emoji: "🌊", text: "A catastrophic earthquake and tsunami levelled much of Lisbon in 1755, and the rebuilt downtown was among the first designed to resist quakes."),
            .init(emoji: "🚋", text: "Tram 28 climbs the old hills on rails laid for much smaller carriages, which is why the trams are so tiny."),
            .init(emoji: "🥚", text: "Pastéis de nata were invented by monks, who used egg whites to starch their habits and had yolks left over."),
            .init(emoji: "🎶", text: "Fado, the city's melancholy song tradition, is UNESCO-listed."),
            .init(emoji: "☀️", text: "Lisbon is one of the sunniest capitals in Europe, with well over 2,500 hours of sun a year."),
        ]),
        .init(keywords: ["copenhagen"], facts: [
            .init(emoji: "🚲", text: "More people commute by bike than by car, and the city has bicycle bridges built purely for cyclists."),
            .init(emoji: "🎢", text: "Tivoli Gardens opened in 1843 and is said to have inspired Walt Disney."),
            .init(emoji: "🧜", text: "The Little Mermaid statue is barely 1.25 m tall, and most visitors are surprised by how small she is."),
            .init(emoji: "♨️", text: "The harbour is clean enough to swim in, in the middle of the city."),
            .init(emoji: "🕯️", text: "Hygge has no exact English translation — it's closer to a warm, unhurried contentment than to “cosiness”."),
        ]),
        .init(keywords: ["reykjavik", "reykjavík"], facts: [
            .init(emoji: "♨️", text: "Nearly all of Iceland's heating and electricity comes from geothermal and hydro power — the hot tap water smells faintly of sulphur."),
            .init(emoji: "🌞", text: "In midsummer the sun barely sets; in midwinter it barely rises."),
            .init(emoji: "🌋", text: "Iceland sits on the Mid-Atlantic Ridge, where two tectonic plates are pulling apart — which is why it has so many volcanoes."),
            .init(emoji: "🗣️", text: "Icelandic has changed so little that speakers can read medieval sagas without much trouble."),
            .init(emoji: "🐴", text: "Icelandic horses have a fifth gait, the tölt, and once they leave the island they may never return."),
        ]),
        .init(keywords: ["havana", "habana"], facts: [
            .init(emoji: "🚗", text: "The classic American cars still running here are kept alive with improvised parts, decades after imports stopped."),
            .init(emoji: "🎺", text: "Son cubano, the root of salsa, grew out of the island's blend of Spanish guitar and African rhythm."),
            .init(emoji: "🌊", text: "The Malecón seawall floods spectacularly when storms drive the sea over it."),
            .init(emoji: "🏛️", text: "El Capitolio was modelled on the US Capitol — and is slightly taller."),
            .init(emoji: "☕", text: "Cuban coffee is served tiny, dark and already sweetened."),
        ]),
        .init(keywords: ["buenos aires"], facts: [
            .init(emoji: "📚", text: "Buenos Aires has more bookshops per person than almost any other city in the world."),
            .init(emoji: "💃", text: "Tango was born in the port neighbourhoods and was considered disreputable long before it became elegant."),
            .init(emoji: "🥩", text: "Argentina is among the world's biggest beef eaters, and the asado is a slow, social ritual."),
            .init(emoji: "🌳", text: "Avenida 9 de Julio is one of the widest avenues on earth."),
            .init(emoji: "🧉", text: "Yerba mate is shared from one gourd passed around the group — refusing the straw is a small insult."),
        ]),
        .init(keywords: ["cape town"], facts: [
            .init(emoji: "☁️", text: "The cloud that spills over Table Mountain is called the “tablecloth”, and it forms almost on cue."),
            .init(emoji: "🌸", text: "The Cape floral kingdom packs more plant species into a small area than almost anywhere on earth."),
            .init(emoji: "🐧", text: "African penguins nest on Boulders Beach, a short drive from the city centre."),
            .init(emoji: "💧", text: "In 2018 the city came within weeks of “Day Zero”, when the taps would have been switched off."),
            .init(emoji: "🏔️", text: "Table Mountain is one of the oldest mountains in the world — far older than the Himalayas or the Alps."),
        ]),
        .init(keywords: ["auckland"], facts: [
            .init(emoji: "🌋", text: "Auckland is built on a volcanic field of around 50 cones — dormant, not extinct."),
            .init(emoji: "⛵", text: "It's nicknamed the City of Sails; there are more boats per head here than almost anywhere."),
            .init(emoji: "🥝", text: "New Zealand had no land mammals apart from bats before humans arrived — which is why so many birds gave up flying."),
            .init(emoji: "🗼", text: "You can jump off the Sky Tower on a wire — a 192 m controlled drop into the middle of the city."),
            .init(emoji: "🌊", text: "The city sits between two harbours, on two different seas."),
        ]),
        .init(keywords: ["manila", "quezon"], facts: [
            .init(emoji: "🚌", text: "Jeepneys began as surplus American army jeeps, stretched and decorated into public transport."),
            .init(emoji: "🗣️", text: "The Philippines has over 170 languages, and Filipino and English are both official."),
            .init(emoji: "⛪", text: "San Agustin Church has survived earthquakes and wars since 1607, and is the oldest stone church in the country."),
            .init(emoji: "🌀", text: "The islands are hit by around twenty tropical cyclones a year — more than almost anywhere on earth."),
            .init(emoji: "🍮", text: "Halo-halo means “mix-mix”, and you're meant to stir it into a mess before eating."),
        ]),
        .init(keywords: ["hanoi", "ho chi minh", "saigon"], facts: [
            .init(emoji: "🛵", text: "Vietnam has tens of millions of motorbikes, and crossing the road is a matter of walking slowly and letting them flow around you."),
            .init(emoji: "☕", text: "Vietnam is the world's second-largest coffee producer, and cà phê sữa đá is served over ice with condensed milk."),
            .init(emoji: "🍜", text: "Phở is a breakfast food first, and the broth may have simmered overnight."),
            .init(emoji: "🚂", text: "In Hanoi a train still squeezes through a residential street so narrow that residents pull in their chairs as it passes."),
            .init(emoji: "🥖", text: "Bánh mì is a legacy of French rule — a baguette, filled with unmistakably Vietnamese things."),
        ]),
    ]

    // MARK: - Countries (fallback when we don't know the city)

    private static let countries: [Entry] = [
        .init(keywords: ["united states", "usa"], facts: [
            .init(emoji: "🌪️", text: "The US gets more tornadoes than any other country — over a thousand in a typical year."),
            .init(emoji: "🏞️", text: "Yellowstone was the world's first national park, established in 1872."),
            .init(emoji: "🗺️", text: "The country spans six time zones, before you even count its territories."),
            .init(emoji: "🦅", text: "Alaska has a longer coastline than all the other states combined."),
        ]),
        .init(keywords: ["united kingdom", "england", "scotland", "wales"], facts: [
            .init(emoji: "☔", text: "Britain's weather is so changeable because it sits where polar and tropical air masses collide."),
            .init(emoji: "🫖", text: "Around 100 million cups of tea are drunk in the UK every day."),
            .init(emoji: "🏰", text: "No point in Britain is more than about 70 miles from the sea."),
            .init(emoji: "📚", text: "The oldest university in the English-speaking world, Oxford, was teaching by 1096."),
        ]),
        .init(keywords: ["france"], facts: [
            .init(emoji: "🧀", text: "France produces well over a thousand distinct cheeses."),
            .init(emoji: "🚄", text: "A TGV holds the world speed record for a conventional train: 574.8 km/h."),
            .init(emoji: "🗺️", text: "France is the most visited country on earth."),
            .init(emoji: "🥐", text: "The croissant is Austrian in origin — it arrived in Paris via Vienna."),
        ]),
        .init(keywords: ["japan"], facts: [
            .init(emoji: "🗻", text: "Japan has over 100 active volcanoes and sits on the Pacific Ring of Fire."),
            .init(emoji: "🚄", text: "The shinkansen has run since 1964 with an extraordinary safety record and average delays measured in seconds."),
            .init(emoji: "🏝️", text: "The country is made up of thousands of islands — far more than the four everyone can name."),
            .init(emoji: "👵", text: "Japan has more people over 100 years old, per head, than almost anywhere."),
        ]),
        .init(keywords: ["china"], facts: [
            .init(emoji: "🕐", text: "China spans five geographic time zones but officially uses only one."),
            .init(emoji: "🐼", text: "Every giant panda in the world's zoos is, technically, on loan from China."),
            .init(emoji: "🚄", text: "China has more high-speed rail than the rest of the world combined."),
            .init(emoji: "🍵", text: "Tea was drunk here for thousands of years before it reached Europe."),
        ]),
        .init(keywords: ["india"], facts: [
            .init(emoji: "🌧️", text: "Mawsynram in Meghalaya is among the wettest inhabited places on earth."),
            .init(emoji: "🗳️", text: "India runs the largest election in the world, with hundreds of millions of voters."),
            .init(emoji: "🗣️", text: "There are 22 official languages, and hundreds more spoken."),
            .init(emoji: "🎬", text: "India produces more feature films each year than any other country."),
        ]),
        .init(keywords: ["australia"], facts: [
            .init(emoji: "🦘", text: "Australia has more kangaroos than people."),
            .init(emoji: "🪸", text: "The Great Barrier Reef is the largest living structure on earth and is visible from space."),
            .init(emoji: "🏜️", text: "Most Australians live on the coast; the interior is mostly desert."),
            .init(emoji: "🕷️", text: "Despite the reputation, deaths from spider bites are vanishingly rare."),
        ]),
        .init(keywords: ["germany"], facts: [
            .init(emoji: "🍺", text: "The beer purity law, the Reinheitsgebot, dates to 1516."),
            .init(emoji: "🛣️", text: "Parts of the autobahn still have no general speed limit."),
            .init(emoji: "🌲", text: "A third of the country is forest."),
            .init(emoji: "🥨", text: "Germany has over a thousand kinds of sausage."),
        ]),
        .init(keywords: ["italy"], facts: [
            .init(emoji: "🏛️", text: "Italy has more UNESCO World Heritage sites than any other country."),
            .init(emoji: "🌋", text: "Europe's only active mainland volcanoes are all in Italy."),
            .init(emoji: "☕", text: "Ordering a cappuccino after lunch marks you out instantly as a visitor."),
            .init(emoji: "🍝", text: "There are hundreds of pasta shapes, and the sauce each is paired with is not arbitrary."),
        ]),
        .init(keywords: ["spain"], facts: [
            .init(emoji: "🕐", text: "Spain is on Central European Time despite sitting at Britain's longitude — a legacy of the 1940s."),
            .init(emoji: "🫒", text: "Spain produces more olive oil than any other country."),
            .init(emoji: "💤", text: "The famous siesta is fading, but many small shops still close in the afternoon."),
            .init(emoji: "🎉", text: "Dinner at 10pm is entirely normal."),
        ]),
        .init(keywords: ["brazil"], facts: [
            .init(emoji: "🌳", text: "Around 60% of the Amazon rainforest lies in Brazil."),
            .init(emoji: "⚽", text: "Brazil has won the World Cup more times than any other nation."),
            .init(emoji: "🗺️", text: "It borders every South American country except Chile and Ecuador."),
            .init(emoji: "☕", text: "Brazil has been the world's biggest coffee producer for over 150 years."),
        ]),
        .init(keywords: ["canada"], facts: [
            .init(emoji: "🏞️", text: "Canada has more lakes than the rest of the world combined."),
            .init(emoji: "🗺️", text: "It has the longest coastline of any country on earth."),
            .init(emoji: "🍁", text: "Canada produces the large majority of the world's maple syrup."),
            .init(emoji: "🐻", text: "Polar bears roam the north — Churchill, Manitoba calls itself their world capital."),
        ]),
        .init(keywords: ["malaysia"], facts: [
            .init(emoji: "🌴", text: "Malaysian Borneo holds some of the oldest rainforest on earth — far older than the Amazon."),
            .init(emoji: "🌺", text: "The rafflesia, the world's largest flower, grows here and smells of rotting meat."),
            .init(emoji: "🍜", text: "The food is a fusion of Malay, Chinese and Indian cooking, and everyone argues about who does it best."),
            .init(emoji: "🐒", text: "Orangutans are found in the wild in only two places: Borneo and Sumatra."),
        ]),
        .init(keywords: ["indonesia"], facts: [
            .init(emoji: "🏝️", text: "Indonesia is made up of more than 17,000 islands."),
            .init(emoji: "🌋", text: "It has more active volcanoes than any other country."),
            .init(emoji: "🗣️", text: "Over 700 living languages are spoken across the archipelago."),
            .init(emoji: "🦎", text: "Komodo dragons live wild on just a handful of Indonesian islands and nowhere else."),
        ]),
        .init(keywords: ["thailand"], facts: [
            .init(emoji: "👑", text: "Thailand is the only country in Southeast Asia never colonised by a European power."),
            .init(emoji: "🐘", text: "The elephant is a national symbol, and white elephants were traditionally royal property."),
            .init(emoji: "📅", text: "The Thai calendar is 543 years ahead of the Gregorian one."),
            .init(emoji: "🌶️", text: "“Thai spicy” is not a marketing phrase — it's a warning."),
        ]),
        .init(keywords: ["vietnam"], facts: [
            .init(emoji: "☕", text: "Vietnam is the world's second-largest coffee exporter, and grows mostly robusta."),
            .init(emoji: "🛵", text: "Motorbikes vastly outnumber cars, and whole families ride on one."),
            .init(emoji: "🍜", text: "Phở is eaten for breakfast far more often than for dinner."),
            .init(emoji: "🏞️", text: "Hạ Long Bay's limestone towers number in the thousands."),
        ]),
        .init(keywords: ["philippines"], facts: [
            .init(emoji: "🏝️", text: "The Philippines is made up of over 7,000 islands."),
            .init(emoji: "🌀", text: "It's struck by around twenty tropical cyclones a year."),
            .init(emoji: "🎤", text: "Karaoke is close to a national pastime."),
            .init(emoji: "🎄", text: "Christmas decorations go up in September — the “ber months” begin the season."),
        ]),
        .init(keywords: ["south korea", "korea"], facts: [
            .init(emoji: "📶", text: "South Korea has among the fastest average internet speeds in the world."),
            .init(emoji: "🥬", text: "Kimchi has hundreds of regional varieties, and many households keep a dedicated fridge for it."),
            .init(emoji: "🏔️", text: "About 70% of the country is mountainous."),
            .init(emoji: "🎂", text: "Traditionally, everyone gained a year on New Year's Day, regardless of their birthday."),
        ]),
        .init(keywords: ["new zealand"], facts: [
            .init(emoji: "🐑", text: "Sheep comfortably outnumber people."),
            .init(emoji: "🦅", text: "Before humans arrived there were no land mammals except bats — so birds filled every niche."),
            .init(emoji: "🌋", text: "The country sits on the Pacific Ring of Fire and gets thousands of earthquakes a year."),
            .init(emoji: "🎬", text: "It was the first country in the world to give women the vote, in 1893."),
        ]),
        .init(keywords: ["netherlands", "holland"], facts: [
            .init(emoji: "🚲", text: "There are more bicycles than people."),
            .init(emoji: "🌊", text: "About a quarter of the country lies below sea level."),
            .init(emoji: "🌷", text: "The Dutch supply the majority of the world's flower bulbs."),
            .init(emoji: "📏", text: "The Dutch are, on average, the tallest people in the world."),
        ]),
        .init(keywords: ["switzerland"], facts: [
            .init(emoji: "🏔️", text: "Roughly 60% of Switzerland is mountainous."),
            .init(emoji: "🗳️", text: "Citizens vote on referendums several times a year — direct democracy in practice."),
            .init(emoji: "🍫", text: "The Swiss eat more chocolate per head than almost anyone."),
            .init(emoji: "🗣️", text: "There are four national languages: German, French, Italian and Romansh."),
        ]),
        .init(keywords: ["united arab emirates", "uae"], facts: [
            .init(emoji: "🏜️", text: "The UAE was formed in 1971 from seven emirates."),
            .init(emoji: "🌡️", text: "Summer heat regularly passes 45°C, and humidity near the coast makes it feel worse."),
            .init(emoji: "🐫", text: "Camel racing is a serious sport, now often run with robot jockeys."),
            .init(emoji: "💧", text: "Most drinking water comes from desalinating the sea."),
        ]),
        .init(keywords: ["egypt"], facts: [
            .init(emoji: "🌊", text: "Almost the entire population lives along the Nile — the rest of the country is desert."),
            .init(emoji: "🔺", text: "The pyramids were already ancient when Cleopatra was born — she lived closer in time to us than to their builders."),
            .init(emoji: "🐈", text: "Ancient Egyptians revered cats, and killing one could be a capital offence."),
            .init(emoji: "📜", text: "The Rosetta Stone was the key that unlocked hieroglyphs."),
        ]),
        .init(keywords: ["turkey", "türkiye"], facts: [
            .init(emoji: "🌍", text: "Turkey sits across two continents."),
            .init(emoji: "☕", text: "Turkish coffee is UNESCO-listed, grounds and all."),
            .init(emoji: "🎈", text: "Cappadocia's fairy chimneys are eroded volcanic rock, and people carved homes into them."),
            .init(emoji: "🍒", text: "Turkey grows more hazelnuts than the rest of the world put together."),
        ]),
        .init(keywords: ["mexico"], facts: [
            .init(emoji: "🌶️", text: "Chocolate, chillies, tomatoes, vanilla and maize all came from Mexico."),
            .init(emoji: "🦋", text: "Millions of monarch butterflies migrate here each winter to roost in the same forests."),
            .init(emoji: "💀", text: "Día de los Muertos is a celebration, not a mourning — the dead are welcomed back."),
            .init(emoji: "🏛️", text: "Mexico has more pyramids than Egypt."),
        ]),
        .init(keywords: ["portugal"], facts: [
            .init(emoji: "🌊", text: "Portugal's borders have barely changed since the 13th century, making them among the oldest in Europe."),
            .init(emoji: "🍾", text: "Most of the world's cork comes from Portuguese oak forests."),
            .init(emoji: "🏄", text: "Nazaré produces some of the largest surfable waves ever ridden."),
            .init(emoji: "🐟", text: "There is said to be a different way to cook bacalhau for every day of the year."),
        ]),
        .init(keywords: ["greece"], facts: [
            .init(emoji: "🏝️", text: "Greece has thousands of islands, but only a couple of hundred are inhabited."),
            .init(emoji: "🫒", text: "Some Greek olive trees are over a thousand years old and still fruiting."),
            .init(emoji: "☀️", text: "Much of the country gets over 250 days of sunshine a year."),
            .init(emoji: "🏛️", text: "No point in Greece is more than about 140 km from the sea."),
        ]),
        .init(keywords: ["russia"], facts: [
            .init(emoji: "🗺️", text: "Russia spans eleven time zones and borders fourteen countries."),
            .init(emoji: "🚂", text: "The Trans-Siberian Railway runs over 9,000 km and takes about a week end to end."),
            .init(emoji: "🌲", text: "Russia holds around a fifth of the world's forest."),
            .init(emoji: "💧", text: "Lake Baikal is the deepest lake on earth and holds a fifth of the world's unfrozen fresh water."),
        ]),
        .init(keywords: ["south africa"], facts: [
            .init(emoji: "🏛️", text: "South Africa has three capital cities: Pretoria, Cape Town and Bloemfontein."),
            .init(emoji: "🗣️", text: "There are twelve official languages."),
            .init(emoji: "🦁", text: "It's one of the few places where you might see lion, leopard, rhino, elephant and buffalo in a single day."),
            .init(emoji: "💎", text: "The largest diamond ever found came from a South African mine."),
        ]),
        .init(keywords: ["kenya", "tanzania", "uganda"], facts: [
            .init(emoji: "🦓", text: "The Serengeti–Mara migration moves well over a million wildebeest in a giant annual loop."),
            .init(emoji: "🏃", text: "The Rift Valley highlands have produced an extraordinary share of the world's best distance runners."),
            .init(emoji: "🏔️", text: "Kilimanjaro is the highest free-standing mountain in the world, and has glaciers almost on the equator."),
            .init(emoji: "☕", text: "East African coffee is grown at altitude, which is what gives it its brightness."),
        ]),
        .init(keywords: ["nigeria", "ghana"], facts: [
            .init(emoji: "🎬", text: "Nollywood is one of the largest film industries in the world by output."),
            .init(emoji: "🗣️", text: "Nigeria has over 500 languages."),
            .init(emoji: "🍫", text: "West Africa grows most of the world's cocoa."),
            .init(emoji: "🥁", text: "Afrobeats has gone from Lagos clubs to global charts in a couple of decades."),
        ]),
        .init(keywords: ["pakistan"], facts: [
            .init(emoji: "🏔️", text: "Pakistan has five of the world's fourteen peaks above 8,000 m, including K2."),
            .init(emoji: "🛣️", text: "The Karakoram Highway is one of the highest paved international roads on earth."),
            .init(emoji: "🏛️", text: "Mohenjo-daro was a planned city with drainage over 4,000 years ago."),
            .init(emoji: "🥭", text: "Pakistani mangoes are a point of genuine national pride."),
        ]),
        .init(keywords: ["nepal", "bhutan"], facts: [
            .init(emoji: "🏔️", text: "Eight of the world's ten highest mountains are in Nepal."),
            .init(emoji: "🚩", text: "Nepal's flag is the only national flag that isn't a rectangle."),
            .init(emoji: "🧘", text: "The Buddha was born at Lumbini, in what is now Nepal."),
            .init(emoji: "⛰️", text: "Everest grows a few millimetres a year as India pushes into Asia."),
        ]),
        .init(keywords: ["sri lanka"], facts: [
            .init(emoji: "🍵", text: "Ceylon tea is still named for the island's colonial name."),
            .init(emoji: "🐘", text: "Sri Lanka has one of the highest densities of wild elephants in Asia."),
            .init(emoji: "🌧️", text: "Two separate monsoons hit the island from opposite directions at different times of year."),
            .init(emoji: "🦁", text: "Sigiriya is a palace built on top of a 200 m rock column."),
        ]),
        .init(keywords: ["saudi", "kuwait", "qatar", "bahrain", "oman"], facts: [
            .init(emoji: "🏜️", text: "The Rub' al Khali — the Empty Quarter — is the largest continuous sand desert in the world."),
            .init(emoji: "☕", text: "Arabic coffee is served in small cups and often flavoured with cardamom."),
            .init(emoji: "🌡️", text: "Summer temperatures here are among the highest recorded anywhere on earth."),
            .init(emoji: "🕋", text: "Millions travel to Mecca each year for the Hajj."),
        ]),
        .init(keywords: ["iran", "iraq"], facts: [
            .init(emoji: "🏛️", text: "Mesopotamia, between the Tigris and Euphrates, is where writing was invented."),
            .init(emoji: "🌹", text: "Persian gardens are a UNESCO-listed art form, built around water and shade."),
            .init(emoji: "🧶", text: "Persian carpets can take years to weave and are knotted entirely by hand."),
            .init(emoji: "🍚", text: "Tahdig — the crisp golden crust at the bottom of the rice pot — is the most fought-over part of the meal."),
        ]),
        .init(keywords: ["poland", "hungary", "czech", "romania", "bulgaria", "serbia", "ukraine"], facts: [
            .init(emoji: "🏰", text: "Central Europe has an extraordinary density of castles — Poland alone has hundreds."),
            .init(emoji: "♨️", text: "Budapest sits on over a hundred thermal springs and has bathed in them for centuries."),
            .init(emoji: "🍺", text: "Pilsner was invented in the Czech town of Plzeň in 1842 and reshaped beer worldwide."),
            .init(emoji: "🌾", text: "Ukraine's black soil is some of the most fertile on earth, which is why it's called a breadbasket."),
        ]),
        .init(keywords: ["norway", "sweden", "finland", "denmark", "iceland"], facts: [
            .init(emoji: "🌌", text: "Above the Arctic Circle the sun doesn't set for weeks in summer, nor rise for weeks in winter."),
            .init(emoji: "☕", text: "The Nordic countries drink more coffee per head than anywhere else."),
            .init(emoji: "🌲", text: "Finland is the most forested country in Europe, and has more saunas than cars."),
            .init(emoji: "🛶", text: "Right of public access lets you walk, camp and forage on most land, even privately owned."),
        ]),
        .init(keywords: ["peru", "bolivia", "ecuador", "colombia", "chile", "argentina", "uruguay"], facts: [
            .init(emoji: "🥔", text: "The potato was domesticated in the Andes, and Peru still grows thousands of varieties."),
            .init(emoji: "🏔️", text: "The Andes are the longest continental mountain range in the world."),
            .init(emoji: "🏜️", text: "Parts of Chile's Atacama Desert have gone without measurable rain for years at a stretch."),
            .init(emoji: "🦙", text: "Llamas and alpacas were domesticated thousands of years ago and are still working animals."),
        ]),
        .init(keywords: ["cuba", "jamaica", "dominican", "puerto rico"], facts: [
            .init(emoji: "🎺", text: "Son, salsa, reggae and merengue all came out of these islands within a century of each other."),
            .init(emoji: "🌀", text: "The Caribbean hurricane season runs from June to November, peaking in September."),
            .init(emoji: "☕", text: "Blue Mountain coffee grows on Jamaica's misty peaks and is among the most expensive in the world."),
            .init(emoji: "🏝️", text: "Cuba is the largest island in the Caribbean by a wide margin."),
        ]),
        .init(keywords: ["cambodia", "laos", "myanmar", "burma"], facts: [
            .init(emoji: "🛕", text: "Angkor was the largest pre-industrial city in the world, sprawling across a thousand square kilometres."),
            .init(emoji: "🚩", text: "Cambodia's flag is the only national flag to feature a building."),
            .init(emoji: "🌊", text: "The Tonlé Sap river reverses direction twice a year as the monsoon fills and drains the lake."),
            .init(emoji: "🙏", text: "Myanmar's Shwedagon Pagoda is covered in genuine gold plate, renewed by donations."),
        ]),
        .init(keywords: ["israel", "jordan", "lebanon"], facts: [
            .init(emoji: "🧂", text: "The Dead Sea is so salty nothing lives in it, and it's the lowest point on any land on earth."),
            .init(emoji: "🌹", text: "Petra was carved directly into rose-red sandstone cliffs over 2,000 years ago."),
            .init(emoji: "🌱", text: "Israel pioneered drip irrigation, which now grows crops in deserts worldwide."),
            .init(emoji: "🫓", text: "Hummus is the subject of genuine, cheerfully unresolvable regional rivalry."),
        ]),
        .init(keywords: ["morocco", "tunisia", "algeria"], facts: [
            .init(emoji: "🏜️", text: "The Sahara is roughly the size of the United States, and it's still growing."),
            .init(emoji: "🌡️", text: "Desert nights can be near freezing even after a scorching day — sand holds no heat."),
            .init(emoji: "🍵", text: "Mint tea is poured from a height to aerate it, and refusing a glass is poor form."),
            .init(emoji: "🧭", text: "Fez has one of the largest car-free urban areas in the world — its medina is a maze on foot."),
        ]),
        .init(keywords: ["kazakhstan", "uzbekistan"], facts: [
            .init(emoji: "🗺️", text: "Kazakhstan is the largest landlocked country in the world."),
            .init(emoji: "🚀", text: "Every crewed mission to the International Space Station has launched from Baikonur, in Kazakhstan."),
            .init(emoji: "🐎", text: "Horses were probably first domesticated on these steppes."),
            .init(emoji: "🕌", text: "Samarkand and Bukhara were the great crossroads of the Silk Road."),
        ]),
        .init(keywords: ["ireland"], facts: [
            .init(emoji: "☘️", text: "There are no native snakes in Ireland — the island separated from Britain before they could arrive."),
            .init(emoji: "🌧️", text: "It rains on well over half the days of the year in much of the country, which is why it's so green."),
            .init(emoji: "📚", text: "Ireland has produced four Nobel laureates in literature."),
            .init(emoji: "🍺", text: "Guinness is served slowly on purpose — the two-part pour takes about 120 seconds."),
        ]),
        .init(keywords: ["austria"], facts: [
            .init(emoji: "🏔️", text: "The Alps cover about two-thirds of Austria."),
            .init(emoji: "🎼", text: "Mozart, Haydn, Schubert and Strauss were all Austrian."),
            .init(emoji: "🚰", text: "Vienna's drinking water flows in from mountain springs entirely by gravity."),
            .init(emoji: "⛷️", text: "Skiing is close to a national religion, and children learn it young."),
        ]),
        .init(keywords: ["belgium"], facts: [
            .init(emoji: "🍟", text: "Chips are Belgian, not French — and they're fried twice."),
            .init(emoji: "🍺", text: "Belgium brews hundreds of distinct beers, many by monasteries."),
            .init(emoji: "🎨", text: "The comic strip is treated as a serious art form here; Tintin was born in Brussels."),
            .init(emoji: "🗣️", text: "The country has three official languages: Dutch, French and German."),
        ]),
    ]

    // MARK: - Fallback

    /// For anywhere we have nothing specific — still true, still worth reading.
    private static let universal: [Fact] = [
        .init(emoji: "🌈", text: "A rainbow is always a full circle. From the ground you only ever see the top of it."),
        .init(emoji: "❄️", text: "No two snowflakes are identical, but they all have six sides — a consequence of how water molecules bond."),
        .init(emoji: "⚡", text: "Lightning heats the air around it to roughly five times the surface temperature of the sun."),
        .init(emoji: "☁️", text: "A modest cumulus cloud can weigh several hundred tonnes. It floats because the air beneath it is heavier still."),
        .init(emoji: "🌊", text: "Most of the rain that falls on land began as water evaporating from the ocean."),
        .init(emoji: "🌡️", text: "It can be too cold to snow: very cold air simply holds too little moisture."),
        .init(emoji: "💨", text: "Wind is just air moving from high pressure to low — the bigger the difference, the harder it blows."),
        .init(emoji: "🌦️", text: "Petrichor, the smell of rain on dry ground, comes partly from oils that plants shed in dry spells."),
    ]
}
