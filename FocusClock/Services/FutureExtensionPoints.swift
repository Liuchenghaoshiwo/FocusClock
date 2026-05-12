import Foundation

struct FocusSessionDraft {
    let taskName: String
    let category: FocusCategory
}

struct FocusWidgetSnapshot {
    let todayDuration: TimeInterval
    let currentTaskName: String?
    let updatedAt: Date
}

protocol FocusWidgetSnapshotProviding {
    func makeWidgetSnapshot(records: [FocusRecord], activeTaskName: String?) -> FocusWidgetSnapshot
}

protocol FocusCloudSyncProviding {
    func prepareForCloudSync(records: [FocusRecord]) async throws
}

protocol WatchFocusCommandHandling {
    func startFocus(from draft: FocusSessionDraft)
    func stopCurrentFocus()
}

enum FutureExtensionNotes {
    static let widget = "Widget 可复用 FocusWidgetSnapshotProviding，从 SwiftData 读取今日统计并写入 App Group。"
    static let iCloud = "iCloud 同步可在 SwiftData ModelContainer 配置 CloudKit container 后接入。"
    static let watch = "Apple Watch 可通过 WatchConnectivity 发送 FocusSessionDraft，主 App 复用开始专注流程。"
}
