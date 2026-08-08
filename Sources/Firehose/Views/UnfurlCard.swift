import SwiftUI

/// Long-press preview card: fixed 320×230 in every state — a 140pt band on
/// top, then a 90pt text block. The card must never resize between states.
struct UnfurlCard: View {
    let story: Story
    let state: UnfurlState

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            band.frame(width: 320, height: 140).clipped()
            textBlock.frame(width: 320, height: 90)
        }
        .frame(width: 320, height: 230)
        .background(Theme.cardSurface)
        .border(Theme.cardBorder, width: colorScheme == .dark ? 1 : 2)
    }

    @ViewBuilder
    private var band: some View {
        switch state {
        case .loaded(.some(let image), _):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .saturation(0)  // the design system prints photography in black and white
        case .idle, .loading:
            ZStack(alignment: .bottom) {
                Theme.inset
                ProgressRule()
            }
        case .loaded(nil, _), .failed:
            // The deliberate typographic fallback: the domain set large in
            // ink, breaking only at dots, over a 2px ink rule at the base.
            ZStack(alignment: .bottomLeading) {
                Theme.inset
                Rectangle().fill(Theme.ink).frame(height: 2)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                Text(breakableHost)
                    .font(Theme.masthead)
                    .kerning(-0.6)
                    .lineSpacing(22 * 0.15)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    @ViewBuilder
    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch state {
            case .idle, .loading:
                Rectangle().fill(Theme.skeletonHeadline)
                    .frame(width: 220, height: 10)
                Rectangle().fill(Theme.skeletonMeta)
                    .frame(width: 120, height: 8)
            case .loaded(_, let title):
                Text(title?.isEmpty == false ? title! : story.title)
                    .font(Theme.cardTitle)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text(story.host)
                    .font(Theme.cardDomain)
                    .foregroundStyle(Theme.metaGrey)
                    .lineLimit(1)
            case .failed:
                Text(story.title)
                    .font(Theme.cardTitle)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text(story.host)
                    .font(Theme.cardDomain)
                    .foregroundStyle(Theme.metaGrey)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// May break only at dots, never mid-label: a zero-width space after
    /// each dot gives the layout its only break opportunities.
    private var breakableHost: String {
        story.host.replacingOccurrences(of: ".", with: ".\u{200B}")
    }
}

/// The loading band's 2px progress rule: accent over a 15%-ink track.
/// LPMetadataProvider reports no real progress, so it eases toward 85% and
/// holds — the card swaps state when the fetch lands.
private struct ProgressRule: View {
    @State private var progress: CGFloat = 0.06

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(Theme.ink.opacity(0.15))
                Rectangle().fill(Theme.accent)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 4)) { progress = 0.85 }
        }
    }
}
