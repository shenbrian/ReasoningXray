import SwiftUI

struct PatientStorySummaryCard: View {
    let summary: PatientStorySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Summary")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Current view")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(summary.currentView)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Why it changed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(summary.whyItChanged)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Next step")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(summary.nextStep)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
