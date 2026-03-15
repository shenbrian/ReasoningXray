import Foundation

final class ReasoningRenderer {

    private let languagePipeline = LanguageGuardrailPipeline()
    private let languageSession = LanguageRenderSessionContext()

    func renderVisit(
        from visit: Visit,
        preferences: ReasoningRenderPreferences
    ) -> RenderedVisitReasoning {

        let session = LanguageRenderSessionContext()

        let reasonForVisit = localized(visit.reasonForVisit, .trajectory, preferences, session)
        let doctorExplanation = localized(visit.doctorExplanation, .trajectory, preferences, session)
        let evidence = visit.evidence.map { localized($0, .trajectory, preferences, session) }
        let decision = localized(visit.decision, .authority, preferences, session)
        let nextSteps = visit.nextSteps.map { localized($0, .expectation, preferences, session) }

        let whatMightBeHappening = localized(visit.whatMightBeHappening, .certainty, preferences, session)
        let howSeriousItAppears = localized(visit.howSeriousItAppears, .emotionalTone, preferences, session)
        let whatTheDoctorIsDoing = localized(visit.whatTheDoctorIsDoing, .authority, preferences, session)
        let whatHappensNext = localized(visit.whatHappensNext, .expectation, preferences, session)
        let questionsForNextVisit = visit.questionsForNextVisit.map {
            localized($0, .expectation, preferences, session)
        }

        let oneLineVisitSummary = localized(visit.oneLineVisitSummary, .trajectory, preferences, session)
        let mainChangeSinceLastVisit = localized(visit.mainChangeSinceLastVisit, .trajectory, preferences, session)
        let biggestOpenQuestion = localized(visit.biggestOpenQuestion, .certainty, preferences, session)
        let whatToWatchBeforeNextVisit = localized(visit.whatToWatchBeforeNextVisit, .expectation, preferences, session)

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

    private func localized(
        _ text: String,
        _ domain: EpistemicDomain,
        _ preferences: ReasoningRenderPreferences,
        _ session: LanguageRenderSessionContext
    ) -> LocalizedText {

        guard preferences.displayLanguage == .chineseSimplified else {
            return LocalizedText(english: text)
        }

        let trajectory = inferTrajectoryState(from: text)

        let carrier = SignalCarrier(
            id: UUID().uuidString,
            sourceText: text,
            domains: [domain],
            trajectoryState: trajectory,
            certaintyEnvelope: envelope(for: trajectory).certainty,
            temporalEnvelope: envelope(for: trajectory).temporal,
            authorityEnvelope: envelope(for: trajectory).authority,
            emotionalEnvelope: envelope(for: trajectory).emotional
        )

        let audit = languagePipeline.renderMandarin(
            for: carrier,
            session: session
        )

        return LocalizedText(
            english: text,
            chineseSimplified: audit.finalOutput
        )
    }
    
    private func inferTrajectoryState(from text: String) -> TrajectoryState {
        let lower = text.lowercased()

        if lower.contains("monitor") || lower.contains("observe") {
            return .exploring
        }

        if lower.contains("trial") || lower.contains("possible") {
            return .narrowing
        }

        if lower.contains("likely") || lower.contains("working diagnosis") {
            return .workingExplanation
        }

        if lower.contains("confirmed") || lower.contains("definite") {
            return .confirmation
        }

        return .narrowing
    }

    private func envelope(
        for state: TrajectoryState
    ) -> (
        certainty: ScoreEnvelope,
        temporal: ScoreEnvelope,
        authority: ScoreEnvelope,
        emotional: ScoreEnvelope
    ) {
        switch state {
        case .exploring:
            return (
                ScoreEnvelope(min: 0.20, max: 0.45),
                ScoreEnvelope(min: 0.10, max: 0.55),
                ScoreEnvelope(min: 0.10, max: 0.45),
                ScoreEnvelope(min: 0.05, max: 0.40)
            )

        case .narrowing:
            return (
                ScoreEnvelope(min: 0.30, max: 0.60),
                ScoreEnvelope(min: 0.10, max: 0.50),
                ScoreEnvelope(min: 0.10, max: 0.50),
                ScoreEnvelope(min: 0.05, max: 0.40)
            )

        case .workingExplanation:
            return (
                ScoreEnvelope(min: 0.45, max: 0.75),
                ScoreEnvelope(min: 0.10, max: 0.45),
                ScoreEnvelope(min: 0.20, max: 0.60),
                ScoreEnvelope(min: 0.05, max: 0.35)
            )

        case .confirmation:
            return (
                ScoreEnvelope(min: 0.60, max: 0.90),
                ScoreEnvelope(min: 0.05, max: 0.30),
                ScoreEnvelope(min: 0.35, max: 0.80),
                ScoreEnvelope(min: 0.05, max: 0.30)
            )
        }
    }

    private func inferDomain(from text: String) -> EpistemicDomain {
        let lower = text.lowercased()

        if lower.contains("likely") || lower.contains("plausible") {
            return .certainty
        }

        if lower.contains("review") || lower.contains("check") || lower.contains("follow up") {
            return .expectation
        }

        if lower.contains("continue") || lower.contains("monitor") {
            return .authority
        }

        if lower.contains("worry") || lower.contains("serious") {
            return .emotionalTone
        }

        return .trajectory
    }
}
