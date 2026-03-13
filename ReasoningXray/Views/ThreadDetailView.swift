import SwiftUI

struct ThreadDetailView: View {
    let thread: CaseThread

    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                trajectorySection
                watchpointsSection
            }
            .padding()
        }
        .navigationTitle("Thread Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ThreadDetailView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reasoning Summary")
                .font(.title3.weight(.semibold))

            if let status = store.trajectoryEpistemicStatus(for: thread.id) {
                TrustSignalBadge(status: status)
            }

            if let presentation = store.trajectoryPresentation(for: thread.id) {
                Text(presentation.technical.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var trajectorySection: some View {
        Group {
            if let presentation = store.trajectoryPresentation(for: thread.id) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reasoning Trajectory")
                        .font(.headline)

                    Text(presentation.technical.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    Text("What This Means For You")
                        .font(.headline)

                    Text(presentation.patient.narrativeMeaning)

                    Divider()

                    Text("Reassurance")
                        .font(.subheadline.weight(.semibold))

                    Text(presentation.patient.reassuranceFraming)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    Text("What To Expect Next")
                        .font(.subheadline.weight(.semibold))

                    Text(presentation.patient.forwardExpectation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    var watchpointsSection: some View {
        let watchpoints = store.watchpoints(for: thread)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Reasoning watchpoints")
                .font(.headline)

            if watchpoints.isEmpty {
                Text("No major reasoning watchpoints detected.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(watchpoints.enumerated()), id: \.offset) { _, item in
                    Text(String(describing: item))
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
