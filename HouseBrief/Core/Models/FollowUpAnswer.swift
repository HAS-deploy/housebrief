import Foundation
import SwiftData

/// A single user response to a follow-up question sent by the ops team.
/// Questions themselves are driven by the rules engine; this is just the answer record.
@Model
final class FollowUpAnswer {
    @Attribute(.unique) var id: UUID
    var questionKey: String
    var prompt: String
    var answer: String
    var answeredAt: Date
    var submission: PropertySubmission?

    init(id: UUID = UUID(), questionKey: String, prompt: String, answer: String) {
        self.id = id
        self.questionKey = questionKey
        self.prompt = prompt
        self.answer = answer
        self.answeredAt = .now
    }
}
