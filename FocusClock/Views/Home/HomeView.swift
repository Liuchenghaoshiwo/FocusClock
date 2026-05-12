import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage(AppSettingsKeys.showsSeconds) private var showsSeconds = true
    @AppStorage(AppSettingsKeys.defaultCategory) private var defaultCategoryRawValue = FocusCategory.study.rawValue
    @AppStorage(AppSettingsKeys.enablesReminder) private var enablesReminder = false
    @AppStorage(AppSettingsKeys.reminderMinutes) private var reminderMinutes = 25

    @Query(sort: \FocusRecord.startTime, order: .reverse)
    private var records: [FocusRecord]

    @State private var taskName = ""
    @State private var selectedCategory: FocusCategory = .study
    @State private var activeSession: ActiveFocusSession?
    @State private var now = Date()
    @State private var showsEndConfirmation = false
    @State private var completionSummary: FocusCompletionSummary?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var trimmedTaskName: String {
        taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var defaultCategory: FocusCategory {
        FocusCategory.value(from: defaultCategoryRawValue)
    }

    private var elapsedTime: TimeInterval {
        guard let activeSession else { return 0 }
        return now.timeIntervalSince(activeSession.startTime)
    }

    private var recentTaskShortcuts: [RecentTaskShortcut] {
        var seenTaskNames = Set<String>()

        return records.compactMap { record in
            let name = record.taskName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, !seenTaskNames.contains(name) else { return nil }
            seenTaskNames.insert(name)

            return RecentTaskShortcut(
                taskName: name,
                category: FocusCategory.value(from: record.category)
            )
        }
        .prefix(6)
        .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let activeSession {
                        activeFocusCard(activeSession)
                    } else {
                        startFocusCard
                        recentTasksCard
                        taskTemplatesCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("专注钟")
            .onAppear {
                selectedCategory = defaultCategory
            }
            .onReceive(timer) { date in
                now = date
            }
            .confirmationDialog("结束本次专注？", isPresented: $showsEndConfirmation, titleVisibility: .visible) {
                Button("结束并保存", role: .destructive) {
                    finishFocus()
                }

                Button("继续专注", role: .cancel) { }
            } message: {
                Text("确认后会保存本次专注记录。")
            }
            .alert(item: $completionSummary) { summary in
                Alert(
                    title: Text("专注完成"),
                    message: Text("本次专注 \(DurationFormatter.readable(summary.duration))"),
                    dismissButton: .default(Text("知道了"))
                )
            }
        }
    }

    private var startFocusCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("当前任务")
                    .font(.headline)

                TextField("输入要专注的事情", text: $taskName)
                    .textInputAutocapitalization(.never)
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("留空将使用“未命名任务”。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("分类")
                    .font(.headline)

                Picker("分类", selection: $selectedCategory) {
                    ForEach(FocusCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button {
                startFocus()
            } label: {
                Label("开始专注", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var recentTasksCard: some View {
        SectionCard {
            Text("最近使用任务")
                .font(.headline)

            if recentTaskShortcuts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("暂无最近任务", systemImage: "clock.arrow.circlepath")
                        .font(.subheadline.weight(.medium))

                    Text("完成一次专注后，会在这里出现快捷入口。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(recentTaskShortcuts) { shortcut in
                            shortcutButton(title: shortcut.taskName, category: shortcut.category)
                        }
                    }
                }
            }
        }
    }

    private var taskTemplatesCard: some View {
        SectionCard {
            Text("常用任务模板")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FocusTaskTemplate.defaults) { template in
                    shortcutButton(title: template.title, category: template.category)
                }
            }
        }
    }

    private func activeFocusCard(_ session: ActiveFocusSession) -> some View {
        SectionCard {
            VStack(spacing: 10) {
                Text("正在专注")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(session.taskName)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Label(session.category.rawValue, systemImage: session.category.iconName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(session.category.tintColor)
            }
            .frame(maxWidth: .infinity)

            Text(DurationFormatter.clock(elapsedTime, showsSeconds: showsSeconds))
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            if enablesReminder {
                Label("\(reminderMinutes) 分钟后提醒", systemImage: "bell")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            Button(role: .destructive) {
                showsEndConfirmation = true
            } label: {
                Label("结束专注", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func shortcutButton(title: String, category: FocusCategory) -> some View {
        Button {
            taskName = title
            selectedCategory = category
        } label: {
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .foregroundStyle(category.tintColor)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func startFocus() {
        let sessionTaskName = trimmedTaskName.isEmpty ? "未命名任务" : trimmedTaskName
        activeSession = ActiveFocusSession(
            taskName: sessionTaskName,
            category: selectedCategory,
            startTime: Date()
        )
        now = Date()

        if enablesReminder {
            FocusNotificationManager.scheduleFocusReminder(
                taskName: sessionTaskName,
                minutes: reminderMinutes
            )
        }
    }

    private func finishFocus() {
        guard let activeSession else { return }

        let endTime = Date()
        let record = FocusRecord(
            taskName: activeSession.taskName,
            category: activeSession.category,
            startTime: activeSession.startTime,
            endTime: endTime
        )

        modelContext.insert(record)
        try? modelContext.save()
        FocusNotificationManager.cancelFocusReminder()

        self.activeSession = nil
        taskName = ""
        selectedCategory = defaultCategory
        completionSummary = FocusCompletionSummary(duration: record.duration)
    }
}

private struct ActiveFocusSession {
    let taskName: String
    let category: FocusCategory
    let startTime: Date
}

private struct RecentTaskShortcut: Identifiable {
    let taskName: String
    let category: FocusCategory

    var id: String {
        "\(taskName)-\(category.rawValue)"
    }
}

private struct FocusCompletionSummary: Identifiable {
    let id = UUID()
    let duration: TimeInterval
}

#Preview {
    HomeView()
        .modelContainer(for: FocusRecord.self, inMemory: true)
}
