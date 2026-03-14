import Foundation

struct ReasoningStageDetector {

    func stage(for movement: ReasoningMovement) -> ReasoningStage {
        switch movement {
        case .initialExplanation, .moreInformationNeeded:
            return .exploration

        case .monitoring, .explanationReconsidered, .testing:
            return .narrowing

        case .treatmentTrial:
            return .workingExplanation

        case .responseObserved:
            return .confirmation
        }
    }
}
