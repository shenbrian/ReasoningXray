import Foundation

struct SharePackageOptions: Codable, Hashable {
    
    var includeTranscript: Bool
    var includeDoctorReasoningMirror: Bool
    var includePatientTranslation: Bool
    var includeTimelineSummary: Bool
    
    var redactDoctorName: Bool
    var redactClinicName: Bool
    var redactLocation: Bool
    
    var language: DisplayLanguage
    var mirrorLanguageMode: MirrorLanguageMode
}
