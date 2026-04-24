import SwiftUI
import SwiftData

struct SummaryView: View {
    @Query(sort: \DailyBPEntry.date, order: .reverse) private var entries: [DailyBPEntry]

    private let bgTop = Color(red: 0.10, green: 0.11, blue: 0.13)
    private let bgMid = Color(red: 0.04, green: 0.05, blue: 0.06)
    private let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.04)
    private let panel = Color(red: 0.08, green: 0.09, blue: 0.11)
    private let panel2 = Color(red: 0.10, green: 0.11, blue: 0.13)
    private let line = Color(red: 0.17, green: 0.18, blue: 0.21)
    private let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.97)
    private let textSecondary = Color(red: 0.60, green: 0.63, blue: 0.67)
    private let teal = Color(red: 0.38, green: 0.78, blue: 0.76)
    private let green = Color(red: 0.52, green: 0.87, blue: 0.61)
    private let yellow = Color(red: 0.87, green: 0.75, blue: 0.44)
    private let red = Color(red: 0.93, green: 0.47, blue: 0.48)
    private let blue = Color(red: 0.49, green: 0.72, blue: 0.95)

    private var recent28DaysEntries: [DailyBPEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        return entries.filter { entry in
            let date = calendar.startOfDay(for: entry.date)
            return date >= startDate && date <= today
        }
    }

    private var averageSystolic: Int {
        rounded(BPAnalyzer.averageSystolic(for: recent28DaysEntries))
    }

    private var averageDiastolic: Int {
        rounded(BPAnalyzer.averageDiastolic(for: recent28DaysEntries))
    }

    private var averagePulse: Int {
        rounded(BPAnalyzer.averagePulse(for: recent28DaysEntries))
    }

    private var normalCount: Int { count(for: .normal) }
    private var hypertension1Count: Int { count(for: .hypertension1) }
    private var hypertension2Count: Int { count(for: .hypertension2) }
    private var hypotensionCount: Int { count(for: .hypotension) }

    private var filledMeasurementsCount: Int {
        recent28DaysEntries.reduce(0) { partial, entry in
            let morning = (entry.morningSystolic != nil && entry.morningDiastolic != nil) ? 1 : 0
            let evening = (entry.eveningSystolic != nil && entry.eveningDiastolic != nil) ? 1 : 0
            return partial + morning + evening
        }
    }

    private var daysWithNormal: Int {
        recent28DaysEntries.filter { entry in
            let morning = BPAnalyzer.status(systolic: entry.morningSystolic, diastolic: entry.morningDiastolic)
            let evening = BPAnalyzer.status(systolic: entry.eveningSystolic, diastolic: entry.eveningDiastolic)
            return morning == .normal || evening == .normal
        }.count
    }

    private var maxMeasurementText: String {
        let pairs = recent28DaysEntries.flatMap { entry -> [(Int, Int)] in
            var result: [(Int, Int)] = []
            if let s = entry.morningSystolic, let d = entry.morningDiastolic { result.append((s, d)) }
            if let s = entry.eveningSystolic, let d = entry.eveningDiastolic { result.append((s, d)) }
            return result
        }

        guard let maxPair = pairs.max(by: { $0.0 < $1.0 }) else { return "—" }
        return "\(maxPair.0) / \(maxPair.1)"
    }

    private var sysGoalText: String {
        averageSystolic <= 130 ? "Ниже цели 130" : "Выше цели 130"
    }

    private var diaGoalText: String {
        averageDiastolic <= 80 ? "Около цели 80" : "Выше цели 80"
    }

    private var summaryTag: (String, Color, Color) {
        if averageSystolic <= 130 && averageDiastolic <= 80 {
            return ("Стабильно", Color(red: 0.07, green: 0.18, blue: 0.14), green)
        } else {
            return ("Нужен контроль", Color(red: 0.16, green: 0.13, blue: 0.08), yellow)
        }
    }

    private var rangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        return "\(formatter.string(from: startDate)) — \(formatter.string(from: today))"
    }

    private var chartPointsSYS: [CGFloat] {
        dayAverages(for: recent28DaysEntries, systolic: true).map { value in
            yPosition(for: value, min: 70, max: 170, height: 148)
        }
    }

    private var chartPointsDIA: [CGFloat] {
        dayAverages(for: recent28DaysEntries, systolic: false).map { value in
            yPosition(for: value, min: 50, max: 110, height: 148)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                        heroCard
                        keyMetricsSection
                        zonesSection
                        trendSection
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
            Text("Сводка давления")
                .font(.system(size: 37, weight: .heavy))
                .foregroundStyle(textPrimary)
                .tracking(-0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 6)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Последние 28 дней")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(textPrimary)

                    Text("\(rangeText) · \(recent28DaysEntries.count) записей")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)
                }

                Spacer()

                Text("Автосводка")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.07, green: 0.18, blue: 0.17))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                metricCard(title: "Среднее SYS", value: "\(averageSystolic)", subtitle: sysGoalText)
                metricCard(title: "Среднее DIA", value: "\(averageDiastolic)", subtitle: diaGoalText)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.09, green: 0.10, blue: 0.11), Color(red: 0.07, green: 0.08, blue: 0.09)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(line, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 16)
    }

    private func metricCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(textPrimary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Ключевые показатели")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                statusTag(summaryTag.0, background: summaryTag.1, foreground: summaryTag.2)
            }

            VStack(spacing: 10) {
                metricRow(title: "Средний пульс", subtitle: "Утро + вечер", value: averagePulse == 0 ? "—" : "\(averagePulse) уд/мин")
                metricRow(title: "Дней с нормой", subtitle: "Из заполненных записей", value: "\(daysWithNormal) из \(recent28DaysEntries.count)")
                metricRow(title: "Максимум за период", subtitle: "Самое высокое измерение", value: maxMeasurementText)
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Распределение по зонам")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                statusTag("Нужен контроль", background: Color(red: 0.16, green: 0.13, blue: 0.08), foreground: yellow)
            }

            VStack(spacing: 10) {
                zoneRow(color: green, title: "Норма", value: normalCount)
                zoneRow(color: yellow, title: "Гипертония 1 ст.", value: hypertension1Count)
                zoneRow(color: red, title: "Гипертония 2 ст.", value: hypertension2Count)
                zoneRow(color: blue, title: "Гипотония", value: hypotensionCount)
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Мини-график тренда")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                statusTag("130 / 80 цель", background: Color(red: 0.07, green: 0.18, blue: 0.14), foreground: green)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.11), Color(red: 0.06, green: 0.07, blue: 0.08)], startPoint: .top, endPoint: .bottom))
                    .frame(height: 148)
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(line, lineWidth: 1))

                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let inset: CGFloat = 14
                    let usableWidth = max(width - inset * 2, 1)

                    ZStack {
                        ForEach([28.0, 62.0, 96.0, 130.0], id: \.self) { y in
                            Path { path in
                                path.move(to: CGPoint(x: inset, y: y))
                                path.addLine(to: CGPoint(x: width - inset, y: y))
                            }
                            .stroke(Color(red: 0.13, green: 0.15, blue: 0.18), lineWidth: 1)
                        }

                        Path { path in
                            path.move(to: CGPoint(x: inset, y: 54))
                            path.addLine(to: CGPoint(x: width - inset, y: 54))
                        }
                        .stroke(teal.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))

                        Path { path in
                            path.move(to: CGPoint(x: inset, y: 88))
                            path.addLine(to: CGPoint(x: width - inset, y: 88))
                        }
                        .stroke(teal.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [5]))

                        chartPath(points: chartPointsSYS, width: usableWidth, inset: inset)
                            .stroke(teal, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        chartPath(points: chartPointsDIA, width: usableWidth, inset: inset)
                            .stroke(green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    }
                }
                .frame(height: 148)
            }

            Text("Линии показывают среднее систолическое и диастолическое давление по дням с целевыми уровнями 130 и 80.")
                .font(.caption)
                .foregroundStyle(textSecondary)
                .lineSpacing(2)
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func metricRow(title: String, subtitle: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(textSecondary)
            }
            Spacer()
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(textPrimary)
        }
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func zoneRow(color: Color, title: String, value: Int) -> some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textPrimary)
            }
            Spacer()
            Text("\(value)")
                .font(.headline.weight(.heavy))
                .foregroundStyle(textPrimary)
        }
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func statusTag(_ text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(background)
            .clipShape(Capsule())
    }

    private func count(for status: BPStatus) -> Int {
        recent28DaysEntries.reduce(0) { partial, entry in
            var total = partial
            if BPAnalyzer.status(systolic: entry.morningSystolic, diastolic: entry.morningDiastolic) == status { total += 1 }
            if BPAnalyzer.status(systolic: entry.eveningSystolic, diastolic: entry.eveningDiastolic) == status { total += 1 }
            return total
        }
    }

    private func rounded(_ value: Double?) -> Int {
        guard let value else { return 0 }
        return Int(value.rounded())
    }

    private func dayAverages(for entries: [DailyBPEntry], systolic: Bool) -> [Double] {
        let sorted = entries.sorted { $0.date < $1.date }
        let values = sorted.map { entry -> Double? in
            let first = systolic ? entry.morningSystolic : entry.morningDiastolic
            let second = systolic ? entry.eveningSystolic : entry.eveningDiastolic
            return BPAnalyzer.dayAverage(first, second)
        }.compactMap { $0 }

        if values.isEmpty {
            return [128, 124, 131, 122, 126, 120, 124, 118, 123, 116, 121, 114]
        }

        if values.count == 1 {
            return Array(repeating: values[0], count: 12)
        }

        if values.count >= 12 {
            let stride = Double(values.count - 1) / 11.0
            return (0..<12).map { i in values[Int((Double(i) * stride).rounded())] }
        }

        var result = values
        while result.count < 12 {
            result.append(values.last ?? 0)
        }
        return result
    }

    private func yPosition(for value: Double, min: Double, max: Double, height: CGFloat) -> CGFloat {
        let clamped = Swift.min(Swift.max(value, min), max)
        let ratio = (clamped - min) / (max - min)
        return CGFloat(height - 14 - ratio * Double(height - 28))
    }

    private func chartPath(points: [CGFloat], width: CGFloat, inset: CGFloat) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }
        let step = points.count > 1 ? width / CGFloat(points.count - 1) : 0
        path.move(to: CGPoint(x: inset, y: points[0]))
        for index in points.indices.dropFirst() {
            path.addLine(to: CGPoint(x: inset + CGFloat(index) * step, y: points[index]))
        }
        return path
    }
}
