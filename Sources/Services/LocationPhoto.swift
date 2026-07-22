import Foundation

/// A photograph of a place, plus the credit its licence requires.
struct LocationPhoto: Sendable, Equatable {
    let data: Data
    /// "Photo: Jane Doe · CC BY-SA 4.0" — shown on the image and in the footer.
    let credit: String?
}

/// Fetches a real photo of a place from Wikimedia — keyless, and a picture of the
/// *actual* city rather than generic condition stock, which fits an app whose whole
/// pitch is "your city, not a stock photo".
///
/// Cached to disk so a place shown once stays instant and works offline. A definitive
/// "no picture exists" is remembered for the session so we don't re-hammer the API; a
/// network failure is *not* remembered, so it retries on the next refresh once you're
/// back online.
actor LocationPhotoStore {
    static let shared = LocationPhotoStore()

    /// Wikimedia's API policy asks for a descriptive User-Agent; a generic one can be
    /// refused with 403. Identify the app plainly.
    private static let userAgent = "Welkin/1.0 (weather app; https://github.com/Jaramah/welkin)"

    private var memory: [String: LocationPhoto?] = [:]
    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 12
        c.waitsForConnectivity = false
        return URLSession(configuration: c)
    }()

    func photo(for place: Place) async -> LocationPhoto? {
        let key = Self.cacheKey(for: place)
        if let remembered = memory[key] { return remembered }
        if let disk = Self.readDisk(key) {
            memory[key] = .some(disk)
            return disk
        }
        do {
            let found = try await fetch(for: place)
            memory[key] = .some(found)        // remember success or definitive absence
            if let found { Self.writeDisk(key, found) }
            return found
        } catch {
            return nil                        // transient — do not memoize; allow retry
        }
    }

    // MARK: Fetch

    private func fetch(for place: Place) async throws -> LocationPhoto? {
        for title in Self.candidateTitles(for: place) {
            guard let (thumbURL, fileTitle) = try await pageImage(title: title) else { continue }
            let credit = try? await imageCredit(fileTitle: fileTitle)
            let data = try await get(thumbURL)
            // A skyline, not a 1-KB flag or map pin. Also weeds out error bodies.
            guard data.count > 3_000 else { continue }
            return LocationPhoto(data: data, credit: credit)
        }
        return nil
    }

    /// The lead image for a Wikipedia article, as a ~1200px thumbnail plus the file's
    /// own title (needed to look up the credit).
    private func pageImage(title: String) async throws -> (URL, String)? {
        var comps = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        comps.queryItems = [
            .init(name: "action", value: "query"),
            .init(name: "format", value: "json"),
            .init(name: "formatversion", value: "2"),
            .init(name: "prop", value: "pageimages"),
            .init(name: "piprop", value: "thumbnail|name"),
            .init(name: "pithumbsize", value: "1200"),
            .init(name: "redirects", value: "1"),
            .init(name: "titles", value: title),
        ]
        let data = try await get(comps.url!)
        let decoded = try JSONDecoder().decode(PageImagesResponse.self, from: data)
        guard let page = decoded.query?.pages.first,
              let thumb = page.thumbnail?.source,
              let url = URL(string: thumb),
              let file = page.pageimage else { return nil }
        return (url, "File:\(file)")
    }

    /// Best-effort author + licence for a Wikimedia file, so we can attribute it.
    private func imageCredit(fileTitle: String) async throws -> String? {
        var comps = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        comps.queryItems = [
            .init(name: "action", value: "query"),
            .init(name: "format", value: "json"),
            .init(name: "formatversion", value: "2"),
            .init(name: "prop", value: "imageinfo"),
            .init(name: "iiprop", value: "extmetadata"),
            .init(name: "titles", value: fileTitle),
        ]
        let data = try await get(comps.url!)
        let decoded = try JSONDecoder().decode(ImageInfoResponse.self, from: data)
        let meta = decoded.query?.pages.first?.imageinfo?.first?.extmetadata
        // Parenthesised so `.map` applies to the optional String, not to the String's
        // characters (String is a Sequence, and `value.map` would map over those).
        let rawArtist = meta?.Artist?.value
        let artist = rawArtist.map(Self.stripHTML).flatMap { $0.isEmpty ? nil : $0 }
        let licence = meta?.LicenseShortName?.value

        switch (artist, licence) {
        case let (author?, lic?): return "Photo: \(author) · \(lic)"
        case let (author?, nil):  return "Photo: \(author)"
        case let (nil, lic?):     return "Photo: Wikimedia · \(lic)"
        case (nil, nil):          return "Photo: Wikimedia Commons"
        }
    }

    private func get(_ url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    // MARK: Query building

    /// Titles to try, best first. A neighbourhood ("Bedok") is worth a shot, but fall
    /// back to its city/country so a searched suburb still lands on *something* local.
    nonisolated private static func candidateTitles(for place: Place) -> [String] {
        var titles: [String] = []
        func add(_ s: String?) {
            guard let s, !s.isEmpty, s != "Current Location",
                  !titles.contains(s) else { return }
            titles.append(s)
        }
        add(place.name)
        add(place.admin)
        add(place.country)
        return titles
    }

    /// `<a>`-wrapped author strings and stray entities become plain text.
    nonisolated private static func stripHTML(_ s: String) -> String {
        var out = s.replacingOccurrences(of: "<[^>]+>", with: "",
                                         options: .regularExpression)
        for (e, c) in ["&amp;": "&", "&nbsp;": " ", "&quot;": "\"", "&#39;": "'"] {
            out = out.replacingOccurrences(of: e, with: c)
        }
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Disk cache

    nonisolated private static func cacheKey(for place: Place) -> String {
        // Name plus a coarse coordinate, so two same-named towns don't share a photo.
        let rounded = "\(place.name.lowercased())|\(Int(place.latitude.rounded()))|\(Int(place.longitude.rounded()))"
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325                 // FNV-1a
        for byte in rounded.utf8 { hash = (hash ^ UInt64(byte)) &* 0x100_0000_01b3 }
        return String(format: "photo-%016llx", hash)
    }

    nonisolated private static func dir() -> URL? {
        guard let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        let dir = base.appendingPathComponent("location-photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    nonisolated private static func readDisk(_ key: String) -> LocationPhoto? {
        guard let dir = dir() else { return nil }
        let img = dir.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: img) else { return nil }
        let credit = try? String(contentsOf: dir.appendingPathComponent("\(key).credit"),
                                 encoding: .utf8)
        return LocationPhoto(data: data, credit: credit)
    }

    nonisolated private static func writeDisk(_ key: String, _ photo: LocationPhoto) {
        guard let dir = dir() else { return }
        try? photo.data.write(to: dir.appendingPathComponent(key), options: .atomic)
        if let credit = photo.credit {
            try? credit.write(to: dir.appendingPathComponent("\(key).credit"),
                              atomically: true, encoding: .utf8)
        }
    }
}

// MARK: - Wikimedia API DTOs

private struct PageImagesResponse: Decodable {
    struct Query: Decodable { let pages: [Page] }
    struct Page: Decodable {
        let thumbnail: Thumb?
        let pageimage: String?
    }
    struct Thumb: Decodable { let source: String }
    let query: Query?
}

private struct ImageInfoResponse: Decodable {
    struct Query: Decodable { let pages: [Page] }
    struct Page: Decodable { let imageinfo: [Info]? }
    struct Info: Decodable { let extmetadata: Meta? }
    struct Meta: Decodable {
        let Artist: Field?
        let LicenseShortName: Field?
    }
    struct Field: Decodable { let value: String }
    let query: Query?
}
