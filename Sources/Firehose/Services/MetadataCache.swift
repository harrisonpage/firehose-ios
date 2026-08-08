import LinkPresentation
import Observation
import UIKit

enum UnfurlState {
    case idle
    case loading
    case loaded(image: UIImage?, title: String?)
    case failed     // renders identically to loaded-without-image
}

@MainActor
@Observable
final class MetadataCache {
    private(set) var states: [String: UnfurlState] = [:]

    private let gate = FetchGate(limit: 5)

    func state(for story: Story) -> UnfurlState {
        states[story.id] ?? .idle
    }

    /// Kicked off from each row's onAppear so the fetch has usually landed by
    /// the time a headline is interesting enough to long-press. Entries that
    /// are loading, loaded, or failed are never re-requested within a session.
    func prefetch(_ story: Story) {
        guard states[story.id] == nil else { return }
        states[story.id] = .loading
        Task { await fetch(story) }
    }

    func clear() {
        states.removeAll()
    }

    private func fetch(_ story: Story) async {
        await gate.acquire()
        defer { gate.releaseLater() }

        // LPMetadataProvider is single-use: fresh instance per URL.
        let provider = LPMetadataProvider()
        provider.timeout = 8
        do {
            let metadata = try await provider.startFetchingMetadata(for: story.url)
            let image = await Self.loadImage(from: metadata.imageProvider)
            states[story.id] = .loaded(image: image, title: metadata.title)
        } catch {
            states[story.id] = .failed
        }
    }

    /// The image is a second async hop after metadata resolves.
    private static func loadImage(from provider: NSItemProvider?) async -> UIImage? {
        guard let provider, provider.canLoadObject(ofClass: UIImage.self) else { return nil }
        return await withCheckedContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                continuation.resume(returning: object as? UIImage)
            }
        }
    }
}

/// Caps concurrent metadata fetches. Without this, fast scrolling spawns
/// hundreds of in-flight requests and the list stalls.
actor FetchGate {
    private let limit: Int
    private var active = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) {
        self.limit = limit
    }

    func acquire() async {
        if active < limit {
            active += 1
            return
        }
        await withCheckedContinuation { waiters.append($0) }
    }

    private func release() {
        if waiters.isEmpty {
            active -= 1
        } else {
            waiters.removeFirst().resume()  // slot passes directly to the waiter
        }
    }

    nonisolated func releaseLater() {
        Task { await self.release() }
    }
}
