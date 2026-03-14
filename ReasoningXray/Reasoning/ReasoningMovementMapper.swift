import Foundation

struct ReasoningMovementMapper {

    func movement(
        previousVisit: Visit?,
        currentVisit: Visit,
        changes: [ReasoningChange]
    ) -> ReasoningMovement {

        guard previousVisit != nil else {
            return .initialExplanation
        }

        let decisionText = normalized("\(currentVisit.decision) \(currentVisit.nextSteps.joined(separator: " "))")
        let explanationText = normalized(currentVisit.doctorExplanation + " " + currentVisit.whatMightBeHappening)
        let evidenceText = normalized(currentVisit.evidence.joined(separator: " "))

        let hasExplicitTesting =
            decisionText.contains("x-ray") ||
            decisionText.contains("xray") ||
            decisionText.contains("blood test") ||
            decisionText.contains("scan") ||
            decisionText.contains("test") ||
            decisionText.contains("imaging")

        let hasExplicitTreatmentTrial =
            decisionText.contains("trial inhaler") ||
            decisionText.contains("try inhaler") ||
            decisionText.contains("start inhaler") ||
            decisionText.contains("prescribed inhaler") ||
            decisionText.contains("trial treatment") ||
            decisionText.contains("start treatment") ||
            decisionText.contains("prescribe") ||
            decisionText.contains("prescribed antibiotics") ||
            decisionText.contains("start antibiotics")

        let hasMonitoringLanguage =
            decisionText.contains("monitor") ||
            decisionText.contains("watch") ||
            decisionText.contains("follow up") ||
            decisionText.contains("follow-up") ||
            decisionText.contains("review again") ||
            decisionText.contains("review") ||
            decisionText.contains("come back")

        let hasResponseLanguage =
            evidenceText.contains("improvement") ||
            evidenceText.contains("improved") ||
            evidenceText.contains("better") ||
            evidenceText.contains("partial response") ||
            evidenceText.contains("some improvement") ||
            evidenceText.contains("responded") ||
            explanationText.contains("response")

        let continuesTreatment =
            decisionText.contains("continue inhaler") ||
            decisionText.contains("continue treatment") ||
            decisionText.contains("continue medication") ||
            decisionText.contains("continue antibiotics") ||
            decisionText.contains("continue therapy")

        let hasExplanationShiftLanguage =
            explanationText.contains("less likely") ||
            explanationText.contains("more likely") ||
            explanationText.contains("instead") ||
            explanationText.contains("rather than") ||
            explanationText.contains("now seems") ||
            explanationText.contains("now think") ||
            explanationText.contains("no longer") ||
            changes.contains(where: { $0.kind == .reconsideredExplanation })

        if hasResponseLanguage && continuesTreatment {
            return .responseObserved
        }

        if hasExplicitTesting || changes.contains(where: { $0.kind == .orderedTesting }) {
            return .testing
        }

        if hasExplicitTreatmentTrial || changes.contains(where: { $0.kind == .startedTreatmentTrial }) {
            return .treatmentTrial
        }

        if hasExplanationShiftLanguage {
            return .explanationReconsidered
        }

        if hasMonitoringLanguage || changes.contains(where: { $0.kind == .continuedMonitoring }) {
            return .monitoring
        }

        if changes.contains(where: { $0.kind == .newEvidenceInfluencedReasoning }) {
            return .moreInformationNeeded
        }

        return .moreInformationNeeded
    }

    private func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
