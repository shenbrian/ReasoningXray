import Foundation

enum ReasoningStage: String, Codable, CaseIterable, Identifiable {
    case exploration
    case narrowing
    case workingExplanation
    case confirmation

    var id: String { rawValue }

    var timelineLabel: String {
        switch self {
        case .exploration:
            return "Exploration"
        case .narrowing:
            return "Narrowing"
        case .workingExplanation:
            return "Working explanation"
        case .confirmation:
            return "Confirmation"
        }
    }

    var patientExplanation: String {
        switch self {
        case .exploration:
            return "The doctor is still exploring possible explanations and gathering direction."
        case .narrowing:
            return "The doctor is narrowing down the possibilities based on how the problem is evolving."
        case .workingExplanation:
            return "The doctor now seems to have a stronger working explanation guiding the next step."
        case .confirmation:
            return "The doctor is checking whether results or treatment response support the current explanation."
        }
    }
}
