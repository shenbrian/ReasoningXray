import Foundation

struct ReasoningWatchpointDetector {

    func detect(for comparisons: [VisitReasoningComparison], thread: CaseThread) -> [ReasoningWatchpoint] {
        guard !comparisons.isEmpty else { return [] }

        var watchpoints: [ReasoningWatchpoint] = []

        let allEvidenceText = comparisons
            .flatMap { $0.currentVisit.evidence }
            .joined(separator: " ")
            .lowercased()

        let allDecisionText = comparisons
            .map { "\($0.currentVisit.decision) \($0.currentVisit.nextSteps.joined(separator: " "))" }
            .joined(separator: " ")
            .lowercased()

        let hasConfirmationLanguage = thread.stillUncertain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false

        let hasPersistenceSignals =
            allEvidenceText.contains("persist") ||
            allEvidenceText.contains("still present") ||
            allEvidenceText.contains("no improvement") ||
            allEvidenceText.contains("ongoing") ||
            allEvidenceText.contains("several weeks")

        let hasEscalationSignals =
            allDecisionText.contains("x-ray") ||
            allDecisionText.contains("scan") ||
            allDecisionText.contains("test") ||
            allDecisionText.contains("trial") ||
            allDecisionText.contains("prescribed")

        let hasResponseSignals =
            allEvidenceText.contains("improvement") ||
            allEvidenceText.contains("response") ||
            allEvidenceText.contains("partial response") ||
            allEvidenceText.contains("better")

        let reconsiderationCount = comparisons.filter {
            $0.movement == .explanationReconsidered
        }.count

        if hasConfirmationLanguage {
            watchpoints.append(
                ReasoningWatchpoint(
                    kind: .explanationStillUnconfirmed,
                    summary: "The doctor’s current explanation remains provisional rather than fully settled."
                )
            )
        }

        if hasPersistenceSignals {
            watchpoints.append(
                ReasoningWatchpoint(
                    kind: .persistentSymptoms,
                    summary: "Symptoms appear to have continued long enough to influence the reasoning."
                )
            )
        }

        if hasEscalationSignals {
            watchpoints.append(
                ReasoningWatchpoint(
                    kind: .escalationAfterInitialExplanation,
                    summary: "The reasoning moved from an initial explanation into more active testing or treatment."
                )
            )
        }

        if hasResponseSignals {
            watchpoints.append(
                ReasoningWatchpoint(
                    kind: .responseUsedToClarify,
                    summary: "Treatment response appears to have helped clarify the doctor’s thinking."
                )
            )
        }

        if reconsiderationCount >= 1 {
            watchpoints.append(
                ReasoningWatchpoint(
                    kind: .repeatedReassessment,
                    summary: "The explanation was revisited as new information appeared across visits."
                )
            )
        }

        return deduplicated(watchpoints)
    }

    private func deduplicated(_ watchpoints: [ReasoningWatchpoint]) -> [ReasoningWatchpoint] {
        var seen: Set<ReasoningWatchpointKind> = []
        var result: [ReasoningWatchpoint] = []

        for watchpoint in watchpoints {
            if !seen.contains(watchpoint.kind) {
                seen.insert(watchpoint.kind)
                result.append(watchpoint)
            }
        }

        return result
    }
}

