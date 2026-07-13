import Foundation

/// A city's signature landmark — the thing that makes Welkin feel local.
enum LandmarkKind: Sendable, CaseIterable {
    // Original set
    case statueOfLiberty, eiffelTower, tokyoTower, bigBen, goldenGate, spaceNeedle
    case sydneyOperaHouse, burjKhalifa, leaningTower, pyramids, tajMahal, christRedeemer
    case washingtonMonument, cnTower, colosseum, stBasils, marinaBaySands, tableMountain
    case willisTower, parthenon, sagradaFamilia, brandenburgGate, palmTrees
    // Rotation set
    case empireState, brooklynBridge, archDeTriomphe, louvrePyramid, towerBridge, londonEye
    case theShard, tokyoSkytree, transamerica, sydneyHarbourBridge, burjAlArab, reichstag
    case capitolBuilding, sugarloaf, superTrees, gatewayArch, petronasTowers, chichenItza
    case atomium, templeOfHeaven, hagiaSophia, windmill, indiaGate
    case merlion, singaporeFlyer
    // Wider world
    case taipei101, orientalPearl, gatewayOfIndia, watArun, namsanTower, bankOfChina
    case torii, monas, skyTower, belemTower, angkorWat
    // True icons for cities that were stuck on the generic skyline
    case stStephens, charlesBridge, duomoMilano, frauenkirche, puertaAlcala, hapennyBridge
    case obelisco, elCapitolio, parliamentHungary, bayterek, minarEPakistan, machuPicchu
    case libertyBell
    /// Regional archetypes. A city we have no icon for still deserves a skyline from
    /// the right continent — a generic glass-box city over Kathmandu or Nairobi reads
    /// as a bug, not a fallback.
    case mosque, stupa, pagoda, onionDomes, gothicCathedral, alpinePeaks
    case colonialCathedral, acaciaSavanna, gabledHouses
    case skyline           // generic fallback

