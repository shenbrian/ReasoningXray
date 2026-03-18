import Foundation

struct TrajectoryDisplayModelBuilder {
    private let compactor = TrajectoryPresentationCompactor()

    func build(
        from presentation: CaseTrajectoryPresentation,
        displayLanguage: DisplayLanguage
    ) -> TrajectoryDisplayModel {
        let policy = compactor.policy(
            for: presentation,
            displayLanguage: displayLanguage
        )

        var sections: [TrajectoryDisplaySection] = []

        if policy.showPatientMeaning {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What This Means For You",
                    body: presentation.patient.narrativeMeaning.resolve(for: displayLanguage)
                )
            )
        }

        if policy.showImplication {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What This Suggests",
                    body: presentation.patient.reassuranceFraming.resolve(for: displayLanguage)
                )
            )
        }

        if policy.showNextStep {
            sections.append(
                TrajectoryDisplaySection(
                    title: "What To Expect Next",
                    body: presentation.patient.forwardExpectation.resolve(for: displayLanguage)
                )
            )
        }

        return TrajectoryDisplayModel(
            technicalSummary: policy.showTechnicalSummary ? presentation.technical.summary : nil,
            sections: sections
        )
    }
}
