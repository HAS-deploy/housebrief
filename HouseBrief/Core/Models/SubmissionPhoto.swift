import Foundation
import SwiftData

@Model
final class SubmissionPhoto {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var order: Int
    @Attribute(.externalStorage) var imageData: Data
    var submission: PropertySubmission?

    init(id: UUID = UUID(), imageData: Data, order: Int = 0) {
        self.id = id
        self.createdAt = .now
        self.imageData = imageData
        self.order = order
    }
}
