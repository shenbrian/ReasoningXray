import SwiftUI

struct ReasoningValidationView: View {
    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        List {
            ForEach(store.threads) { thread in
                Section(thread.title) {
                    ForEach(store.comparisons(for: thread)) { comparison in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(comparison.currentVisit.visitDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(comparison.currentVisit.oneLineVisitSummary)
                                .font(.headline)

                            Text("Movement: \(comparison.movement.timelineLabel)")
                                .font(.subheadline)

                            Text("Stage: \(comparison.stage.timelineLabel)")
                                .font(.subheadline)

                            if let turningPoint = comparison.turningPoint {
                                Text("Turning point: \(turningPoint.kind.timelineLabel)")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            } else {
                                Text("Turning point: none")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Divider()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Reasoning Validation")
    }
}
