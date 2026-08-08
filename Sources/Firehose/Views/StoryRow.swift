import SwiftUI

struct StoryRow: View {
    let story: Story
    let now: Date

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.title)
                .font(Theme.headline)
                .kerning(-0.2)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
            metadata
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.rowRule)
                .frame(height: 2)
        }
        .contentShape(Rectangle())
    }

    /// domain · age · submitter. The domain leads but is not styled
    /// differently from what follows — no bold, no color, no badge.
    /// At accessibility sizes the line wraps instead of truncating.
    @ViewBuilder
    private var metadata: some View {
        let age = story.age(relativeTo: now)
        if typeSize.isAccessibilitySize {
            (Text(story.host)
                + Text(" · ").foregroundColor(Theme.dots)
                + Text(age)
                + Text(" · ").foregroundColor(Theme.dots)
                + Text(story.author))
                .font(Theme.meta)
                .foregroundStyle(Theme.metaGrey)
        } else {
            HStack(spacing: 8) {
                // The domain truncates before age/submitter do; age never wraps.
                Text(story.host)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("·").foregroundStyle(Theme.dots)
                Text(age)
                    .fixedSize()
                    .layoutPriority(2)
                Text("·").foregroundStyle(Theme.dots)
                Text(story.author)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
            .font(Theme.meta)
            .foregroundStyle(Theme.metaGrey)
        }
    }
}
