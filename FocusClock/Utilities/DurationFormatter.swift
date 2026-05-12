import Foundation

enum DurationFormatter {
    static func clock(_ duration: TimeInterval, showsSeconds: Bool = true) -> String {
        let totalSeconds = max(0, Int(duration))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if showsSeconds {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", hours, minutes)
    }

    static func readable(_ duration: TimeInterval) -> String {
        let totalMinutes = max(0, Int(duration / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }

        return "\(minutes)分钟"
    }
}
