import Foundation

enum StateAvailability: String, Codable {
    case enabled              // seller can submit freely
    case restricted           // seller can submit but extra disclosures required
    case internalReviewOnly   // accept intake, do not proceed until compliance signs off
    case blocked              // do not accept submissions at all
}

struct StateRule: Codable, Hashable {
    let code: String
    let name: String
    let availability: StateAvailability
    let assignmentSensitivity: Sensitivity
    let buyerMarketingSensitivity: Sensitivity
    let manualLegalReviewRequired: Bool
    let requiredDisclosures: [String]
    let specialWarnings: [String]

    enum Sensitivity: String, Codable { case low, medium, high }
}

/// Seed set for v1 launch. Compliance can change these via the admin dashboard
/// later — this enum is a fallback when the server copy isn't reachable yet.
enum StateRulesEngine {

    static func rule(for stateCode: String) -> StateRule {
        let code = stateCode.uppercased()
        return seeded[code] ?? defaultBlocked(for: code)
    }

    static func canSubmit(stateCode: String) -> Bool {
        switch rule(for: stateCode).availability {
        case .blocked: return false
        default: return true
        }
    }

    static func disclosures(for stateCode: String) -> [String] {
        let r = rule(for: stateCode)
        var out = universalDisclosures
        out.append(contentsOf: r.requiredDisclosures)
        return out
    }

    static let universalDisclosures: [String] = [
        "We are a private home-buying company (principal buyer). We are not a real estate broker, agent, or representative.",
        "Submitting does not guarantee an offer.",
        "Any offer we make is from our affiliated acquisition entity as a direct buyer.",
        "If we enter a contract, we may close ourselves or assign our contract rights where lawful.",
        "Availability depends on your property, market conditions, title review, and state eligibility.",
    ]

    private static func defaultBlocked(for code: String) -> StateRule {
        StateRule(
            code: code,
            name: usStateNames[code] ?? code,
            availability: .blocked,
            assignmentSensitivity: .high,
            buyerMarketingSensitivity: .high,
            manualLegalReviewRequired: true,
            requiredDisclosures: [],
            specialWarnings: ["We're not currently buying in this state. Please check back later."]
        )
    }

    // Phase-1 launch set (compliance-confirmable list). All others default to `.blocked`.
    private static let seeded: [String: StateRule] = [
        "TX": StateRule(code: "TX", name: "Texas", availability: .enabled,
                        assignmentSensitivity: .low, buyerMarketingSensitivity: .low,
                        manualLegalReviewRequired: false, requiredDisclosures: [], specialWarnings: []),
        "TN": StateRule(code: "TN", name: "Tennessee", availability: .enabled,
                        assignmentSensitivity: .low, buyerMarketingSensitivity: .low,
                        manualLegalReviewRequired: false, requiredDisclosures: [], specialWarnings: []),
        "OH": StateRule(code: "OH", name: "Ohio", availability: .enabled,
                        assignmentSensitivity: .medium, buyerMarketingSensitivity: .low,
                        manualLegalReviewRequired: false, requiredDisclosures: [], specialWarnings: []),
        "MO": StateRule(code: "MO", name: "Missouri", availability: .enabled,
                        assignmentSensitivity: .low, buyerMarketingSensitivity: .low,
                        manualLegalReviewRequired: false, requiredDisclosures: [], specialWarnings: []),
        "IN": StateRule(code: "IN", name: "Indiana", availability: .enabled,
                        assignmentSensitivity: .low, buyerMarketingSensitivity: .low,
                        manualLegalReviewRequired: false, requiredDisclosures: [], specialWarnings: []),
    ]

    // Full U.S. state name table for display
    static let usStateNames: [String: String] = [
        "AL":"Alabama","AK":"Alaska","AZ":"Arizona","AR":"Arkansas","CA":"California",
        "CO":"Colorado","CT":"Connecticut","DE":"Delaware","FL":"Florida","GA":"Georgia",
        "HI":"Hawaii","ID":"Idaho","IL":"Illinois","IN":"Indiana","IA":"Iowa",
        "KS":"Kansas","KY":"Kentucky","LA":"Louisiana","ME":"Maine","MD":"Maryland",
        "MA":"Massachusetts","MI":"Michigan","MN":"Minnesota","MS":"Mississippi","MO":"Missouri",
        "MT":"Montana","NE":"Nebraska","NV":"Nevada","NH":"New Hampshire","NJ":"New Jersey",
        "NM":"New Mexico","NY":"New York","NC":"North Carolina","ND":"North Dakota","OH":"Ohio",
        "OK":"Oklahoma","OR":"Oregon","PA":"Pennsylvania","RI":"Rhode Island","SC":"South Carolina",
        "SD":"South Dakota","TN":"Tennessee","TX":"Texas","UT":"Utah","VT":"Vermont",
        "VA":"Virginia","WA":"Washington","WV":"West Virginia","WI":"Wisconsin","WY":"Wyoming",
        "DC":"District of Columbia",
    ]
}
