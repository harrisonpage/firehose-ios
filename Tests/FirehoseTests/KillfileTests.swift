import XCTest
@testable import Firehose

/// The killfile is the one place where bugs are silent — a bad rule quietly
/// eats stories the user never learns existed.
final class KillfileTests: XCTestCase {

    // MARK: Phrase matching — token boundaries, not substrings

    func testMultiTokenPhraseMatchesConsecutiveRun() {
        XCTAssertTrue(Killfile.phraseMatches("machine learning", title: "New machine learning benchmark"))
    }

    func testMultiTokenPhraseRequiresConsecutiveTokens() {
        XCTAssertFalse(Killfile.phraseMatches("machine learning", title: "learning about machine tools"))
        XCTAssertFalse(Killfile.phraseMatches("machine learning", title: "machine deep learning"))
    }

    func testSingleTokenPhraseDoesNotMatchSubstrings() {
        XCTAssertTrue(Killfile.phraseMatches("AI", title: "AI startup raises"))
        XCTAssertFalse(Killfile.phraseMatches("AI", title: "Ukraine ceasefire talks resume"))
        XCTAssertFalse(Killfile.phraseMatches("AI", title: "He said it plainly"))
        XCTAssertFalse(Killfile.phraseMatches("AI", title: "How to explain chain reactions"))
    }

    func testPhraseMatchingIsCaseInsensitive() {
        XCTAssertTrue(Killfile.phraseMatches("BITCOIN", title: "bitcoin hits new low"))
        XCTAssertTrue(Killfile.phraseMatches("bitcoin", title: "BITCOIN HITS NEW LOW"))
    }

    func testPunctuationActsAsTokenBoundary() {
        XCTAssertTrue(Killfile.phraseMatches("AI", title: "AI: the next platform"))
        XCTAssertTrue(Killfile.phraseMatches("AI", title: "The problem with (AI) agents"))
    }

    func testRuleWithPunctuationTokenizesLikeTitles() {
        XCTAssertTrue(Killfile.phraseMatches("node.js", title: "Node.js 22 released"))
        XCTAssertTrue(Killfile.phraseMatches("node.js", title: "Why node js still matters"))
    }

    func testPhraseAtTitleEdges() {
        XCTAssertTrue(Killfile.phraseMatches("show hn", title: "Show HN: a tiny thing"))
        XCTAssertTrue(Killfile.phraseMatches("rust", title: "Rewritten in Rust"))
    }

    func testEmptyAndDegenerateInputs() {
        XCTAssertFalse(Killfile.phraseMatches("", title: "Anything at all"))
        XCTAssertFalse(Killfile.phraseMatches("...", title: "Anything at all"))
        XCTAssertFalse(Killfile.phraseMatches("rust", title: ""))
        XCTAssertFalse(Killfile.phraseMatches("one two three", title: "one two"))
    }

    // MARK: Domain matching — suffix on label boundaries

    func testDomainMatchesExactHost() {
        XCTAssertTrue(Killfile.domainMatches("wikipedia.org", host: "wikipedia.org"))
    }

    func testDomainMatchesSubdomains() {
        XCTAssertTrue(Killfile.domainMatches("wikipedia.org", host: "en.wikipedia.org"))
        XCTAssertTrue(Killfile.domainMatches("wikipedia.org", host: "en.m.wikipedia.org"))
    }

    func testDomainDoesNotMatchLabelSubstrings() {
        XCTAssertFalse(Killfile.domainMatches("wikipedia.org", host: "notwikipedia.org"))
    }

    func testDomainSuffixMustAlignToLabelBoundaries() {
        XCTAssertFalse(Killfile.domainMatches("wikipedia.org", host: "wikipedia.org.evil.com"))
        XCTAssertFalse(Killfile.domainMatches("wikipedia.org", host: "org"))
    }

    func testBareTLDRuleMatchesBroadly() {
        // A rule of "com" matching nearly everything is the developer's
        // problem, not a bug to guard against.
        XCTAssertTrue(Killfile.domainMatches("com", host: "example.com"))
        XCTAssertFalse(Killfile.domainMatches("com", host: "example.org"))
    }

    func testDomainMatchingIsCaseInsensitive() {
        XCTAssertTrue(Killfile.domainMatches("Wikipedia.ORG", host: "en.wikipedia.org"))
    }

    func testEmptyDomainRuleMatchesNothing() {
        XCTAssertFalse(Killfile.domainMatches("", host: "example.com"))
    }

    // MARK: Rule dispatch

    func testKillsChecksBothRuleTypes() {
        // The seeded rule: wikipedia.org submissions die at ingest.
        XCTAssertTrue(Killfile.kills(title: "History of the semicolon", host: "en.wikipedia.org"))
        XCTAssertFalse(Killfile.kills(title: "History of the semicolon", host: "example.com"))
    }

    // MARK: Tokenizer

    func testTokenizerSplitsOnNonAlphanumerics() {
        XCTAssertEqual(Killfile.tokens("Node.js 22 — what's new?"), ["node", "js", "22", "what", "s", "new"])
        XCTAssertEqual(Killfile.tokens("  "), [])
    }
}
