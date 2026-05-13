# FocusClock Project Handoff

这是给新对话里的 Codex/AI 工程师看的项目交接说明。开始继续开发前，请先阅读本文件，并以当前代码为准做增量修改。

## 当前项目

- 项目名称：FocusClock / 专注钟
- 本地路径：`/Users/liuchenghao/Desktop/Xcode/专注钟`
- Xcode 项目：`FocusClock.xcodeproj`
- GitHub 仓库：`https://github.com/Liuchenghaoshiwo/FocusClock.git`
- 当前分支：`main`
- 最新已知提交：`99fd779 Add JSON export share sheet`
- 仓库状态：已推送到 GitHub，仓库已公开

## 技术栈

- Swift
- SwiftUI
- SwiftData
- SwiftUI Charts
- UserNotifications
- UIKit bridge only for system share sheet
- 目标设备优先适配：iPhone 17 Pro Max，大屏 iPhone 体验优先

## 已完成阶段

### 第一阶段：项目骨架 + 核心 MVP

- 4 个底部 Tab：首页、记录、统计、设置
- 首页可输入任务、选择分类、开始/结束专注
- 结束后用 SwiftData 保存专注记录
- 记录页列表展示历史记录并支持删除
- 统计页提供基础统计
- 设置页提供初版占位

### 第二阶段：增强统计功能

- 统计页支持时间范围筛选：今天、本周、本月、自定义
- 使用 SwiftUI Charts：
  - 最近 7 天每日专注时长条形图
  - 分类专注时间分布图
  - 任务累计时长排行列表
- 增加统计指标：
  - 平均每日专注时长
  - 单次最长专注时长
  - 连续专注天数 streak
- 统计空状态已优化

### 第三阶段：体验优化

- 首页增加最近使用任务快捷选择
- 首页增加常用任务模板
- 未填写任务名时默认使用“未命名任务”
- 结束专注前弹出确认
- 结束后弹出本次专注总结
- 记录页支持进入详情页
- 详情页支持编辑任务名称和分类
- 设置页增加基础可用逻辑
- 空状态、卡片布局、深色模式和整体 UI 质感已优化

### 第四阶段：成品化增强

- 本地通知：
  - 设置页可开关
  - 支持提醒时间选择
  - 开始专注后自动安排提醒
  - 结束专注后取消未触发提醒
  - 已加入通知权限请求与状态展示
- 数据导出：
  - 当前支持导出 JSON
  - 会先写入 App 的 Documents 目录
  - 随后打开系统分享面板，可保存到“文件”、AirDrop、邮件或其他 App
- 扩展点预留：
  - Home Screen Widget
  - iCloud 同步
  - Apple Watch 快速开始专注
- App 图标已生成并接入 `Assets.xcassets/AppIcon.appiconset`

## 关键文件结构

```text
FocusClock/
  FocusClockApp.swift
  Models/
    FocusRecord.swift
    FocusCategory.swift
  Utilities/
    AppSettingsKeys.swift
    DurationFormatter.swift
  Services/
    FocusNotificationManager.swift
    FocusDataExporter.swift
    FutureExtensionPoints.swift
  Views/
    MainTabView.swift
    Components/
      SectionCard.swift
      ShareSheet.swift
    Home/
      HomeView.swift
      FocusTaskTemplate.swift
    Records/
      RecordsView.swift
      RecordDetailView.swift
    Statistics/
      StatisticsView.swift
      FocusStatistics.swift
    Settings/
      SettingsView.swift
      AboutView.swift
  Assets.xcassets/
    AppIcon.appiconset/
FocusClock.xcodeproj/
```

## 文件职责

