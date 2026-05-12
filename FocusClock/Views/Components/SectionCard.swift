import SwiftUI

struct SectionCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    SectionCard {
        Text("卡片标题")
            .font(.headline)
        Text("用于统一页面里的轻量卡片样式。")
            .foregroundStyle(.secondary)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
