import SwiftUI

/// Presented from the header info button over a dimmed, blurred list.
struct AboutPanel: View {
    let dismiss: () -> Void

    @Environment(\.openURL) private var openURL

    private static let sourceURL = URL(string: "https://github.com/harrisonpage/firehose-ios")!

    var body: some View {
        ZStack {
            Theme.ground.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss)
            panel
                .padding(.horizontal, 24)
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("FIREHOSE")
                .font(Theme.wordmark)
                .kerning(2.4)
                .foregroundStyle(Theme.metaGrey)
                .padding(.bottom, 12)
            Text(Version.version)
                .font(Theme.masthead)
                .kerning(-0.44)
                .foregroundStyle(Theme.ink)
                .padding(.bottom, 4)
            Text("build \(Version.build) · \(Version.date)")
                .font(Theme.meta)
                .foregroundStyle(Theme.metaGrey)
                .padding(.bottom, 20)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                row(label: "Author") {
                    Text("Harrison Page").foregroundStyle(Theme.ink)
                }
                row(label: "Source") {
                    Button {
                        openURL(Self.sourceURL)
                    } label: {
                        Text("github.com/harrisonpage/firehose-ios")
                            .foregroundStyle(Theme.accentText)
                    }
                    .buttonStyle(.plain)
                }
                row(label: "License") {
                    Text("MIT").foregroundStyle(Theme.ink)
                }
                row(label: "Data") {
                    Text("Algolia HN Search API").foregroundStyle(Theme.ink)
                }
            }
            .font(Theme.body13)
            .padding(.bottom, 20)

            Rectangle()
                .fill(Theme.headerRule)
                .frame(height: 2)
            Button(action: dismiss) {
                Text("Close")
                    .font(Theme.meta)
                    .foregroundStyle(Theme.ink)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Theme.ground)
        .border(Theme.ink, width: 2)
    }

    private func row(label: String, @ViewBuilder value: () -> some View) -> some View {
        GridRow(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(Theme.metaGrey)
            value()
        }
    }
}