    /// Subtitle shown under the city name.
    var displayName: String {
        switch self {
        case .statueOfLiberty:   return "Statue of Liberty"
        case .eiffelTower:       return "Eiffel Tower"
        case .tokyoTower:        return "Tokyo Tower"
        case .bigBen:            return "Elizabeth Tower"
        case .goldenGate:        return "Golden Gate Bridge"
        case .spaceNeedle:       return "Space Needle"
        case .sydneyOperaHouse:  return "Sydney Opera House"
        case .burjKhalifa:       return "Burj Khalifa"
        case .leaningTower:      return "Leaning Tower of Pisa"
        case .pyramids:          return "Great Pyramids of Giza"
        case .tajMahal:          return "Taj Mahal"
        case .christRedeemer:    return "Christ the Redeemer"
        case .washingtonMonument:return "Washington Monument"
        case .cnTower:           return "CN Tower"
        case .colosseum:         return "The Colosseum"
        case .stBasils:          return "St. Basil's Cathedral"
        case .marinaBaySands:    return "Marina Bay Sands"
        case .tableMountain:     return "Table Mountain"
        case .willisTower:       return "Willis Tower"
        case .parthenon:         return "The Parthenon"
        case .sagradaFamilia:    return "Sagrada Família"
        case .brandenburgGate:   return "Brandenburg Gate"
        case .palmTrees:         return "Sunset Palms"
        case .empireState:       return "Empire State Building"
        case .brooklynBridge:    return "Brooklyn Bridge"
        case .archDeTriomphe:    return "Arc de Triomphe"
        case .louvrePyramid:     return "The Louvre"
        case .towerBridge:       return "Tower Bridge"
        case .londonEye:         return "London Eye"
        case .theShard:          return "The Shard"
        case .tokyoSkytree:      return "Tokyo Skytree"
        case .transamerica:      return "Transamerica Pyramid"
        case .sydneyHarbourBridge: return "Sydney Harbour Bridge"
        case .burjAlArab:        return "Burj Al Arab"
        case .reichstag:         return "Reichstag"
        case .capitolBuilding:   return "The Capitol"
        case .sugarloaf:         return "Sugarloaf Mountain"
        case .superTrees:        return "Gardens by the Bay"
        case .gatewayArch:       return "Gateway Arch"
        case .petronasTowers:    return "Petronas Towers"
        case .chichenItza:       return "Chichén Itzá"
        case .atomium:           return "Atomium"
        case .templeOfHeaven:    return "Temple of Heaven"
        case .hagiaSophia:       return "Hagia Sophia"
        case .windmill:          return "Dutch Windmills"
        case .indiaGate:         return "India Gate"
        case .merlion:           return "The Merlion"
        case .singaporeFlyer:    return "Singapore Flyer"
        case .taipei101:         return "Taipei 101"
        case .orientalPearl:     return "Oriental Pearl Tower"
        case .gatewayOfIndia:    return "Gateway of India"
        case .watArun:           return "Wat Arun"
        case .namsanTower:       return "N Seoul Tower"
        case .bankOfChina:       return "Bank of China Tower"
        case .torii:             return "Fushimi Inari Torii"
        case .monas:             return "National Monument"
        case .skyTower:          return "Sky Tower"
        case .belemTower:        return "Belém Tower"
        case .angkorWat:         return "Angkor Wat"
        case .stStephens:        return "St. Stephen's Cathedral"
        case .charlesBridge:     return "Charles Bridge"
        case .duomoMilano:       return "Duomo di Milano"
        case .frauenkirche:      return "Frauenkirche"
        case .puertaAlcala:      return "Puerta de Alcalá"
        case .hapennyBridge:     return "Ha'penny Bridge"
        case .obelisco:          return "El Obelisco"
        case .elCapitolio:       return "El Capitolio"
        case .parliamentHungary: return "Hungarian Parliament"
        case .bayterek:          return "Bayterek Tower"
        case .minarEPakistan:    return "Minar-e-Pakistan"
        case .machuPicchu:       return "Machu Picchu"
        case .libertyBell:       return "Liberty Bell"
        case .mosque:            return "Old Quarter Minarets"
        case .stupa:             return "Golden Stupa"
        case .pagoda:            return "Riverside Pagoda"
        case .onionDomes:        return "Orthodox Domes"
        case .gothicCathedral:   return "Old Town Cathedral"
        case .alpinePeaks:       return "Mountain Skyline"
        case .colonialCathedral: return "Colonial Cathedral"
        case .acaciaSavanna:     return "Acacia Sunset"
        case .gabledHouses:      return "Harbour Houses"
        case .skyline:           return "Skyline"
        }
    }
}

struct Landmark: Sendable {
    let kind: LandmarkKind
    let name: String        // subtitle shown under the city name
    /// Seeds the procedural skyline so each city's is its own. Ignored by the
    /// hand-drawn landmarks, which are the same building wherever you view them.
    var seed: Int = 0
}

enum LandmarkCatalog {
    private struct Entry {
        let city: String
        let kinds: [LandmarkKind]   // one or more; rotated daily
        let keywords: [String]
        let lat: Double
        let lon: Double
    }

