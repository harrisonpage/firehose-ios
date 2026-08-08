import Foundation
import Observation

@MainActor
@Observable
final class StoryStore {
    enum LoadState {
        case cold           // nothing loaded yet — skeleton rows
        case loaded
        case refreshFailed  // offline banner; any loaded rows stay visible
        case pageFailed     // footer retry; loaded rows unaffected
    }

    private(set) var stories: [Story] = []
    private(set) var loadState: LoadState = .cold
    private(set) var lastSuccessfulRefresh: Date?

    /// Ticked periodically so relative ages re-render.
    var now = Date()

    let metadata = MetadataCache()

    private let client = AlgoliaClient()
    private var loadedIDs = Set<String>()
    /// Smallest created_at_i across all raw hits seen (including dropped
    /// ones), so the cursor always advances even through pages the killfile
    /// eats entirely.
    private var cursor: Int?
    private var lastPageWasFull = false
    private var isLoadingOlder = false

    /// If filtering leaves too few rows to scroll, the scroll-triggered
    /// pagination can never fire — below this count we fetch more eagerly.
    private static let minimumScrollableCount = 25

    /// Pull-to-refresh and cold load: discard everything and refetch page one
    /// from scratch. On failure the previously loaded rows are kept and the
    /// offline banner shows. An empty response is treated as a failure — the
    /// API always returns stories.
    func refresh() async {
        do {
            let hits = try await client.fetchPage()
            guard !hits.isEmpty else { throw URLError(.badServerResponse) }
            stories.removeAll()
            loadedIDs.removeAll()
            cursor = nil
            metadata.clear()
            ingest(hits)
            lastSuccessfulRefresh = Date()
            now = Date()
            loadState = .loaded
            await topUpIfNeeded()
        } catch {
            loadState = .refreshFailed
        }
    }

    func loadOlder() async {
        guard !isLoadingOlder, let cursor, loadState != .cold else { return }
        isLoadingOlder = true
        defer { isLoadingOlder = false }
        do {
            let hits = try await client.fetchPage(olderThan: cursor)
            ingest(hits)
            now = Date()
            if loadState == .pageFailed { loadState = .loaded }
            await topUpIfNeeded()
        } catch {
            loadState = .pageFailed
        }
    }

    func shouldLoadOlder(after story: Story) -> Bool {
        guard let index = stories.lastIndex(of: story) else { return false }
        return index >= stories.count - 20
    }

    private func ingest(_ hits: [AlgoliaHit]) {
        lastPageWasFull = hits.count >= 200
        for hit in hits {
            if let oldest = cursor {
                cursor = min(oldest, hit.created_at_i)
            } else {
                cursor = hit.created_at_i
            }
            guard let story = Story(hit: hit) else { continue }
            guard !loadedIDs.contains(story.id) else { continue }
            guard !Killfile.kills(title: story.title, host: story.host) else { continue }
            loadedIDs.insert(story.id)
            stories.append(story)
        }
        // Algolia's ordering (newest first) is preserved: appends only.
    }

    private func topUpIfNeeded() async {
        var guardrail = 5
        while stories.count < Self.minimumScrollableCount, lastPageWasFull, guardrail > 0, let cursor {
            guardrail -= 1
            guard let hits = try? await client.fetchPage(olderThan: cursor) else { break }
            ingest(hits)
        }
    }
}
