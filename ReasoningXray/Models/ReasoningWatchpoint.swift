import Foundation

enum ReasoningWatchpointKind: String, Codable, CaseIterable, Identifiable {
    case explanationStillUnconfirmed
    case persistentSymptoms
    case escalationAfterInitialExplanation
    case responseUsedToClarify
    case repeatedReassessment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .explanationStillUnconfirmed:
            return "Explanation still being confirmed"
        case .persistentSymptoms:
            return "Symptoms continued across visits"
        case .escalationAfterInitialExplanation:
            return "Reasoning became more active over time"
        case .responseUsedToClarify:
            return "Treatment response helped clarify the picture"
        case .repeatedReassessment:
            return "The explanation was revised over multiple visits"
        }
    }

    var patientExplanation: String {
        switch self {
        case .explanationStillUnconfirmed:
            return "The doctor has a leading explanation, but it is not yet fully confirmed."
        case .persistentSymptoms:
            return "The reasoning changed partly because the symptoms continued rather than settling quickly."
        case .escalationAfterInitialExplanation:
            return "The doctor moved from initial explanation to more active testing or treatment as the picture evolved."
        case .responseUsedToClarify:
            return "The doctor used the response to treatment to better understand what might be going on."
        case .repeatedReassessment:
            return "The doctor revisited the explanation across several visits rather than staying with the first view."
        }
    }
}

struct ReasoningWatchpoint: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: ReasoningWatchpointKind
    let summary: String

    init(id: UUID = UUID(), kind: ReasoningWatchpointKind, summary: String) {
        self.id = id
        self.kind = kind
        self.summary = summary
    }
}
