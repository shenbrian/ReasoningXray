import Foundation

struct ReasoningTurningPointDetector {

    func detectTurningPoint(
        previousVisit: Visit?,
        currentVisit: Visit,
        previousMovement: ReasoningMovement?,
        currentMovement: ReasoningMovement,
        changes: [ReasoningChange]
    ) -> ReasoningTurningPoint? {

        guard let previousVisit else {
            return ReasoningTurningPoint(
                kind: .initialFrame,
                traceSummary: "This is the first recorded visit in the issue thread."
            )
        }

        let previousDecision = normalized("\(previousVisit.decision) \(previousVisit.nextSteps.joined(separator: " "))")
        let currentDecision = normalized("\(currentVisit.decision) \(currentVisit.nextSteps.joined(separator: " "))")
        let currentEvidence = normalized(currentVisit.evidence.joined(separator: " "))
        let currentExplanation = normalized(currentVisit.doctorExplanation)

        if currentMovement == .testing,
           previousMovement != .testing {
            return ReasoningTurningPoint(
                kind: .movedToTesting,
                traceSummary: "Decision moved from monitoring or observation into testing."
            )
        }

        if currentMovement == .treatmentTrial,
           previousMovement != .treatmentTrial {
            return ReasoningTurningPoint(
                kind: .movedToTreatmentTrial,
                traceSummary: "Decision moved into a treatment trial."
            )
        }

        if currentMovement == .responseObserved,
           previousMovement != .responseObserved {
            return ReasoningTurningPoint(
                kind: .responseShift,
                traceSummary: "Evidence and decision indicate treatment response influenced the reasoning."
            )
        }

        let hasPositiveResponseLanguage =
            currentEvidence.contains("improvement") ||
            currentEvidence.contains("improved") ||
            currentEvidence.contains("better") ||
            currentEvidence.contains("partial response") ||
            currentEvidence.contains("some improvement") ||
            currentEvidence.contains("responded") ||
            currentExplanation.contains("supports") ||
            currentExplanation.contains("supported")

        if changes.contains(where: { $0.kind == .reconsideredExplanation }) &&
            !hasPositiveResponseLanguage &&
            currentMovement != .responseObserved {
            return ReasoningTurningPoint(
                kind: .explanationPivot,
                traceSummary: "Doctor explanation changed between visits."
            )
        }

        if isEscalation(from: previousDecision, to: currentDecision) {
            return ReasoningTurningPoint(
                kind: .escalation,
                traceSummary: "Decision changed from a lighter step to a more active step."
            )
        }

        return nil
    }
}

private extension ReasoningTurningPointDetector {

    func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func decisionLevel(_ text: String) -> Int {

        if text.contains("continue inhaler") ||
           text.contains("continue treatment") ||
           text.contains("continue medication") {
            return 4
        }

        if text.contains("trial") ||
           text.contains("start") ||
           text.contains("begin") ||
           text.contains("prescribe") {
            return 3
        }

        if text.contains("x-ray") ||
           text.contains("xray") ||
           text.contains("test") ||
           text.contains("scan") {
            return 2
        }

        if text.contains("monitor") ||
           text.contains("watch") ||
           text.contains("follow up") ||
           text.contains("follow-up") {
            return 1
        }

        return 0
    }

    func isEscalation(from previousDecision: String, to currentDecision: String) -> Bool {
        decisionLevel(currentDecision) > decisionLevel(previousDecision)
    }
}
