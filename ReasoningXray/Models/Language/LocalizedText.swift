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

    var base: String {
        english ?? chineseSimplified ?? ""
    }

    var count: Int {
        base.count
    }

    func lowercased() -> String {
        base.lowercased()
    }

    func range(of string: String) -> Range<String.Index>? {
        base.range(of: string)
    }

    subscript(bounds: Range<String.Index>) -> Substring {
        base[bounds]
    }

    static func == (lhs: LocalizedText, rhs: String) -> Bool {
        lhs.base == rhs
    }

    static func != (lhs: LocalizedText, rhs: String) -> Bool {
        lhs.base != rhs
    }

    var isEmpty: Bool {
        base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
