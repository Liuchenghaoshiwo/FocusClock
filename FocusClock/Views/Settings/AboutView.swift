import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "timer.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)

                    Text("专注钟")
                        .font(.title2.weight(.bold))

                    Text("一个用于记录专注任务、复盘时间分布的私人效率工具。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("版本") {
                LabeledContent("当前阶段", value: "第四阶段")
                LabeledContent("技术栈", value: "SwiftUI + SwiftData + Charts")
                LabeledContent("数据存储", value: "本地设备")
            }

            Section("扩展方向") {
                Text(FutureExtensionNotes.widget)
                Text(FutureExtensionNotes.iCloud)
                Text(FutureExtensionNotes.watch)
            }

            Section("隐私") {
                Text("专注记录保存在本机，不会上传到服务器。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
