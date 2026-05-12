import SwiftData
import SwiftUI

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FocusRecord.startTime, order: .reverse)
    private var records: [FocusRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    recordsEmptyView
                } else {
                    List {
                        ForEach(records) { record in
                            NavigationLink {
                                RecordDetailView(record: record)
                            } label: {
                                FocusRecordRow(record: record)
                            }
                        }
                        .onDelete(perform: deleteRecords)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("记录")
            .toolbar {
                if !records.isEmpty {
                    EditButton()
                }
            }
        }
    }

    private var recordsEmptyView: some View {
        ContentUnavailableView(
            "暂无专注记录",
            systemImage: "clock.badge.questionmark",
            description: Text("回到首页开始一次专注，结束后记录会自动保存。")
        )
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }

        try? modelContext.save()
    }
}

private struct FocusRecordRow: View {
    let record: FocusRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(record.taskName)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                Text(record.category)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Label("开始：\(record.startTime.formatted(date: .abbreviated, time: .shortened))", systemImage: "play.circle")
                Label("结束：\(record.endTime.formatted(date: .abbreviated, time: .shortened))", systemImage: "stop.circle")
                Label("时长：\(DurationFormatter.readable(record.duration))", systemImage: "timer")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RecordsView()
        .modelContainer(for: FocusRecord.self, inMemory: true)
}
