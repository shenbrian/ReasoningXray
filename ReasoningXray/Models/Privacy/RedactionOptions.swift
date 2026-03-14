import Foundation

struct RedactionOptions: Codable, Hashable {
    var redactDoctorName: Bool
    var redactClinicName: Bool
    var redactLocationLikeTerms: Bool

    static let none = RedactionOptions(
        redactDoctorName: false,
        redactClinicName: false,
        redactLocationLikeTerms: false
    )

    static let safeDefault = RedactionOptions(
        redactDoctorName: true,
        redactClinicName: true,
        redactLocationLikeTerms: true
    )
}

