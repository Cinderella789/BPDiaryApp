import SwiftUI
import Charts

struct BPChartView: View {
    let entries: [DailyBPEntry]

    private let bgTop = Color(red: 0.10, green: 0.11, blue: 0.13)
    private let bgMid = Color(red: 0.04, green: 0.05, blue: 0.06)
    private let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.04)
    private let panel = Color(red: 0.08, green: 0.09, blue: 0.11)
    private let line = Color(red: 0.17, green: 0.18, blue: 0.21)
    private let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.97)
    private let textSecondary = Color(red: 0.60, green: 0.63, blue: 0.67)
    private let teal = Color(red: 0.38, green: 0.78, blue: 0.76)
    private let red = Color(red: 0.93, green: 0.47, blue: 0.48)
    private let yellow = Color(red: 0.87, green: 0.75, blue: 0.44)

    private var recentEntries: [DailyBPEntry] {
        Array(entries.sorted { $0.date < $1.date }.suffix(28))
    }

    private var chartData: [ChartPoint] {
        recentEntries.compactMap { entry in
            guard let avg = BPAnalyzer.dayAverage(for: entry) else { return nil }
            return ChartPoint(date: entry.date, systolic: avg.systolic, diastolic: avg.diastolic)
        }
    }

    private var avgSystolic: Int {
        Int(BPAnalyzer.averageSystolic(entries: recentEntries).rounded())
    }

    private var avgDiastolic: Int {
        Int(BPAnalyzer.averageDiastolic(entries: recentEntries).rounded())
    }

    private var highDays: Int {
        chartData.filter { $0.systolic >= 140 || $0.diastolic >= 90 }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                        chartCard
                        metricsCard
                        analysisCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Последние 28 дней")
                .font(.caption)
                .foregroundStyle(textSecondary)

            Text("График")
                .font(.system(size: 37, weight: .heavy))
                .foregroundStyle(textPrimary)
                .tracking(-0.8)

            Text("Динамика среднего систолического и диастолического давления с ориентацией на целевые значения 130 / 80.")
                .font(.subheadline)
                .foregroundStyle(textSecondary)
                .lineSpacing(2)
        }
        .padding(.top, 6)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Давление по дням")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                legend
            }

            Chart {
                ForEach(chartData) { point in
                    LineMark(
                        x: .value("Дата", point.date),
                        y: .value("SYS", point.systolic)
                    )
                    .foregroundStyle(teal)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    LineMark(
                        x: .value("Дата", point.date),
                        y: .value("DIA", point.diastolic)
                    )
                    .foregroundStyle(red)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }

                RuleMark(y: .value("Target SYS", 130))
                    .foregroundStyle(teal.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 6]))

                RuleMark(y: .value("Target DIA", 80))
                    .foregroundStyle(red.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            }
            .frame(height: 260)
            .chartYScale(domain: 50...190)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(line)
                    AxisValueLabel(format: .dateTime.day().month(.defaultDigits), centered: true)
                        .foregroundStyle(textSecondary)
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(line)
                    AxisValueLabel()
                        .foregroundStyle(textSecondary)
                        .font(.caption2)
                }
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(line, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 16)
    }

    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Ключевые показатели")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                capsule("Средние", color: yellow)
            }

            HStack(spacing: 12) {
                metricTile(title: "Среднее SYS", value: "\(avgSystolic)", accent: teal)
                metricTile(title: "Среднее DIA", value: "\(avgDiastolic)", accent: red)
                metricTile(title: "Высоких дней", value: "\(highDays)", accent: yellow)
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Краткий анализ")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                capsule(statusText, color: statusColor)
            }

            VStack(spacing: 10) {
                analysisRow(title: "Целевой уровень", value: avgSystolic < 130 && avgDiastolic < 80 ? "Ниже цели" : "Выше цели")
                analysisRow(title: "Текущий фокус", value: highDays >= 5 ? "Есть серия высоких дней" : "Динамика спокойнее")
                analysisRow(title: "Наблюдение", value: chartData.isEmpty ? "Недостаточно данных" : "Ориентир — последние 28 дней")
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var legend: some View {
        HStack(spacing: 12) {
            legendItem(color: teal, text: "SYS")
            legendItem(color: red, text: "DIA")
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Capsule().fill(color).frame(width: 18, height: 6)
            Text(text)
                .font(.caption.weight(.bold))
                .foregroundStyle(textSecondary)
        }
    }

    private func metricTile(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(accent)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(red: 0.10, green: 0.11, blue: 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func analysisRow(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textPrimary)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(red: 0.10, green: 0.11, blue: 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func capsule(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var statusText: String {
        if chartData.isEmpty { return "Нет данных" }
        if avgSystolic < 130 && avgDiastolic < 80 { return "Спокойно" }
        if avgSystolic >= 140 || avgDiastolic >= 90 { return "Контроль" }
        return "Наблюдение"
    }

    private var statusColor: Color {
        if chartData.isEmpty { return yellow }
        if avgSystolic < 130 && avgDiastolic < 80 { return teal }
        if avgSystolic >= 140 || avgDiastolic >= 90 { return red }
        return yellow
    }
}

struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let systolic: Int
    let diastolic: Int
}
