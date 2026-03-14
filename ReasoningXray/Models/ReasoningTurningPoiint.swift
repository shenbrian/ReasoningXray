import Foundation

enum ReasoningTurningPointKind: String, Codable, CaseIterable, Identifiable {
    case initialFrame
    case explanationPivot
    case movedToTesting
    case movedToTreatmentTrial
    case responseShift
    case escalation

    var id: String { rawValue }

    var timelineLabel: String {
        switch self {
        case .initialFrame:
            return "Initial reasoning frame"
        case .explanationPivot:
            return "Reasoning pivot"
        case .movedToTesting:
            return "Shifted to testing"
        case .movedToTreatmentTrial:
            return "Shifted to treatment trial"
        case .responseShift:
            return "Response changed the reasoning"
        case .escalation:
            return "Reasoning escalated"
        }
    }

    var patientExplanation: String {
        switch self {
        case .initialFrame:
            return "This was the doctor’s first recorded way of framing the problem."
        case .explanationPivot:
            return "The doctor’s explanation changed in a meaningful way."
        case .movedToTesting:
            return "The doctor moved from watching the problem to actively gathering more evidence."
        case .movedToTreatmentTrial:
            return "The doctor moved from observation into using treatment to help clarify the problem."
        case .responseShift:
            return "The doctor used the response to treatment or time to update the explanation."
        case .escalation:
            return "The doctor moved to a stronger or more active next step."
        }
    }
}

struct ReasoningTurningPoint: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: ReasoningTurningPointKind
    let traceSummary: String

    init(
        id: UUID = UUID(),
        kind: ReasoningTurningPointKind,
        traceSummary: String
    ) {
        self.id = id
        self.kind = kind
        self.traceSummary = traceSummary
    }
}
