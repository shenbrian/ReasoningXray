import Foundation

struct WorkingExplanationDetector {

    func detect(for visits: [Visit]) -> WorkingExplanation? {
        let orderedVisits = visits.sorted { $0.visitDate < $1.visitDate }

        guard let latest = orderedVisits.last else {
            return nil
        }

        let latestHypothesis = cleaned(latest.whatMightBeHappening)
        let latestDoctorExplanation = cleaned(latest.doctorExplanation)
        let diagnoses = latest.diagnosesConsidered
            .map { cleaned($0) }
            .filter { !$0.isEmpty }

        let title = buildTitle(
            from: diagnoses,
            hypothesis: latestHypothesis,
            doctorExplanation: latestDoctorExplanation
        )

        let explanation = buildExplanation(
            hypothesis: latestHypothesis,
            doctorExplanation: latestDoctorExplanation,
            reasonForVisit: latest.reasonForVisit
        )

        let confidenceNote = buildConfidenceNote(from: latest)
        let traceSummary = buildTraceSummary(from: latest, diagnoses: diagnoses)

        return WorkingExplanation(
            title: title,
            explanation: explanation,
            confidenceNote: confidenceNote,
            traceSummary: traceSummary
        )
    }
}

private extension WorkingExplanationDetector {

    func cleaned(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func buildTitle(
        from diagnoses: [String],
        hypothesis: String,
        doctorExplanation: String
    ) -> String {

        if let firstDiagnosis = diagnoses.first {
            return softenDiagnosisLabel(firstDiagnosis)
        }

        let lowerHypothesis = hypothesis.lowercased()

        if lowerHypothesis.contains("airway") && lowerHypothesis.contains("asthma") {
            return "Airway irritation (possible asthma)"
        }

        if lowerHypothesis.contains("asthma") {
            return "Possible asthma"
        }

        if lowerHypothesis.contains("airway") {
            return "Airway irritation"
        }

        if lowerHypothesis.contains("infection") || lowerHypothesis.contains("viral") {
            return "Possible infection-related cause"
        }

        if lowerHypothesis.contains("blood pressure") || lowerHypothesis.contains("hypertension") {
            return "Persistent blood pressure elevation"
        }

        if !hypothesis.isEmpty || !doctorExplanation.isEmpty {
            return "Current leading explanation"
        }

        return "Explanation still being assessed"
    }

    func buildExplanation(
        hypothesis: String,
        doctorExplanation: String,
        reasonForVisit: String
    ) -> String {

        if !hypothesis.isEmpty {
            return softenExplanationSentence(hypothesis)
        }

        if !doctorExplanation.isEmpty {
            return softenExplanationSentence(doctorExplanation)
        }

        return "The doctor is still assessing possible explanations for \(reasonForVisit.lowercased())."
    }

    func buildConfidenceNote(from visit: Visit) -> String {
        let decisionText = "\(visit.decision) \(visit.nextSteps.joined(separator: " "))".lowercased()
        let evidenceText = visit.evidence.joined(separator: " ").lowercased()

        if evidenceText.contains("improvement") &&
            (decisionText.contains("continue inhaler") ||
             decisionText.contains("continue treatment") ||
             decisionText.contains("continue medication") ||
             decisionText.contains("continue antibiotics")) {
            return "This explanation appears more supported because the response over time seems to fit it better."
        }

        if decisionText.contains("trial") ||
            decisionText.contains("test") ||
            decisionText.contains("x-ray") ||
            decisionText.contains("scan") {
            return "This still appears to be a working explanation rather than a fully settled conclusion."
        }

        if decisionText.contains("monitor") || decisionText.contains("watch") || decisionText.contains("review") {
            return "The doctor still appears to be watching how the situation develops."
        }

        return "This reflects the doctor’s current leading explanation from the latest visit."
    }

    func buildTraceSummary(from visit: Visit, diagnoses: [String]) -> String {
        if !visit.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Derived primarily from the latest 'what might be happening' field."
        }

        if !diagnoses.isEmpty {
            return "Derived from the latest diagnoses considered."
        }

        return "Derived from the latest doctor explanation."
    }

    func softenDiagnosisLabel(_ diagnosis: String) -> String {
        let lower = diagnosis.lowercased()

        if lower == "asthma" {
            return "Possible asthma"
        }

        if lower == "infection" {
            return "Possible infection"
        }

        if lower == "viral illness" {
            return "Possible viral illness"
        }

        if lower == "hypertension" {
            return "Possible hypertension"
        }

        return diagnosis
    }

    func softenExplanationSentence(_ text: String) -> String {
        let trimmed = cleaned(text)
        let lower = trimmed.lowercased()

        if lower.hasPrefix("the doctor currently seems to think") {
            return trimmed
        }

        if lower.hasPrefix("the doctor thinks") {
            return trimmed.replacingOccurrences(
                of: "The doctor thinks",
                with: "The doctor currently seems to think"
            )
        }

        if lower.hasPrefix("this may be") || lower.hasPrefix("this seems") || lower.hasPrefix("the doctor") {
            return trimmed
        }

        return "The doctor currently seems to think \(trimmed.prefix(1).lowercased() + trimmed.dropFirst())"
    }
}
