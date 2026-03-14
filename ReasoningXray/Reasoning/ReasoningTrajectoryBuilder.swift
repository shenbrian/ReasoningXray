import Foundation

struct ReasoningTrajectoryBuilder {

    static func buildTrajectory(from comparisons: [VisitReasoningComparison]) -> String {
        guard !comparisons.isEmpty else {
            return "No visits recorded yet."
        }

        var parts: [String] = []

        for comparison in comparisons {
            let label = comparison.movement.timelineLabel
            if parts.last != label {
                parts.append(label)
            }
        }

        return parts.joined(separator: " → ")
    }
}
