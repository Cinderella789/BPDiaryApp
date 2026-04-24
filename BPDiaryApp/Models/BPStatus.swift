import Foundation
import SwiftUI

enum BPStatus: String, CaseIterable {
    case hypotension = "Гипотония"
    case hypertension2 = "Гипертония 2"
    case hypertension1 = "Гипертония 1"
    case normal = "Норма"
    case unknown = "Нет данных"

    var color: Color {
        switch self {
        case .hypotension: return .blue
        case .hypertension2: return .red
        case .hypertension1: return .orange
        case .normal: return .green
        case .unknown: return .gray
        }
    }

    var symbol: String {
        switch self {
        case .hypotension: return "🔵"
        case .hypertension2: return "🔴"
        case .hypertension1: return "🟡"
        case .normal: return "🟢"
        case .unknown: return "⚪️"
        }
    }
}
