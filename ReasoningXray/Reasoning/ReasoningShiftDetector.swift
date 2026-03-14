import Foundation

struct ReasoningShiftDetector {

    func detect(for visits: [Visit]) -> ReasoningShift? {
        let ordered = visits.sorted { $0.visitDate < $1.visitDate }

        guard ordered.count >= 2,
              let first = ordered.first,
              let last = ordered.last else {
            return nil
        }

        let firstHypothesis = normalized(first.whatMightBeHappening)
        let lastHypothesis = normalized(last.whatMightBeHappening)

        let firstExplanation = normalized(first.doctorExplanation)
        let lastExplanation = normalized(last.doctorExplanation)

        let firstDecision = normalized("\(first.decision) \(first.nextSteps.joined(separator: " "))")
        let lastDecision = normalized("\(last.decision) \(last.nextSteps.joined(separator: " "))")

        let lastEvidence = normalized(last.evidence.joined(separator: " "))

        if meaningfullyDifferent(firstHypothesis, lastHypothesis) ||
            meaningfullyDifferent(firstExplanation, lastExplanation) {

            return ReasoningShift(
                kind: .explanationShift,
                summary: buildExplanationShiftSummary(first: first, last: last),
                traceSummary: "Detected from a meaningful change between the earliest and latest explanation fields."
            )
        }

        if evidenceChallengesEarlierFrame(
            earlierHypothesis: firstHypothesis,
            laterEvidence: lastEvidence,
            laterDecision: lastDecision
        ) {
            return ReasoningShift(
                kind: .evidenceTension,
                summary: buildEvidenceTensionSummary(first: first, last: last),
                traceSummary: "Detected from later evidence or response language that no longer fits the earlier explanation well."
            )
        }

        if decisionLevel(lastDecision) > decisionLevel(firstDecision) + 1 {
            return ReasoningShift(
                kind: .managementEscalation,
                summary: buildEscalationSummary(first: first, last: last),
                traceSummary: "Detected from a shift from lighter management to a more active step."
            )
        }

        return nil
    }
}

private extension ReasoningShiftDetector {

    func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func meaningfullyDifferent(_ lhs: String, _ rhs: String) -> Bool {
        guard !lhs.isEmpty, !rhs.isEmpty else { return false }
        guard lhs != rhs else { return false }

        let lhsCategory = explanationCategory(lhs)
        let rhsCategory = explanationCategory(rhs)

        if lhsCategory != .unknown && rhsCategory != .unknown && lhsCategory != rhsCategory {
            return true
        }

        return lhs != rhs
    }

    enum ExplanationCategory {
        case viralOrInfectious
        case airwayOrAsthma
        case bloodPressure
        case unknown
    }

    func explanationCategory(_ text: String) -> ExplanationCategory {
        if text.contains("viral") || text.contains("infection") || text.contains("post-viral") {
            return .viralOrInfectious
        }
        if text.contains("airway") || text.contains("asthma") || text.contains("inhaler") {
            return .airwayOrAsthma
        }
        if text.contains("blood pressure") || text.contains("hypertension") {
            return .bloodPressure
        }
        return .unknown
    }

    func evidenceChallengesEarlierFrame(
        earlierHypothesis: String,
        laterEvidence: String,
        laterDecision: String
    ) -> Bool {
        if earlierHypothesis.contains("viral") || earlierHypothesis.contains("infection") {
            if laterEvidence.contains("improvement with inhaler") ||
                laterEvidence.contains("partial response") ||
                laterDecision.contains("continue inhaler") ||
                laterDecision.contains("trial inhaler") {
                return true
            }
        }

        if laterEvidence.contains("no improvement") && laterDecision.contains("x-ray") {
            return true
        }

        return false
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

    func buildExplanationShiftSummary(first: Visit, last: Visit) -> String {
        let early = first.whatMightBeHappening.isEmpty ? first.doctorExplanation : first.whatMightBeHappening
        let late = last.whatMightBeHappening.isEmpty ? last.doctorExplanation : last.whatMightBeHappening

        return "The doctor’s explanation appears to have shifted from “\(early)” toward “\(late)” over the course of the visits."
    }

    func buildEvidenceTensionSummary(first: Visit, last: Visit) -> String {
        return "Later findings or treatment response appear to have made the earlier explanation less convincing."
    }

    func buildEscalationSummary(first: Visit, last: Visit) -> String {
        return "The doctor moved from a lighter approach to a more active step, suggesting the earlier view no longer fully fit."
    }
}
