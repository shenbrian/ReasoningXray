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

    private func rewrite(
        candidate: String,
        carrier: SignalCarrier
    ) -> (text: String, score: EpistemicScore, steps: [RewriteStep]) {

        var current = candidate
        var steps: [RewriteStep] = []

        let domain = carrier.domains.first ?? .trajectory

        let score1 = scorer.score(current, against: carrier)
        if score1.css > carrier.certaintyEnvelope.max {
            let before = current

            switch domain {
            case .certainty:
                if !current.contains("目前") {
                    current = "目前" + current
                }
                if !current.contains("仍") && current.contains("判断") {
                    current = current.replacingOccurrences(of: "判断", with: "判断仍")
                }

            case .trajectory:
                if !current.contains("逐渐") && current.contains("集中") {
                    current = current.replacingOccurrences(of: "集中", with: "逐渐集中")
                }
                if !current.contains("较") && current.contains("明确") {
                    current = current.replacingOccurrences(of: "明确", with: "较明确")
                }

            case .expectation:
                if !current.contains("还需要") {
                    current = "还需要继续观察。" + current
                }

            case .authority:
                if !current.contains("暂时") {
                    current = current.replacingOccurrences(of: "选择", with: "暂时选择")
                }

            case .emotionalTone:
                if !current.contains("现阶段") {
                    current = "现阶段" + current
                }
            }

            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Reduce certainty intensity for domain-aware safety."
                    )
                )
            }
        }

        let score2 = scorer.score(current, against: carrier)
        if score2.tps > carrier.temporalEnvelope.max {
            let before = current

            if !current.contains("逐渐") && current.contains("改善") {
                current = current.replacingOccurrences(of: "改善", with: "逐渐改善")
            } else if !current.contains("后续") {
                current = "后续" + current
            }

            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Insert softer temporal progression marker."
                    )
                )
            }
        }

        let score3 = scorer.score(current, against: carrier)
        if score3.ags > carrier.authorityEnvelope.max {
            let before = current

            if !current.contains("医生目前") && current.contains("医生") {
                current = current.replacingOccurrences(of: "医生", with: "医生目前")
            } else if !current.contains("现阶段") {
                current = "现阶段" + current
            }

            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Reduce authority force by re-anchoring to present-stage framing."
                    )
                )
            }
        }

        let score4 = scorer.score(current, against: carrier)
        if score4.ets > carrier.emotionalEnvelope.max {
            let before = current

            if current.contains("严重") {
                current = current.replacingOccurrences(of: "严重", with: "更值得关注")
            }
            if current.contains("危险") {
                current = current.replacingOccurrences(of: "危险", with: "需要留意")
            }

            if current != before {
                steps.append(
                    RewriteStep(
                        before: before,
                        after: current,
                        reason: "Reduce emotional intensity."
                    )
                )
            }
        }

        let finalScore = scorer.score(current, against: carrier)
        return (current, finalScore, steps)
    }

    private func fallbackText(for carrier: SignalCarrier) -> String {
        pack.approvedFallbacks[carrier.trajectoryState]?.randomElement()
            ?? "目前还需要进一步观察。"
    }
}
