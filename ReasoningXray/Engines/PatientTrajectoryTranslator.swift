import Foundation

struct PatientTrajectoryTranslator {

    func translate(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> PatientTrajectoryTranslation {

        let narrativeMeaningEN = makeNarrativeMeaningEN(
            overallPath: overallPath,
            activeUncertainty: activeUncertainty
        )
        let narrativeMeaningZH = makeNarrativeMeaningZH(
            overallPath: overallPath,
            activeUncertainty: activeUncertainty
        )

        let reassuranceFramingEN = makeReassuranceFramingEN(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )
        let reassuranceFramingZH = makeReassuranceFramingZH(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        let forwardExpectationEN = makeForwardExpectationEN(overallPath: overallPath)
        let forwardExpectationZH = makeForwardExpectationZH(overallPath: overallPath)

        let decisionSafetyFramingEN = makeDecisionSafetyFramingEN(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            activeUncertainty: activeUncertainty
        )
        let decisionSafetyFramingZH = makeDecisionSafetyFramingZH(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            activeUncertainty: activeUncertainty
        )

        return PatientTrajectoryTranslation(
            narrativeMeaning: LocalizedText(
                english: narrativeMeaningEN,
                chineseSimplified: narrativeMeaningZH
            ),
            reassuranceFraming: LocalizedText(
                english: reassuranceFramingEN,
                chineseSimplified: reassuranceFramingZH
            ),
            forwardExpectation: LocalizedText(
                english: forwardExpectationEN,
                chineseSimplified: forwardExpectationZH
            ),
            decisionSafetyFraming: LocalizedText(
                english: decisionSafetyFramingEN,
                chineseSimplified: decisionSafetyFramingZH
            )
        )
    }
}

private extension PatientTrajectoryTranslator {

    func makeNarrativeMeaningEN(
        overallPath: ReasoningOverallPath,
        activeUncertainty: Bool
    ) -> String {
        switch overallPath {
        case .confirmation:
            return activeUncertainty
                ? "The doctor's thinking appears to be moving toward a clearer explanation, although some uncertainty is still present."
                : "The doctor's thinking appears to be settling around a clearer explanation."
        case .workingDiagnosis:
            return activeUncertainty
                ? "The doctor's thinking appears to be forming a likely explanation, but the picture is not fully settled yet."
                : "The doctor's thinking appears to be settling around a likely explanation."
        case .narrowing:
            return activeUncertainty
                ? "The doctor's thinking appears to be narrowing toward a more focused explanation, but some uncertainty is still present."
                : "The doctor's thinking appears to be narrowing toward a more focused explanation."
        case .earlyExploration:
            return "The doctor's thinking appears to still be exploring different possible explanations."
        case .monitoring:
            return "The doctor's thinking appears to be monitoring the situation over time rather than reaching a final explanation yet."
        case .reopened:
            return "The doctor's thinking appears to be reconsidering the earlier explanation and reopening the case."
        case .mixed:
            return "The doctor's reasoning appears to contain both forward progress and unresolved uncertainty at the same time."
        }
    }

    func makeNarrativeMeaningZH(
        overallPath: ReasoningOverallPath,
        activeUncertainty: Bool
    ) -> String {
        switch overallPath {
        case .confirmation:
            return activeUncertainty
                ? "医生的判断似乎正朝着一个更清晰的解释发展，不过目前仍然存在一些不确定性。"
                : "医生的判断似乎正在围绕一个更清晰的解释逐渐稳定下来。"
        case .workingDiagnosis:
            return activeUncertainty
                ? "医生的判断似乎正在形成一个较可能的解释，但整体情况尚未完全稳定。"
                : "医生的判断似乎正在围绕一个较可能的解释逐渐稳定下来。"
        case .narrowing:
            return activeUncertainty
                ? "医生的判断似乎正在缩小到一个更聚焦的解释，但目前仍然存在一些不确定性。"
                : "医生的判断似乎正在缩小到一个更聚焦的解释。"
        case .earlyExploration:
            return "医生的判断似乎仍在探索不同的可能解释。"
        case .monitoring:
            return "医生的判断似乎是在随时间持续观察情况，而不是目前就得出最终解释。"
        case .reopened:
            return "医生的判断似乎正在重新考虑先前的解释，并再次审视这个情况。"
        case .mixed:
            return "医生的判断似乎同时包含了向前推进的进展和仍未解决的不确定性。"
        }
    }

    func makeReassuranceFramingEN(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "This usually suggests the situation is becoming clearer and more stable."
        }
        if overallPath == .workingDiagnosis && certaintyTrend != .decreasing {
            return activeUncertainty
                ? "This suggests the doctor is moving toward a likely explanation, even though some uncertainty remains."
                : "This suggests the doctor has reached a more defined working explanation."
        }
        if overallPath == .narrowing && momentum == .advancing {
            return activeUncertainty
                ? "This suggests progress is being made, even though some uncertainty remains."
                : "This suggests the picture is becoming more focused."
        }
        if overallPath == .reopened || certaintyTrend == .decreasing {
            return "This does not necessarily mean something is wrong, but it does mean the reasoning is still being actively reassessed."
        }
        if overallPath == .earlyExploration {
            return "At this stage, it is normal for the reasoning to still be open while different possibilities are being considered."
        }
        if overallPath == .monitoring {
            return "This suggests the situation is being watched carefully over time rather than rushed to a conclusion."
        }
        if activeUncertainty {
            return "It is reasonable that things still feel open at this stage, because the reasoning has not fully settled yet."
        }
        return "The reasoning appears to be moving in an orderly way, even if it is not fully final yet."
    }

    func makeReassuranceFramingZH(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "这通常表示目前情况正变得更加清晰，也更加稳定。"
        }
        if overallPath == .workingDiagnosis && certaintyTrend != .decreasing {
            return activeUncertainty
                ? "这表示医生正朝着一个较可能的解释推进，虽然仍然保留一些不确定性。"
                : "这表示医生已经形成了一个更明确的工作性解释。"
        }
        if overallPath == .narrowing && momentum == .advancing {
            return activeUncertainty
                ? "这表示目前正在取得进展，虽然仍然存在一些不确定性。"
                : "这表示整体情况正在变得更加聚焦。"
        }
        if overallPath == .reopened || certaintyTrend == .decreasing {
            return "这并不一定意味着出现了问题，但表示医生的判断仍在被积极重新评估。"
        }
        if overallPath == .earlyExploration {
            return "在这个阶段，当医生仍在考虑不同可能性时，判断尚未完全收敛是正常的。"
        }
        if overallPath == .monitoring {
            return "这表示目前是在随时间谨慎观察情况，而不是仓促下结论。"
        }
        if activeUncertainty {
            return "在这个阶段，情况仍显得开放是合理的，因为医生的判断尚未完全稳定。"
        }
        return "医生的判断似乎正在有条理地推进，尽管目前还没有完全定论。"
    }

