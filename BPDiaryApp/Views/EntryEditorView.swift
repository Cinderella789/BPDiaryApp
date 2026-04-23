import SwiftUI
import SwiftData

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var entry: DailyBPEntry

    @State private var morningSystolicText = ""
    @State private var morningDiastolicText = ""
    @State private var morningPulseText = ""
    @State private var eveningSystolicText = ""
    @State private var eveningDiastolicText = ""
    @State private var eveningPulseText = ""
    @State private var selectedFeeling = "Хорошо"

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
    private let green = Color(red: 0.52, green: 0.87, blue: 0.61)
    private let gold = Color(red: 0.84, green: 0.70, blue: 0.44)
    private let feelings = ["Хорошо", "Головная боль", "Слабость", "Сердцебиение"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    titleBlock
                    summaryCard
                    measurementSection(title: "🌅 Утреннее измерение", badgeText: morningBadgeText, badgeBackground: morningBadgeBackground, badgeForeground: morningBadgeForeground, systolic: $morningSystolicText, diastolic: $morningDiastolicText, pulse: $morningPulseText, time: $entry.morningTime)
                    measurementSection(title: "🌙 Вечернее измерение", badgeText: eveningBadgeText, badgeBackground: eveningBadgeBackground, badgeForeground: eveningBadgeForeground, systolic: $eveningSystolicText, diastolic: $eveningDiastolicText, pulse: $eveningPulseText, time: $entry.eveningTime)
                    detailsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            morningSystolicText = entry.morningSystolic.map(String.init) ?? ""
            morningDiastolicText = entry.morningDiastolic.map(String.init) ?? ""
            morningPulseText = entry.morningPulse.map(String.init) ?? ""
            eveningSystolicText = entry.eveningSystolic.map(String.init) ?? ""
            eveningDiastolicText = entry.eveningDiastolic.map(String.init) ?? ""
            eveningPulseText = entry.eveningPulse.map(String.init) ?? ""
            if let mood = entry.wellBeing, !mood.isEmpty { selectedFeeling = mood }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { smallIconButton("←") }
            Spacer()
            smallIconButton("⋯")
        }
    }

    private func smallIconButton(_ symbol: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.07, green: 0.09, blue: 0.10))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(line, lineWidth: 1))
                .frame(width: 38, height: 38)
            Text(symbol)
                .font(.headline)
                .foregroundStyle(Color(red: 0.85, green: 0.87, blue: 0.89))
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ввод измерения")
                .font(.system(size: 31, weight: .heavy))
                .foregroundStyle(textPrimary)
                .tracking(-0.6)
            Text("Экран для записи утреннего и вечернего давления, пульса, времени, препарата, самочувствия и комментария.")
                .font(.subheadline)
                .foregroundStyle(textSecondary)
                .lineSpacing(2)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Запись на сегодня")
                        .font(.caption)
                        .foregroundStyle(textSecondary)
                    Text(formattedDate(entry.date))
                        .font(.system(size: 23, weight: .heavy))
                        .foregroundStyle(textPrimary)
                    Text("Утро 07:00 · Вечер 20:00")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)
                }
                Spacer()
                Text(dayBadge)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.07, green: 0.18, blue: 0.17))
                    .clipShape(Capsule())
            }
            HStack(spacing: 12) {
                statusMiniCard(title: "Утренний статус", status: BPAnalyzer.status(systolic: intValue(morningSystolicText), diastolic: intValue(morningDiastolicText)))
                statusMiniCard(title: "Вечерний статус", status: BPAnalyzer.status(systolic: intValue(eveningSystolicText), diastolic: intValue(eveningDiastolicText)))
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(LinearGradient(colors: [Color(red: 0.09, green: 0.10, blue: 0.11), Color(red: 0.07, green: 0.08, blue: 0.09)], startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 16)
    }

    private func statusMiniCard(title: String, status: BPStatus) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            if status == .unknown {
                Text("—")
                    .font(.system(size: 28, weight: .heavy))
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
        .padding(13)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func measurementSection(title: String, badgeText: String, badgeBackground: Color, badgeForeground: Color, systolic: Binding<String>, diastolic: Binding<String>, pulse: Binding<String>, time: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                Text(badgeText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(badgeForeground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(badgeBackground)
                    .clipShape(Capsule())
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricField(title: "Систолическое", text: systolic)
                metricField(title: "Диастолическое", text: diastolic)
                metricField(title: "Пульс", text: pulse)
                timeField(title: "Время", date: time)
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func metricField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            TextField("", text: text)
                .keyboardType(.numberPad)
                .font(.headline.weight(.bold))
                .foregroundStyle(textPrimary)
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(Color(red: 0.06, green: 0.07, blue: 0.09))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(red: 0.14, green: 0.16, blue: 0.20), lineWidth: 1))
        }
        .padding(12)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func timeField(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            DatePicker("", selection: date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                .background(Color(red: 0.06, green: 0.07, blue: 0.09))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(red: 0.14, green: 0.16, blue: 0.20), lineWidth: 1))
        }
        .padding(12)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Дополнительно")
                .font(.system(size: 19, weight: .heavy))
                .foregroundStyle(textPrimary)

            fullField(title: "Препарат / доза") {
                TextField("Например: Телмисартан 40 мг", text: Binding(get: { entry.medicationDose ?? "" }, set: { entry.medicationDose = $0 }))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(textPrimary)
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .background(Color(red: 0.06, green: 0.07, blue: 0.09))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(red: 0.14, green: 0.16, blue: 0.20), lineWidth: 1))
            }

            fullField(title: "Самочувствие") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                    ForEach(feelings, id: \.self) { feeling in
                        Button {
                            selectedFeeling = feeling
                            entry.wellBeing = feeling
                        } label: {
                            Text(feeling)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(selectedFeeling == feeling ? teal : Color(red: 0.84, green: 0.86, blue: 0.89))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(selectedFeeling == feeling ? Color(red: 0.07, green: 0.17, blue: 0.16) : Color(red: 0.06, green: 0.07, blue: 0.09))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(selectedFeeling == feeling ? Color(red: 0.18, green: 0.38, blue: 0.36) : Color(red: 0.14, green: 0.16, blue: 0.20), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            fullField(title: "Комментарий") {
                TextEditor(text: Binding(get: { entry.comment ?? "" }, set: { entry.comment = $0 }))
                    .font(.body)
                    .foregroundStyle(textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 90)
                    .padding(8)
                    .background(Color(red: 0.06, green: 0.07, blue: 0.09))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(red: 0.14, green: 0.16, blue: 0.20), lineWidth: 1))
            }

            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Text("Отмена")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color(red: 0.84, green: 0.86, blue: 0.89))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.09, green: 0.10, blue: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button { saveEntry() } label: {
                    Text("Сохранить запись")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(tealDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color(red: 0.40, green: 0.82, blue: 0.79), Color(red: 0.26, green: 0.71, blue: 0.68)], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Text("По шаблону дневника запись включает утреннее и вечернее давление, пульс, время, препарат / дозу, самочувствие и комментарий.")
                .font(.caption)
                .foregroundStyle(textSecondary)
                .lineSpacing(2)
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }

    private func fullField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(textSecondary)
            content()
        }
        .padding(12)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }

    private var dayBadge: String {
        let start = Calendar.current.startOfDay(for: entry.date)
        let today = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: today, to: start).day ?? 0
        return "День \(max(1, days + 1))"
    }

    private var morningBadgeText: String {
        let status = BPAnalyzer.status(systolic: intValue(morningSystolicText), diastolic: intValue(morningDiastolicText))
        return status == .unknown ? "Статус появится" : status.rawValue
    }

    private var morningBadgeBackground: Color {
        let status = BPAnalyzer.status(systolic: intValue(morningSystolicText), diastolic: intValue(morningDiastolicText))
        return status == .unknown ? Color(red: 0.07, green: 0.18, blue: 0.14) : statusBackground(status)
    }

    private var morningBadgeForeground: Color {
        let status = BPAnalyzer.status(systolic: intValue(morningSystolicText), diastolic: intValue(morningDiastolicText))
        return status == .unknown ? green : statusForeground(status)
    }

    private var eveningBadgeText: String {
        let status = BPAnalyzer.status(systolic: intValue(eveningSystolicText), diastolic: intValue(eveningDiastolicText))
        return status == .unknown ? "Пока пусто" : status.rawValue
    }

    private var eveningBadgeBackground: Color {
        let status = BPAnalyzer.status(systolic: intValue(eveningSystolicText), diastolic: intValue(eveningDiastolicText))
        return status == .unknown ? Color(red: 0.16, green: 0.14, blue: 0.09) : statusBackground(status)
    }

    private var eveningBadgeForeground: Color {
        let status = BPAnalyzer.status(systolic: intValue(eveningSystolicText), diastolic: intValue(eveningDiastolicText))
        return status == .unknown ? gold : statusForeground(status)
    }

    private func statusForeground(_ status: BPStatus) -> Color {
        switch status {
        case .normal: return green
        case .hypertension1: return gold
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

    private func intValue(_ text: String) -> Int? {
        Int(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter.string(from: date).capitalized
    }

    private func saveEntry() {
        entry.morningSystolic = intValue(morningSystolicText)
        entry.morningDiastolic = intValue(morningDiastolicText)
        entry.morningPulse = intValue(morningPulseText)
        entry.eveningSystolic = intValue(eveningSystolicText)
        entry.eveningDiastolic = intValue(eveningDiastolicText)
        entry.eveningPulse = intValue(eveningPulseText)
        entry.wellBeing = selectedFeeling
        try? context.save()
        dismiss()
    }
}
