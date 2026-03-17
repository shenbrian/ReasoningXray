import SwiftUI

struct ThreadCardView: View {

    let thread: CaseThread
    let visitCount: Int

    @EnvironmentObject var store: ReasoningHistoryStore

    private var displayLanguage: DisplayLanguage {
        store.displayLanguage
    }

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

        switch (path, displayLanguage) {
        case (.earlyExploration, .english):
            return "Exploring"
        case (.earlyExploration, .chineseSimplified):
            return "探索中"

        case (.narrowing, .english):
            return "Narrowing"
        case (.narrowing, .chineseSimplified):
            return "聚焦中"

        case (.workingDiagnosis, .english):
            return "Working explanation"
        case (.workingDiagnosis, .chineseSimplified):
            return "工作性解释"

        case (.confirmation, .english):
            return "Becoming clearer"
        case (.confirmation, .chineseSimplified):
            return "逐渐清晰"

        case (.monitoring, .english):
            return "Monitoring"
        case (.monitoring, .chineseSimplified):
            return "观察中"

        case (.reopened, .english):
            return "Reconsidering"
        case (.reopened, .chineseSimplified):
            return "重新考虑中"

        case (.mixed, .english):
            return "Mixed pattern"
        case (.mixed, .chineseSimplified):
            return "混合模式"
        }
    }

    private var compactNarrativeMeaning: String {
        guard let text = presentation?.patient.narrativeMeaning.resolve(for: displayLanguage) else {
            return ""
        }

        if text.count <= 85 { return text }

        if let range = text.range(of: ".") {
            return String(text[..<range.upperBound])
        }

        return text
    }

    private var compactExpectationLine: String? {
        guard let path = presentation?.technical.overallPath else { return nil }

        switch (path, displayLanguage) {
        case (.confirmation, .english):
            return "Likely moving toward confirmation."
        case (.confirmation, .chineseSimplified):
            return "接下来可能朝确认方向推进。"

        case (.narrowing, .english):
            return "Further clarification likely."
        case (.narrowing, .chineseSimplified):
            return "接下来可能会进一步澄清。"

        case (.workingDiagnosis, .english):
            return "Treatment or confirmation likely."
        case (.workingDiagnosis, .chineseSimplified):
            return "接下来可能进入治疗或确认阶段。"

        case (.monitoring, .english):
            return "Follow-up or observation likely."
        case (.monitoring, .chineseSimplified):
            return "接下来可能继续随访或观察。"

        case (.reopened, .english):
            return "Reassessment likely."
        case (.reopened, .chineseSimplified):
            return "接下来可能会重新评估。"

        case (.earlyExploration, .english):
            return "More exploration likely."
        case (.earlyExploration, .chineseSimplified):
            return "接下来可能继续探索。"

        case (.mixed, .english):
            return "Direction still evolving."
        case (.mixed, .chineseSimplified):
            return "当前方向仍在演变中。"
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
