import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyBPEntry.date, order: .reverse) private var entries: [DailyBPEntry]

    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var selectedEntry: DailyBPEntry?
    

    private let bgTop = Color(red: 0.10, green: 0.11, blue: 0.13)
    private let bgMid = Color(red: 0.04, green: 0.05, blue: 0.06)
    private let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.04)
    private let panel = Color(red: 0.08, green: 0.09, blue: 0.11)
    private let panel2 = Color(red: 0.10, green: 0.11, blue: 0.13)
    private let line = Color(red: 0.17, green: 0.18, blue: 0.21)
    private let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.97)
    private let textSecondary = Color(red: 0.60, green: 0.63, blue: 0.67)
    private let teal = Color(red: 0.38, green: 0.78, blue: 0.76)
    private let tealDark = Color(red: 0.03, green: 0.13, blue: 0.12)

    private var latestEntries: [DailyBPEntry] {
        Array(entries.prefix(5))
    }

    private var hasFewEntries: Bool {
        entries.count < 3
    }

    private var todayEntry: DailyBPEntry? {
        let today = Calendar.current.startOfDay(for: selectedDate)
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        heroHeader
                        todayCard
                        if hasFewEntries { lowDataCard }
                        recentEntriesBlock
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedEntry) { entry in
                EntryEditorView(entry: entry)
            }      }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Дневник контроля давления")
                .font(.system(size: 37, weight: .heavy))
                .foregroundStyle(textPrimary)
                .tracking(-0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 6)
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Запись на сегодня")
                        .font(.caption)
                        .foregroundStyle(textSecondary)

                    Text(formattedTodayDate())
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(textPrimary)

                    Text("Утро 07:00 · Вечер 20:00")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)
                }

                Spacer()

                Text("28 дней")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.07, green: 0.18, blue: 0.17))
                    .clipShape(Capsule())
            }

            Button {
                selectedEntry = entryForSelectedDate()
            } label: {
                Text("Заполнить измерение")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(tealDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.40, green: 0.82, blue: 0.79), Color(red: 0.26, green: 0.71, blue: 0.68)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                statusMiniCard(title: "Утренний статус", status: BPAnalyzer.status(systolic: todayEntry?.morningSystolic, diastolic: todayEntry?.morningDiastolic))
                statusMiniCard(title: "Вечерний статус", status: BPAnalyzer.status(systolic: todayEntry?.eveningSystolic, diastolic: todayEntry?.eveningDiastolic))
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
    
    private func statusMiniCard(title: String, status: BPStatus) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            if status == .unknown {
                Text("—")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Color(red: 0.43, green: 0.45, blue: 0.48))
            } else {
                Text(status.symbol)
                    .font(.title2)
                Text(status.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusForeground(status))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var lowDataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.11, green: 0.13, blue: 0.15))
                    .frame(width: 58, height: 58)
                Text("✨")
                    .font(.title2)
            }

            Text("Начните с одной записи сегодня")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(textPrimary)

            Text("Приложение само покажет цветовой статус, сохранит утро и вечер, а затем подготовит сводку и график.")
                .font(.subheadline)
                .foregroundStyle(textSecondary)
                .lineSpacing(2)

            HStack(spacing: 10) {
                helperChip("🌅 Утро")
                helperChip("🌙 Вечер")
                helperChip("📈 График")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.11), Color(red: 0.07, green: 0.08, blue: 0.09)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(Color(red: 0.22, green: 0.25, blue: 0.29))
        )
    }

    private func helperChip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(Color(red: 0.84, green: 0.85, blue: 0.88))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.10, green: 0.12, blue: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var recentEntriesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Последние записи")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(textPrimary)
                Spacer()
                if !entries.isEmpty {
                    Text("Все")
                        .font(.caption)
                        .foregroundStyle(teal)
                }
            }

            if latestEntries.isEmpty {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(panel)
                    .frame(height: 88)
                    .overlay(Text("Пока нет записей").font(.subheadline).foregroundStyle(textSecondary))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(line, lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(latestEntries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            recentEntryCard(entry)
                        }
                  
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func recentEntryCard(_ entry: DailyBPEntry) -> some View {
        let primary = primaryMeasurement(for: entry)
        let status = primary.status

        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                Text(primary.pressureText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(textPrimary)
                    .monospacedDigit()

                Spacer(minLength: 8)

                compactStatusBadge(status, title: statusTitle(status))
            }

            Text(primary.metaText)
                .font(.caption2)
                .foregroundStyle(textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(line, lineWidth: 1)
        )
    }
    
    private func compactStatusBadge(_ status: BPStatus, title: String) -> some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(status == .unknown ? textSecondary : statusForeground(status))
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(statusBackground(status))
            .clipShape(Capsule())
    }
    
    
    private func primaryMeasurement(for entry: DailyBPEntry) -> (pressureText: String, metaText: String, status: BPStatus) {
        if let systolic = entry.morningSystolic,
           let diastolic = entry.morningDiastolic {
            let pulse = entry.morningPulse.map { "Пульс \($0)" } ?? "Пульс —"
            let time = formattedTime(entry.morningTime)
            let meta = "Утро • \(time) • \(pulse)"
            let status = BPAnalyzer.status(systolic: systolic, diastolic: diastolic)
            return ("\(systolic) / \(diastolic)", meta, status)
        }

        if let systolic = entry.eveningSystolic,
           let diastolic = entry.eveningDiastolic {
            let pulse = entry.eveningPulse.map { "Пульс \($0)" } ?? "Пульс —"
            let time = formattedTime(entry.eveningTime)
            let meta = "Вечер • \(time) • \(pulse)"
            let status = BPAnalyzer.status(systolic: systolic, diastolic: diastolic)
            return ("\(systolic) / \(diastolic)", meta, status)
        }

        return ("— / —", "Нет данных измерения", .unknown)
    }

    private func formattedTime(_ date: Date?) -> String {
        guard let date else { return "—:—" }
        return AppFormatters.timeOnly.string(from: date)
    }
    
    private func statusTitle(_ status: BPStatus) -> String {
        switch status {
        case .normal:
            return "Норма"
        case .hypertension1:
            return "Выше цели"
        case .hypertension2:
            return "Высокое"
        case .hypotension:
            return "Низкое"
        case .unknown:
            return "Нет данных"
        }
    }

    

    private func statusForeground(_ status: BPStatus) -> Color {
        switch status {
        case .normal: return Color(red: 0.52, green: 0.87, blue: 0.61)
        case .hypertension1: return Color(red: 0.92, green: 0.77, blue: 0.41)
        case .hypertension2: return Color(red: 0.95, green: 0.45, blue: 0.47)
        case .hypotension: return Color(red: 0.47, green: 0.72, blue: 0.98)
        case .unknown: return textSecondary
        }
    }

    private func statusBackground(_ status: BPStatus) -> Color {
        switch status {
        case .normal: return Color(red: 0.07, green: 0.18, blue: 0.14)
        case .hypertension1: return Color(red: 0.16, green: 0.13, blue: 0.08)
        case .hypertension2: return Color(red: 0.20, green: 0.09, blue: 0.10)
        case .hypotension: return Color(red: 0.08, green: 0.13, blue: 0.20)
        case .unknown: return Color(red: 0.13, green: 0.14, blue: 0.16)
        }
    }

    private func entrySubtitle(_ entry: DailyBPEntry) -> String {
        let hasMorning = entry.morningSystolic != nil || entry.morningDiastolic != nil
        let hasEvening = entry.eveningSystolic != nil || entry.eveningDiastolic != nil
        switch (hasMorning, hasEvening) {
        case (true, true): return "Утреннее и вечернее измерение заполнены"
        case (true, false): return "Утреннее измерение заполнено"
        case (false, true): return "Есть только вечернее измерение"
        default: return "Запись создана, но данные ещё не внесены"
        }
    }

    private func entryForSelectedDate() -> DailyBPEntry {
        let normalized = Calendar.current.startOfDay(for: selectedDate)
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: normalized) }) {
            return existing
        }
        let newEntry = DailyBPEntry(
            date: normalized,
            morningTime: defaultTime(for: normalized, hour: 7),
            eveningTime: defaultTime(for: normalized, hour: 20)
        )
        context.insert(newEntry)
        try? context.save()
        return newEntry
    }

    private func defaultTime(for date: Date, hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
    }

    private func formattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter.string(from: selectedDate).capitalized
    }
}
