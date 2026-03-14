import Foundation

enum ReasoningMovement: String, Codable, CaseIterable, Identifiable {
    case initialExplanation
    case monitoring
    case moreInformationNeeded
    case explanationReconsidered
    case testing
    case treatmentTrial
    case responseObserved

    var id: String { rawValue }

    var timelineLabel: String {
        switch self {
        case .initialExplanation:
            return "Initial explanation"
        case .monitoring:
            return "Monitoring"
        case .moreInformationNeeded:
            return "More information needed"
        case .explanationReconsidered:
            return "Explanation reconsidered"
        case .testing:
            return "Testing"
        case .treatmentTrial:
            return "Treatment trial"
        case .responseObserved:
            return "Response observed"
        }
    }

    var patientExplanation: String {
        switch self {
        case .initialExplanation:
            return "This was the doctor's first recorded explanation for what might be happening."
        case .monitoring:
            return "The doctor chose to keep watching the problem over time before changing direction."
        case .moreInformationNeeded:
            return "The doctor did not yet have enough information to settle on a stronger explanation."
        case .explanationReconsidered:
            return "The doctor’s earlier explanation changed as the situation developed."
        case .testing:
            return "The doctor moved into gathering more evidence through testing."
        case .treatmentTrial:
            return "The doctor started or used treatment to help clarify what might be going on."
        case .responseObserved:
            return "The doctor used the response to treatment or time as part of the reasoning."
        }
    }

    /// Used to stabilize trajectory progression.
    var progressionRank: Int {
        switch self {
        case .initialExplanation:
            return 0
        case .monitoring, .moreInformationNeeded, .explanationReconsidered:
            return 1
        case .testing:
            return 2
        case .treatmentTrial:
            return 3
        case .responseObserved:
            return 4
        }
    }
}
