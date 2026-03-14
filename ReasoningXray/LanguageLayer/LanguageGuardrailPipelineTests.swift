import XCTest
@testable import ReasoningXray

final class LanguageGuardrailPipelineTests: XCTestCase {

    func testNarrowingSentencePassesAfterRewrite() {
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

        XCTAssertEqual(audit.validation.decision, .pass)
        XCTAssertTrue(carrier.certaintyEnvelope.contains(audit.finalScore.css))
        XCTAssertTrue(carrier.temporalEnvelope.contains(audit.finalScore.tps))
        XCTAssertTrue(carrier.authorityEnvelope.contains(audit.finalScore.ags))
        XCTAssertTrue(carrier.emotionalEnvelope.contains(audit.finalScore.ets))
        XCTAssertFalse(audit.finalOutput.isEmpty)
    }

    func testForbiddenPatternTriggersFallback() {
        let carrier = SignalCarrier(
            id: "seg_forbidden_001",
            sourceText: "The reasoning appears to be narrowing toward a more focused explanation.",
            domains: [.trajectory, .certainty],
            trajectoryState: .narrowing,
            certaintyEnvelope: ScoreEnvelope(min: 0.35, max: 0.55),
            temporalEnvelope: ScoreEnvelope(min: 0.10, max: 0.40),
            authorityEnvelope: ScoreEnvelope(min: 0.15, max: 0.45),
            emotionalEnvelope: ScoreEnvelope(min: 0.10, max: 0.30)
        )

        let pack = MandarinLanguagePack()
        let scorer = EpistemicScoringEngine(pack: pack)
        let score = scorer.score("医生可以确定这是原因。", against: carrier)

        XCTAssertTrue(score.violationFlags.contains(where: { $0.hasPrefix("FORBIDDEN_PATTERN:") }))
    }
}
