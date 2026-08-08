import Foundation

/// The whole data layer: one concrete client for the Algolia HN Search API.
struct AlgoliaClient {
    private static let endpoint = "https://hn.algolia.com/api/v1/search_by_date"

    /// Fetches one page of stories, newest first. Pagination uses a timestamp
    /// cursor rather than the `page` parameter: offset pagination drifts as
    /// new stories land, and Algolia caps paginated results at 1000 hits per
    /// query — a fresh query per page sidesteps both.
    func fetchPage(olderThan cursor: Int? = nil) async throws -> [AlgoliaHit] {
        var components = URLComponents(string: Self.endpoint)!
        var items = [
            URLQueryItem(name: "tags", value: "story"),
            URLQueryItem(name: "hitsPerPage", value: "200"),
        ]
        if let cursor {
            items.append(URLQueryItem(name: "numericFilters", value: "created_at_i<\(cursor)"))
        }
        components.queryItems = items

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(AlgoliaPage.self, from: data).hits
    }
}
