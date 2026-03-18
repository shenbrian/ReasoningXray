import Foundation

struct EpistemicSignalExtractor {

    func carrier(
        for text: String,
        domain: EpistemicDomain,
        role: SemanticRole
    ) -> SignalCarrier {
        let trajectoryState = inferTrajectoryState(from: text, role: role)
        let certaintyState = inferCertaintyState(
            from: text,
            domain: domain,
            trajectoryState: trajectoryState,
            role: role
        )

        let expectationState = inferExpectationState(from: text)

        let signalEnvelopes = resolveEnvelopes(
            for: domain,
            trajectoryState: trajectoryState,
            certaintyState: certaintyState
        )

        return SignalCarrier(
            id: UUID().uuidString,
            sourceText: text,
            domains: [domain],
            trajectoryState: trajectoryState,
            certaintyState: certaintyState,
            expectationState: expectationState,
            semanticRole: role,
            certaintyEnvelope: signalEnvelopes.certainty,
            temporalEnvelope: signalEnvelopes.temporal,
            authorityEnvelope: signalEnvelopes.authority,
            emotionalEnvelope: signalEnvelopes.emotional
        )
    }
    
    private func inferExpectationState(from text: String) -> ExpectationState? {

        let lower = text.lowercased()

        if lower.contains("clearer") || lower.contains("become clearer") {
            return .clarityMayIncrease
        }

        if lower.contains("more tests") || lower.contains("more information") {
            return .moreInformationNeeded
        }

        if lower.contains("follow") || lower.contains("review") {
            return .followUpMatters
        }

        if lower.contains("monitor") || lower.contains("observe") {
            return .noImmediateResolutionExpected
        }

        return nil
    }

    private func inferTrajectoryState(
        from text: String,
        role: SemanticRole
    ) -> TrajectoryState {
        let lower = text.lowercased()

        if lower.contains("monitor") || lower.contains("observe") {
            return .exploring
        }

        if lower.contains("narrow") || lower.contains("focus") || lower.contains("possible") {
            return .narrowing
        }

        if lower.contains("working diagnosis") || lower.contains("likely") {
            return .workingExplanation
        }

        if lower.contains("confirm") || lower.contains("definite") || lower.contains("clear") {
            return .confirmation
        }

        switch role {
        case .nextStep, .expectation:
            return .exploring
        case .decision:
            return .workingExplanation
        case .summary:
            return .narrowing
        case .explanation:
            return .narrowing
        case .evidence:
            return .narrowing
        }
    }

    private func inferCertaintyState(
        from text: String,
        domain: EpistemicDomain,
        trajectoryState: TrajectoryState,
        role: SemanticRole
    ) -> CertaintyState {
        let lower = text.lowercased()

        if lower.contains("may") || lower.contains("might") || lower.contains("unclear") {
            return .activeUncertainty
        }

        if lower.contains("possible") || lower.contains("appears") || lower.contains("seems") {
            return .emergingClarity
        }

        if lower.contains("likely") || role == .decision {
            return .workingExplanation
        }

        if lower.contains("confirmed") || lower.contains("definite") {
            return .stabilizingUnderstanding
        }

        switch trajectoryState {
        case .exploring:
            return .activeUncertainty
        case .narrowing:
            return .emergingClarity
        case .workingExplanation:
            return .workingExplanation
        case .confirmation:
            return .stabilizingUnderstanding
        }
    }

    private func resolveEnvelopes(
        for domain: EpistemicDomain,
        trajectoryState: TrajectoryState,
        certaintyState: CertaintyState
    ) -> (
        certainty: ScoreEnvelope,
        temporal: ScoreEnvelope,
        authority: ScoreEnvelope,
        emotional: ScoreEnvelope
    ) {
        switch domain {
        case .certainty:
            switch certaintyState {
            case .activeUncertainty:
                return (
                    ScoreEnvelope(min: 0.20, max: 0.40),
                    ScoreEnvelope(min: 0.10, max: 0.45),
                    ScoreEnvelope(min: 0.10, max: 0.35),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .emergingClarity:
                return (
                    ScoreEnvelope(min: 0.30, max: 0.55),
                    ScoreEnvelope(min: 0.10, max: 0.40),
                    ScoreEnvelope(min: 0.10, max: 0.40),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .workingExplanation:
                return (
                    ScoreEnvelope(min: 0.40, max: 0.65),
                    ScoreEnvelope(min: 0.10, max: 0.35),
                    ScoreEnvelope(min: 0.15, max: 0.45),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .stabilizingUnderstanding:
                return (
                    ScoreEnvelope(min: 0.50, max: 0.75),
                    ScoreEnvelope(min: 0.05, max: 0.25),
                    ScoreEnvelope(min: 0.15, max: 0.45),
                    ScoreEnvelope(min: 0.05, max: 0.25)
                )
            }

        case .trajectory:
            switch trajectoryState {
            case .exploring:
                return (
                    ScoreEnvelope(min: 0.20, max: 0.40),
                    ScoreEnvelope(min: 0.10, max: 0.50),
                    ScoreEnvelope(min: 0.10, max: 0.35),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .narrowing:
                return (
                    ScoreEnvelope(min: 0.30, max: 0.55),
                    ScoreEnvelope(min: 0.10, max: 0.40),
                    ScoreEnvelope(min: 0.10, max: 0.40),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .workingExplanation:
                return (
                    ScoreEnvelope(min: 0.40, max: 0.65),
                    ScoreEnvelope(min: 0.10, max: 0.35),
                    ScoreEnvelope(min: 0.15, max: 0.45),
                    ScoreEnvelope(min: 0.05, max: 0.30)
                )
            case .confirmation:
                return (
                    ScoreEnvelope(min: 0.50, max: 0.75),
                    ScoreEnvelope(min: 0.05, max: 0.25),
                    ScoreEnvelope(min: 0.15, max: 0.45),
                    ScoreEnvelope(min: 0.05, max: 0.25)
                )
            }

        case .expectation:
            return (
                ScoreEnvelope(min: 0.20, max: 0.45),
                ScoreEnvelope(min: 0.10, max: 0.35),
                ScoreEnvelope(min: 0.10, max: 0.35),
                ScoreEnvelope(min: 0.05, max: 0.25)
            )

        case .authority:
            return (
                ScoreEnvelope(min: 0.25, max: 0.50),
                ScoreEnvelope(min: 0.05, max: 0.25),
                ScoreEnvelope(min: 0.10, max: 0.30),
                ScoreEnvelope(min: 0.05, max: 0.20)
            )

        case .emotionalTone:
            return (
                ScoreEnvelope(min: 0.20, max: 0.45),
                ScoreEnvelope(min: 0.05, max: 0.25),
                ScoreEnvelope(min: 0.10, max: 0.30),
                ScoreEnvelope(min: 0.05, max: 0.20)
            )
        }
    }
}
