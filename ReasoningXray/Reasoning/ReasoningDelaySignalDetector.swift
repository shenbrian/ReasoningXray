import Foundation

struct ReasoningDelaySignal {
    let visitCountBeforeClarity: Int
    let summary: String
    let patientMessage: String
}

struct ReasoningDelaySignalDetector {

    func detect(in comparisons: [VisitReasoningComparison]) -> ReasoningDelaySignal? {
        guard comparisons.count >= 3 else { return nil }

        let sorted = comparisons.sorted { $0.currentVisit.visitDate < $1.currentVisit.visitDate }

        var repeatedUnsettledCount = 0
        var foundClarifyingShift = false

        for comparison in sorted {
            let stage = comparison.stage
            let hasTurningPoint = comparison.turningPoint != nil
            let hasMajorChange = comparison.changes.contains { change in
                switch change.kind {
                case .reconsideredExplanation,
                     .orderedTesting,
                     .startedTreatmentTrial,
                     .newEvidenceInfluencedReasoning:
                    return true
                case .continuedMonitoring:
                    return false
                }
            }

            switch stage {
            case .exploration, .narrowing:
                if !hasTurningPoint && !hasMajorChange {
                    repeatedUnsettledCount += 1
                } else if repeatedUnsettledCount > 0 {
                    foundClarifyingShift = true
                    break
                }

            case .workingExplanation, .confirmation:
                if repeatedUnsettledCount > 0 {
                    foundClarifyingShift = true
                    break
                }
            }
        }

        guard repeatedUnsettledCount >= 2, foundClarifyingShift else {
            return nil
        }

        return ReasoningDelaySignal(
            visitCountBeforeClarity: repeatedUnsettledCount,
            summary: "The reasoning stayed unsettled for \(repeatedUnsettledCount) visits before becoming clearer.",
            patientMessage: "The cause was not clear at first and became clearer over time."
        )
    }
}
