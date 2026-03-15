import SwiftUI

struct VisitDetailView: View {
    let visit: Visit
    @EnvironmentObject var store: ReasoningHistoryStore

    private var rendered: RenderedVisitReasoning {
        store.renderedVisitReasoning(for: visit)
    }

    private var displayLanguage: DisplayLanguage {
        store.renderPreferences.displayLanguage
    }

    private var currentThread: CaseThread? {
        store.threads.first { $0.id == visit.caseThreadId }
    }

    private var currentComparison: VisitReasoningComparison? {
        guard let thread = currentThread else { return nil }
        return store.comparisons(for: thread).first { $0.currentVisit.id == visit.id }
    }

    private var whatChangedSinceLastVisitText: String {
        guard let comparison = currentComparison else {
            return "This is the first recorded visit for this issue."
        }

        if comparison.changes.isEmpty {
            return "No major reasoning change was detected from the previous visit."
        }

        let changeTexts = comparison.changes.map { changeSummary(for: $0.kind) }

        if changeTexts.count == 1 {
            return changeTexts[0]
        }

        if changeTexts.count == 2 {
            return "\(changeTexts[0]) and \(changeTexts[1])."
        }

        let head = changeTexts.dropLast().joined(separator: ", ")
        let tail = changeTexts.last ?? ""
        return "\(head), and \(tail)."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                languageDebugSection
                changeSummarySection
                layer2Section
                layer1Section
                additionalSection
            }
            .padding()
        }
        .navigationTitle(visit.visitDate.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var languageDebugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Display Language")
                .font(.title3.bold())

            HStack(spacing: 12) {
                Button {
                    store.renderPreferences = .englishDefault
                } label: {
                    Text("English")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            displayLanguage == .english ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.10)
                        )
                        .foregroundStyle(displayLanguage == .english ? Color.blue : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button {
                    store.renderPreferences = .chineseDefault
                } label: {
                    Text("中文")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            displayLanguage == .chineseSimplified ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.10)
                        )
                        .foregroundStyle(displayLanguage == .chineseSimplified ? Color.blue : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            Text("Current language: \(displayLanguage == .english ? "English" : "Chinese")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Temporary debug toggle for bilingual rendering.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var changeSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Compared with the previous visit")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("What changed since last visit")
                .font(.title3.bold())

            Text(whatChangedSinceLastVisitText)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var layer2Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What This Means For You")
                .font(.title3.bold())

            detailRow(
                "Why this visit happened",
                rendered.reasonForVisit.resolve(for: displayLanguage)
            )

            detailRow(
                "What might be happening",
                rendered.whatMightBeHappening.resolve(for: displayLanguage)
            )

            detailRow(
                "What this suggests",
                rendered.howSeriousItAppears.resolve(for: displayLanguage)
            )

            detailRow(
                "What the doctor is doing",
                rendered.whatTheDoctorIsDoing.resolve(for: displayLanguage)
            )

            detailRow(
                "What happens next",
                rendered.whatHappensNext.resolve(for: displayLanguage)
            )

            detailList(
                "Questions for next visit",
                rendered.questionsForNextVisit.map { $0.resolve(for: displayLanguage) }
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var layer1Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Doctor Reasoning Mirror")
                .font(.title3.bold())

            detailRow(
                "Reason for visit",
                rendered.reasonForVisit.resolve(for: displayLanguage)
            )

            detailRow(
                "Doctor explanation",
                rendered.doctorExplanation.resolve(for: displayLanguage)
            )

            detailList(
                "Evidence",
                rendered.evidence.map { $0.resolve(for: displayLanguage) }
            )

            detailRow(
                "Decision",
                rendered.decision.resolve(for: displayLanguage)
            )

            detailList(
                "Next steps",
                rendered.nextSteps.map { $0.resolve(for: displayLanguage) }
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var additionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What Changed Since Last Visit")
                .font(.title3.bold())

            detailRow("Main change since last visit", visit.mainChangeSinceLastVisit)
            detailRow("What triggered the reasoning change", reasoningTriggerText)
            detailRow("Biggest open question", visit.biggestOpenQuestion)
            detailRow("What to watch before next visit", visit.whatToWatchBeforeNextVisit)
            detailList("Symptoms mentioned", visit.symptomsMentioned)
            detailList("Tests ordered", visit.testsOrdered)
            detailList("Diagnoses considered", visit.diagnosesConsidered)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var reasoningTriggerText: String {
        if !visit.testsOrdered.isEmpty {
            return "Testing influenced the reasoning change."
        }

        let evidenceText = visit.evidence.joined(separator: " ").lowercased()

        if evidenceText.contains("improvement") || evidenceText.contains("response") {
            return "Treatment response influenced the reasoning change."
        }

        if evidenceText.contains("persist") || evidenceText.contains("still present") || evidenceText.contains("wors") {
            return "Ongoing symptoms influenced the reasoning change."
        }

        if !visit.evidence.isEmpty {
            return "New evidence influenced the reasoning change."
        }

        return "The doctor's updated assessment influenced the reasoning change."
    }

    private func changeSummary(for kind: ReasoningChangeKind) -> String {
        switch kind {
        case .continuedMonitoring:
            return "The doctor continued monitoring the problem"
        case .reconsideredExplanation:
            return "The doctor reconsidered the earlier explanation"
        case .orderedTesting:
            return "The doctor moved to testing"
        case .startedTreatmentTrial:
            return "The doctor started a treatment trial"
        case .newEvidenceInfluencedReasoning:
            return "New information affected the doctor's thinking"
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not recorded" : value)
        }
    }

    private func detailList(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            let cleaned = items
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            if cleaned.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(cleaned.enumerated()), id: \.offset) { _, item in
                    Text(item)
                }
            }
        }
    }
}
