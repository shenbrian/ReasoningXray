import Foundation
import Combine

final class RenderPreferencesStore: ObservableObject {
    @Published var preferences: ReasoningRenderPreferences

    init(preferences: ReasoningRenderPreferences = .englishDefault) {
        self.preferences = preferences
    }

    func setDisplayLanguage(_ language: DisplayLanguage) {
        switch language {
        case .english:
            preferences = .englishDefault
        case .chineseSimplified:
            preferences = .chineseDefault
        }
    }

    func setMirrorLanguageMode(_ mode: MirrorLanguageMode) {
        preferences = ReasoningRenderPreferences(
            displayLanguage: preferences.displayLanguage,
            mirrorLanguageMode: mode
        )
    }
}
