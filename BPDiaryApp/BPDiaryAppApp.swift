import SwiftUI
import SwiftData

@main
struct BPDiaryAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DailyBPEntry.self)
    }
}
