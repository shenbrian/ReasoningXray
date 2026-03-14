import Foundation

final class ReasoningRenderer {

    func renderVisit(
        from visit: Visit,
        preferences: ReasoningRenderPreferences
    ) -> RenderedVisitReasoning {

        let reasonForVisit = localized(visit.reasonForVisit)
        let doctorExplanation = localized(visit.doctorExplanation)
        let evidence = visit.evidence.map { localized($0) }
        let decision = localized(visit.decision)
        let nextSteps = visit.nextSteps.map { localized($0) }

        let whatMightBeHappening = localized(visit.whatMightBeHappening)
        let howSeriousItAppears = localized(visit.howSeriousItAppears)
        let whatTheDoctorIsDoing = localized(visit.whatTheDoctorIsDoing)
        let whatHappensNext = localized(visit.whatHappensNext)
        let questionsForNextVisit = visit.questionsForNextVisit.map { localized($0) }

        let oneLineVisitSummary = localized(visit.oneLineVisitSummary)
        let mainChangeSinceLastVisit = localized(visit.mainChangeSinceLastVisit)
        let biggestOpenQuestion = localized(visit.biggestOpenQuestion)
        let whatToWatchBeforeNextVisit = localized(visit.whatToWatchBeforeNextVisit)

        return RenderedVisitReasoning(
            reasonForVisit: reasonForVisit,
            doctorExplanation: doctorExplanation,
            evidence: evidence,
            decision: decision,
            nextSteps: nextSteps,
            whatMightBeHappening: whatMightBeHappening,
            howSeriousItAppears: howSeriousItAppears,
            whatTheDoctorIsDoing: whatTheDoctorIsDoing,
            whatHappensNext: whatHappensNext,
            questionsForNextVisit: questionsForNextVisit,
            oneLineVisitSummary: oneLineVisitSummary,
            mainChangeSinceLastVisit: mainChangeSinceLastVisit,
            biggestOpenQuestion: biggestOpenQuestion,
            whatToWatchBeforeNextVisit: whatToWatchBeforeNextVisit
        )
    }

    private func localized(_ text: String) -> LocalizedText {
        LocalizedText(
            english: text,
            chineseSimplified: nil
        )
    }
}
