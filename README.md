# Firehose

Blog post: [Hacker News Firehose for iOS](https://blog.harrison.page/firehose)

## Saturday Morning Project

> Ask Claude Fable to create a custom app for browsing Hacker News by `/new`

Claude was able to one-shot this given a spec and screenshots.

Source here: [github.com/harrisonpage/firehose-ios](https://github.com/harrisonpage/firehose-ios)

Reading model is simple:

* Open the app
* Scroll from newest to oldest
* Stop when bored

Content is ephemeral. There's value in the unfiltered firehose of submissions, most are low quality but occasional gems surface.

The app talks to one external service: the **Algolia HN Search API** (`hn.algolia.com/api/v1`)

## Platform

- SwiftUI, Swift concurrency (`async`/`await`), `@Observable`
- iPhone only, portrait only
- Frameworks: `SwiftUI`, `LinkPresentation`, `SafariServices`

## Features

* Drop any headline where `url` is nil effectively removing Ask HN and text-only posts
* Killfile support by word or hostname (currently hardcoded)
* Link previews formed with available Open Graph metadata on long-press
* Menu items: Add to Reading List, Share, Open in Safari

## Building

Open `Firehose.xcodeproj` in Xcode, or:

```
./build.sh              # iOS simulator
./build.sh device       # generic iOS device build
```

Tests (killfile matching logic):

```
xcodebuild -project Firehose.xcodeproj -scheme Firehose \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Killfile

There is no filter UI. Rules live in
`Sources/Firehose/Services/Killfile.swift` as a compile-time constant — edit
and rebuild. Phrase rules match on token boundaries (an `AI` rule will not
kill "Ukraine"); domain rules match label suffixes (`wikipedia.org` kills
`en.wikipedia.org` but not `notwikipedia.org`).

## License

MIT. Bundled [Archivo](https://fonts.google.com/specimen/Archivo) is under the
SIL Open Font License.

## Thank Yous

* [App Icon Generators](www.appicongenerators.com)
* [Hackernews SVG Vector](https://www.svgrepo.com/svg/349397/hackernews) from the [Tiny App Icons Collection](https://www.svgrepo.com/collection/tiny-app-icons/)
* Data comes from the [Algolia HN Search API](https://hn.algolia.com/api/v1)
