import Foundation
import SwiftData

enum SubmissionStatus: String, Codable, CaseIterable {
    case draft
    case submitted
    case underReview = "under_review"
    case needMoreInfo = "need_more_info"
    case notAFit = "not_a_fit"
    case reviewComplete = "review_complete"
    case contactRequested = "contact_requested"

    var displayText: String {
        switch self {
        case .draft: return "Draft"
        case .submitted: return "Submitted"
        case .underReview: return "Under Review"
        case .needMoreInfo: return "Need More Info"
        case .notAFit: return "Not a Fit Right Now"
        case .reviewComplete: return "Review Complete"
        case .contactRequested: return "Contact Requested"
        }
    }
}

enum PropertyType: String, Codable, CaseIterable, Identifiable {
    case singleFamily = "single_family"
    case condo, townhouse, multiFamily = "multi_family"
    case manufactured, land, other
    var id: String { rawValue }
    var displayText: String {
        switch self {
        case .singleFamily: return "Single-family house"
        case .condo: return "Condo"
        case .townhouse: return "Townhouse"
        case .multiFamily: return "Multi-family (duplex, triplex, etc.)"
        case .manufactured: return "Manufactured / mobile home"
        case .land: return "Vacant land"
        case .other: return "Other"
        }
    }
}

enum Occupancy: String, Codable, CaseIterable, Identifiable {
    case vacant, ownerOccupied = "owner_occupied", tenantOccupied = "tenant_occupied", unknown
    var id: String { rawValue }
    var displayText: String {
        switch self {
        case .vacant: return "Vacant"
        case .ownerOccupied: return "I live there"
        case .tenantOccupied: return "Tenant-occupied"
        case .unknown: return "Prefer not to say"
        }
    }
}

enum Timeline: String, Codable, CaseIterable, Identifiable {
    case asap, within30, within90, within180, flexible, justBrowsing = "just_browsing"
    var id: String { rawValue }
    var displayText: String {
        switch self {
        case .asap: return "As soon as possible"
        case .within30: return "Within 30 days"
        case .within90: return "Within 90 days"
        case .within180: return "Within 6 months"
        case .flexible: return "Flexible"
        case .justBrowsing: return "Just exploring"
        }
    }
}

@Model
final class PropertySubmission {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var statusRaw: String
    var status: SubmissionStatus {
        get { SubmissionStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    // Address
    var addressLine1: String
    var addressLine2: String
    var city: String
    var stateCode: String
    var zip: String

    // Basics
    var propertyTypeRaw: String
    var yearBuilt: Int?
    var beds: Int?
    var baths: Double?
    var sqftEst: Int?

    // Condition + situation
    var conditionScore: Int // 1 poor – 5 excellent
    var repairNotes: String
    var occupancyRaw: String
    var leaseEndDate: Date?

    // Situation flags
    var flagInherited: Bool = false
    var flagProbate: Bool = false
    var flagBehindOnPayments: Bool = false
    var flagTaxOrLien: Bool = false
    var flagCodeViolation: Bool = false

    // Motivation
    var timelineRaw: String
    var askingAmountCents: Int?

    // Scores (set by follow-up engine)
    var motivationScore: Int = 0
    var complexityScore: Int = 0
    var urgencyScore: Int = 0
    var confidenceScore: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \SubmissionPhoto.submission)
    var photos: [SubmissionPhoto] = []
    @Relationship(deleteRule: .cascade, inverse: \FollowUpAnswer.submission)
    var followUpAnswers: [FollowUpAnswer] = []

    init(id: UUID = UUID(), createdAt: Date = .now) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.statusRaw = SubmissionStatus.draft.rawValue
        self.addressLine1 = ""
        self.addressLine2 = ""
        self.city = ""
        self.stateCode = ""
        self.zip = ""
        self.propertyTypeRaw = PropertyType.singleFamily.rawValue
        self.conditionScore = 3
        self.repairNotes = ""
        self.occupancyRaw = Occupancy.unknown.rawValue
        self.timelineRaw = Timeline.flexible.rawValue
    }

    var displayAddress: String {
        let line1 = addressLine1.isEmpty ? "(no address)" : addressLine1
        let locality = [city, stateCode].filter { !$0.isEmpty }.joined(separator: ", ")
        return locality.isEmpty ? line1 : "\(line1), \(locality) \(zip)"
    }
}
