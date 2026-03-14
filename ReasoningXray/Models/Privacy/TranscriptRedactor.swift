import Foundation

struct TranscriptRedactor {

    func redact(_ text: String, using options: RedactionOptions) -> String {
        var output = text

        if options.redactDoctorName {
            output = redactDoctorName(in: output)
        }

        if options.redactClinicName {
            output = redactClinicName(in: output)
        }

        if options.redactLocationLikeTerms {
            output = redactLocationLikeTerms(in: output)
        }

        return normalizeSpacing(in: output)
    }

    // MARK: - Doctor name

    private func redactDoctorName(in text: String) -> String {
        var output = text

        let patterns = [
            #"(?i)\bdr\.?\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\b"#,
            #"(?i)\bdoctor\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\b"#
        ]

        for pattern in patterns {
            output = replacingMatches(
                pattern: pattern,
                in: output,
                with: "[Doctor]"
            )
        }

        return output
    }

    // MARK: - Clinic name

    private func redactClinicName(in text: String) -> String {
        var output = text

        let patterns = [
            #"(?i)\b[A-Z][A-Za-z&' -]{1,40}\s+Clinic\b"#,
            #"(?i)\b[A-Z][A-Za-z&' -]{1,40}\s+Medical Centre\b"#,
            #"(?i)\b[A-Z][A-Za-z&' -]{1,40}\s+Medical Center\b"#,
            #"(?i)\b[A-Z][A-Za-z&' -]{1,40}\s+Hospital\b"#,
            #"(?i)\b[A-Z][A-Za-z&' -]{1,40}\s+Health\b"#
        ]

        for pattern in patterns {
            output = replacingMatches(
                pattern: pattern,
                in: output,
                with: "[Clinic]"
            )
        }

        return output
    }

    // MARK: - Location-like terms

    private func redactLocationLikeTerms(in text: String) -> String {
        var output = text

        let patterns = [
            #"(?i)\b(?:street|st|road|rd|avenue|ave|drive|dr|lane|ln|boulevard|blvd)\b\.?\s*\d*\b"#,
            #"(?i)\b(?:suburb|city|postcode)\s*:\s*[A-Za-z0-9 -]+\b"#,
            #"(?i)\b[A-Z][a-z]+,\s*(?:NSW|VIC|QLD|SA|WA|TAS|ACT|NT)\b"#
        ]

        for pattern in patterns {
            output = replacingMatches(
                pattern: pattern,
                in: output,
                with: "[Location]"
            )
        }

        return output
    }

    // MARK: - Helpers

    private func replacingMatches(pattern: String, in text: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: replacement)
    }

    private func normalizeSpacing(in text: String) -> String {
        var output = text

        while output.contains("  ") {
            output = output.replacingOccurrences(of: "  ", with: " ")
        }

        output = output.replacingOccurrences(of: " ,", with: ",")
        output = output.replacingOccurrences(of: " .", with: ".")
        output = output.replacingOccurrences(of: " ]", with: "]")

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
