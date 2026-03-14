import Foundation

struct PatientStorySummary {
    let currentView: String
    let whyItChanged: String
    let nextStep: String
}

final class PatientStorySummarizer {

    private let narrator = ReasoningPatientNarrator()

    func summarize(thread: CaseThread, visits: [Visit]) -> PatientStorySummary {
        let sorted = visits.sorted { $0.visitDate < $1.visitDate }

        guard let latest = sorted.last else {
            return PatientStorySummary(
                currentView: "No reasoning summary available yet.",
                whyItChanged: "No change summary available yet.",
                nextStep: "No next step recorded."
            )
        }

        let currentView: String = {
            let explanation = latest.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines)

            if explanation.isEmpty {
                return "No current explanation recorded."
            }

            return "Based on recent visits, the doctor's current working explanation is: \(explanation)"
        }()

        let whyItChanged: String = {
            let raw = latest.mainChangeSinceLastVisit.trimmingCharacters(in: .whitespacesAndNewlines)

            if raw.isEmpty {
                return "No major reasoning change recorded."
            }

            let lower = raw.lowercased()

            if lower.contains("response") || lower.contains("improv") || lower.contains("better") {
                let strength = signalStrength(
                    explanationText: latest.doctorExplanation,
                    evidenceText: latest.evidence.joined(separator: " ")
                )
                return narrator.responseExplanation(strength: strength)
            }

            return raw
        }()

        let nextStep: String = {
            let direct = latest.whatHappensNext.trimmingCharacters(in: .whitespacesAndNewlines)
            if !direct.isEmpty {
                return direct
            }

            if let first = latest.nextSteps.first?.trimmingCharacters(in: .whitespacesAndNewlines),
               !first.isEmpty {
                return first
            }

            return "No next step recorded."
        }()

        return PatientStorySummary(
            currentView: currentView,
            whyItChanged: whyItChanged,
            nextStep: nextStep
        )
    }

    private func signalStrength(
        explanationText: String,
        evidenceText: String
    ) -> ReasoningSignalStrength {
        let text = (explanationText + " " + evidenceText).lowercased()

        if text.contains("supports") ||
            text.contains("supported") ||
            text.contains("confirms") ||
            text.contains("confirmed") ||
            text.contains("because of the response") {
            return .explicit
        }

        if text.contains("improved") ||
            text.contains("improvement") ||
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
