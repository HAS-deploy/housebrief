import XCTest
@testable import HouseBrief

final class FollowUpEngineTests: XCTestCase {

    private func makeSubmission() -> PropertySubmission {
        let s = PropertySubmission()
        s.stateCode = "TX"
        s.addressLine1 = "100 Main St"
        s.city = "Austin"
        s.zip = "78701"
        return s
    }

    func testTenantOccupiedAsksLeaseEndDate() {
        let s = makeSubmission()
        s.occupancyRaw = Occupancy.tenantOccupied.rawValue
        let d = FollowUpEngine.evaluate(submission: s, answered: [])
        XCTAssertEqual(d.nextQuestion?.key, "lease_end_date")
        XCTAssertTrue(d.complexityDelta >= 2)
    }

    func testInheritedPropertyAsksTitleClarity() {
        let s = makeSubmission()
        s.flagInherited = true
        let d = FollowUpEngine.evaluate(submission: s, answered: [])
        XCTAssertEqual(d.nextQuestion?.key, "title_clear")
        XCTAssertTrue(d.flags.contains("inherited_title_check"))
    }

    func testUrgentVacantPoorConditionFlagsHighPriority() {
        let s = makeSubmission()
        s.occupancyRaw = Occupancy.vacant.rawValue
        s.conditionScore = 1
        s.timelineRaw = Timeline.asap.rawValue
        s.beds = 3
        s.baths = 2
        let d = FollowUpEngine.evaluate(submission: s, answered: ["photos_uploaded"])
        XCTAssertTrue(d.flags.contains("priority_queue_high"))
        XCTAssertTrue(d.urgencyDelta >= 2)
    }

    func testClosedPathEventuallyRunsOut() {
        let s = makeSubmission()
        s.beds = 3
        s.baths = 2
        let d = FollowUpEngine.evaluate(submission: s, answered: ["photos_uploaded"])
        XCTAssertNil(d.nextQuestion, "All signals satisfied should return nil")
    }
}
