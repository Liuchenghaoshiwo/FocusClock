import SwiftData
import SwiftUI

@main
struct FocusClockApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: FocusRecord.self)
    }
}
