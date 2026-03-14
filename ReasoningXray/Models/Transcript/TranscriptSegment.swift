import Foundation

enum SpeakerRole: String, Codable, CaseIterable {
    case doctor
    case patient
    case unknown
}

struct TranscriptSegment: Identifiable, Codable, Hashable {
    let id: UUID
    let speaker: SpeakerRole
    let text: String
    let detectedLanguage: SupportedLanguage
    let timestamp: Date?

    init(
        id: UUID = UUID(),
        speaker: SpeakerRole,
        text: String,
        detectedLanguage: SupportedLanguage,
        timestamp: Date? = nil
    ) {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.detectedLanguage = detectedLanguage
        self.timestamp = timestamp
    }
}
