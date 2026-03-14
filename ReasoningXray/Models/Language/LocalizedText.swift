import Foundation

struct LocalizedText: Codable, Hashable {
    var english: String?
    var chineseSimplified: String?

    init(
        english: String? = nil,
        chineseSimplified: String? = nil
    ) {
        self.english = english
        self.chineseSimplified = chineseSimplified
    }

    func resolve(for language: DisplayLanguage) -> String {
        switch language {
        case .english:
            return english ?? chineseSimplified ?? ""
        case .chineseSimplified:
            return chineseSimplified ?? english ?? ""
        }
    }

    var isEmpty: Bool {
        let en = english?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let zh = chineseSimplified?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return en.isEmpty && zh.isEmpty
    }
}
