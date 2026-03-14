import Foundation

struct TrajectoryDisplayModelBuilder {
    private let compactor = TrajectoryPresentationCompactor()

    func build(from presentation: CaseTrajectoryPresentation) -> TrajectoryDisplayModel {
        let policy = compactor.policy(for: presentation)

        var sections: [TrajectoryDisplaySection] = []

        if policy.showPatientMeaning {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What This Means For You",
                    body: presentation.patient.narrativeMeaning
                )
            )
        }

        if policy.showImplication {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What This Suggests",
                    body: presentation.patient.reassuranceFraming
                )
            )
        }

        if policy.showNextStep {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What To Expect Next",
                    body: presentation.patient.forwardExpectation
                )
            )
        }

        return TrajectoryDisplayModel(
            technicalSummary: policy.showTechnicalSummary ? presentation.technical.summary : nil,
            sections: sections
        )
    }
}
