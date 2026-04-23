import Foundation
import SwiftData

@Model
final class DailyBPEntry {
    var date: Date

    var morningSystolic: Int?
    var morningDiastolic: Int?
    var morningPulse: Int?
    var morningTime: Date

    var eveningSystolic: Int?
    var eveningDiastolic: Int?
    var eveningPulse: Int?
    var eveningTime: Date

    var medicationDose: String?
    var wellBeing: String?
    var comment: String?

    init(
        date: Date = Date(),
        morningSystolic: Int? = nil,
        morningDiastolic: Int? = nil,
        morningPulse: Int? = nil,
        morningTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
        eveningSystolic: Int? = nil,
        eveningDiastolic: Int? = nil,
        eveningPulse: Int? = nil,
        eveningTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
        medicationDose: String? = nil,
        wellBeing: String? = nil,
        comment: String? = nil
    ) {
        self.date = date
        self.morningSystolic = morningSystolic
        self.morningDiastolic = morningDiastolic
        self.morningPulse = morningPulse
        self.morningTime = morningTime
        self.eveningSystolic = eveningSystolic
        self.eveningDiastolic = eveningDiastolic
        self.eveningPulse = eveningPulse
        self.eveningTime = eveningTime
        self.medicationDose = medicationDose
        self.wellBeing = wellBeing
        self.comment = comment
    }
}
