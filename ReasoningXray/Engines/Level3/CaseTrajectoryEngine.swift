// ==========================================================
// LEVEL 3 TRAJECTORY ENGINE — FROZEN (v1)
// Status:
// - Core execution complete
// - Validation passed on baseline threads
// - Monitoring-loop stress test passed
//
// Locked dimensions:
// - overallPath
// - certaintyTrend
// - momentum
// - activeUncertainty
//
// Change policy:
// Only modify if:
// 1) validator reveals structural contradiction
// 2) stress-test scenario fails
// 3) Level 2 signal model changes
// ==========================================================

import Foundation

struct CaseTrajectoryEngine {

    func summarizeThread(
        thread: CaseThread,
        comparisons: [VisitReasoningComparison]
    ) -> CaseTrajectorySummary {
        let orderedComparisons: [VisitReasoningComparison] = comparisons

        let stages: [ReasoningStage] = orderedComparisons.map { comparison in
            comparison.stage
        }

        let turningPoints: [ReasoningTurningPoint] = orderedComparisons.compactMap { comparison in
            comparison.turningPoint
        }

        let overallPath = classifyOverallPath(
            stages: stages,
            comparisons: orderedComparisons
        )

        let certaintyTrend = classifyCertaintyTrend(
            stages: stages,
            comparisons: orderedComparisons,
            turningPoints: turningPoints
        )

        let momentum = classifyMomentum(
            stages: stages,
            comparisons: orderedComparisons
        )

        let activeUncertainty = detectActiveUncertainty(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            stages: stages
        )

        let summary = buildSummary(
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty
        )

        return CaseTrajectorySummary(
            threadID: thread.id,
            overallPath: overallPath,
            certaintyTrend: certaintyTrend,
            momentum: momentum,
            activeUncertainty: activeUncertainty,
            keyTransitionPoints: turningPoints,
            summary: summary
        )
    }
}

// MARK: - Private Rules

private extension CaseTrajectoryEngine {

    func classifyOverallPath(
        stages: [ReasoningStage],
        comparisons: [VisitReasoningComparison]
    ) -> ReasoningOverallPath {
        guard !stages.isEmpty else { return .mixed }

        let monitoringCount = comparisons.filter {
            $0.movement == .monitoring
        }.count

        let latestComparison = comparisons.last
        let latestHasReconsideration = latestComparison?.changes.contains(where: {
            $0.kind == .reconsideredExplanation
        }) ?? false

        if monitoringCount >= 2 && !latestHasReconsideration {
            return .monitoring
        }

        let hasConfirmationStage = stages.contains(.confirmation)
        let hasNarrowingStage = stages.contains(.narrowing)
        let allExploration = stages.allSatisfy { $0 == .exploration }

        let hasContinuedMonitoring = comparisons.contains {
            $0.changes.contains(where: { $0.kind == .continuedMonitoring })
        }

        let hasReconsideration = comparisons.contains {
            $0.changes.contains(where: { $0.kind == .reconsideredExplanation })
        }

        let latestStage = stages.last ?? .exploration

        if latestHasReconsideration && latestStage != .confirmation {
            return .reopened
        }

        if hasContinuedMonitoring && !hasReconsideration && !hasConfirmationStage {
            return .monitoring
        }

        if hasConfirmationStage {
            return .confirmation
        }

        if hasNarrowingStage {
            return .narrowing
        }

        if allExploration {
            return .earlyExploration
        }

        return .mixed
    }
    
    func classifyCertaintyTrend(
        stages: [ReasoningStage],
        comparisons: [VisitReasoningComparison],
        turningPoints: [ReasoningTurningPoint]
    ) -> CertaintyTrend {
        guard !stages.isEmpty else { return .unclear }

        let averageStageScore =
            Double(stages.map(score(for:)).reduce(0, +)) / Double(stages.count)

        let latestComparison = comparisons.last
        let latestHasReconsideration = latestComparison?.changes.contains(where: {
            $0.kind == .reconsideredExplanation
        }) ?? false

        let latestStage = stages.last ?? .exploration
        let hasAnyTurningPoint = !turningPoints.isEmpty

        if latestStage == .confirmation {
            return .increasing
        }

        if latestHasReconsideration && averageStageScore < 2.5 && !hasAnyTurningPoint {
            return .decreasing
        }

        if averageStageScore >= 2.0 {
            return .stable
        }

        return .unclear
    }

