import Foundation

struct EpistemicScoringEngine {
    let pack: MandarinLanguagePack

    func score(_ text: String, against carrier: SignalCarrier) -> EpistemicScore {
        var css = 0.50
        var tps = 0.25
        var ags = 0.25
        var ets = 0.15

        for (token, delta) in pack.certaintyAdjustments where text.contains(token) {
            css += delta
        }

        for (token, delta) in pack.temporalAdjustments where text.contains(token) {
            tps += delta
        }

        for (token, delta) in pack.authorityAdjustments where text.contains(token) {
            ags += delta
        }

        for (token, delta) in pack.emotionalAdjustments where text.contains(token) {
            ets += delta
        }

        css = clamp(css)
        tps = clamp(tps)
        ags = clamp(ags)
        ets = clamp(ets)

        var flags: [String] = []

        if !carrier.certaintyEnvelope.contains(css) {
            flags.append("CSS_OUT_OF_RANGE")
        }
        if !carrier.temporalEnvelope.contains(tps) {
            flags.append("TPS_OUT_OF_RANGE")
        }
        if !carrier.authorityEnvelope.contains(ags) {
            flags.append("AGS_OUT_OF_RANGE")
        }
        if !carrier.emotionalEnvelope.contains(ets) {
            flags.append("ETS_OUT_OF_RANGE")
        }

        for pattern in pack.forbiddenPatterns where text.contains(pattern) {
            flags.append("FORBIDDEN_PATTERN:\(pattern)")
        }

        let pri =
            riskDelta(css, carrier.certaintyEnvelope) * 0.35 +
            riskDelta(tps, carrier.temporalEnvelope) * 0.30 +
            riskDelta(ags, carrier.authorityEnvelope) * 0.20 +
            riskDelta(ets, carrier.emotionalEnvelope) * 0.15

        return EpistemicScore(
            css: css,
            tps: tps,
            ags: ags,
            ets: ets,
            violationFlags: flags,
            compositeRiskIndex: pri
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

    private func riskDelta(_ value: Double, _ envelope: ScoreEnvelope) -> Double {
        if value < envelope.min { return envelope.min - value }
        if value > envelope.max { return value - envelope.max }
        return 0.0
    }
}
