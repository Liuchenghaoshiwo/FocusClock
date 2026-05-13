import SwiftData
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage(AppSettingsKeys.showsSeconds) private var showsSeconds = true
    @AppStorage(AppSettingsKeys.defaultCategory) private var defaultCategoryRawValue = FocusCategory.study.rawValue
    @AppStorage(AppSettingsKeys.enablesReminder) private var enablesReminder = false
    @AppStorage(AppSettingsKeys.reminderMinutes) private var reminderMinutes = 25

    @Query(sort: \FocusRecord.startTime, order: .reverse)
    private var records: [FocusRecord]

    @State private var notificationStatusText = "未检查"
    @State private var exportShareItem: FocusExportResult?
    @State private var exportErrorMessage: String?

    private let reminderMinuteOptions = [5, 10, 15, 25, 45, 60]

    var body: some View {
        NavigationStack {
            Form {
                timerPreferencesSection
                notificationSection
                dataSection
                futureExtensionsSection
                aboutSection
            }
            .navigationTitle("设置")
            .onAppear {
                refreshNotificationStatus()
            }
            .sheet(item: $exportShareItem) { result in
                ShareSheet(items: [result.fileURL])
                    .presentationDetents([.medium, .large])
            }
            .alert("导出失败", isPresented: Binding(
                get: { exportErrorMessage != nil },
                set: { if !$0 { exportErrorMessage = nil } }
            )) {
                Button("知道了", role: .cancel) { }
            } message: {
                Text(exportErrorMessage ?? "")
            }
        }
    }

    private var timerPreferencesSection: some View {
        Section("计时偏好") {
            Toggle("显示秒级计时", isOn: $showsSeconds)

            Picker("默认分类", selection: $defaultCategoryRawValue) {
                ForEach(FocusCategory.allCases) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                        .tag(category.rawValue)
                }
            }
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("开启本地提醒", isOn: $enablesReminder)
                .onChange(of: enablesReminder) { _, isOn in
                    if isOn {
                        requestNotificationPermission()
                    } else {
                        FocusNotificationManager.cancelFocusReminder()
                    }
                }

            Picker("提醒时间", selection: $reminderMinutes) {
                ForEach(reminderMinuteOptions, id: \.self) { minutes in
                    Text("\(minutes) 分钟").tag(minutes)
                }
            }
            .disabled(!enablesReminder)

            LabeledContent("通知权限", value: notificationStatusText)

            Button("检查通知权限") {
                refreshNotificationStatus()
            }
        } header: {
            Text("本地提醒")
        } footer: {
            Text("开启后，开始专注时会自动安排一次提醒；提前结束专注会取消未触发的提醒。")
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                exportRecordsAsJSON()
            } label: {
                Label("导出 JSON", systemImage: "square.and.arrow.up")
            }
            .disabled(records.isEmpty)

            LabeledContent("记录数量", value: "\(records.count) 条")
        } header: {
            Text("数据")
        } footer: {
            Text("导出后会打开系统分享面板，可保存到「文件」、AirDrop、邮件或其他 App。")
        }
    }

    private var futureExtensionsSection: some View {
        Section("扩展预留") {
            LabeledContent("Widget", value: "已预留快照协议")
            LabeledContent("iCloud", value: "已预留同步接口")
            LabeledContent("Apple Watch", value: "已预留快速开始接口")
        }
    }

    private var aboutSection: some View {
        Section("关于") {
            NavigationLink("关于专注钟") {
                AboutView()
            }
        }
    }

    private func requestNotificationPermission() {
        FocusNotificationManager.requestAuthorization { granted in
            enablesReminder = granted
            notificationStatusText = granted ? "已允许" : "未允许"
        }
    }

    private func refreshNotificationStatus() {
        FocusNotificationManager.authorizationStatus { status in
            notificationStatusText = description(for: status)
            enablesReminder = status == .authorized || status == .provisional
        }
    }

    private func exportRecordsAsJSON() {
        do {
            exportShareItem = try FocusDataExporter.exportJSON(records: records)
        } catch {
            exportErrorMessage = error.localizedDescription
        }
    }

    private func description(for status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "未请求"
        case .denied:
            return "未允许"
        case .authorized:
            return "已允许"
        case .provisional:
            return "临时允许"
        case .ephemeral:
            return "临时会话"
        @unknown default:
            return "未知"
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: FocusRecord.self, inMemory: true)
}
