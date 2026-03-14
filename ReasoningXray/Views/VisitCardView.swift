import SwiftUI

struct VisitCardView: View {
    let visit: Visit
    let threadTitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(visit.visitDate, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(stageLabel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray.opacity(0.15))
                    .clipShape(Capsule())
            }

            if let threadTitle {
                Text(threadTitle)
                    .font(.headline)
            }

            Text(visit.oneLineVisitSummary)
                .font(.body)

            Text("Changed since last visit")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(visit.mainChangeSinceLastVisit)
                .font(.subheadline)

            Divider()

            Text("Decision: \(visit.decision)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Reasoning Stage Label

    private var stageLabel: String {

        let decision = visit.decision.lowercased()
        let explanation = visit.whatMightBeHappening.lowercased()

        if decision.contains("x-ray") || decision.contains("test") || decision.contains("scan") {
            return "Testing"
        }

        if decision.contains("trial") || decision.contains("start") || decision.contains("treatment") {
            return "Treatment Trial"
        }

        if decision.contains("monitor") || decision.contains("watch") {
            return "Monitoring"
        }

        if explanation.contains("infection") || explanation.contains("viral") || explanation.contains("asthma") {
            return "Working Diagnosis"
        }

        return "Evaluation"
    }
}
