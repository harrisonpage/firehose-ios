import Foundation

struct Story: Identifiable, Hashable {
    let id: String          // objectID
    let title: String
    let url: URL
    let host: String        // lowercased, "www." stripped
    let author: String
    let createdAt: Date
}

extension Story {
    /// Converts a raw hit, applying ingest rules 1–2 and 5 (nil/unparseable
    /// URL, empty title, host derivation). Identity dedup and the killfile
    /// are applied by the store.
    init?(hit: AlgoliaHit) {
        guard
            let urlString = hit.url,
            let url = URL(string: urlString),
            let rawHost = url.host(),
            let title = hit.title?.trimmingCharacters(in: .whitespacesAndNewlines),
            !title.isEmpty
        else { return nil }

        var host = rawHost.lowercased()
        if host.hasPrefix("www.") {
            host.removeFirst(4)
        }

        self.id = hit.objectID
        self.title = title
        self.url = url
        self.host = host
        self.author = hit.author ?? ""
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(hit.created_at_i))
    }

    /// Compact relative age: "3m", "5h", "2d".
    func age(relativeTo now: Date) -> String {
        let seconds = max(0, now.timeIntervalSince(createdAt))
        let minutes = Int(seconds / 60)
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        return "\(hours / 24)d"
    }
}