    // ~50 cities. Marquee cities carry several landmarks that rotate day-to-day.
    private static let entries: [Entry] = [
        .init(city: "New York", kinds: [.statueOfLiberty, .empireState, .brooklynBridge],
              keywords: ["new york", "nyc", "manhattan", "brooklyn", "queens", "bronx"], lat: 40.7128, lon: -74.0060),
        .init(city: "Paris", kinds: [.eiffelTower, .archDeTriomphe, .louvrePyramid],
              keywords: ["paris"], lat: 48.8566, lon: 2.3522),
        .init(city: "London", kinds: [.bigBen, .towerBridge, .londonEye, .theShard],
              keywords: ["london"], lat: 51.5074, lon: -0.1278),
        .init(city: "Tokyo", kinds: [.tokyoTower, .tokyoSkytree],
              keywords: ["tokyo", "shibuya", "shinjuku", "suginami"], lat: 35.6762, lon: 139.6503),
        .init(city: "San Francisco", kinds: [.goldenGate, .transamerica],
              keywords: ["san francisco", "oakland", "berkeley"], lat: 37.7749, lon: -122.4194),
        .init(city: "Sydney", kinds: [.sydneyOperaHouse, .sydneyHarbourBridge],
              keywords: ["sydney"], lat: -33.8688, lon: 151.2093),
        .init(city: "Dubai", kinds: [.burjKhalifa, .burjAlArab],
              keywords: ["dubai"], lat: 25.2048, lon: 55.2708),
        .init(city: "Berlin", kinds: [.brandenburgGate, .reichstag],
              keywords: ["berlin"], lat: 52.5200, lon: 13.4050),
        .init(city: "Washington", kinds: [.washingtonMonument, .capitolBuilding],
              keywords: ["washington", "district of columbia"], lat: 38.9072, lon: -77.0369),
        .init(city: "Rio de Janeiro", kinds: [.christRedeemer, .sugarloaf],
              keywords: ["rio de janeiro", "rio"], lat: -22.9068, lon: -43.1729),
        .init(city: "Singapore", kinds: [.marinaBaySands, .superTrees, .merlion, .singaporeFlyer],
              keywords: ["singapore"], lat: 1.3521, lon: 103.8198),
        // Single-landmark cities
        .init(city: "Seattle", kinds: [.spaceNeedle], keywords: ["seattle"], lat: 47.6062, lon: -122.3321),
        .init(city: "Pisa", kinds: [.leaningTower], keywords: ["pisa"], lat: 43.7228, lon: 10.3966),
        .init(city: "Cairo", kinds: [.pyramids], keywords: ["cairo", "giza"], lat: 30.0444, lon: 31.2357),
        .init(city: "Agra", kinds: [.tajMahal], keywords: ["agra"], lat: 27.1751, lon: 78.0421),
        .init(city: "Toronto", kinds: [.cnTower], keywords: ["toronto"], lat: 43.6532, lon: -79.3832),
        .init(city: "Rome", kinds: [.colosseum], keywords: ["rome", "roma"], lat: 41.9028, lon: 12.4964),
        .init(city: "Moscow", kinds: [.stBasils], keywords: ["moscow"], lat: 55.7558, lon: 37.6173),
        .init(city: "Cape Town", kinds: [.tableMountain], keywords: ["cape town"], lat: -33.9249, lon: 18.4241),
        .init(city: "Chicago", kinds: [.willisTower], keywords: ["chicago"], lat: 41.8781, lon: -87.6298),
        .init(city: "Athens", kinds: [.parthenon], keywords: ["athens"], lat: 37.9838, lon: 23.7275),
        .init(city: "Barcelona", kinds: [.sagradaFamilia], keywords: ["barcelona"], lat: 41.3874, lon: 2.1686),
        .init(city: "Los Angeles", kinds: [.palmTrees],
              keywords: ["los angeles", "hollywood", "santa monica", "venice", "malibu"], lat: 34.0522, lon: -118.2437),
        .init(city: "St. Louis", kinds: [.gatewayArch], keywords: ["st. louis", "st louis", "saint louis"], lat: 38.6270, lon: -90.1994),
        .init(city: "Kuala Lumpur", kinds: [.petronasTowers], keywords: ["kuala lumpur"], lat: 3.1390, lon: 101.6869),
        .init(city: "Mexico City", kinds: [.chichenItza], keywords: ["mexico city", "ciudad de m"], lat: 19.4326, lon: -99.1332),
        .init(city: "Brussels", kinds: [.atomium], keywords: ["brussels", "bruxelles"], lat: 50.8503, lon: 4.3517),
        .init(city: "Beijing", kinds: [.templeOfHeaven], keywords: ["beijing", "peking"], lat: 39.9042, lon: 116.4074),
        .init(city: "Istanbul", kinds: [.hagiaSophia], keywords: ["istanbul"], lat: 41.0082, lon: 28.9784),
        .init(city: "Amsterdam", kinds: [.windmill], keywords: ["amsterdam", "rotterdam"], lat: 52.3676, lon: 4.9041),
        .init(city: "New Delhi", kinds: [.indiaGate], keywords: ["delhi", "new delhi"], lat: 28.6139, lon: 77.2090),
        // Cities that lean on the procedural skyline (still recognizable, still local name)
        .init(city: "Boston", kinds: [.skyline], keywords: ["boston"], lat: 42.3601, lon: -71.0589),
        .init(city: "Miami", kinds: [.skyline], keywords: ["miami"], lat: 25.7617, lon: -80.1918),
        .init(city: "Houston", kinds: [.skyline], keywords: ["houston"], lat: 29.7604, lon: -95.3698),
        .init(city: "Denver", kinds: [.alpinePeaks, .skyline], keywords: ["denver"], lat: 39.7392, lon: -104.9903),
        .init(city: "Las Vegas", kinds: [.skyline], keywords: ["las vegas"], lat: 36.1699, lon: -115.1398),
        .init(city: "Vancouver", kinds: [.skyline], keywords: ["vancouver"], lat: 49.2827, lon: -123.1207),
        .init(city: "Hong Kong", kinds: [.bankOfChina, .skyline], keywords: ["hong kong", "kowloon"], lat: 22.3193, lon: 114.1694),
        .init(city: "Shanghai", kinds: [.orientalPearl, .skyline], keywords: ["shanghai"], lat: 31.2304, lon: 121.4737),
        .init(city: "Mumbai", kinds: [.gatewayOfIndia, .skyline], keywords: ["mumbai", "bombay"], lat: 19.0760, lon: 72.8777),
        .init(city: "Bangkok", kinds: [.watArun, .skyline], keywords: ["bangkok"], lat: 13.7563, lon: 100.5018),
        .init(city: "Madrid", kinds: [.puertaAlcala, .skyline], keywords: ["madrid"], lat: 40.4168, lon: -3.7038),
        .init(city: "Amman", kinds: [.mosque], keywords: ["amman"], lat: 31.9539, lon: 35.9106),
        .init(city: "Buenos Aires", kinds: [.obelisco, .skyline], keywords: ["buenos aires"], lat: -34.6037, lon: -58.3816),
        .init(city: "São Paulo", kinds: [.skyline], keywords: ["são paulo", "sao paulo"], lat: -23.5505, lon: -46.6333),
        .init(city: "Melbourne", kinds: [.skyline], keywords: ["melbourne"], lat: -37.8136, lon: 144.9631),
        .init(city: "Seoul", kinds: [.namsanTower, .skyline], keywords: ["seoul"], lat: 37.5665, lon: 126.9780),
        .init(city: "Austin", kinds: [.skyline], keywords: ["austin"], lat: 30.2672, lon: -97.7431),
        .init(city: "Philadelphia", kinds: [.libertyBell, .skyline], keywords: ["philadelphia"], lat: 39.9526, lon: -75.1652),
        .init(city: "Atlanta", kinds: [.skyline], keywords: ["atlanta"], lat: 33.7490, lon: -84.3880),
        // Newly covered countries & cities
        .init(city: "Taipei", kinds: [.taipei101, .skyline], keywords: ["taipei"], lat: 25.0330, lon: 121.5654),
        .init(city: "Kyoto", kinds: [.torii], keywords: ["kyoto"], lat: 35.0116, lon: 135.7681),
        .init(city: "Osaka", kinds: [.torii, .skyline], keywords: ["osaka"], lat: 34.6937, lon: 135.5023),
        .init(city: "Jakarta", kinds: [.monas, .skyline], keywords: ["jakarta"], lat: -6.2088, lon: 106.8456),
        .init(city: "Manila", kinds: [.colonialCathedral, .skyline], keywords: ["manila", "quezon"], lat: 14.5995, lon: 120.9842),
        .init(city: "Hanoi", kinds: [.pagoda], keywords: ["hanoi", "ha noi"], lat: 21.0278, lon: 105.8342),
        .init(city: "Ho Chi Minh City", kinds: [.pagoda, .skyline], keywords: ["ho chi minh", "saigon"], lat: 10.8231, lon: 106.6297),
        .init(city: "Siem Reap", kinds: [.angkorWat], keywords: ["siem reap", "phnom penh"], lat: 13.3671, lon: 103.8448),
        .init(city: "Auckland", kinds: [.skyTower], keywords: ["auckland"], lat: -36.8485, lon: 174.7633),
        .init(city: "Lisbon", kinds: [.belemTower], keywords: ["lisbon", "lisboa"], lat: 38.7223, lon: -9.1393),
        .init(city: "Dublin", kinds: [.hapennyBridge], keywords: ["dublin"], lat: 53.3498, lon: -6.2603),
        .init(city: "Prague", kinds: [.charlesBridge], keywords: ["prague", "praha"], lat: 50.0755, lon: 14.4378),
        .init(city: "Vienna", kinds: [.stStephens], keywords: ["vienna", "wien"], lat: 48.2082, lon: 16.3738),
        .init(city: "Copenhagen", kinds: [.gabledHouses], keywords: ["copenhagen", "kobenhavn"], lat: 55.6761, lon: 12.5683),
        .init(city: "Stockholm", kinds: [.gabledHouses], keywords: ["stockholm"], lat: 59.3293, lon: 18.0686),
        .init(city: "Zurich", kinds: [.alpinePeaks], keywords: ["zurich", "zürich"], lat: 47.3769, lon: 8.5417),
        .init(city: "Milan", kinds: [.duomoMilano], keywords: ["milan", "milano"], lat: 45.4642, lon: 9.1900),
        .init(city: "Munich", kinds: [.frauenkirche], keywords: ["munich", "münchen"], lat: 48.1351, lon: 11.5820),
        .init(city: "Doha", kinds: [.skyline], keywords: ["doha"], lat: 25.2854, lon: 51.5310),
        .init(city: "Tel Aviv", kinds: [.skyline], keywords: ["tel aviv"], lat: 32.0853, lon: 34.7818),
        .init(city: "Nairobi", kinds: [.acaciaSavanna], keywords: ["nairobi"], lat: -1.2921, lon: 36.8219),
        .init(city: "Lagos", kinds: [.acaciaSavanna], keywords: ["lagos"], lat: 6.5244, lon: 3.3792),
        .init(city: "Marrakech", kinds: [.mosque], keywords: ["marrakech", "marrakesh", "casablanca"], lat: 31.6295, lon: -7.9811),
        .init(city: "Montreal", kinds: [.gothicCathedral, .skyline], keywords: ["montreal", "montréal"], lat: 45.5017, lon: -73.5673),
        .init(city: "New Orleans", kinds: [.colonialCathedral], keywords: ["new orleans"], lat: 29.9511, lon: -90.0715),
        .init(city: "Honolulu", kinds: [.palmTrees], keywords: ["honolulu"], lat: 21.3069, lon: -157.8583),
        .init(city: "Lima", kinds: [.colonialCathedral], keywords: ["lima"], lat: -12.0464, lon: -77.0428),
        .init(city: "Santiago", kinds: [.alpinePeaks, .skyline], keywords: ["santiago"], lat: -33.4489, lon: -70.6693),
        .init(city: "Havana", kinds: [.elCapitolio], keywords: ["havana", "habana"], lat: 23.1136, lon: -82.3666),
        // Countries the app didn't reach before
        .init(city: "Budapest", kinds: [.parliamentHungary], keywords: ["budapest"], lat: 47.4979, lon: 19.0402),
        .init(city: "Warsaw", kinds: [.gothicCathedral], keywords: ["warsaw", "warszawa"], lat: 52.2297, lon: 21.0122),
        .init(city: "Kraków", kinds: [.gothicCathedral], keywords: ["krakow", "kraków"], lat: 50.0647, lon: 19.9450),
        .init(city: "Kyiv", kinds: [.onionDomes], keywords: ["kyiv", "kiev"], lat: 50.4501, lon: 30.5234),
        .init(city: "Oslo", kinds: [.gabledHouses], keywords: ["oslo"], lat: 59.9139, lon: 10.7522),
        .init(city: "Helsinki", kinds: [.gothicCathedral], keywords: ["helsinki"], lat: 60.1699, lon: 24.9384),
        .init(city: "Reykjavík", kinds: [.alpinePeaks], keywords: ["reykjavik", "reykjavík"], lat: 64.1466, lon: -21.9426),
        .init(city: "Edinburgh", kinds: [.gothicCathedral], keywords: ["edinburgh", "glasgow"], lat: 55.9533, lon: -3.1883),
        .init(city: "Bucharest", kinds: [.gothicCathedral], keywords: ["bucharest", "bucurești"], lat: 44.4268, lon: 26.1025),
        .init(city: "Sofia", kinds: [.onionDomes], keywords: ["sofia"], lat: 42.6977, lon: 23.3219),
        .init(city: "Belgrade", kinds: [.onionDomes], keywords: ["belgrade", "beograd"], lat: 44.7866, lon: 20.4489),
        .init(city: "Astana", kinds: [.bayterek], keywords: ["astana", "nur-sultan", "almaty"], lat: 51.1694, lon: 71.4491),
        .init(city: "Lahore", kinds: [.minarEPakistan], keywords: ["lahore", "islamabad"], lat: 31.5204, lon: 74.3587),
        .init(city: "Karachi", kinds: [.mosque], keywords: ["karachi"], lat: 24.8607, lon: 67.0011),
        .init(city: "Dhaka", kinds: [.mosque], keywords: ["dhaka"], lat: 23.8103, lon: 90.4125),
        .init(city: "Riyadh", kinds: [.mosque], keywords: ["riyadh", "jeddah"], lat: 24.7136, lon: 46.6753),
        .init(city: "Kuwait City", kinds: [.mosque], keywords: ["kuwait"], lat: 29.3759, lon: 47.9774),
        .init(city: "Tehran", kinds: [.mosque], keywords: ["tehran"], lat: 35.6892, lon: 51.3890),
        .init(city: "Baghdad", kinds: [.mosque], keywords: ["baghdad"], lat: 33.3152, lon: 44.3661),
        .init(city: "Kathmandu", kinds: [.stupa], keywords: ["kathmandu"], lat: 27.7172, lon: 85.3240),
        .init(city: "Yangon", kinds: [.stupa], keywords: ["yangon", "rangoon"], lat: 16.8661, lon: 96.1951),
        .init(city: "Colombo", kinds: [.stupa], keywords: ["colombo"], lat: 6.9271, lon: 79.8612),
        .init(city: "Vientiane", kinds: [.stupa], keywords: ["vientiane", "luang prabang"], lat: 17.9757, lon: 102.6331),
        .init(city: "Cusco", kinds: [.machuPicchu], keywords: ["cusco", "cuzco"], lat: -13.5319, lon: -71.9675),
        .init(city: "Bogotá", kinds: [.colonialCathedral], keywords: ["bogota", "bogotá", "medellin"], lat: 4.7110, lon: -74.0721),
        .init(city: "Quito", kinds: [.colonialCathedral], keywords: ["quito", "guayaquil"], lat: -0.1807, lon: -78.4678),
        .init(city: "Montevideo", kinds: [.colonialCathedral], keywords: ["montevideo"], lat: -34.9011, lon: -56.1645),
        .init(city: "Accra", kinds: [.acaciaSavanna], keywords: ["accra"], lat: 5.6037, lon: -0.1870),
        .init(city: "Addis Ababa", kinds: [.acaciaSavanna], keywords: ["addis"], lat: 9.0320, lon: 38.7469),
        .init(city: "Dar es Salaam", kinds: [.acaciaSavanna], keywords: ["dar es salaam"], lat: -6.7924, lon: 39.2083),
        .init(city: "Johannesburg", kinds: [.acaciaSavanna], keywords: ["johannesburg", "pretoria"], lat: -26.2041, lon: 28.0473),
    ]