- `FocusClockApp.swift`：App 入口，注入 SwiftData `modelContainer`。
- `FocusRecord.swift`：SwiftData 专注记录模型。
- `FocusCategory.swift`：专注分类枚举、图标和颜色。
- `DurationFormatter.swift`：时长格式化工具。
- `AppSettingsKeys.swift`：`@AppStorage` 设置项 key。
- `FocusNotificationManager.swift`：本地通知权限、安排提醒、取消提醒。
- `FocusDataExporter.swift`：JSON 导出到本地 Documents，并返回可分享的文件 URL。
- `FutureExtensionPoints.swift`：Widget、iCloud、Apple Watch 的协议和扩展预留。
- `MainTabView.swift`：底部 4 Tab 容器。
- `SectionCard.swift`：可复用卡片组件。
- `ShareSheet.swift`：SwiftUI 对 `UIActivityViewController` 的封装。
- `HomeView.swift`：首页专注计时主流程。
- `FocusTaskTemplate.swift`：常用任务模板。
- `RecordsView.swift`：历史记录列表和删除。
- `RecordDetailView.swift`：记录详情、编辑任务名和分类。
- `StatisticsView.swift`：统计页面 UI 和 Charts 展示。
- `FocusStatistics.swift`：统计计算、时间范围和图表数据结构。
- `SettingsView.swift`：设置页、本地通知配置、JSON 导出入口。
- `AboutView.swift`：关于页和扩展说明。

## 当前导出逻辑说明

用户点“导出 JSON”后：

1. `SettingsView.exportRecordsAsJSON()` 调用 `FocusDataExporter.exportJSON(records:)`。
2. `FocusDataExporter` 将记录编码为 pretty printed JSON。
3. 文件写入 App 沙盒 Documents 目录，文件名类似 `focus-records-20260513-123456.json`。
4. `SettingsView` 用 `ShareSheet` 弹出系统分享面板。
5. 用户可以在分享面板里选择保存到“文件”、AirDrop、邮件等。

不要再把导出只做成静默写入本地目录，用户需要能拿到文件。

## 构建验证命令

在项目根目录执行：

```sh
xcodebuild -project FocusClock.xcodeproj \
  -scheme FocusClock \
  -configuration Debug \
  -destination generic/platform=iOS \
  -derivedDataPath ./DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

上一次验证结果：`BUILD SUCCEEDED`。

如果构建后不需要保留产物，可以删除 `DerivedData`，避免提交构建缓存。

## Git 常用命令

```sh
git status --short --branch
git log -1 --oneline
git add .
git commit -m "Your commit message"
git push origin main
```

如果需要推送到 GitHub，注意当前环境可能需要网络权限或用户授权。

## 开发原则

- 继续增量修改，不要推翻重写。
- 优先保证能编译、结构清晰、原生体验稳定。
- 使用 SwiftUI + SwiftData 的现有模式。
- 不要引入复杂第三方依赖。
- 修改旧文件时输出完整文件或直接改代码后说明变更点。
- 做 UI 时保持简洁、圆润、原生 iOS 风格，支持深色模式。
- 如果新增能力，优先拆成 `Services`、`Utilities`、`Views/Components` 等清晰文件。
- 不要破坏已有 SwiftData 模型，除非明确处理迁移。
- 操作 Git 前先看 `git status`，不要回滚用户未授权的改动。

## 给新对话的推荐开场

可以直接把下面这段发给新对话：

```text
我在继续开发一个 SwiftUI + SwiftData 的 iPhone App，项目在 /Users/liuchenghao/Desktop/Xcode/专注钟。
请先阅读项目根目录的 Agents.md，了解当前阶段、文件结构、已完成能力和开发约束。
接下来请基于现有代码增量修改，不要推翻重写。修改后请用 xcodebuild 验证能编译。
```

## 下一步可能继续做的方向

- 优化导出体验：增加导出成功提示、文件名预览、支持 CSV。
- 增加专注目标时长和倒计时模式。
- 增加记录搜索、筛选和按分类过滤。
- 为 Widget 扩展创建独立 target。
- 为 iCloud 同步接入 CloudKit-backed SwiftData。
- 为 Apple Watch 增加 watchOS target 和快速开始入口。
