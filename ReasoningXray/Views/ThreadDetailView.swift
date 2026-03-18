import SwiftUI

struct ThreadDetailView: View {
    let thread: CaseThread

    @EnvironmentObject var store: ReasoningHistoryStore

    private var runtimeLanguage: DisplayLanguage {
        store.displayLanguage
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                reasoningMirrorPanel
                trajectorySection
                reasoningDirectionSection   // ← NEW
                continuitySection
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
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func continuityRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    func sectionCardTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var reasoningMirrorPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patient Understanding")
                .font(.headline)

            Text("This explains the current clinical reasoning in a calmer patient-facing form, based on what is known so far.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text(store.reasoningPosture(for: thread).title)
                    .font(.subheadline.weight(.semibold))

                Text(store.reasoningPosture(for: thread).summary)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                if let uncertainty = store.reasoningUncertaintyNote(for: thread) {
                    Divider()

                    Text("What may still change")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(uncertainty.body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                continuityRow(
                    title: "Evidence status",
                    value: softenedEvidenceStatusText(store.reasoningEvidenceStatus(for: thread).body)
                )

                if let turningPointSummary = store.recentTurningPointSummary(for: thread.id) {
                    Divider()

                    Text("Recent change in direction")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(turningPointSummary)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                let timelineStrip = store.reasoningTimelineStrip(for: thread.id)
                if !timelineStrip.isEmpty {
                    Divider()

                    Text("Reasoning course so far")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    var trajectorySection: some View {
        Group {
            if let presentation = store.trajectoryPresentation(for: thread.id) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How the reasoning is holding together")
                        .font(.headline)

                    Text("This section shows where the reasoning now stands, how it has been moving, and what direction it seems to be taking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("Current position")

                        snapshotRow(
                            title: "Where it stands now",
                            value: readableLabel(for: presentation.technical.overallPath)
                        )

                        snapshotRow(
                            title: "How it has moved",
                            value: readableLabel(for: presentation.technical.momentum)
                        )

                        snapshotRow(
                            title: "How settled it feels",
                            value: readableLabel(for: presentation.technical.certaintyTrend)
                        )
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("What this means for you")

                        Text(
                            presentation.patient.narrativeMeaning
                                .resolve(for: runtimeLanguage)
                        )
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("Reassurance")

                        Text(
                            presentation.patient.reassuranceFraming
                                .resolve(for: runtimeLanguage)
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("What to expect next")

                        Text(
                            presentation.patient.forwardExpectation
                                .resolve(for: runtimeLanguage)
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("Decision safety")

                        Text(
                            presentation.patient.decisionSafetyFraming
                                .resolve(for: runtimeLanguage)
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }
            }
        }
    }

    var continuitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let continuity = store.longitudinalContinuityPresentation(for: thread) {
                Text(continuity.title)
                    .font(.headline)

                Text(anchoredContinuitySummary(continuity.summary))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    sectionCardTitle("What seems stable")

                    Text(continuity.stabilityAnchor)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    sectionCardTitle("What recently shifted")

                    Text(continuity.recentMovement)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    sectionCardTitle("What could meaningfully change next")

                    Text(continuity.nextMeaningfulShift)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .cardStyle()

                if !continuity.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        sectionCardTitle("Visit-to-visit progression")

                        ForEach(continuity.steps) { step in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(step.title)
                                    .font(.subheadline.weight(.semibold))

                                Text(step.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .cardStyle()
                        }
                    }
                }
            }
        }
    }

    var watchpointsSection: some View {
        let watchpoints = store.watchpoints(for: thread)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Reading watchpoints")
                .font(.headline)

            Text("These are not conclusions. They are points to keep in mind while the reasoning remains open.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if watchpoints.isEmpty {
                Text("No major watchpoints are standing out at this stage.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(watchpoints.enumerated()), id: \.offset) { _, item in
                        let content = store.watchpointPresentation(for: item)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(content.title)
                                .font(.subheadline.weight(.semibold))

                            Text(content.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .cardStyle()
                    }
                }
            }
        }
    }
    
    var reasoningDirectionSection: some View {
        if let presentation = store.reasoningDirectionPresentation(for: thread.id) {
            return AnyView(
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reasoning direction")
                        .font(.headline)

                    Text(presentation.title)
                        .font(.subheadline.weight(.semibold))

                    Text(presentation.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            )
        } else {
            return AnyView(EmptyView())
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

    func softenedEvidenceStatusText(_ text: String) -> String {
        if text == "The interpretation has shifted across visits as new information appeared." {
            return "As new information appeared across visits, the reasoning direction became clearer."
        }

        if text == "The reasoning looks relatively steady across recent visits." {
            return "Across recent visits, the reasoning has looked relatively steady."
        }

        if text == "The overall direction is becoming clearer, but it still depends on how later evidence fits." {
            return "The overall direction is becoming clearer, while still depending on how later evidence fits."
        }

        return text
    }

    func anchoredContinuitySummary(_ text: String) -> String {
        if text == "The line of reasoning is still developing across visits." {
            return "The line of reasoning is still developing across visits, but it appears to be moving toward greater clarity rather than away from it."
        }

        return text
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
