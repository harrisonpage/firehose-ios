import Foundation

enum KillRule {
    case phrase(String)     // matched against title
    case domain(String)     // matched against host
}

/// v1 has no editing UI and no persistence: rules are a compile-time
/// constant. Edit, rebuild, done.
enum Killfile {
    static let rules: [KillRule] = [
        .domain("wikipedia.org"),
        .domain("substack.com"),
        .domain("medium.com"),
        .domain("whitehouse.gov"),
        .domain("twitter.com"),
        .domain("x.com"),
        // add rules here and rebuild
    ]

    static func kills(title: String, host: String) -> Bool {
        rules.contains { rule in
            switch rule {
            case .phrase(let phrase): phraseMatches(phrase, title: title)
            case .domain(let domain): domainMatches(domain, host: host)
            }
        }
    }

    /// Token-boundary matching, not substring matching — a substring rule of
    /// "AI" would silently kill "Ukraine" and "explain". The rule's token
    /// sequence must appear as a consecutive run in the title's tokens.
    static func phraseMatches(_ phrase: String, title: String) -> Bool {
        let ruleTokens = tokens(phrase)
        guard !ruleTokens.isEmpty else { return false }
        let titleTokens = tokens(title)
        guard titleTokens.count >= ruleTokens.count else { return false }
        for start in 0...(titleTokens.count - ruleTokens.count) {
            if Array(titleTokens[start..<(start + ruleTokens.count)]) == ruleTokens {
                return true
            }
        }
        return false
    }

    /// Suffix matching on label boundaries: "wikipedia.org" matches
    /// "en.wikipedia.org" but not "notwikipedia.org".
    static func domainMatches(_ domain: String, host: String) -> Bool {
        let ruleLabels = labels(domain)
        let hostLabels = labels(host)
        guard !ruleLabels.isEmpty, ruleLabels.count <= hostLabels.count else { return false }
        return Array(hostLabels.suffix(ruleLabels.count)) == ruleLabels
    }

    /// Lowercase, split on any non-alphanumeric character, discard empties.
    static func tokens(_ text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !($0.isLetter || $0.isNumber) })
            .map(String.init)
    }

    private static func labels(_ host: String) -> [String] {
        host.lowercased().split(separator: ".").map(String.init)
    }
}
