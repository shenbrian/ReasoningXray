import Foundation

enum SupportedLanguage: String, Codable, CaseIterable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
}

enum DisplayLanguage: String, Codable, CaseIterable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
}

enum MirrorLanguageMode: String, Codable, CaseIterable {
    case sourceOnly
    case bilingual
}
