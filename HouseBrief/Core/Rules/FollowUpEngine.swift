import Foundation

/// v1 rules engine — declarative + deterministic. No LLM, no network calls,
/// no surprises. Input: a PropertySubmission's current state. Output: the
/// single next-best question to ask, plus any flags + score updates.
///
/// Runs client-side for pre-submit coverage hints and server-side for the
/// actual production pipeline. Server is authoritative; client version exists
/// so the seller sees meaningful follow-ups in a mock/offline mode.
struct FollowUpDecision {
    struct NextQuestion {
        let key: String
        let prompt: String
    }

    let nextQuestion: NextQuestion?
    let flags: [String]
    let motivationDelta: Int
    let complexityDelta: Int
    let urgencyDelta: Int
    let confidenceDelta: Int
    let routeToHuman: Bool
}

enum FollowUpEngine {

    static func evaluate(submission: PropertySubmission, answered: Set<String>) -> FollowUpDecision {
        var flags: [String] = []
        var motivation = 0, complexity = 0, urgency = 0, confidence = 0
        var routeToHuman = false

        let occupancy = Occupancy(rawValue: submission.occupancyRaw) ?? .unknown
        let timeline = Timeline(rawValue: submission.timelineRaw) ?? .flexible

        // --- signals ---
        if occupancy == .tenantOccupied {
            complexity += 2
            if !answered.contains("lease_end_date") && submission.leaseEndDate == nil {
                return FollowUpDecision(
                    nextQuestion: .init(key: "lease_end_date",
                                        prompt: "When does the current lease end? An approximate date is fine."),
                    flags: flags, motivationDelta: 0, complexityDelta: complexity,
                    urgencyDelta: 0, confidenceDelta: 0, routeToHuman: false)
            }
        }

        if submission.flagInherited {
            complexity += 2
            flags.append("inherited_title_check")
            if !answered.contains("title_clear") {
                return FollowUpDecision(
                    nextQuestion: .init(key: "title_clear",
                                        prompt: "Is the title currently in your name, or is it still being transferred through probate or estate?"),
                    flags: flags, motivationDelta: 0, complexityDelta: complexity,
                    urgencyDelta: 0, confidenceDelta: 0, routeToHuman: false)
            }
        }

        if submission.flagTaxOrLien {
            complexity += 1
            flags.append("title_compliance")
            if !answered.contains("tax_lien_detail") {
                return FollowUpDecision(
                    nextQuestion: .init(key: "tax_lien_detail",
                                        prompt: "Could you share roughly how much is owed on taxes or liens, and whether you've received any formal notices?"),
                    flags: flags, motivationDelta: 0, complexityDelta: complexity,
                    urgencyDelta: 0, confidenceDelta: 0, routeToHuman: false)
            }
        }

        if submission.flagBehindOnPayments {
            urgency += 1
            if !answered.contains("mortgage_balance") {
                return FollowUpDecision(
                    nextQuestion: .init(key: "mortgage_balance",
                                        prompt: "Roughly what's the remaining mortgage balance? A ballpark is fine."),
                    flags: flags, motivationDelta: 1, complexityDelta: 0,
                    urgencyDelta: urgency, confidenceDelta: 0, routeToHuman: false)
            }
        }

        if timeline == .asap || timeline == .within30 {
            urgency += 2
            motivation += 1
        }

        if submission.conditionScore <= 2 && occupancy == .vacant && urgency >= 2 {
            // high-priority acquisition candidate
            motivation += 2
            confidence += 1
            flags.append("priority_queue_high")
        }

        // --- still missing basic info? ---
        if submission.beds == nil && !answered.contains("beds_baths") {
            return FollowUpDecision(
                nextQuestion: .init(key: "beds_baths",
                                    prompt: "How many bedrooms and bathrooms does the property have?"),
                flags: flags, motivationDelta: motivation, complexityDelta: complexity,
                urgencyDelta: urgency, confidenceDelta: confidence, routeToHuman: false)
        }

        // (Photos removed from v1 — reintroduce this question when photo
        // upload ships in v1.1.)

        // --- state requires human legal review ---
        let rule = StateRulesEngine.rule(for: submission.stateCode)
        if rule.manualLegalReviewRequired { routeToHuman = true; flags.append("state_legal_review") }

        // Nothing to ask — all signals collected
        return FollowUpDecision(
            nextQuestion: nil,
            flags: flags,
            motivationDelta: motivation,
            complexityDelta: complexity,
            urgencyDelta: urgency,
            confidenceDelta: confidence + 1, // we have everything we need
            routeToHuman: routeToHuman
        )
    }
}
