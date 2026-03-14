import Foundation

struct Visit: Identifiable, Codable {
    let id: UUID
    let caseThreadId: UUID

    let visitDate: Date
    let doctorName: String
    let clinicName: String
    let visitType: VisitType

    // Layer 1 — Doctor Reasoning Mirror
    let reasonForVisit: String
    let doctorExplanation: String
    let evidence: [String]
    let decision: String
    let nextSteps: [String]

    // Layer 2 — Patient Comprehension Translation
    let whatMightBeHappening: String
    let howSeriousItAppears: String
    let whatTheDoctorIsDoing: String
    let whatHappensNext: String
    let questionsForNextVisit: [String]

    // Longitudinal / timeline fields
    let oneLineVisitSummary: String
    let mainChangeSinceLastVisit: String
    let biggestOpenQuestion: String
    let whatToWatchBeforeNextVisit: String

    // Structured reasoning signals
    let symptomsMentioned: [String]
    let testsOrdered: [String]
    let diagnosesConsidered: [String]

    // Bilingual / transcript-readiness fields
    let transcriptSegments: [TranscriptSegment]?
    let sourceLanguageHint: SupportedLanguage?

    init(
        id: UUID = UUID(),
        caseThreadId: UUID,
        visitDate: Date,
        doctorName: String,
        clinicName: String,
        visitType: VisitType,
        reasonForVisit: String,
        doctorExplanation: String,
        evidence: [String],
        decision: String,
        nextSteps: [String],
        whatMightBeHappening: String,
        howSeriousItAppears: String,
        whatTheDoctorIsDoing: String,
        whatHappensNext: String,
        questionsForNextVisit: [String],
        oneLineVisitSummary: String,
        mainChangeSinceLastVisit: String,
        biggestOpenQuestion: String,
        whatToWatchBeforeNextVisit: String,
        symptomsMentioned: [String],
        testsOrdered: [String],
        diagnosesConsidered: [String],
        transcriptSegments: [TranscriptSegment]? = nil,
        sourceLanguageHint: SupportedLanguage? = nil
    ) {
        self.id = id
        self.caseThreadId = caseThreadId
        self.visitDate = visitDate
        self.doctorName = doctorName
        self.clinicName = clinicName
        self.visitType = visitType

        self.reasonForVisit = reasonForVisit
        self.doctorExplanation = doctorExplanation
        self.evidence = evidence
        self.decision = decision
        self.nextSteps = nextSteps

        self.whatMightBeHappening = whatMightBeHappening
        self.howSeriousItAppears = howSeriousItAppears
        self.whatTheDoctorIsDoing = whatTheDoctorIsDoing
        self.whatHappensNext = whatHappensNext
        self.questionsForNextVisit = questionsForNextVisit

        self.oneLineVisitSummary = oneLineVisitSummary
        self.mainChangeSinceLastVisit = mainChangeSinceLastVisit
        self.biggestOpenQuestion = biggestOpenQuestion
        self.whatToWatchBeforeNextVisit = whatToWatchBeforeNextVisit

        self.symptomsMentioned = symptomsMentioned
        self.testsOrdered = testsOrdered
        self.diagnosesConsidered = diagnosesConsidered

        self.transcriptSegments = transcriptSegments
        self.sourceLanguageHint = sourceLanguageHint
    }
}