    func makeForwardExpectationEN(
        overallPath: ReasoningOverallPath
    ) -> String {
        switch overallPath {
        case .confirmation:
            return "Expect the next steps to focus more on confirming or acting on the current explanation."
        case .workingDiagnosis:
            return "Expect the next steps to test, confirm, or refine the current working explanation."
        case .narrowing:
            return "Expect the next steps to further clarify which explanation best fits the pattern."
        case .earlyExploration:
            return "Expect the next steps to involve more questions, comparisons, or early tests before the picture becomes clearer."
        case .monitoring:
            return "Expect follow-up or observation over time rather than immediate closure."
        case .reopened:
            return "Expect the next steps to involve reconsideration, new questions, or different tests before things become clearer."
        case .mixed:
            return "Expect some parts of the reasoning to move forward while other parts may still need clarification."
        }
    }

    func makeForwardExpectationZH(
        overallPath: ReasoningOverallPath
    ) -> String {
        switch overallPath {
        case .confirmation:
            return "接下来的步骤可能会更集中于确认当前解释，或依据当前解释采取行动。"
        case .workingDiagnosis:
            return "接下来的步骤可能会围绕检验、确认或进一步完善当前的工作性解释。"
        case .narrowing:
            return "接下来的步骤可能会进一步澄清，哪一种解释最符合目前的整体模式。"
        case .earlyExploration:
            return "在情况变得更清晰之前，接下来的步骤可能包括更多问诊、比较，或初步检查。"
        case .monitoring:
            return "接下来更可能是继续随访或一段时间内观察，而不是立即得出结论。"
        case .reopened:
            return "在情况变得更清晰之前，接下来的步骤可能包括重新考虑、提出新的问题，或进行不同的检查。"
        case .mixed:
            return "接下来可能会出现这样的情况：部分判断继续向前推进，而另一些部分仍需要进一步澄清。"
        }
    }

    func makeDecisionSafetyFramingEN(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "At this point, the reasoning appears relatively stable rather than exploratory."
        }
        if overallPath == .workingDiagnosis && !activeUncertainty {
            return "The reasoning appears to have reached a working explanation, although it may still need confirmation."
        }
        if overallPath == .narrowing && !activeUncertainty {
            return "The reasoning is becoming more focused, though it still appears somewhat provisional."
        }
        if overallPath == .monitoring {
            return "The situation does not yet appear fully settled, and continued follow-up may still matter."
        }
        if overallPath == .earlyExploration || overallPath == .mixed {
            return "This stage should be understood as still developing rather than settled."
        }
        if overallPath == .reopened || certaintyTrend == .decreasing || activeUncertainty {
            return "The reasoning still appears open, so it is safer to view the current explanation as provisional."
        }
        return "The current explanation should still be viewed as developing rather than final."
    }

    func makeDecisionSafetyFramingZH(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        activeUncertainty: Bool
    ) -> String {
        if overallPath == .confirmation && certaintyTrend == .increasing && !activeUncertainty {
            return "在目前这个阶段，医生的判断看起来相对稳定，而不再主要处于探索阶段。"
        }
        if overallPath == .workingDiagnosis && !activeUncertainty {
            return "医生的判断似乎已经形成了一个工作性解释，不过仍可能需要进一步确认。"
        }
        if overallPath == .narrowing && !activeUncertainty {
            return "医生的判断正在变得更加聚焦，不过目前看起来仍带有一定暂时性。"
        }
        if overallPath == .monitoring {
            return "目前情况看起来尚未完全稳定，因此继续随访仍然可能很重要。"
        }
        if overallPath == .earlyExploration || overallPath == .mixed {
            return "这个阶段应理解为仍在发展中，而不是已经稳定下来。"
        }
        if overallPath == .reopened || certaintyTrend == .decreasing || activeUncertainty {
            return "医生的判断目前看起来仍然开放，因此更稳妥的理解方式是把当前解释视为暂时性的。"
        }
        return "当前解释仍应被视为在发展中的判断，而不是最终结论。"
    }
}
