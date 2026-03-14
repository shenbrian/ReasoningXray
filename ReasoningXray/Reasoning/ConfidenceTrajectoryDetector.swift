import Foundation

struct ConfidenceTrajectoryDetector {

    func detect(visits: [Visit]) -> ConfidenceTrajectory {

        let ordered = visits.sorted { $0.visitDate < $1.visitDate }

        guard ordered.count >= 2 else {
            return .uncertain
        }

        let recent = ordered.suffix(2)

        let combinedEvidence = recent
            .flatMap { $0.evidence }
            .joined(separator: " ")
            .lowercased()

        let combinedDecision = recent
            .map { $0.decision }
            .joined(separator: " ")
            .lowercased()

        if combinedEvidence.contains("improvement") ||
           combinedEvidence.contains("response") ||
           combinedDecision.contains("continue treatment") ||
           combinedDecision.contains("continue inhaler") {

            return .increasing
        }

        if combinedEvidence.contains("no improvement") ||
           combinedEvidence.contains("worse") ||
           combinedDecision.contains("reconsider") {

            return .decreasing
        }

        if combinedDecision.contains("monitor") ||
           combinedDecision.contains("observe") ||
           combinedDecision.contains("watch") {

            return .uncertain
        }

        return .stable
    }
}
