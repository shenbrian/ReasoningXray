import Foundation

enum ReasoningShiftKind: String, Codable, CaseIterable, Identifiable {
    case explanationShift
    case evidenceTension
    case managementEscalation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .explanationShift:
            return "Reasoning shift detected"
        case .evidenceTension:
            return "New evidence changed the earlier picture"
        case .managementEscalation:
            return "Management became more active"
        }
    }

    var patientExplanation: String {
        switch self {
        case .explanationShift:
            return "The doctor’s current explanation appears meaningfully different from the earlier one."
        case .evidenceTension:
            return "New findings or treatment response appear to have made the earlier explanation less convincing."
        case .managementEscalation:
            return "The doctor moved from watching the problem to taking a more active step, suggesting the earlier view no longer fully fit."
        }
    }
}

struct ReasoningShift: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: ReasoningShiftKind
    let summary: String
    let traceSummary: String

    init(
        id: UUID = UUID(),
        kind: ReasoningShiftKind,
        summary: String,
        traceSummary: String
    ) {
        self.id = id
        self.kind = kind
        self.summary = summary
        self.traceSummary = traceSummary
    }
}
