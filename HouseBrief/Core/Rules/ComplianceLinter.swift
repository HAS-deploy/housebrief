import Foundation

/// Compiled-in guard against broker-implication language. Any user-facing
/// string that could ship with the app should be passed through
/// `ComplianceLinter.check(_:)` in tests. The CI test suite asserts this
/// against every copy constant — if a reviewer or marketer slips a forbidden
/// word in, the build fails.
enum ComplianceLinter {

    /// Words we never use. Case-insensitive, whole-word match.
    static let forbiddenWords: [String] = [
        "broker", "brokerage", "realtor", "agent", "agency",
        "licensee", "fiduciary", "representative", "intermediary",
        "listing", "listed", "mls",
        "guaranteed offer", "guaranteed cash", "instant offer", "instant cash",
        "top dollar", "best price",
        "we work for you", "your best interest", "on your behalf",
        "find you a buyer", "market your home", "list your home",
    ]

    struct Finding: Equatable {
        let word: String
        let context: String
    }

    /// Negation prefixes that whitelist an otherwise-forbidden word. A match is
    /// allowed when one of these appears within ~60 chars before the match,
    /// without a sentence terminator in between. This is what lets the
    /// disclosure "We are NOT a broker or agent" pass while "We're a broker"
    /// still fails.
    private static let negationMarkers: [String] = [
        "not a ", "not an ", "not the ",
        "do not ", "don't ", "doesn't ", "never ",
        "we aren't ", "we are not ", "we're not ",
    ]

    /// Returns findings; empty = clean. Case-insensitive, whole-word,
    /// negation-aware.
    static func check(_ text: String) -> [Finding] {
        var findings: [Finding] = []
        let lower = text.lowercased()
        for word in forbiddenWords {
            let w = word.lowercased()
            var searchStart = lower.startIndex
            while let range = lower.range(of: w, range: searchStart..<lower.endIndex) {
                let before = range.lowerBound == lower.startIndex ? " " : String(lower[lower.index(before: range.lowerBound)])
                let after = range.upperBound == lower.endIndex ? " " : String(lower[range.upperBound])
                let isBoundary: (String) -> Bool = { $0.first.map { !$0.isLetter && !$0.isNumber } ?? true }
                if isBoundary(before) && isBoundary(after) {
                    if !isNegated(in: lower, matchStart: range.lowerBound) {
                        findings.append(Finding(word: word, context: text))
                    }
                }
                searchStart = range.upperBound
            }
        }
        return findings
    }

    /// Look back up to 60 chars before the match for a negation marker.
    /// Stop at sentence terminators (`.`, `!`, `?`) — a negation in a prior
    /// sentence does not cover a following claim.
    private static func isNegated(in lower: String, matchStart: String.Index) -> Bool {
        let windowBytes = 60
        let windowStart = lower.index(matchStart, offsetBy: -windowBytes, limitedBy: lower.startIndex) ?? lower.startIndex
        let window = String(lower[windowStart..<matchStart])
        // Truncate at last sentence terminator so negation doesn't leak across sentences.
        let lastTerminator = window.lastIndex(where: { ".!?".contains($0) })
        let scanRange = lastTerminator.map { window.index(after: $0)..<window.endIndex } ?? window.startIndex..<window.endIndex
        let scan = String(window[scanRange])
        return negationMarkers.contains { scan.contains($0) }
    }
}
