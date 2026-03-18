import Foundation

enum EpistemicDomain: String, Codable {
    case certainty
    case trajectory
    case expectation
    case authority
    case emotionalTone
}

enum TrajectoryState: String, Codable {
    case exploring
    case narrowing
    case workingExplanation
    case confirmation
}

enum CertaintyState: String, Codable {
    case activeUncertainty
    case emergingClarity
    case workingExplanation
    case stabilizingUnderstanding
}

enum ExpectationState: String, Codable {
    case clarityMayIncrease
    case moreInformationNeeded
    case followUpMatters
    case noImmediateResolutionExpected
}

enum GuardrailDecision: String, Codable {
    case pass
    case rewrite
    case fallback
    case blocked
}

struct ScoreEnvelope: Codable {
    let min: Double
    let max: Double

    func contains(_ value: Double) -> Bool {
        value >= min && value <= max
    }
}

enum SemanticRole: String, Codable {
    case evidence
    case decision
    case nextStep
    case explanation
    case summary
    case expectation
}

struct SignalCarrier: Identifiable, Codable {
    let id: String
    let sourceText: String
    let domains: [EpistemicDomain]
    let trajectoryState: TrajectoryState
    let certaintyState: CertaintyState
    let expectationState: ExpectationState?
    let semanticRole: SemanticRole

    let certaintyEnvelope: ScoreEnvelope
    let temporalEnvelope: ScoreEnvelope
    let authorityEnvelope: ScoreEnvelope
    let emotionalEnvelope: ScoreEnvelope

    var semanticSignature: String {
        "\(trajectoryState.rawValue)-\(certaintyState.rawValue)-\(expectationState?.rawValue ?? "nil")-\(semanticRole.rawValue)"
    }
}

struct EpistemicScore: Codable {
    let css: Double
    let tps: Double
    let ags: Double
    let ets: Double
    let violationFlags: [String]
    let compositeRiskIndex: Double
}

struct GuardrailValidationResult: Codable {
    let decision: GuardrailDecision
    let reasons: [String]
}

struct RewriteStep: Codable {
    let before: String
    let after: String
    let reason: String
}

struct RenderAudit: Identifiable, Codable {
    let id: UUID
    let segmentID: String
    let sourceText: String
    let initialCandidate: String
    let initialScore: EpistemicScore
    let rewriteSteps: [RewriteStep]
    let finalOutput: String
    let finalScore: EpistemicScore
    let validation: GuardrailValidationResult
    let languageCode: String
}
