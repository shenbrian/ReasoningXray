import Foundation

final class PilotReadinessEvaluator {

    private let changeDetector = ReasoningChangeDetector()
    private let movementMapper = ReasoningMovementMapper()
    private let stageDetector = ReasoningStageDetector()
    private let turningPointDetector = ReasoningTurningPointDetector()

    func evaluate(_ validationCase: ValidationCase) -> ValidationResult {
        let visits = validationCase.visits.sorted { $0.visitDate < $1.visitDate }

        var detectedStages: [String] = []
        var detectedChangeKinds: [[String]] = []
        var detectedTurningPoints: [String] = []

        var previousVisit: Visit?
        var previousMovement: ReasoningMovement?

        for visit in visits {
            let changes = changeDetector.detectChanges(from: previousVisit, to: visit)
            detectedChangeKinds.append(changes.map { String(describing: $0.kind) })

            let currentMovement = movementMapper.movement(
                previousVisit: previousVisit,
                currentVisit: visit,
                changes: changes
            )

            let stage = stageDetector.stage(for: currentMovement)
            detectedStages.append(String(describing: stage))

            let turningPoint = turningPointDetector.detectTurningPoint(
                previousVisit: previousVisit,
                currentVisit: visit,
                previousMovement: previousMovement,
                currentMovement: currentMovement,
                changes: changes
            )

            if let turningPoint {
                detectedTurningPoints.append(String(describing: turningPoint.kind))
            }

            previousVisit = visit
            previousMovement = currentMovement
        }

        let expectedStageStrings = validationCase.expectedStages?.map { String(describing: $0) }
        let expectedChangeStrings = validationCase.expectedChangeKinds?.map { kinds in
            kinds.map { String(describing: $0) }
        }
        let expectedTurningPointStrings = validationCase.expectedTurningPoints?.map {
            String(describing: $0)
        }

        let stageMatchesExpectation: Bool? = {
            guard let expectedStageStrings else { return nil }
            return expectedStageStrings == detectedStages
        }()

        let changeKindsMatchExpectation: Bool? = {
            guard let expectedChangeStrings else { return nil }
            return expectedChangeStrings == detectedChangeKinds
        }()

        let turningPointsMatchExpectation: Bool? = {
            guard let expectedTurningPointStrings else { return nil }
            return expectedTurningPointStrings == detectedTurningPoints
        }()

        let wordingNotes = evaluateWording(of: visits)
        let timelineNotes = evaluateTimeline(of: visits, detectedStages: detectedStages)

        let summary = buildSummary(
            caseTitle: validationCase.title,
            visitCount: visits.count,
            stageMatchesExpectation: stageMatchesExpectation,
            changeKindsMatchExpectation: changeKindsMatchExpectation,
            turningPointsMatchExpectation: turningPointsMatchExpectation
        )

        return ValidationResult(
            caseTitle: validationCase.title,
            visitCount: visits.count,
            stageMatchesExpectation: stageMatchesExpectation,
            changeKindsMatchExpectation: changeKindsMatchExpectation,
            turningPointsMatchExpectation: turningPointsMatchExpectation,
            detectedStages: detectedStages,
            detectedChangeKinds: detectedChangeKinds,
            detectedTurningPoints: detectedTurningPoints,
            wordingNotes: wordingNotes,
            timelineNotes: timelineNotes,
            evaluatorSummary: summary
        )
    }

    private func evaluateWording(of visits: [Visit]) -> [String] {
        var notes: [String] = []

        for visit in visits {
            if visit.whatMightBeHappening.count > 160 {
                notes.append("Patient wording may be too long in visit dated \(formatted(visit.visitDate)).")
            }

            if visit.whatTheDoctorIsDoing.lowercased().contains("appears") &&
                visit.howSeriousItAppears.lowercased().contains("appears") {
                notes.append("Repeated 'appears' wording may sound unnatural in visit dated \(formatted(visit.visitDate)).")
            }

            if visit.questionsForNextVisit.count > 4 {
                notes.append("Too many next-visit questions may reduce clarity in visit dated \(formatted(visit.visitDate)).")
            }
        }

        return notes
    }

    private func evaluateTimeline(of visits: [Visit], detectedStages: [String]) -> [String] {
        var notes: [String] = []

        if visits.count >= 8 {
            notes.append("Timeline may become dense for this case and may need grouping or compaction.")
        }

        let uniqueStages = Set(detectedStages)
        if visits.count >= 5 && uniqueStages.count == 1 {
            notes.append("Many visits remain in the same reasoning stage; consider summarizing repetitive visits.")
        }

        if visits.count >= 3 && detectedStages.isEmpty {
            notes.append("Timeline did not produce detectable stages despite multiple visits.")
        }

        return notes
    }

    private func buildSummary(
        caseTitle: String,
        visitCount: Int,
        stageMatchesExpectation: Bool?,
        changeKindsMatchExpectation: Bool?,
        turningPointsMatchExpectation: Bool?
    ) -> String {
        let stageText = summaryLabel(stageMatchesExpectation)
        let changeText = summaryLabel(changeKindsMatchExpectation)
        let turningPointText = summaryLabel(turningPointsMatchExpectation)

        return "\(caseTitle): \(visitCount) visits reviewed. Stage match: \(stageText). Change match: \(changeText). Turning point match: \(turningPointText)."
    }

    private func summaryLabel(_ value: Bool?) -> String {
        switch value {
        case true:
            return "pass"
        case false:
            return "fail"
        case nil:
            return "not provided"
        }
    }

    private func formatted(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
