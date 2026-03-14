import Foundation

struct PatientLanguageFormatter {

    func simplify(_ text: String) -> String {

        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        result = removeSoftHedges(result)
        result = shortenCommonPhrases(result)
        result = normalizeSpacing(result)

        return result
    }

    // MARK: - Reduce overly cautious phrasing

    private func removeSoftHedges(_ text: String) -> String {

        var t = text

        let replacements: [String: String] = [
            "appears to be": "is likely",
            "seems to be": "is likely",
            "seems more likely": "is more likely",
            "may be related to": "may be due to",
            "might be related to": "may be due to",
            "it is possible that": "",
            "the doctor currently thinks": "The doctor thinks",
            "the doctor currently seems to think": "The doctor thinks"
        ]

        for (key, value) in replacements {
            t = t.replacingOccurrences(of: key, with: value, options: .caseInsensitive)
        }

        return t
    }

    // MARK: - Shorten common medical phrases

    private func shortenCommonPhrases(_ text: String) -> String {

        var t = text

        let replacements: [String: String] = [
            "in order to": "to",
            "based on": "from",
            "as a result of": "after",
            "with respect to": "for",
            "in relation to": "for",
            "in the event that": "if"
        ]

        for (key, value) in replacements {
            t = t.replacingOccurrences(of: key, with: value, options: .caseInsensitive)
        }

        return t
    }

    // MARK: - Clean spacing

    private func normalizeSpacing(_ text: String) -> String {

        var t = text

        while t.contains("  ") {
            t = t.replacingOccurrences(of: "  ", with: " ")
        }

        t = t.trimmingCharacters(in: .whitespacesAndNewlines)

        return t
    }
}

