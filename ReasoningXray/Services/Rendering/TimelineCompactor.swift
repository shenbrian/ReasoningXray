import Foundation

struct TimelineCluster: Identifiable {
    let id = UUID()
    let title: String
    let visitIDs: [UUID]
    let startDate: Date
    let endDate: Date
    let stage: ReasoningStage
    let count: Int
    let containsTurningPoint: Bool
    let containsMajorChange: Bool
}

final class TimelineCompactor {

    func compact(_ comparisons: [VisitReasoningComparison]) -> [TimelineCluster] {
        guard !comparisons.isEmpty else { return [] }

        var clusters: [TimelineCluster] = []
        var bucket: [VisitReasoningComparison] = []

        func flushBucket() {
            guard let first = bucket.first, let last = bucket.last else { return }

            let containsTurningPoint = bucket.contains { $0.turningPoint != nil }
            let containsMajorChange = bucket.contains { comparison in
                comparison.changes.contains { change in
                    switch change.kind {
                    case .reconsideredExplanation, .orderedTesting, .startedTreatmentTrial, .newEvidenceInfluencedReasoning:
                        return true
                    case .continuedMonitoring:
                        return false
                    }
                }
            }

            let title: String = {
                if bucket.count == 1 {
                    return first.currentVisit.oneLineVisitSummary
                } else {
                    return "\(bucket.count) similar visits grouped together"
                }
            }()

            let cluster = TimelineCluster(
                title: title,
                visitIDs: bucket.map { $0.currentVisit.id },
                startDate: first.currentVisit.visitDate,
                endDate: last.currentVisit.visitDate,
                stage: first.stage,
                count: bucket.count,
                containsTurningPoint: containsTurningPoint,
                containsMajorChange: containsMajorChange
            )

            clusters.append(cluster)
            bucket.removeAll()
        }

        for comparison in comparisons {
            if bucket.isEmpty {
                bucket.append(comparison)
                continue
            }

            guard let last = bucket.last else {
                bucket.append(comparison)
                continue
            }

            let sameStage = last.stage == comparison.stage
            let currentHasTurningPoint = comparison.turningPoint != nil
            let currentHasMajorChange = comparison.changes.contains { change in
                switch change.kind {
                case .reconsideredExplanation, .orderedTesting, .startedTreatmentTrial, .newEvidenceInfluencedReasoning:
                    return true
                case .continuedMonitoring:
                    return false
                }
            }

            if sameStage && !currentHasTurningPoint && !currentHasMajorChange {
                bucket.append(comparison)
            } else {
                flushBucket()
                bucket.append(comparison)
            }
        }

        flushBucket()
        return clusters
    }
}
