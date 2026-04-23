import Foundation

enum BPAnalyzer {
    static func status(systolic: Int?, diastolic: Int?) -> BPStatus {
        guard let systolic, let diastolic else { return .unknown }

        if systolic < 90 || diastolic < 60 {
            return .hypotension
        }

        if systolic >= 160 || diastolic >= 100 {
            return .hypertension2
        }

        if systolic >= 130 || diastolic >= 80 {
            return .hypertension1
        }

        return .normal
    }

    static func dayAverage(_ first: Int?, _ second: Int?) -> Double? {
        switch (first, second) {
        case let (a?, b?):
            return Double(a + b) / 2.0
        case let (a?, nil):
            return Double(a)
        case let (nil, b?):
            return Double(b)
        default:
            return nil
        }
    }

    static func averageSystolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.flatMap { entry in
            [entry.morningSystolic, entry.eveningSystolic]
        }
        .compactMap { $0 }

        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averageDiastolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.flatMap { entry in
            [entry.morningDiastolic, entry.eveningDiastolic]
        }
        .compactMap { $0 }

        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averagePulse(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.flatMap { entry in
            [entry.morningPulse, entry.eveningPulse]
        }
        .compactMap { $0 }

        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averageMorningSystolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.compactMap { $0.morningSystolic }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averageEveningSystolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.compactMap { $0.eveningSystolic }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averageMorningDiastolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.compactMap { $0.morningDiastolic }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    static func averageEveningDiastolic(for entries: [DailyBPEntry]) -> Double? {
        let values = entries.compactMap { $0.eveningDiastolic }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}
