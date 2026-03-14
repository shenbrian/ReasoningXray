import Foundation

enum ReasoningChangeKind: String, Codable, CaseIterable, Identifiable {

    case continuedMonitoring
    case reconsideredExplanation
    case orderedTesting
    case startedTreatmentTrial
    case newEvidenceInfluencedReasoning

    var id: String { rawValue }

    // Label shown in the timeline (Layer 1)
    var timelineLabel: String {
        switch self {
        case .continuedMonitoring:
            return "Doctor continued monitoring"

        case .reconsideredExplanation:
            return "Doctor reconsidered the explanation"

        case .orderedTesting:
            return "Doctor ordered testing"

        case .startedTreatmentTrial:
            return "Doctor started a treatment trial"

        case .newEvidenceInfluencedReasoning:
            return "New evidence influenced the reasoning"
        }
    }

    // Patient-facing translation (Layer 2)
    var patientExplanation: String {
        switch self {
        case .continuedMonitoring:
            return "The doctor chose to keep watching the problem before making a new decision."

        case .reconsideredExplanation:
            return "The doctor’s explanation changed compared with the earlier visit."

        case .orderedTesting:
            return "The doctor ordered tests to gather more information."

        case .startedTreatmentTrial:
            return "The doctor started a treatment to see whether it improves the condition."

        case .newEvidenceInfluencedReasoning:
            return "New information from this visit appears to have influenced the doctor’s thinking."
        }
    }
}
