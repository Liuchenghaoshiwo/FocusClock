import Foundation

struct FocusExportResult: Identifiable {
    let id = UUID()
    let fileURL: URL
    let recordCount: Int
}

struct ExportedFocusRecord: Codable {
    let id: UUID
    let taskName: String
    let category: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let createdAt: Date
}

enum FocusDataExporter {
    static func exportJSON(records: [FocusRecord]) throws -> FocusExportResult {
        let exportedRecords = records.map {
            ExportedFocusRecord(
                id: $0.id,
                taskName: $0.taskName,
                category: $0.category,
                startTime: $0.startTime,
                endTime: $0.endTime,
                duration: $0.duration,
                createdAt: $0.createdAt
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(exportedRecords)
        let fileURL = documentsDirectory()
            .appendingPathComponent("focus-records-\(timestamp()).json")

        try data.write(to: fileURL, options: [.atomic])
        return FocusExportResult(fileURL: fileURL, recordCount: exportedRecords.count)
    }

    private static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }
}
