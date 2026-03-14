import Foundation

struct TranscriptVisitBuilder {

    static func buildVisit(
        from extracted: ExtractedReasoning,
        caseThreadId: UUID,
        visitDate: Date = Date(),
        visitType: VisitType = .gp
    ) -> Visit {

        Visit(
            id: UUID(),
            caseThreadId: caseThreadId,

            visitDate: visitDate,
            doctorName: extracted.doctorName.isEmpty ? "Unknown doctor" : extracted.doctorName,
            clinicName: extracted.clinic ?? "",
            visitType: visitType,

            // Layer 1 — Doctor Reasoning Mirror
            reasonForVisit: extracted.reasonForVisit,
            doctorExplanation: extracted.doctorExplanation,
            evidence: extracted.evidence,
            decision: extracted.decision,
            nextSteps: splitNextSteps(extracted.nextSteps),

            // Layer 2 — Patient Comprehension Translation
            whatMightBeHappening: extracted.whatMightBeHappening,
            howSeriousItAppears: extracted.howSeriousItAppears,
            whatTheDoctorIsDoing: extracted.whatTheDoctorIsDoing,
            whatHappensNext: extracted.whatHappensNext,
            questionsForNextVisit: extracted.questionsForNextVisit,

            // Longitudinal fields
            oneLineVisitSummary: buildOneLineVisitSummary(from: extracted),
            mainChangeSinceLastVisit: "New visit recorded — reasoning change will be detected when compared with previous visits.",
            biggestOpenQuestion: extracted.questionsForNextVisit.first ?? "",
            whatToWatchBeforeNextVisit: extracted.whatHappensNext,

            // Structured reasoning signals (for reasoning engine)
            symptomsMentioned: inferSymptoms(from: extracted),
            testsOrdered: inferTests(from: extracted),
            diagnosesConsidered: inferDiagnoses(from: extracted)
        )
    }

    // MARK: - Helpers

    private static func splitNextSteps(_ text: String) -> [String] {
        let separators = CharacterSet(charactersIn: ".;•\n")

        return text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func buildOneLineVisitSummary(from extracted: ExtractedReasoning) -> String {

        if !extracted.whatMightBeHappening.isEmpty {
            return extracted.whatMightBeHappening
        }

        if !extracted.doctorExplanation.isEmpty {
            return extracted.doctorExplanation
        }

        return extracted.reasonForVisit
    }

    // MARK: - Signal inference (lightweight heuristics)

    private static func inferSymptoms(from extracted: ExtractedReasoning) -> [String] {

        let source = [
            extracted.reasonForVisit,
            extracted.whatMightBeHappening,
            extracted.doctorExplanation
        ]
        .joined(separator: " ")
        .lowercased()

        var symptoms: [String] = []

        if source.contains("cough") { symptoms.append("Cough") }
        if source.contains("wheeze") { symptoms.append("Wheeze") }
        if source.contains("breath") || source.contains("shortness of breath") { symptoms.append("Breathlessness") }
        if source.contains("fever") { symptoms.append("Fever") }
        if source.contains("pain") { symptoms.append("Pain") }
        if source.contains("blood pressure") { symptoms.append("Elevated blood pressure") }

        return symptoms
    }

    private static func inferTests(from extracted: ExtractedReasoning) -> [String] {

        let source = [
            extracted.decision,
            extracted.nextSteps,
            extracted.whatTheDoctorIsDoing
        ]
        .joined(separator: " ")
        .lowercased()

        var tests: [String] = []

        if source.contains("x-ray") || source.contains("xray") {
            tests.append("X-ray")
        }

        if source.contains("blood test") {
            tests.append("Blood test")
        }

        if source.contains("scan") {
            tests.append("Scan")
        }

        if source.contains("ultrasound") {
            tests.append("Ultrasound")
        }

        if source.contains("mri") {
            tests.append("MRI")
        }

        if source.contains("ct") {
            tests.append("CT scan")
        }

        return tests
    }

    private static func inferDiagnoses(from extracted: ExtractedReasoning) -> [String] {

        let source = [
            extracted.whatMightBeHappening,
            extracted.doctorExplanation
        ]
        .joined(separator: " ")
        .lowercased()

        var diagnoses: [String] = []

        if source.contains("asthma") { diagnoses.append("Asthma") }
        if source.contains("infection") { diagnoses.append("Infection") }
        if source.contains("viral") { diagnoses.append("Viral illness") }
        if source.contains("airway") { diagnoses.append("Airway irritation") }
        if source.contains("blood pressure") || source.contains("hypertension") { diagnoses.append("Hypertension") }

        return diagnoses
    }
}
