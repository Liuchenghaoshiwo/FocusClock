import SwiftUI

enum FocusCategory: String, CaseIterable, Identifiable, Codable {
    case study = "学习"
    case work = "工作"
    case exercise = "运动"
    case life = "生活"
    case other = "其他"

    var id: String { rawValue }

    static func value(from rawValue: String) -> FocusCategory {
        FocusCategory(rawValue: rawValue) ?? .other
    }

    var iconName: String {
        switch self {
        case .study:
            "book.closed"
        case .work:
            "briefcase"
        case .exercise:
            "figure.run"
        case .life:
            "house"
        case .other:
            "ellipsis.circle"
        }
    }

    var tintColor: Color {
        switch self {
        case .study:
            .blue
        case .work:
            .indigo
        case .exercise:
            .green
        case .life:
            .orange
        case .other:
            .gray
        }
    }
}
