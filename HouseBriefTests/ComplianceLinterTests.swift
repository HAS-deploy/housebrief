import XCTest
@testable import HouseBrief

/// These tests are the CI guardrail for compliance language. Any change that
/// introduces a forbidden word (broker / realtor / agent / guaranteed /
/// etc.) in shipped copy fails the build.
final class ComplianceLinterTests: XCTestCase {

    func testForbiddenWordsAreCaught() {
        let findings = ComplianceLinter.check("We are a broker who will find you a buyer.")
        XCTAssertTrue(findings.contains(where: { $0.word == "broker" }))
        XCTAssertTrue(findings.contains(where: { $0.word == "find you a buyer" }))
    }

    func testNegationIsNotFlagged() {
        // Our disclosure language must pass the linter.
        XCTAssertTrue(ComplianceLinter.check("We are not a real estate broker, agent, or representative.").isEmpty)
        XCTAssertTrue(ComplianceLinter.check("HouseBrief is not a broker or agent.").isEmpty)
        XCTAssertTrue(ComplianceLinter.check("We do not find buyers or market your home.").isEmpty)
        XCTAssertTrue(ComplianceLinter.check("We don't market your home or list your home.").isEmpty)
    }

    func testNegationDoesNotLeakAcrossSentences() {
        // "not" in a prior sentence should NOT cover a later positive claim.
        let findings = ComplianceLinter.check("We are not a bank. We are a broker.")
        XCTAssertTrue(findings.contains(where: { $0.word == "broker" }))
    }

    func testCleanCopyPasses() {
        let findings = ComplianceLinter.check("We are a private home-buying company. We review submissions and reach out if we're interested.")
        XCTAssertTrue(findings.isEmpty, "Unexpected findings: \(findings)")
    }

    func testWholeWordBoundaries() {
        // "agentic" should not match "agent"
        let findings = ComplianceLinter.check("This uses agentic AI for internal ops.")
        XCTAssertTrue(findings.isEmpty)
    }

    func testAllShippedCopyIsClean() {
        let allCopy: [String] = [
            Copy.onboardingIntroTitle, Copy.onboardingIntroBody,
            Copy.onboardingPrincipalTitle, Copy.onboardingPrincipalBody,
            Copy.onboardingUsOnlyTitle, Copy.onboardingUsOnlyBody,
            Copy.submitHeroTitle, Copy.submitHeroBody,
            Copy.universalDisclosure,
            Copy.statusSubmittedBody, Copy.statusReviewCompleteBody, Copy.statusNotAFitBody,
            Copy.pushFollowUp, Copy.pushStatusChanged,
        ] + Copy.acknowledgementItems
            + StateRulesEngine.universalDisclosures

        var violations: [String] = []
        for text in allCopy {
            let findings = ComplianceLinter.check(text)
            if !findings.isEmpty {
                violations.append("\(findings.map(\.word).joined(separator: ", ")) → \"\(text)\"")
            }
        }
        XCTAssertTrue(violations.isEmpty,
                      "Compliance violations in shipped copy:\n" + violations.joined(separator: "\n"))
    }
}
