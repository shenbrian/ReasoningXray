import SwiftUI

struct ThreadDetailView: View {
    let thread: CaseThread

    @EnvironmentObject var store: ReasoningHistoryStore

    private var runtimeLanguage: DisplayLanguage {
        store.displayLanguage
    }
    
    private var trustSummaryStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            reasoningPosturePanel
            reasoningEvidenceStatusPanel
            reasoningUncertaintyPanel
        }
    }
    
    private var reasoningPosturePanel: some View {
        let posture = store.reasoningPosture(for: thread)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Reasoning posture")
                .font(.headline)

            Text(posture.title)
                .font(.subheadline.weight(.semibold))

            Text(posture.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if posture.isProvisional {
                Text("This reflects the doctor’s current reasoning posture, not a final conclusion.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var reasoningUncertaintyPanel: some View {
        guard let note = store.reasoningUncertaintyNote(for: thread) else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.subheadline.weight(.semibold))

                Text(note.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        )
    }
    
    private var reasoningSignalsSection: some View {
        let signals = store.reasoningSignals(for: thread)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Reasoning changes")
                .font(.headline)

            Text("This highlights where the doctor’s reasoning appears to have stayed stable, remained provisional, or shifted across visits.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if signals.isEmpty {
                Text("No major reasoning changes were highlighted.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(signals) { signal in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(signal.title)
                            .font(.subheadline.weight(.semibold))

                        Text(signal.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if signal.emphasis == .caution {
                            Text("This reflects evolving reasoning, not a final conclusion.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(backgroundStyle(for: signal.emphasis), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var visitCountOrientationSection: some View {
        let summary = store.visitCountSummary(for: thread)

        return HStack(alignment: .top, spacing: 8) {
            Text(summary)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
    
    private var reasoningConsistencySummarySection: some View {
        let summary = store.reasoningConsistencySummary(for: thread)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Reasoning across visits")
                .font(.headline)

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func backgroundStyle(for emphasis: ReasoningSignalEmphasis) -> Material {
        switch emphasis {
        case .neutral:
            return .thinMaterial
        case .caution:
            return .regularMaterial
        case .stable:
            return .thinMaterial
        }
    }
    
    private var reasoningEvidenceStatusPanel: some View {
        let status = store.reasoningEvidenceStatus(for: thread)

        return VStack(alignment: .leading, spacing: 6) {
            Text(status.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(status.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                reasoningMirrorPanel
                visitCountOrientationSection
                reasoningConsistencySummarySection
                reasoningSignalsSection
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
    func snapshotRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
    
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

    var reasoningMirrorPanel: some View {
        Group {
            if let presentation = store.trajectoryPresentation(for: thread.id) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Doctor Reasoning Mirror")
                        .font(.headline)

                    Text("This shows how the doctor’s working interpretation is currently being structured.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    HStack {
                        Text("Current Path")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(readableLabel(for: presentation.technical.overallPath))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Reasoning Movement")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(readableLabel(for: presentation.technical.momentum))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Certainty Trend")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(readableLabel(for: presentation.technical.certaintyTrend))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if presentation.technical.activeUncertainty {
                        Text("Uncertainty is still active in the case.")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    } else {
                        Text("Reasoning appears to be stabilising.")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }

                    if let workingExplanationSummary = store.workingExplanationSummary(for: thread.id) {
                        Divider()

                        Text("Working Explanation")
                            .font(.subheadline.weight(.semibold))

                        Text(workingExplanationSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let turningPointSummary = store.recentTurningPointSummary(for: thread.id) {
                        Divider()

                        Text("Recent Turning Point")
                            .font(.subheadline.weight(.semibold))

                        Text(turningPointSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    let timelineStrip = store.reasoningTimelineStrip(for: thread.id)
                    if !timelineStrip.isEmpty {
                        Divider()

                        Text("Reasoning Course So Far")
                            .font(.subheadline.weight(.semibold))

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(timelineStrip.enumerated()), id: \.offset) { _, item in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)

                                    Text(item)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    var trajectorySection: some View {
        Group {
            if let presentation = store.trajectoryPresentation(for: thread.id) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Patient Understanding")
                        .font(.headline)

                    Text("This translates the current reasoning position into a patient-readable explanation without implying a final conclusion.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trajectory Snapshot")
                            .font(.subheadline.weight(.semibold))

                        snapshotRow(
                            title: "Current path",
                            value: readableLabel(for: presentation.technical.overallPath)
                        )

                        snapshotRow(
                            title: "Movement",
                            value: readableLabel(for: presentation.technical.momentum)
                        )

                        snapshotRow(
                            title: "Certainty trend",
                            value: readableLabel(for: presentation.technical.certaintyTrend)
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    Divider()

                    Text("What This Means For You")
                        .font(.subheadline.weight(.semibold))

                    Text(
                        presentation.patient.narrativeMeaning
                            .resolve(for: runtimeLanguage)
                    )

                    Divider()

                    Text("Reassurance")
                        .font(.subheadline.weight(.semibold))

                    Text(
                        presentation.patient.reassuranceFraming
                            .resolve(for: runtimeLanguage)
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Divider()

                    Text("What To Expect Next")
                        .font(.subheadline.weight(.semibold))

                    Text(
                        presentation.patient.forwardExpectation
                            .resolve(for: runtimeLanguage)
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Divider()

                    Text("Decision Safety")
                        .font(.subheadline.weight(.semibold))

                    Text(
                        presentation.patient.decisionSafetyFraming
                            .resolve(for: runtimeLanguage)
                    )
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

        return VStack(alignment: .leading, spacing: 14) {
            Text("Reasoning Watchpoints")
                .font(.headline)

            Text("These signals show where the doctor’s thinking shifted or required closer attention.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if watchpoints.isEmpty {
                Text("No major reasoning watchpoints detected.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(watchpoints.enumerated()), id: \.offset) { _, item in
                    let content = store.watchpointPresentation(for: item)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.title)
                            .font(.subheadline.weight(.semibold))

                        Text(content.body)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    func readableLabel(for value: Any) -> String {
        let raw = String(describing: value)
        let withSpaces = raw.replacingOccurrences(
            of: "([a-z])([A-Z])",
            with: "$1 $2",
            options: .regularExpression
        )
        return withSpaces.prefix(1).uppercased() + withSpaces.dropFirst()
    }
}
