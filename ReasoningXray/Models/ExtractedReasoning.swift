import Foundation

struct ExtractedReasoning: Codable {
    let doctorName: String
    let clinic: String?

    let reasonForVisit: String
    let doctorExplanation: String
    let evidence: [String]
    let decision: String
    let nextSteps: String

    let whatMightBeHappening: String
    let howSeriousItAppears: String
    let whatTheDoctorIsDoing: String
    let whatHappensNext: String
    let questionsForNextVisit: [String]

    init(
        doctorName: String,
        clinic: String?,
        reasonForVisit: String,
        doctorExplanation: String,
        evidence: [String],
        decision: String,
        nextSteps: String,
        whatMightBeHappening: String,
        howSeriousItAppears: String,
        whatTheDoctorIsDoing: String,
        whatHappensNext: String,
        questionsForNextVisit: [String]
    ) {
        self.doctorName = doctorName
        self.clinic = clinic
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
    }
}
