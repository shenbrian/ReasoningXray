import Foundation

struct CaseTrajectoryPresentation {
    let technical: CaseTrajectorySummary
    let patient: PatientTrajectoryTranslation
    let epistemicStatus: EpistemicStatus

    init(
        technical: CaseTrajectorySummary,
        patient: PatientTrajectoryTranslation,
        epistemicStatus: EpistemicStatus
    ) {
        self.technical = technical
        self.patient = patient
        self.epistemicStatus = epistemicStatus
    }
}
