import Foundation

struct LanguageGuardrailPipeline {
    private let pack: MandarinLanguagePack
    private let scorer: EpistemicScoringEngine

    init() {
        let pack = MandarinLanguagePack()
        self.pack = pack
        self.scorer = EpistemicScoringEngine(pack: pack)
    }

    func renderMandarin(
        for carrier: SignalCarrier,
        session: LanguageRenderSessionContext
    ) -> RenderAudit {
        let initialCandidate = pack.initialCandidate(for: carrier)
        let initialScore = scorer.score(initialCandidate, against: carrier)

        let initialValidation = validate(initialScore)

        switch initialValidation.decision {
        case .pass:
            return RenderAudit(
                id: UUID(),
                segmentID: carrier.id,
                sourceText: carrier.sourceText,
                initialCandidate: initialCandidate,
                initialScore: initialScore,
                rewriteSteps: [],
                finalOutput: initialCandidate,
                finalScore: initialScore,
                validation: initialValidation,
                languageCode: pack.languageCode
            )

        case .rewrite:
            let rewriteResult = rewrite(candidate: initialCandidate, carrier: carrier)
            let finalValidation = validate(rewriteResult.score)

            if finalValidation.decision == .pass || finalValidation.decision == .rewrite {
                return RenderAudit(
                    id: UUID(),
                    segmentID: carrier.id,
                    sourceText: carrier.sourceText,
                    initialCandidate: initialCandidate,
                    initialScore: initialScore,
                    rewriteSteps: rewriteResult.steps,
                    finalOutput: rewriteResult.text,
                    finalScore: rewriteResult.score,
                    validation: finalValidation,
                    languageCode: pack.languageCode
                )
            } else {
                let fallback = fallbackText(for: carrier)
                let fallbackScore = scorer.score(fallback, against: carrier)
                let fallbackValidation = validate(fallbackScore)

                return RenderAudit(
                    id: UUID(),
                    segmentID: carrier.id,
                    sourceText: carrier.sourceText,
                    initialCandidate: initialCandidate,
                    initialScore: initialScore,
                    rewriteSteps: rewriteResult.steps,
                    finalOutput: fallback,
                    finalScore: fallbackScore,
                    validation: fallbackValidation,
                    languageCode: pack.languageCode
                )
            }

        case .fallback, .blocked:
            let fallback = fallbackText(for: carrier)
            let fallbackScore = scorer.score(fallback, against: carrier)
            let fallbackValidation = validate(fallbackScore)

            return RenderAudit(
                id: UUID(),
                segmentID: carrier.id,
                sourceText: carrier.sourceText,
                initialCandidate: initialCandidate,
                initialScore: initialScore,
                rewriteSteps: [],
                finalOutput: fallback,
                finalScore: fallbackScore,
                validation: fallbackValidation,
                languageCode: pack.languageCode
            )
        }
    }

    private func validate(_ score: EpistemicScore) -> GuardrailValidationResult {
        let hasForbiddenPattern = score.violationFlags.contains { $0.hasPrefix("FORBIDDEN_PATTERN:") }

        if hasForbiddenPattern {
            return GuardrailValidationResult(
                decision: .fallback,
                reasons: score.violationFlags
            )
        }

        let outOfRangeCount = score.violationFlags.count

        if outOfRangeCount == 0 {
            return GuardrailValidationResult(
                decision: .pass,
                reasons: []
            )
        }

        if score.compositeRiskIndex <= 0.15 {
            return GuardrailValidationResult(
                decision: .rewrite,
                reasons: score.violationFlags
            )
        }

        return GuardrailValidationResult(
            decision: .fallback,
            reasons: score.violationFlags
        )
    }

    private func rewrite(candidate: String, carrier: SignalCarrier) -> (text: String, score: EpistemicScore, steps: [RewriteStep]) {
        var current = candidate
        var steps: [RewriteStep] = []

        let score1 = scorer.score(current, against: carrier)
        if score1.css > carrier.certaintyEnvelope.max {
            let before = current
            if !current.contains("似乎") {
                current = current.replacingOccurrences(of: "正在", with: "似乎正在")
            }
            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Insert uncertainty softener to reduce CSS."
                    )
                )
            }
        }

        let score2 = scorer.score(current, against: carrier)
        if score2.tps > carrier.temporalEnvelope.max {
            let before = current
            if !current.contains("逐渐") {
                current = current.replacingOccurrences(of: "聚焦", with: "逐渐聚焦")
            }
            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Insert gradual temporal marker to reduce TPS."
                    )
                )
            }
        }

        let score3 = scorer.score(current, against: carrier)
        if score3.ags > carrier.authorityEnvelope.max {
            let before = current
            if !current.contains("医生的思路") {
                current = "医生的思路" + current
            }
            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Anchor statement back to doctor reasoning to reduce AGS."
                    )
                )
            }
        }

        let score4 = scorer.score(current, against: carrier)
        if score4.ags < carrier.authorityEnvelope.min {
            let before = current
            if current.contains("医生的思路") {
                current = current.replacingOccurrences(of: "医生的思路", with: "目前医生的思路")
            }
            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Slightly strengthen neutral structural framing to raise AGS."
                    )
                )
            }
        }
        
        
        let finalScore = scorer.score(current, against: carrier)
        return (current, finalScore, steps)
    }

    private func fallbackText(for carrier: SignalCarrier) -> String {
        pack.approvedFallbacks[carrier.trajectoryState] ?? "目前还需要进一步观察。"
    }
}
