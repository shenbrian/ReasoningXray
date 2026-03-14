// LEVEL 3 TRAJECTORY SEMANTIC CONTRACT — FROZEN (v1)

import Foundation

enum ReasoningOverallPath: String {
    case earlyExploration
    case narrowing
    case workingDiagnosis
    case confirmation
    case monitoring
    case reopened
    case mixed
}

enum CertaintyTrend: String {
    case increasing
    case stable
    case decreasing
    case unclear
}

enum ReasoningMomentum: String {
    case advancing
    case paused
    case looping
    case redirected
}

struct CaseTrajectorySummary: Identifiable {
    let id: UUID
    let threadID: UUID
    let overallPath: ReasoningOverallPath
    let certaintyTrend: CertaintyTrend
    let momentum: ReasoningMomentum
    let activeUncertainty: Bool
    let keyTransitionPoints: [ReasoningTurningPoint]
    let summary: String

    init(
        id: UUID = UUID(),
        threadID: UUID,
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool,
        keyTransitionPoints: [ReasoningTurningPoint],
        summary: String
    ) {
        self.id = id
        self.threadID = threadID
        self.overallPath = overallPath
        self.certaintyTrend = certaintyTrend
        self.momentum = momentum
        self.activeUncertainty = activeUncertainty
        self.keyTransitionPoints = keyTransitionPoints
        self.summary = summary
    }
}
