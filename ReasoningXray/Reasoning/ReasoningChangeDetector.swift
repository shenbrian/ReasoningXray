import Foundation

struct ReasoningChangeDetector {

    func detectChanges(
        from previous: Visit?,
        to current: Visit
    ) -> [ReasoningChange] {
        guard let previous else { return [] }

        var changes: [ReasoningChange] = []

        if isContinuedMonitoring(from: previous, to: current) {
            changes.append(
                ReasoningChange(
                    kind: .continuedMonitoring,
                    traceSummary: "Decision or next steps in both visits indicate continued monitoring or follow-up."
                )
            )
        }

        if didReconsiderExplanation(from: previous, to: current) {
            changes.append(
                ReasoningChange(
                    kind: .reconsideredExplanation,
                    traceSummary: "Doctor explanation meaningfully changed between visits."
                )
            )
        }

        if didOrderTesting(from: previous, to: current) {
            changes.append(
                ReasoningChange(
                    kind: .orderedTesting,
                    traceSummary: "Decision or next steps in the current visit mention new testing."
                )
            )
        }

        if didStartTreatmentTrial(from: previous, to: current) {
            changes.append(
                ReasoningChange(
                    kind: .startedTreatmentTrial,
                    traceSummary: "Decision or next steps in the current visit mention starting treatment."
                )
            )
        }

        if didGainNewEvidence(from: previous, to: current) {
            changes.append(
                ReasoningChange(
                    kind: .newEvidenceInfluencedReasoning,
                    traceSummary: "New evidence items were added in the current visit."
                )
            )
        }

        return changes
    }
}

private extension ReasoningChangeDetector {

    func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    func normalizedSet(_ items: [String]) -> Set<String> {
        Set(
            items
                .map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                }
                .filter { !$0.isEmpty }
        )
    }

    func combinedDecisionText(for visit: Visit) -> String {
        normalized("\(visit.decision) \(visit.nextSteps.joined(separator: " "))")
    }

    func isMonitoringText(_ text: String) -> Bool {
        text.contains("monitor")
        || text.contains("observe")
        || text.contains("watch")
        || text.contains("follow up")
        || text.contains("follow-up")
        || text.contains("review")
        || text.contains("wait and see")
    }

    func containsTestingText(_ text: String) -> Bool {
        text.contains("test")
        || text.contains("x-ray")
        || text.contains("xray")
        || text.contains("scan")
        || text.contains("mri")
        || text.contains("ct")
        || text.contains("ultrasound")
        || text.contains("blood")
        || text.contains("swab")
        || text.contains("urine")
        || text.contains("spirometry")
        || text.contains("imaging")
    }

    func containsTreatmentStartText(_ text: String) -> Bool {
        text.contains("start ")
        || text.contains("begin ")
        || text.contains("trial ")
        || text.contains("try ")
        || text.contains("prescribe")
        || text.contains("inhaler")
        || text.contains("antibiotic")
        || text.contains("medication")
        || text.contains("medicine")
        || text.contains("cream")
        || text.contains("physio")
        || text.contains("therapy")
        || text.contains("iron")
    }

    func containsOngoingTreatmentText(_ text: String) -> Bool {
        text.contains("continue inhaler")
        || text.contains("continue treatment")
        || text.contains("continue medication")
        || text.contains("continue antibiotics")
        || text.contains("continue therapy")
        || text.contains("continue iron")
        || text.contains("continue current treatment")
    }

    func isContinuedMonitoring(from previous: Visit, to current: Visit) -> Bool {
        let previousText = combinedDecisionText(for: previous)
        let currentText = combinedDecisionText(for: current)

        guard isMonitoringText(previousText), isMonitoringText(currentText) else {
            return false
        }

        if containsTestingText(currentText) || containsTreatmentStartText(currentText) || containsOngoingTreatmentText(currentText) {
            return false
        }

        return true
    }

    func didReconsiderExplanation(from previous: Visit, to current: Visit) -> Bool {
        let prev = normalized(previous.doctorExplanation)
        let curr = normalized(current.doctorExplanation)

        guard !prev.isEmpty, !curr.isEmpty, prev != curr else {
            return false
        }

        let shiftMarkers = [
            "less likely",
            "more likely",
            "instead",
            "rather than",
            "now seems",
            "now think",
            "no longer",
            "supports",
            "supported",
            "suggest",
            "suggests",
            "suggested",
            "most likely"
        ]

        if shiftMarkers.contains(where: { curr.contains($0) || prev.contains($0) }) {
            return true
        }

        let previousDiagnoses = normalizedSet(previous.diagnosesConsidered)
        let currentDiagnoses = normalizedSet(current.diagnosesConsidered)

        return previousDiagnoses != currentDiagnoses
    }

    func didOrderTesting(from previous: Visit, to current: Visit) -> Bool {
        let prevText = combinedDecisionText(for: previous)
        let currText = combinedDecisionText(for: current)

        return !containsTestingText(prevText) && containsTestingText(currText)
    }

    func didStartTreatmentTrial(from previous: Visit, to current: Visit) -> Bool {
        let prevText = combinedDecisionText(for: previous)
        let currText = combinedDecisionText(for: current)

        return !containsTreatmentStartText(prevText) && containsTreatmentStartText(currText)
    }

    func didGainNewEvidence(from previous: Visit, to current: Visit) -> Bool {
        let prevEvidence = normalizedSet(previous.evidence)
        let currEvidence = normalizedSet(current.evidence)

        return !currEvidence.subtracting(prevEvidence).isEmpty
    }

    func signalStrength(
        explanationText: String,
        evidenceText: String
    ) -> ReasoningSignalStrength {

        let text = (explanationText + " " + evidenceText).lowercased()

        if text.contains("this supports") ||
           text.contains("this confirms") ||
           text.contains("this explains") ||
           text.contains("because of the response") {
            return .explicit
        }

        if text.contains("improved") ||
           text.contains("better") ||
           text.contains("response") {
            return .inferred
        }

        if text.contains("review") ||
           text.contains("monitor") {
            return .weak
        }

        return .none
    }
}
