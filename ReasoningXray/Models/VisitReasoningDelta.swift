import Foundation

enum ReasoningChangeType: String, Codable, CaseIterable {
    case initial
    case hypothesisShift
    case confidenceUp
    case confidenceDown
    case evidenceAdded
    case decisionChanged
    case nextStepChanged
    case mixed
    case noMajorChange
}

struct VisitReasoningDelta: Identifiable, Hashable {
    let id = UUID()
    let currentVisitId: UUID
    let previousVisitId: UUID?
    let changeType: ReasoningChangeType
    let title: String
    let summary: String
}
