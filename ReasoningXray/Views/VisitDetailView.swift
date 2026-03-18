import SwiftUI

struct VisitDetailView: View {
    let visit: Visit
    @EnvironmentObject var store: ReasoningHistoryStore

    private var rendered: RenderedVisitReasoning {
        store.renderedVisitReasoning(for: visit)
    }

    private var displayLanguage: DisplayLanguage {
        store.displayLanguage
    }

    private var isChinese: Bool {
        String(describing: displayLanguage).lowercased().contains("chinese")
    }

    private var isEnglish: Bool {
        !isChinese
    }

    private func ui(_ english: String, _ chinese: String) -> String {
        isChinese ? chinese : english
    }

    private var debugLanguage: some View {
        Text(ui("LANG = EN", "LANG = ZH"))
            .font(.caption)
            .foregroundColor(.red)
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
            return ui(
                "This is the first recorded visit for this issue.",
                "这是该问题第一次被记录的就诊。"
            )
        }

        if comparison.changes.isEmpty {
            return ui(
                "No major reasoning change was detected from the previous visit.",
                "与上一次就诊相比，没有发现明显的判断变化。"
            )
        }

        let changeTexts = comparison.changes.map { changeSummary(for: $0.kind) }

        if changeTexts.count == 1 {
            return changeTexts[0]
        }

        if changeTexts.count == 2 {
            return isChinese
                ? "\(changeTexts[0])，并且\(changeTexts[1])。"
                : "\(changeTexts[0]) and \(changeTexts[1])."
        }

        let head = changeTexts.dropLast().joined(separator: isChinese ? "，" : ", ")
        let tail = changeTexts.last ?? ""

        return isChinese
            ? "\(head)，并且\(tail)。"
            : "\(head), and \(tail)."
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
            Text(ui("Display Language", "显示语言"))
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
                            isEnglish ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.10)
                        )
                        .foregroundStyle(isEnglish ? Color.blue : Color.primary)
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
                            isChinese ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.10)
                        )
                        .foregroundStyle(isChinese ? Color.blue : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            Text(ui("Current language: English", "当前语言：中文"))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(ui("Temporary debug toggle for bilingual rendering.", "用于双语显示测试的临时调试切换。"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var changeSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ui("Compared with the previous visit", "与上一次就诊相比"))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(ui("What changed since last visit", "自上次就诊后有什么变化"))
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
            Text(ui("What This Means For You", "这对你的意义"))
                .font(.title3.bold())

            detailRow(
                ui("Why this visit happened", "这次就诊为什么发生"),
                rendered.reasonForVisit.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What might be happening", "目前可能是什么情况"),
                rendered.whatMightBeHappening.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What this suggests", "这提示什么"),
                rendered.howSeriousItAppears.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What the doctor is doing", "医生目前在做什么"),
                rendered.whatTheDoctorIsDoing.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What happens next", "接下来会怎样"),
                rendered.whatHappensNext.resolve(for: displayLanguage)
            )

            detailList(
                ui("Questions for next visit", "下次就诊可问的问题"),
                rendered.questionsForNextVisit.map { $0.resolve(for: displayLanguage) }
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var layer1Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ui("Doctor Reasoning Mirror", "医生推理镜像"))
                .font(.title3.bold())

            detailRow(
                ui("Reason for visit", "就诊原因"),
                rendered.reasonForVisit.resolve(for: displayLanguage)
            )

            detailRow(
                ui("Doctor explanation", "医生的解释"),
                rendered.doctorExplanation.resolve(for: displayLanguage)
            )

            detailList(
                ui("Evidence", "依据"),
                rendered.evidence.map { $0.resolve(for: displayLanguage) }
            )

            detailRow(
                ui("Decision", "当前决定"),
                rendered.decision.resolve(for: displayLanguage)
            )

            detailList(
                ui("Next steps", "下一步"),
                rendered.nextSteps.map { $0.resolve(for: displayLanguage) }
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var additionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ui("What Changed Since Last Visit", "自上次就诊后的变化"))
                .font(.title3.bold())

            detailRow(
                ui("Main change since last visit", "与上次相比的主要变化"),
                rendered.mainChangeSinceLastVisit.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What triggered the reasoning change", "是什么促使判断发生变化"),
                reasoningTriggerText
            )

            detailRow(
                ui("Biggest open question", "目前最大的未决问题"),
                rendered.biggestOpenQuestion.resolve(for: displayLanguage)
            )

            detailRow(
                ui("What to watch before next visit", "下次就诊前需要留意什么"),
                rendered.whatToWatchBeforeNextVisit.resolve(for: displayLanguage)
            )

            detailList(
                ui("Symptoms mentioned", "提到的症状"),
                translatedItems(visit.symptomsMentioned)
            )

            detailList(
                ui("Tests ordered", "已安排的检查"),
                translatedItems(visit.testsOrdered)
            )

            detailList(
                ui("Diagnoses considered", "考虑过的诊断"),
                translatedItems(visit.diagnosesConsidered)
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var reasoningTriggerText: String {
        if !visit.testsOrdered.isEmpty {
            return ui(
                "Testing influenced the reasoning change.",
                "检查结果影响了医生判断的变化。"
            )
        }

        let evidenceText = visit.evidence.joined(separator: " ").lowercased()

        if evidenceText.contains("improvement") || evidenceText.contains("response") {
            return ui(
                "Treatment response influenced the reasoning change.",
                "治疗后的反应影响了医生判断的变化。"
            )
        }

        if evidenceText.contains("persist") || evidenceText.contains("still present") || evidenceText.contains("wors") {
            return ui(
                "Ongoing symptoms influenced the reasoning change.",
                "持续存在的症状影响了医生判断的变化。"
            )
        }

        if !visit.evidence.isEmpty {
            return ui(
                "New evidence influenced the reasoning change.",
                "新的信息影响了医生判断的变化。"
            )
        }

        return ui(
            "The doctor's updated assessment influenced the reasoning change.",
            "医生更新后的评估影响了判断的变化。"
        )
    }

    private func changeSummary(for kind: ReasoningChangeKind) -> String {
        switch kind {
        case .continuedMonitoring:
            return ui(
                "The doctor continued monitoring the problem",
                "医生继续观察这个问题"
            )
        case .reconsideredExplanation:
            return ui(
                "The doctor reconsidered the earlier explanation",
                "医生重新考虑了先前的解释"
            )
        case .orderedTesting:
            return ui(
                "The doctor moved to testing",
                "医生转向进一步检查"
            )
        case .startedTreatmentTrial:
            return ui(
                "The doctor started a treatment trial",
                "医生开始尝试治疗"
            )
        case .newEvidenceInfluencedReasoning:
            return ui(
                "New information affected the doctor's thinking",
                "新信息影响了医生的判断"
            )
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? ui("Not recorded", "未记录")
                    : value
            )
        }
    }

    private func translateRaw(_ text: String) -> String {
        guard isChinese else { return text }
        return ClinicalFaithfulTranslator().translate(text)
    }

    private func translatedItems(_ items: [String]) -> [String] {
        items.map { translateRaw($0) }
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
                Text(ui("None", "无"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(cleaned.enumerated()), id: \.offset) { _, item in
                    Text(item)
                }
            }
        }
    }
}
