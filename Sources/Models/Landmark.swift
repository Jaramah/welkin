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
        case .skyline:           return "Skyline"
        }
    }
}

struct Landmark: Sendable {
    let kind: LandmarkKind
    let name: String        // subtitle shown under the city name
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
        .init(city: "Singapore", kinds: [.marinaBaySands, .superTrees],
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
        .init(city: "Denver", kinds: [.skyline], keywords: ["denver"], lat: 39.7392, lon: -104.9903),
        .init(city: "Las Vegas", kinds: [.skyline], keywords: ["las vegas"], lat: 36.1699, lon: -115.1398),
        .init(city: "Vancouver", kinds: [.skyline], keywords: ["vancouver"], lat: 49.2827, lon: -123.1207),
        .init(city: "Hong Kong", kinds: [.skyline], keywords: ["hong kong", "kowloon"], lat: 22.3193, lon: 114.1694),
        .init(city: "Shanghai", kinds: [.skyline], keywords: ["shanghai"], lat: 31.2304, lon: 121.4737),
        .init(city: "Mumbai", kinds: [.skyline], keywords: ["mumbai", "bombay"], lat: 19.0760, lon: 72.8777),
        .init(city: "Bangkok", kinds: [.skyline], keywords: ["bangkok"], lat: 13.7563, lon: 100.5018),
        .init(city: "Madrid", kinds: [.skyline], keywords: ["madrid"], lat: 40.4168, lon: -3.7038),
        .init(city: "Amman", kinds: [.skyline], keywords: ["amman"], lat: 31.9539, lon: 35.9106),
        .init(city: "Buenos Aires", kinds: [.skyline], keywords: ["buenos aires"], lat: -34.6037, lon: -58.3816),
        .init(city: "São Paulo", kinds: [.skyline], keywords: ["são paulo", "sao paulo"], lat: -23.5505, lon: -46.6333),
        .init(city: "Melbourne", kinds: [.skyline], keywords: ["melbourne"], lat: -37.8136, lon: 144.9631),
        .init(city: "Seoul", kinds: [.skyline], keywords: ["seoul"], lat: 37.5665, lon: 126.9780),
        .init(city: "Austin", kinds: [.skyline], keywords: ["austin"], lat: 30.2672, lon: -97.7431),
        .init(city: "Philadelphia", kinds: [.skyline], keywords: ["philadelphia"], lat: 39.9526, lon: -75.1652),
        .init(city: "Atlanta", kinds: [.skyline], keywords: ["atlanta"], lat: 33.7490, lon: -84.3880),
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

        // 3) Generic skyline for anywhere else.
        return Landmark(kind: .skyline, name: "\(place.name) Skyline")
    }

    /// Pick one of the city's landmarks based on the day of the year, so it
    /// changes daily but stays stable for the whole day.
    private static func rotated(_ entry: Entry, on date: Date) -> Landmark {
        guard entry.kinds.count > 1 else {
            let kind = entry.kinds.first ?? .skyline
            let name = kind == .skyline ? "\(entry.city) Skyline" : kind.displayName
            return Landmark(kind: kind, name: name)
        }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let kind = entry.kinds[(day - 1) % entry.kinds.count]
        return Landmark(kind: kind, name: kind.displayName)
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
