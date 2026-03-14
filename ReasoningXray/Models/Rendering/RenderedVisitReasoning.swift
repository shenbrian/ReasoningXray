import Foundation

struct RenderedVisitReasoning: Codable, Hashable {

    // Layer 1 — Doctor Reasoning Mirror
    let reasonForVisit: LocalizedText
    let doctorExplanation: LocalizedText
    let evidence: [LocalizedText]
    let decision: LocalizedText
    let nextSteps: [LocalizedText]

    // Layer 2 — Patient Comprehension Translation
    let whatMightBeHappening: LocalizedText
    let howSeriousItAppears: LocalizedText
    let whatTheDoctorIsDoing: LocalizedText
    let whatHappensNext: LocalizedText
    let questionsForNextVisit: [LocalizedText]

    // Timeline / visit summary layer
    let oneLineVisitSummary: LocalizedText
    let mainChangeSinceLastVisit: LocalizedText
    let biggestOpenQuestion: LocalizedText
    let whatToWatchBeforeNextVisit: LocalizedText
}
