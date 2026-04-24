import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \DailyBPEntry.date, order: .reverse) private var entries: [DailyBPEntry]

    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    Label("Дневник", systemImage: "list.bullet.rectangle")
                }

            BPChartView(entries: entries)
                .tabItem {
                    Label("График", systemImage: "waveform.path.ecg")
                }

            SummaryView()
                .tabItem {
                    Label("Сводка", systemImage: "chart.bar.fill")
                }

            InstructionView()
                .tabItem {
                    Label("Инфо", systemImage: "info.circle.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DailyBPEntry.self, inMemory: true)
}
