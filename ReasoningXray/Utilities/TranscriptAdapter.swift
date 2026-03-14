import Foundation

enum TranscriptAdapter {

    static func combinedText(for visit: Visit) -> String {
        if let segments = visit.transcriptSegments, !segments.isEmpty {
            return segments.map { $0.text }.joined(separator: "\n")
        }

        return fallbackCombinedText(for: visit)
    }

    static func sourceLanguage(for visit: Visit) -> SupportedLanguage {
        if let hint = visit.sourceLanguageHint {
            return hint
        }

        if let first = visit.transcriptSegments?.first {
            return first.detectedLanguage
        }

        return .english
    }

    private static func fallbackCombinedText(for visit: Visit) -> String {
        var lines: [String] = []

        if !visit.reasonForVisit.isEmpty {
            lines.append("Reason for visit: \(visit.reasonForVisit)")
        }

        if !visit.doctorExplanation.isEmpty {
            lines.append("Doctor explanation: \(visit.doctorExplanation)")
        }

        if !visit.evidence.isEmpty {
            lines.append("Evidence: \(visit.evidence.joined(separator: ", "))")
        }

        if !visit.decision.isEmpty {
            lines.append("Decision: \(visit.decision)")
        }

        if !visit.nextSteps.isEmpty {
            lines.append("Next steps: \(visit.nextSteps.joined(separator: ", "))")
        }

        return lines.joined(separator: "\n")
    }
}
