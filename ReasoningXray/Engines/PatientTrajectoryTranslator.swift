import Foundation

struct PatientTrajectoryTranslator {

    func translate(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> PatientTrajectoryTranslation {

        let narrativeMeaning = makeNarrativeMeaning(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        let reassuranceFraming = makeReassuranceFraming(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        let forwardExpectation = makeForwardExpectation(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        let decisionSafetyFraming = makeDecisionSafetyFraming(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        return PatientTrajectoryTranslation(
            narrativeMeaning: narrativeMeaning,
            reassuranceFraming: reassuranceFraming,
            forwardExpectation: forwardExpectation,
            decisionSafetyFraming: decisionSafetyFraming
        )
    }

    private func makeNarrativeMeaning(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        switch overallPath {
        case .confirmation:
            return activeUncertainty
                ? "The doctor's thinking appears to be moving toward a clearer explanation, although some uncertainty is still present."
                : "The doctor's thinking appears to be settling around a clearer explanation."

        case .workingDiagnosis:
            return activeUncertainty
                ? "The doctor's thinking appears to be forming a likely explanation, but the picture is not fully settled yet."
                : "The doctor's thinking appears to be settling around a likely explanation."

        case .narrowing:
            return activeUncertainty
                ? "The doctor's thinking appears to be narrowing toward a more focused explanation, but some uncertainty is still present."
                : "The doctor's thinking appears to be narrowing toward a more focused explanation."

        case .earlyExploration:
            return "The doctor's thinking appears to still be exploring different possible explanations."

        case .monitoring:
            return "The doctor's thinking appears to be monitoring the situation over time rather than reaching a final explanation yet."

        case .reopened:
            return "The doctor's thinking appears to be reconsidering the earlier explanation and reopening the case."

        case .mixed:
            return "The doctor's reasoning appears to contain both forward progress and unresolved uncertainty at the same time."
        }
    }

    private func makeReassuranceFraming(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "This usually suggests the situation is becoming clearer and more stable."
        }

        if overallPath == .workingDiagnosis && certaintyTrend != .decreasing {
            return activeUncertainty
                ? "This suggests the doctor is moving toward a likely explanation, even though some uncertainty remains."
                : "This suggests the doctor has reached a more defined working explanation."
        }

        if overallPath == .narrowing && momentum == .advancing {
            return activeUncertainty
                ? "This suggests progress is being made, even though some uncertainty remains."
                : "This suggests the picture is becoming more focused."
        }

        if overallPath == .reopened || certaintyTrend == .decreasing {
            return "This does not necessarily mean something is wrong, but it does mean the reasoning is still being actively reassessed."
        }

        if overallPath == .earlyExploration {
            return "At this stage, it is normal for the reasoning to still be open while different possibilities are being considered."
        }

        if overallPath == .monitoring {
            return "This suggests the situation is being watched carefully over time rather than rushed to a conclusion."
        }

        if activeUncertainty {
            return "It is reasonable that things still feel open at this stage, because the reasoning has not fully settled yet."
        }

        return "The reasoning appears to be moving in an orderly way, even if it is not fully final yet."
    }

    private func makeForwardExpectation(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        switch overallPath {
        case .confirmation:
            return "Expect the next steps to focus more on confirming or acting on the current explanation."

        case .workingDiagnosis:
            return "Expect the next steps to test, confirm, or refine the current working explanation."

        case .narrowing:
            return "Expect the next steps to further clarify which explanation best fits the pattern."

        case .earlyExploration:
            return "Expect the next steps to involve more questions, comparisons, or early tests before the picture becomes clearer."

        case .monitoring:
            return "Expect follow-up or observation over time rather than immediate closure."

        case .reopened:
            return "Expect the next steps to involve reconsideration, new questions, or different tests before things become clearer."

        case .mixed:
            return "Expect some parts of the reasoning to move forward while other parts may still need clarification."
        }
    }

    private func makeDecisionSafetyFraming(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "At this point, the reasoning appears relatively stable rather than exploratory."
        }

        if overallPath == .workingDiagnosis && !activeUncertainty {
            return "The reasoning appears to have reached a working explanation, although it may still need confirmation."
        }

        if overallPath == .narrowing && !activeUncertainty {
            return "The reasoning is becoming more focused, though it still appears somewhat provisional."
        }

        if overallPath == .monitoring {
            return "The situation does not yet appear fully settled, and continued follow-up may still matter."
        }

        if overallPath == .earlyExploration || overallPath == .mixed {
            return "This stage should be understood as still developing rather than settled."
        }

        if overallPath == .reopened || certaintyTrend == .decreasing || activeUncertainty {
            return "The reasoning still appears open, so it is safer to view the current explanation as provisional."
        }

        return "The current explanation should still be viewed as developing rather than final."
    }
}
