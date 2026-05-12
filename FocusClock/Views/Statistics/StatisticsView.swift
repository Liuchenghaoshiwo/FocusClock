import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query private var records: [FocusRecord]

    @State private var selectedRange: StatisticsRange = .week
    @State private var customStartDate = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
    @State private var customEndDate = Date()

    private var selectedInterval: DateInterval {
        FocusStatistics.dateInterval(
            for: selectedRange,
            customStartDate: customStartDate,
            customEndDate: customEndDate
        )
    }

    private var filteredRecords: [FocusRecord] {
        FocusStatistics.records(records, in: selectedInterval)
    }

    private var summary: FocusStatisticsSummary {
        FocusStatistics.summary(
            records: records,
            filteredRecords: filteredRecords,
            interval: selectedInterval
        )
    }

    private var recentSevenDays: [DailyFocusDuration] {
        FocusStatistics.recentSevenDays(from: records)
    }

    private var categoryDurations: [CategoryFocusDuration] {
        FocusStatistics.categoryDistribution(from: filteredRecords)
    }

    private var taskDurations: [TaskFocusDuration] {
        FocusStatistics.taskRanking(from: filteredRecords)
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    statisticsEmptyView
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            rangePicker
                            summaryGrid
                            recentSevenDaysChart
                            categoryChart
                            taskRankingList
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("统计")
        }
    }

    private var statisticsEmptyView: some View {
        ContentUnavailableView(
            "暂无统计数据",
            systemImage: "chart.bar.xaxis",
            description: Text("完成一次专注后，这里会展示时长、分类和任务排行。")
        )
    }

    private var rangePicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("时间范围")
                .font(.headline)

            Picker("时间范围", selection: $selectedRange) {
                ForEach(StatisticsRange.allCases) { range in
                    Text(range.rawValue)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)

            if selectedRange == .custom {
                VStack(spacing: 10) {
                    DatePicker("开始日期", selection: $customStartDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $customEndDate, displayedComponents: .date)
                }
                .datePickerStyle(.compact)
                .font(.subheadline)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "总专注时长", value: DurationFormatter.readable(summary.totalDuration), iconName: "timer")
            StatCard(title: "记录次数", value: "\(summary.recordCount)次", iconName: "number")
            StatCard(title: "平均每日", value: DurationFormatter.readable(summary.averageDailyDuration), iconName: "calendar")
            StatCard(title: "最长单次", value: DurationFormatter.readable(summary.longestDuration), iconName: "crown")
            StatCard(title: "连续专注", value: "\(summary.streakDays)天", iconName: "flame")
        }
    }

    private var recentSevenDaysChart: some View {
        AnalysisCard(title: "最近 7 天", subtitle: "每日专注时长") {
            Chart(recentSevenDays) { item in
                BarMark(
                    x: .value("日期", item.day, unit: .day),
                    y: .value("分钟", item.duration / 60)
                )
                .foregroundStyle(Color.accentColor.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
        }
    }

    private var categoryChart: some View {
        AnalysisCard(title: "分类分布", subtitle: selectedRange.rawValue) {
            if categoryDurations.isEmpty {
                EmptyChartHint(text: "当前范围内暂无记录")
            } else {
                Chart(categoryDurations) { item in
                    SectorMark(
                        angle: .value("时长", item.duration),
                        innerRadius: .ratio(0.58),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("分类", item.category))
                    .cornerRadius(4)
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: 240)
            }
        }
    }

    private var taskRankingList: some View {
        AnalysisCard(title: "任务排行", subtitle: "累计专注时长") {
            if taskDurations.isEmpty {
                EmptyChartHint(text: "当前范围内暂无任务排行")
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(taskDurations.prefix(8).enumerated()), id: \.element.id) { index, item in
                        TaskRankingRow(
                            rank: index + 1,
                            task: item,
                            maxDuration: taskDurations.first?.duration ?? item.duration
                        )
                    }
                }
            }
        }
    }
}

private struct AnalysisCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)

                Spacer()

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TaskRankingRow: View {
    let rank: Int
    let task: TaskFocusDuration
    let maxDuration: TimeInterval

    private var progress: Double {
        guard maxDuration > 0 else { return 0 }
        return min(task.duration / maxDuration, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("\(rank)")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.taskName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text("\(task.recordCount)次")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(DurationFormatter.readable(task.duration))
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.secondarySystemGroupedBackground))

                    Capsule()
                        .fill(Color.accentColor.gradient)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }
}

private struct EmptyChartHint: View {
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: FocusRecord.self, inMemory: true)
}
