import Foundation
import SwiftData

@Model
final class MessageThread {
    @Attribute(.unique) var id: UUID
    var submissionId: UUID
    var subject: String
    var lastActivityAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MessageItem.thread)
    var items: [MessageItem] = []

    init(id: UUID = UUID(), submissionId: UUID, subject: String) {
        self.id = id
        self.submissionId = submissionId
        self.subject = subject
        self.lastActivityAt = .now
    }
}

enum MessageAuthor: String, Codable {
    case user
    case acquisitions
}

@Model
final class MessageItem {
    @Attribute(.unique) var id: UUID
    var sentAt: Date
    var authorRaw: String
    var body: String
    var thread: MessageThread?

    var author: MessageAuthor {
        get { MessageAuthor(rawValue: authorRaw) ?? .user }
        set { authorRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), author: MessageAuthor, body: String) {
        self.id = id
        self.sentAt = .now
        self.authorRaw = author.rawValue
        self.body = body
    }
}