    static func landmark(for place: Place, on date: Date = Date()) -> Landmark {
        let name = place.name.lowercased()

        // 1) Name match (most reliable when we have a city name).
        if let match = entries.first(where: { entry in
            entry.keywords.contains(where: { name.contains($0) })
        }) {
            return rotated(match, on: date)
        }

        // 2) Proximity match (within ~60 km) for "Current Location" etc.
        var best: (entry: Entry, dist: Double)?
        for entry in entries {
            let d = haversineKm(place.latitude, place.longitude, entry.lat, entry.lon)
            if best == nil || d < best!.dist { best = (entry, d) }
        }
        if let best, best.dist < 60 {
            return rotated(best.entry, on: date)
        }

        // 3) Nothing matched. Rather than hand every unknown city on earth the same
        //    eleven boxes, fall back to an archetype from its own part of the world,
        //    and seed the skyline from the city name so at least it is *its* skyline.
        let seed = stableSeed(place.name)
        if let regional = regionKind(for: place) {
            return Landmark(kind: regional, name: regional.displayName, seed: seed)
        }
        return Landmark(kind: .skyline, name: "\(place.name) Skyline", seed: seed)
    }

    /// A same-continent archetype for a city we have no icon for. Better a mosque
    /// over Tabriz and a stupa over Pokhara than a Manhattan skyline over both.
    private static func regionKind(for place: Place) -> LandmarkKind? {
        guard let country = place.country?.lowercased() else { return nil }
        func any(_ names: [String]) -> Bool { names.contains { country.contains($0) } }

        switch true {
        case any(["saudi", "emirat", "qatar", "kuwait", "bahrain", "oman", "yemen",
                  "iran", "iraq", "jordan", "syria", "lebanon", "palestin",
                  "pakistan", "bangladesh", "afghan", "azerbaijan",
                  "egypt", "morocco", "algeria", "tunisia", "libya", "sudan",
                  "uzbek", "turkmen", "tajik", "kyrgyz", "malaysia", "brunei", "maldiv"]):
            return .mosque

        case any(["nepal", "bhutan", "myanmar", "burma", "sri lanka", "laos", "cambodia", "mongolia"]):
            return .stupa

        case any(["vietnam", "china", "taiwan", "hong kong", "macau", "japan", "korea"]):
            return .pagoda

        case any(["russia", "ukraine", "belarus", "serbia", "bulgaria", "macedonia",
                  "montenegro", "georgia", "armenia", "moldova", "greece", "cyprus"]):
            return .onionDomes

        case any(["norway", "sweden", "denmark", "finland", "iceland", "estonia", "latvia", "lithuania"]):
            return .gabledHouses

        case any(["switzerland", "austria", "liechtenstein", "slovenia", "nepal"]):
            return .alpinePeaks

        case any(["mexico", "guatemala", "honduras", "salvador", "nicaragua", "costa rica",
                  "panama", "colombia", "venezuela", "ecuador", "peru", "bolivia",
                  "paraguay", "uruguay", "argentina", "chile", "cuba", "dominican",
                  "philippin"]):
            return .colonialCathedral

        case any(["kenya", "tanzania", "uganda", "ethiopia", "somalia", "rwanda", "burundi",
                  "nigeria", "ghana", "senegal", "mali", "ivoire", "ivory", "cameroon",
                  "zambia", "zimbabwe", "botswana", "namibia", "mozambique", "angola",
                  "south africa", "congo", "malawi"]):
            return .acaciaSavanna

        case any(["poland", "czech", "slovak", "hungary", "romania", "croatia", "bosnia",
                  "germany", "belgium", "france", "netherlands", "ireland", "portugal",
                  "spain", "italy", "united kingdom", "luxembourg", "albania"]):
            return .gothicCathedral

        case any(["fiji", "samoa", "tonga", "vanuatu", "papua", "solomon", "jamaica",
                  "bahamas", "barbados", "trinidad", "haiti", "puerto rico", "seychelles",
                  "mauritius", "sri lanka"]):
            return .palmTrees

        default:
            return nil     // USA, Canada, Australia, Gulf megacities... a skyline is honest
        }
    }

    /// A hash that is stable across launches. Swift's own String.hashValue is seeded
    /// randomly per process, so a city's skyline would be different every time the
    /// app started.
    static func stableSeed(_ text: String) -> Int {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325          // FNV-1a
        for byte in text.lowercased().utf8 {
            hash = (hash ^ UInt64(byte)) &* 0x100_0000_01b3
        }
        return Int(truncatingIfNeeded: hash & 0x7fff_ffff)
    }

    /// Pick one of the city's landmarks based on the day of the year, so it
    /// changes daily but stays stable for the whole day.
    private static func rotated(_ entry: Entry, on date: Date) -> Landmark {
        let seed = stableSeed(entry.city)
        guard entry.kinds.count > 1 else {
            let kind = entry.kinds.first ?? .skyline
            let name = kind == .skyline ? "\(entry.city) Skyline" : kind.displayName
            return Landmark(kind: kind, name: name, seed: seed)
        }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let kind = entry.kinds[(day - 1) % entry.kinds.count]
        let name = kind == .skyline ? "\(entry.city) Skyline" : kind.displayName
        return Landmark(kind: kind, name: name, seed: seed)
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
