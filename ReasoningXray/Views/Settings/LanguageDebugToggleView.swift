import SwiftUI

struct LanguageDebugToggleView: View {
    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Display Language")
                .font(.headline)

            Picker("Display Language", selection: $store.renderPreferences.displayLanguage) {
                Text("English").tag(DisplayLanguage.english)
                Text("Chinese").tag(DisplayLanguage.chineseSimplified)
            }
            .pickerStyle(.segmented)

            Text("Mirror Mode")
                .font(.headline)

            Picker("Mirror Mode", selection: $store.renderPreferences.mirrorLanguageMode) {
                Text("Source Only").tag(MirrorLanguageMode.sourceOnly)
                Text("Bilingual").tag(MirrorLanguageMode.bilingual)
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
