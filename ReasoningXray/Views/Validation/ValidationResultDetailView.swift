import SwiftUI

struct ValidationResultDetailView: View {

    let result: ValidationResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                section(
                    title: "Stages Detected",
                    items: result.detectedStages
                )

                section(
                    title: "Change Kinds Detected",
                    items: result.detectedChangeKinds.flatMap { $0 }
                )

                section(
                    title: "Turning Points Detected",
                    items: result.detectedTurningPoints
                )

                section(
                    title: "Wording Notes",
                    items: result.wordingNotes
                )

                section(
                    title: "Timeline Notes",
                    items: result.timelineNotes
                )
            }
            .padding()
        }
        .navigationTitle(result.caseTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if items.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                }
            }
        }
    }
}
