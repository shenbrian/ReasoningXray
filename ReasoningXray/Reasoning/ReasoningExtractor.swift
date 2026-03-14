import Foundation

struct ReasoningExtractor {

    func extract(from transcript: String) -> ExtractedReasoning {
        let lower = transcript.lowercased()

        let explanation = extractExplanation(lower)
        let decision = extractDecision(lower)
        let nextSteps = extractNextSteps(lower)

        return ExtractedReasoning(
            doctorName: detectDoctorName(transcript),
            clinic: detectClinic(transcript),
            reasonForVisit: extractReasonForVisit(lower),
            doctorExplanation: explanation,
            evidence: extractEvidence(lower),
            decision: decision,
            nextSteps: nextSteps,
            whatMightBeHappening: explanation,
            howSeriousItAppears: extractSeriousness(lower),
            whatTheDoctorIsDoing: decision,
            whatHappensNext: nextSteps,
            questionsForNextVisit: extractQuestions(lower)
        )
    }

    private func detectDoctorName(_ text: String) -> String {
        "Doctor"
    }

    private func detectClinic(_ text: String) -> String? {
        nil
    }

    private func extractReasonForVisit(_ text: String) -> String {
        if text.contains("cough") { return "Cough symptoms discussed" }
        if text.contains("chest") { return "Chest symptoms discussed" }
        if text.contains("pain") { return "Pain symptoms discussed" }
        if text.contains("blood pressure") { return "Blood pressure concern" }
        return "General consultation"
    }

    private func extractExplanation(_ text: String) -> String {
        if text.contains("infection") || text.contains("infected") {
            return "Doctor suspects an infection"
        }

        if text.contains("viral") || text.contains("post-viral") {
            return "Doctor mentioned a viral cause"
        }

        if text.contains("asthma") || text.contains("airway") || text.contains("inhaler") {
            return "Doctor suspects airway inflammation or asthma"
        }

        if text.contains("blood pressure") || text.contains("hypertension") {
            return "Doctor suspects elevated blood pressure"
        }

        if text.contains("antibiotic") {
            return "Doctor suspects a bacterial or infection-related cause"
        }

        return ""
    }

    private func extractEvidence(_ text: String) -> [String] {
        var evidence: [String] = []

        if text.contains("wheeze") {
            evidence.append("Doctor heard wheeze")
        }

        if text.contains("improvement") {
            evidence.append("Some improvement mentioned")
        }

        if text.contains("no improvement") {
            evidence.append("Symptoms not improving")
        }

        if text.contains("persistent") || text.contains("still present") || text.contains("three weeks") {
            evidence.append("Symptoms persisted")
        }

        if text.contains("infection") {
            evidence.append("Doctor mentioned infection")
        }

        return evidence
    }

    private func extractDecision(_ text: String) -> String {
        if text.contains("x-ray") || text.contains("xray") {
            return "Doctor ordered X-ray"
        }

        if text.contains("antibiotic") || text.contains("antibiotics") {
            return "Doctor prescribed antibiotics"
        }

        if text.contains("inhaler") && (text.contains("trial") || text.contains("start") || text.contains("prescribe")) {
            return "Doctor prescribed inhaler"
        }

        if text.contains("monitor") || text.contains("watch") {
            return "Doctor suggested monitoring"
        }

        if text.contains("blood pressure") && text.contains("monitor") {
            return "Doctor suggested blood pressure monitoring"
        }

        return ""
    }

    private func extractNextSteps(_ text: String) -> String {
        if text.contains("follow up") || text.contains("follow-up") || text.contains("come back") || text.contains("return") {
            return "Follow-up visit recommended"
        }

        if text.contains("x-ray") || text.contains("xray") || text.contains("scan") || text.contains("test") {
            return "Testing planned"
        }

        if text.contains("continue") {
            return "Continue current plan and review"
        }

        if text.contains("antibiotic") {
            return "Start treatment and monitor response"
        }

        return ""
    }

    private func extractSeriousness(_ text: String) -> String {
        if text.contains("not serious") {
            return "Doctor suggested the issue is not serious"
        }

        if text.contains("concern") || text.contains("concerned") || text.contains("bad") {
            return "Doctor showed some concern"
        }

        return ""
    }

    private func extractQuestions(_ text: String) -> [String] {
        var questions: [String] = []

        if text.contains("come back") || text.contains("return") {
            questions.append("Should I return if symptoms continue?")
        }

        if text.contains("test result") || text.contains("results") || text.contains("x-ray") {
            questions.append("What did the test or X-ray show?")
        }

        return questions
    }
}
