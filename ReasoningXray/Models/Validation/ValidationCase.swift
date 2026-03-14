import Foundation

struct ValidationCase: Identifiable, Codable {
    let id: UUID
    let title: String
    let threadTitle: String
    let visits: [Visit]

    // Expected outputs for pilot-readiness checking
    let expectedStages: [ReasoningStage]?
    let expectedChangeKinds: [[ReasoningChangeKind]]?
    let expectedTurningPoints: [ReasoningTurningPointKind]?

    // Human review notes
    let notes: String?

    init(
        id: UUID = UUID(),
        title: String,
        threadTitle: String,
        visits: [Visit],
        expectedStages: [ReasoningStage]? = nil,
        expectedChangeKinds: [[ReasoningChangeKind]]? = nil,
        expectedTurningPoints: [ReasoningTurningPointKind]? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.threadTitle = threadTitle
        self.visits = visits
        self.expectedStages = expectedStages
        self.expectedChangeKinds = expectedChangeKinds
        self.expectedTurningPoints = expectedTurningPoints
        self.notes = notes
    }
}
