import SwiftData
import SwiftUI

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let record: FocusRecord

    @State private var taskName: String
    @State private var selectedCategory: FocusCategory

    init(record: FocusRecord) {
        self.record = record
        _taskName = State(initialValue: record.taskName)
        _selectedCategory = State(initialValue: FocusCategory.value(from: record.category))
    }

    var body: some View {
        Form {
            Section("编辑") {
                TextField("任务名称", text: $taskName)
                    .textInputAutocapitalization(.never)

                Picker("分类", selection: $selectedCategory) {
                    ForEach(FocusCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .tag(category)
                    }
                }
            }

            Section("时间") {
                LabeledContent("开始时间", value: record.startTime.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("结束时间", value: record.endTime.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("总时长", value: DurationFormatter.readable(record.duration))
            }
        }
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    saveChanges()
                }
            }
        }
    }

    private func saveChanges() {
        let trimmedName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        record.taskName = trimmedName.isEmpty ? "未命名任务" : trimmedName
        record.category = selectedCategory.rawValue
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(
            record: FocusRecord(
                taskName: "阅读",
                category: .study,
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date()
            )
        )
    }
    .modelContainer(for: FocusRecord.self, inMemory: true)
}
