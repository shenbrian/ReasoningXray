import SwiftUI

struct ThreadCardView: View {

    let thread: CaseThread
    let visitCount: Int

    @EnvironmentObject var store: ReasoningHistoryStore

    private var presentation: CaseTrajectoryPresentation? {
        store.trajectoryPresentation(for: thread.id)
    }

    private func trajectoryTrustBadge(for thread: CaseThread) -> some View {
        Group {
            if let status = store.trajectoryEpistemicStatus(for: thread.id) {
                TrustSignalBadge(status: status)
            }
        }
    }

    private var compactPathLabel: String? {
        guard let path = presentation?.technical.overallPath else { return nil }

        switch path {
        case .earlyExploration:
            return "Exploring"
        case .narrowing:
            return "Narrowing"
        case .workingDiagnosis:
            return "Working explanation"
        case .confirmation:
            return "Becoming clearer"
        case .monitoring:
            return "Monitoring"
        case .reopened:
            return "Reconsidering"
        case .mixed:
            return "Mixed pattern"
        }
    }

    private var compactNarrativeMeaning: String {
        guard let text = presentation?.patient.narrativeMeaning else { return "" }

        if text.count <= 85 { return text }

        if let range = text.range(of: ".") {
            return String(text[..<range.upperBound])
        }

        return text
    }

    private var compactExpectationLine: String? {
        guard let path = presentation?.technical.overallPath else { return nil }

        switch path {
        case .confirmation:
            return "Likely moving toward confirmation."
        case .narrowing:
            return "Further clarification likely."
        case .workingDiagnosis:
            return "Treatment or confirmation likely."
        case .monitoring:
            return "Follow-up or observation likely."
        case .reopened:
            return "Reassessment likely."
        case .earlyExploration:
            return "More exploration likely."
        case .mixed:
            return "Direction still evolving."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 8) {
                Text(thread.title)
                    .font(.headline)

                Spacer(minLength: 8)

                trajectoryTrustBadge(for: thread)

                Text(thread.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text("\(visitCount) visits")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let presentation {
                Divider()

                if let compactPathLabel {
                    Text(compactPathLabel)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Text(compactNarrativeMeaning)
                    .font(.subheadline)
                    .lineLimit(2)

                if let compactExpectationLine {
                    Text(compactExpectationLine)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            } else {
                Divider()

                Text(thread.currentUnderstanding)
                    .font(.subheadline)
                    .lineLimit(2)

                Text(thread.nextLikelyStep)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
