import Foundation

struct MedicalSafetyGuardResult {
    let sanitized: ExtractedReasoning
    let warnings: [String]
    let blocked: Bool
}

struct MedicalSafetyGuard {

    func review(_ extracted: ExtractedReasoning) -> MedicalSafetyGuardResult {
        var warnings: [String] = []
        var blocked = false

        var safe = extracted

        // Rule 1: no invented diagnosis-style certainty
        if soundsTooDefinitive(safe.whatMightBeHappening) {
            warnings.append("Working explanation sounded too definitive and was softened.")
            safe = replacing(
                safe,
                whatMightBeHappening: soften(safe.whatMightBeHappening)
            )
        }

        // Rule 2: no treatment recommendation language as if AI is advising
        if soundsLikeAdvice(safe.whatHappensNext) {
            warnings.append("Next-step wording sounded like direct advice and was softened.")
            safe = replacing(
                safe,
                whatHappensNext: softenAdvice(safe.whatHappensNext)
            )
        }

        // Rule 3: doctor explanation must not be empty if downstream reasoning is populated
        if safe.doctorExplanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (
                !safe.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                !safe.decision.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
            warnings.append("Missing doctor explanation trace. Extraction should be reviewed manually.")
            blocked = true
        }

        // Rule 4: if reason for visit is empty, block save
        if safe.reasonForVisit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append("Reason for visit is missing.")
            blocked = true
        }

        // Rule 5: if all core reasoning fields are empty, block save
        let coreFieldsAreEmpty =
            safe.doctorExplanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            safe.whatMightBeHappening.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            safe.decision.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if coreFieldsAreEmpty {
            warnings.append("No usable reasoning content detected.")
            blocked = true
        }

        return MedicalSafetyGuardResult(
            sanitized: safe,
            warnings: warnings,
            blocked: blocked
        )
    }
}

private extension MedicalSafetyGuard {

    func soundsTooDefinitive(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("this is ") ||
            lower.contains("definitely") ||
            lower.contains("certainly") ||
            lower.contains("confirmed")
    }

    func soundsLikeAdvice(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("you should") ||
            lower.contains("you must") ||
            lower.contains("start taking") ||
            lower.contains("stop taking")
    }

    func soften(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        if trimmed.lowercased().hasPrefix("this is ") {
            return trimmed.replacingOccurrences(of: "This is ", with: "This may be ")
        }

        return "This may reflect the doctor's current explanation: \(trimmed)"
    }

    func softenAdvice(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        return "The doctor appears to be suggesting this next step: \(trimmed)"
    }

    func replacing(
        _ extracted: ExtractedReasoning,
        whatMightBeHappening: String? = nil,
        whatHappensNext: String? = nil
    ) -> ExtractedReasoning {
        ExtractedReasoning(
            doctorName: extracted.doctorName,
            clinic: extracted.clinic,
            reasonForVisit: extracted.reasonForVisit,
            doctorExplanation: extracted.doctorExplanation,
            evidence: extracted.evidence,
            decision: extracted.decision,
            nextSteps: extracted.nextSteps,
            whatMightBeHappening: whatMightBeHappening ?? extracted.whatMightBeHappening,
            howSeriousItAppears: extracted.howSeriousItAppears,
            whatTheDoctorIsDoing: extracted.whatTheDoctorIsDoing,
            whatHappensNext: whatHappensNext ?? extracted.whatHappensNext,
            questionsForNextVisit: extracted.questionsForNextVisit
        )
    }
}
