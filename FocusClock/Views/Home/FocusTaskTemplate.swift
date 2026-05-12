import Foundation

struct FocusTaskTemplate: Identifiable {
    let id = UUID()
    let title: String
    let category: FocusCategory

    static let defaults: [FocusTaskTemplate] = [
        FocusTaskTemplate(title: "阅读", category: .study),
        FocusTaskTemplate(title: "写代码", category: .work),
        FocusTaskTemplate(title: "英语学习", category: .study),
        FocusTaskTemplate(title: "运动训练", category: .exercise),
        FocusTaskTemplate(title: "整理生活", category: .life)
    ]
}
