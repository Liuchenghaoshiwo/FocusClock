import Foundation
import SwiftData

@Model
final class FocusRecord {
    @Attribute(.unique) var id: UUID
    var taskName: String
    var category: String
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var createdAt: Date

    init(
        id: UUID = UUID(),
        taskName: String,
        category: FocusCategory,
        startTime: Date,
        endTime: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.taskName = taskName
        self.category = category.rawValue
        self.startTime = startTime
        self.endTime = endTime
        self.duration = max(0, endTime.timeIntervalSince(startTime))
        self.createdAt = createdAt
    }
}
