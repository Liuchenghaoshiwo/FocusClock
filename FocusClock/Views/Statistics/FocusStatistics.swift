import Foundation

enum StatisticsRange: String, CaseIterable, Identifiable {
    case today = "今天"
    case week = "本周"
    case month = "本月"
    case custom = "自定义"

    var id: String { rawValue }
}

struct DailyFocusDuration: Identifiable {
    let day: Date
    let duration: TimeInterval

    var id: Date { day }
}

struct CategoryFocusDuration: Identifiable {
    let category: String
    let duration: TimeInterval

    var id: String { category }
}

struct TaskFocusDuration: Identifiable {
    let taskName: String
    let duration: TimeInterval
    let recordCount: Int

    var id: String { taskName }
}

struct FocusStatisticsSummary {
    let totalDuration: TimeInterval
    let recordCount: Int
    let averageDailyDuration: TimeInterval
    let longestDuration: TimeInterval
    let streakDays: Int
}

enum FocusStatistics {
    static func dateInterval(
        for range: StatisticsRange,
        customStartDate: Date,
        customEndDate: Date,
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> DateInterval {
        switch range {
        case .today:
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)

        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? fallbackInterval(for: referenceDate, calendar: calendar)

        case .month:
            return calendar.dateInterval(of: .month, for: referenceDate) ?? fallbackInterval(for: referenceDate, calendar: calendar)

        case .custom:
            let start = calendar.startOfDay(for: min(customStartDate, customEndDate))
            let endDay = calendar.startOfDay(for: max(customStartDate, customEndDate))
            let end = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay
            return DateInterval(start: start, end: end)
        }
    }

    static func records(_ records: [FocusRecord], in interval: DateInterval) -> [FocusRecord] {
        records.filter { interval.contains($0.startTime) }
    }

    static func summary(
        records: [FocusRecord],
        filteredRecords: [FocusRecord],
        interval: DateInterval,
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> FocusStatisticsSummary {
        let totalDuration = filteredRecords.reduce(0) { $0 + $1.duration }
        let longestDuration = filteredRecords.map(\.duration).max() ?? 0
        let dayCount = elapsedDayCount(in: interval, calendar: calendar, referenceDate: referenceDate)

        return FocusStatisticsSummary(
            totalDuration: totalDuration,
            recordCount: filteredRecords.count,
            averageDailyDuration: totalDuration / Double(max(dayCount, 1)),
            longestDuration: longestDuration,
            streakDays: currentStreakDays(records: records, calendar: calendar, referenceDate: referenceDate)
        )
    }

    static func recentSevenDays(
        from records: [FocusRecord],
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> [DailyFocusDuration] {
        let today = calendar.startOfDay(for: referenceDate)

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset - 6, to: today),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
                return nil
            }

            let interval = DateInterval(start: day, end: nextDay)
            let duration = records
                .filter { interval.contains($0.startTime) }
                .reduce(0) { $0 + $1.duration }

            return DailyFocusDuration(day: day, duration: duration)
        }
    }

    static func categoryDistribution(from records: [FocusRecord]) -> [CategoryFocusDuration] {
        Dictionary(grouping: records, by: \.category)
            .map { category, records in
                CategoryFocusDuration(
                    category: category,
                    duration: records.reduce(0) { $0 + $1.duration }
                )
            }
            .filter { $0.duration > 0 }
            .sorted { $0.duration > $1.duration }
    }

    static func taskRanking(from records: [FocusRecord]) -> [TaskFocusDuration] {
        Dictionary(grouping: records, by: \.taskName)
            .map { taskName, records in
                TaskFocusDuration(
                    taskName: taskName,
                    duration: records.reduce(0) { $0 + $1.duration },
                    recordCount: records.count
                )
            }
            .filter { $0.duration > 0 }
            .sorted {
                if $0.duration == $1.duration {
                    return $0.taskName < $1.taskName
                }

                return $0.duration > $1.duration
            }
    }

    private static func currentStreakDays(
        records: [FocusRecord],
        calendar: Calendar,
        referenceDate: Date
    ) -> Int {
        let focusedDays = Set(records.map { calendar.startOfDay(for: $0.startTime) })
        var streak = 0
        var day = calendar.startOfDay(for: referenceDate)

        while focusedDays.contains(day) {
            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }

            day = previousDay
        }

        return streak
    }

    private static func elapsedDayCount(
        in interval: DateInterval,
        calendar: Calendar,
        referenceDate: Date
    ) -> Int {
        let start = calendar.startOfDay(for: interval.start)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate)) ?? referenceDate
        let effectiveEnd = min(interval.end, tomorrow)
        let end = calendar.startOfDay(for: effectiveEnd)
        let components = calendar.dateComponents([.day], from: start, to: end)

        return max(components.day ?? 1, 1)
    }

    private static func fallbackInterval(for date: Date, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}
