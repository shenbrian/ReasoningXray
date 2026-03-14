import Foundation

enum LanguageLayerDemo {
    static func runNarrowingDemo() {
        let carrier = SignalCarrier(
            id: "seg_narrowing_001",
            sourceText: "The reasoning appears to be narrowing toward a more focused explanation.",
            domains: [.trajectory, .certainty],
            trajectoryState: .narrowing,
            certaintyEnvelope: ScoreEnvelope(min: 0.35, max: 0.55),
            temporalEnvelope: ScoreEnvelope(min: 0.10, max: 0.40),
            authorityEnvelope: ScoreEnvelope(min: 0.15, max: 0.45),
            emotionalEnvelope: ScoreEnvelope(min: 0.10, max: 0.30)
        )

        let pipeline = LanguageGuardrailPipeline()
        let audit = pipeline.renderMandarin(for: carrier)

        print("----- Language Layer Demo -----")
        print("Segment ID: \(audit.segmentID)")
        print("Source: \(audit.sourceText)")
        print("Initial Candidate: \(audit.initialCandidate)")
        print("Initial Score:")
        print("  CSS: \(format(audit.initialScore.css))")
        print("  TPS: \(format(audit.initialScore.tps))")
        print("  AGS: \(format(audit.initialScore.ags))")
        print("  ETS: \(format(audit.initialScore.ets))")
        print("  Flags: \(audit.initialScore.violationFlags)")

        if !audit.rewriteSteps.isEmpty {
            print("Rewrite Steps:")
            for step in audit.rewriteSteps {
                print("  - Reason: \(step.reason)")
                print("    Before: \(step.before)")
                print("    After:  \(step.after)")
            }
        }

        print("Final Output: \(audit.finalOutput)")
        print("Final Score:")
        print("  CSS: \(format(audit.finalScore.css))")
        print("  TPS: \(format(audit.finalScore.tps))")
        print("  AGS: \(format(audit.finalScore.ags))")
        print("  ETS: \(format(audit.finalScore.ets))")
        print("Validation Decision: \(audit.validation.decision.rawValue)")
        print("Validation Reasons: \(audit.validation.reasons)")
        print("-------------------------------")
    }

    private static func format(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
