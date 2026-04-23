import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    Label("Дневник", systemImage: "heart.text.square")
                }

            SummaryView()
                .tabItem {
                    Label("Сводка", systemImage: "list.clipboard")
                }

            BPChartView()
                .tabItem {
                    Label("График", systemImage: "chart.line.uptrend.xyaxis")
                }

            InstructionView()
                .tabItem {
                    Label("Инструкция", systemImage: "book")
                }
        }
    }
}
