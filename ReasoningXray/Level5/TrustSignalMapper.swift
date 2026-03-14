import Foundation

struct TrustSignalMapper {

    func visitStatus(for comparison: VisitReasoningComparison) -> EpistemicStatus {
        if hasExplicitObservedChange(in: comparison.changes) {
            return .observed
        }

        if comparison.turningPoint != nil {
            return .provisional
        }

        switch comparison.stage {
        case .exploration:
            return .provisional

        case .narrowing:
            return .evolving

        case .workingExplanation:
            return .inferred

        case .confirmation:
            return .stable
        }
    }

    func trajectoryStatus(for summary: CaseTrajectorySummary) -> EpistemicStatus {
        if summary.activeUncertainty {
            return .provisional
        }

        switch summary.overallPath {
        case .earlyExploration:
            return .provisional

        case .narrowing:
            return .evolving

        case .workingDiagnosis:
            return .inferred

        case .confirmation:
            return .stable

        case .monitoring:
            return .observed

        case .reopened:
            return .provisional

        case .mixed:
            return .evolving
        }
    }

    func watchpointStatus(for watchpoint: ReasoningWatchpoint) -> EpistemicStatus {
        switch watchpoint.kind {
        case .explanationStillUnconfirmed:
            return .provisional

        case .persistentSymptoms:
            return .evolving

        case .escalationAfterInitialExplanation:
            return .evolving

        case .responseUsedToClarify:
            return .observed

        case .repeatedReassessment:
            return .inferred
        }
    }

    private func hasExplicitObservedChange(in changes: [ReasoningChange]) -> Bool {
        changes.contains { (change: ReasoningChange) in
            switch change.kind {
            case .continuedMonitoring,
                 .orderedTesting,
                 .startedTreatmentTrial,
                 .newEvidenceInfluencedReasoning:
                return true

            case .reconsideredExplanation:
                return false
            }
        }
    }
}
