import Foundation

struct ReasoningRenderPreferences: Codable, Hashable {
    var displayLanguage: DisplayLanguage
    var mirrorLanguageMode: MirrorLanguageMode

    init(
        displayLanguage: DisplayLanguage,
        mirrorLanguageMode: MirrorLanguageMode
    ) {
        self.displayLanguage = displayLanguage
        self.mirrorLanguageMode = mirrorLanguageMode
    }

    static let englishDefault = ReasoningRenderPreferences(
        displayLanguage: .english,
        mirrorLanguageMode: .sourceOnly
    )

    static let chineseDefault = ReasoningRenderPreferences(
        displayLanguage: .chineseSimplified,
        mirrorLanguageMode: .bilingual
    )
}
