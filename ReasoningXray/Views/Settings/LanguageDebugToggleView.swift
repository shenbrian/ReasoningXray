import SwiftUI

struct LanguageDebugToggleView: View {
    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Display Language")
                .font(.headline)

            Picker(
                "Display Language",
                selection: Binding(
                    get: { store.displayLanguage },
                    set: { store.setDisplayLanguage($0) }
                )
            ) {
                Text("English").tag(DisplayLanguage.english)
                Text("Chinese").tag(DisplayLanguage.chineseSimplified)
            }
            .pickerStyle(.segmented)

        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
