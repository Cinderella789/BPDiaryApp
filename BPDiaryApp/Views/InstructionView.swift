import SwiftUI

struct InstructionView: View {
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                        heroCard
                        zonesSection
                        attentionSection
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
            Text("Инструкция")
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
                    
                    Text("Измеряйте в одном ритме")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(textPrimary)
                    
                    Text("Утро около 07:00 · вечер около 20:00 · до внесения данных можно быстро свериться с подсказками.")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)
                        .lineSpacing(2)
                }
                
                Spacer()
                
            }
            
            VStack(spacing: 10) {
                instructionStep(number: "1", title: "Сядьте спокойно на 5 минут", text: "Измеряйте после короткого отдыха, без спешки, разговора и физической нагрузки.")
                instructionStep(number: "2", title: "Держите руку на уровне сердца", text: "Манжета должна быть надета правильно, а положение тела — стабильным и удобным.")
                instructionStep(number: "3", title: "Внесите SYS, DIA и пульс", text: "После измерения сразу заполните утренний или вечерний блок, чтобы не терять точность.")
                instructionStep(number: "4", title: "Проверьте цветовой статус", text: "Приложение покажет зону давления и поможет заметить изменения в динамике.")
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
    
    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Цветовые зоны")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                
            }
            
            VStack(spacing: 10) {
                zoneCard(color: green, title: "Норма", subtitle: "Ниже 130 / 80", tagText: "Спокойно", tagBackground: Color(red: 0.07, green: 0.18, blue: 0.14), tagForeground: green)
                zoneCard(color: yellow, title: "Гипертония 1", subtitle: "130–159 или 80–99", tagText: "Контроль", tagBackground: Color(red: 0.16, green: 0.13, blue: 0.08), tagForeground: yellow)
                zoneCard(color: red, title: "Гипертония 2", subtitle: "160+ или 100+", tagText: "Высоко", tagBackground: Color(red: 0.20, green: 0.09, blue: 0.10), tagForeground: red)
                zoneCard(color: blue, title: "Гипотония", subtitle: "Ниже 90 / 60", tagText: "Низко", tagBackground: Color(red: 0.07, green: 0.14, blue: 0.22), tagForeground: blue)
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }
    
    private var attentionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Когда обратить внимание")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(textPrimary)
                Spacer()
                
            }
            
            VStack(spacing: 10) {
                attentionRow(title: "Несколько высоких дней подряд", subtitle: "Повторяющиеся значения выше цели", value: "Проверьте сводку и график")
                attentionRow(title: "Резкий скачок давления", subtitle: "Особенно при плохом самочувствии", value: "Не игнорируйте симптомы")
                attentionRow(title: "Очень низкие значения", subtitle: "Слабость, головокружение, сонливость", value: "Сравните с предыдущими днями")
            }
        }
        .padding(18)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(line, lineWidth: 1))
    }
    
    private func instructionStep(number: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.08, green: 0.19, blue: 0.19))
                    .frame(width: 34, height: 34)
                
                Text(number)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(teal)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(textPrimary)
                
                Text(text)
                    .font(.caption)
                    .foregroundStyle(textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(line, lineWidth: 1))
    }
    
    private func zoneCard(color: Color, title: String, subtitle: String, tagText: String, tagBackground: Color, tagForeground: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                    
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(textPrimary)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(textSecondary)
                    .padding(.leading, 20)
            }
            
            Spacer()
            
            statusTag(tagText, background: tagBackground, foreground: tagForeground)
        }
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(line, lineWidth: 1))
    }
    
    private func attentionRow(title: String, subtitle: String, value: String) -> some View {
        HStack(alignment: .center) {
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
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 128, alignment: .trailing)
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
}