    func classifyMomentum(
        stages: [ReasoningStage],
        comparisons: [VisitReasoningComparison]
    ) -> ReasoningMomentum {
        guard !comparisons.isEmpty else { return .paused }

        let monitoringCount = comparisons.filter {
            $0.movement == .monitoring
        }.count

        let latestComparison = comparisons.last
        let latestHasContinuedMonitoring = latestComparison?.changes.contains(where: {
            $0.kind == .continuedMonitoring
        }) ?? false

        let latestHasReconsideration = latestComparison?.changes.contains(where: {
            $0.kind == .reconsideredExplanation
        }) ?? false

        let uniqueStageNames = Set(stages.map { $0.rawValue })

        if monitoringCount >= 2 && latestHasContinuedMonitoring {
            return .looping
        }

        if let first = stages.first, let last = stages.last, score(for: last) > score(for: first) {
            return .advancing
        }

        if latestHasReconsideration {
            return .redirected
        }

        if latestHasContinuedMonitoring && uniqueStageNames.count == 1 {
            return .looping
        }

        return .paused
    }

    func detectActiveUncertainty(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        stages: [ReasoningStage]
    ) -> Bool {
        guard let latestStage = stages.last else { return true }

        if latestStage == .confirmation && certaintyTrend == .increasing {
            return false
        }

        if overallPath == .earlyExploration || overallPath == .reopened {
            return true
        }

        if certaintyTrend == .decreasing || certaintyTrend == .unclear {
            return true
        }

        return latestStage == .exploration || latestStage == .narrowing
    }

    func buildSummary(
        overallPath: ReasoningOverallPath,
        certaintyTrend: CertaintyTrend,
        momentum: ReasoningMomentum,
        activeUncertainty: Bool
    ) -> String {
        let pathText: String
        switch overallPath {
        case .earlyExploration:
            pathText = "The case remains in an exploratory reasoning phase."
        case .narrowing:
            pathText = "The reasoning appears to be narrowing toward a more focused explanation."
        case .workingDiagnosis:
            pathText = "The reasoning appears to be organized around a working diagnosis."
        case .confirmation:
            pathText = "The reasoning appears to be moving toward confirmation."
        case .monitoring:
            pathText = "The case appears to be in a monitoring pattern rather than active reframing."
        case .reopened:
            pathText = "The reasoning appears to have reopened after an earlier narrowing or explanation."
        case .mixed:
            pathText = "The reasoning pattern is mixed and does not follow a single clear path."
        }

        let certaintyText: String
        switch certaintyTrend {
        case .increasing:
            certaintyText = "Overall certainty appears to be increasing."
        case .stable:
            certaintyText = "Overall certainty appears relatively stable."
        case .decreasing:
            certaintyText = "Overall certainty appears to be decreasing."
        case .unclear:
            certaintyText = "The certainty trend remains unclear."
        }

        let momentumText: String
        switch momentum {
        case .advancing:
            momentumText = "The case shows forward reasoning movement."
        case .paused:
            momentumText = "The reasoning movement appears limited."
        case .looping:
            momentumText = "The case shows repeated monitoring without strong directional change."
        case .redirected:
            momentumText = "The reasoning path appears to have been redirected."
        }

        let uncertaintyText = activeUncertainty
            ? "Uncertainty is still active in the case."
            : "Uncertainty appears to be reducing."

        return [
            pathText,
            certaintyText,
            momentumText,
            uncertaintyText
        ].joined(separator: " ")
    }

    func score(for stage: ReasoningStage) -> Int {
        switch stage {
        case .exploration:
            return 1
        case .narrowing:
            return 2
        case .confirmation:
            return 3
        default:
            return 2
        }
    }
}
