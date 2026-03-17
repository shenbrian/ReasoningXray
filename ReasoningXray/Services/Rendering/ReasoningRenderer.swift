import Foundation

final class ReasoningRenderer {

    private let languagePipeline = LanguageGuardrailPipeline()
    private let trajectoryMemoryStore = TrajectoryLanguageMemoryStore()
    private let signalExtractor = EpistemicSignalExtractor()
    private let faithfulTranslator = ClinicalFaithfulTranslator()

    func renderVisit(
        from visit: Visit,
        threadID: UUID,
        preferences: ReasoningRenderPreferences
    ) -> RenderedVisitReasoning {

        let session = LanguageRenderSessionContext()
        let memory = trajectoryMemoryStore.memory(for: threadID)
        
        // ⭐ ADD THIS LINE HERE
            var emittedSemanticKeys = Set<String>()
        
        let summaryCarrier = signalExtractor.carrier(
            for: visit.oneLineVisitSummary,
            domain: .trajectory,
            role: .summary
        )
        let currentTrajectory = summaryCarrier.trajectoryState

        let reasonForVisit = localized(
            visit.reasonForVisit,
            .trajectory,
            preferences,
            session,
            role: .summary
        )

        let doctorExplanation = localized(
            visit.doctorExplanation,
            .trajectory,
            preferences,
            session,
            role: .explanation
        )

        let evidence = visit.evidence.map {
            localized($0, .trajectory, preferences, session, role: .evidence)
        }

        let decision = localized(
            visit.decision,
            .authority,
            preferences,
            session,
            role: .decision
        )

        let nextSteps: [LocalizedText] = visit.nextSteps.compactMap { step in
            let carrier = signalExtractor.carrier(
                for: step,
                domain: .expectation,
                role: .nextStep
            )

            let semanticKey = carrier.semanticSignature

            guard !emittedSemanticKeys.contains(semanticKey) else {
                return nil
            }

            emittedSemanticKeys.insert(semanticKey)

            let localizedText = localized(
                step,
                .expectation,
                preferences,
                session,
                role: .nextStep
            )

            if memory.lastTrajectoryState == currentTrajectory {
                return localizedText
            }

            return localizedText
        }

        let whatMightBeHappening = localized(
            visit.whatMightBeHappening,
            .certainty,
            preferences,
            session,
            role: .explanation
        )

        let howSeriousItAppears = localized(
            visit.howSeriousItAppears,
            .emotionalTone,
            preferences,
            session,
            role: .summary
        )

        let whatTheDoctorIsDoing = localized(
            visit.whatTheDoctorIsDoing,
            .authority,
            preferences,
            session,
            role: .decision
        )

        let whatHappensNext = localized(
            visit.whatHappensNext,
            .expectation,
            preferences,
            session,
            role: .expectation
        )

        let questionsForNextVisit = visit.questionsForNextVisit.map {
            localized($0, .expectation, preferences, session, role: .expectation)
        }

        let oneLineVisitSummary = localized(
            visit.oneLineVisitSummary,
            .trajectory,
            preferences,
            session,
            role: .summary
        )

        let mainChangeSinceLastVisit = localized(
            visit.mainChangeSinceLastVisit,
            .trajectory,
            preferences,
            session,
            role: .summary
        )

        let biggestOpenQuestion = localized(
            visit.biggestOpenQuestion,
            .certainty,
            preferences,
            session,
            role: .explanation
        )

        let whatToWatchBeforeNextVisit = localized(
            visit.whatToWatchBeforeNextVisit,
            .expectation,
            preferences,
            session,
            role: .expectation
        )

        trajectoryMemoryStore.advance(
            threadID: visit.caseThreadId,
            with: currentTrajectory
        )

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
        _ session: LanguageRenderSessionContext,
        role: SemanticRole
    ) -> LocalizedText {

        let chinese = faithfulTranslator.translate(text)

        return LocalizedText(
            english: text,
            chineseSimplified: chinese
        )
    }
}


