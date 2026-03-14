import Foundation

struct ValidationResult: Identifiable, Codable {
    let id: UUID
    let caseTitle: String

    let visitCount: Int

    let stageMatchesExpectation: Bool?
    let changeKindsMatchExpectation: Bool?
    let turningPointsMatchExpectation: Bool?

    let detectedStages: [String]
    let detectedChangeKinds: [[String]]
    let detectedTurningPoints: [String]

    let wordingNotes: [String]
    let timelineNotes: [String]
    let evaluatorSummary: String

    init(
        id: UUID = UUID(),
        caseTitle: String,
        visitCount: Int,
        stageMatchesExpectation: Bool? = nil,
        changeKindsMatchExpectation: Bool? = nil,
        turningPointsMatchExpectation: Bool? = nil,
        detectedStages: [String] = [],
        detectedChangeKinds: [[String]] = [],
        detectedTurningPoints: [String] = [],
        wordingNotes: [String] = [],
        timelineNotes: [String] = [],
        evaluatorSummary: String
    ) {
        self.id = id
        self.caseTitle = caseTitle
        self.visitCount = visitCount
        self.stageMatchesExpectation = stageMatchesExpectation
        self.changeKindsMatchExpectation = changeKindsMatchExpectation
        self.turningPointsMatchExpectation = turningPointsMatchExpectation
        self.detectedStages = detectedStages
        self.detectedChangeKinds = detectedChangeKinds
        self.detectedTurningPoints = detectedTurningPoints
        self.wordingNotes = wordingNotes
        self.timelineNotes = timelineNotes
        self.evaluatorSummary = evaluatorSummary
    }
}

