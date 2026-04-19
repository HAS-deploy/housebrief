import XCTest
@testable import HouseBrief

final class StateRulesEngineTests: XCTestCase {

    func testLaunchStatesAreEnabled() {
        for code in ["TX","TN","OH","MO","IN"] {
            XCTAssertEqual(StateRulesEngine.rule(for: code).availability, .enabled, "\(code) should be enabled at launch")
            XCTAssertTrue(StateRulesEngine.canSubmit(stateCode: code))
        }
    }

    func testUnknownStateDefaultsBlocked() {
        XCTAssertEqual(StateRulesEngine.rule(for: "CA").availability, .blocked)
        XCTAssertFalse(StateRulesEngine.canSubmit(stateCode: "CA"))
        XCTAssertFalse(StateRulesEngine.canSubmit(stateCode: "NY"))
    }

    func testCaseInsensitive() {
        XCTAssertEqual(StateRulesEngine.rule(for: "tx").availability, .enabled)
    }

    func testUniversalDisclosuresIncluded() {
        let disc = StateRulesEngine.disclosures(for: "TX")
        XCTAssertTrue(disc.contains(where: { $0.contains("principal buyer") }))
        XCTAssertTrue(disc.contains(where: { $0.contains("not a real estate broker") }))
    }
}
