import Foundation

struct TrajectoryPresentationPolicy {
    let showTechnicalSummary: Bool
    let showPatientMeaning: Bool
    let showImplication: Bool
    let showNextStep: Bool
    let showCertainty: Bool
}

struct TrajectoryPresentationCompactor {

    func policy(for presentation: CaseTrajectoryPresentation) -> TrajectoryPresentationPolicy {

        let technical = normalized(presentation.technical.summary)
        let meaning = normalized(presentation.patient.narrativeMeaning)
        let implication = normalized(presentation.patient.reassuranceFraming)
        let nextStep = normalized(presentation.patient.forwardExpectation)

        let showTechnicalSummary = !technical.isEmpty
        let showPatientMeaning = !meaning.isEmpty

        // NEW — implication suppression refinement
        let implicationAddsNewIdea = !(
            implication.contains("clear") ||
            implication.contains("clearer") ||
            implication.contains("stable") ||
            implication.contains("settling") ||
            implication.contains("becoming")
        )

        let showImplication =
            !implication.isEmpty &&
            implication != meaning &&
            implicationAddsNewIdea

        let showNextStep =
            !nextStep.isEmpty &&
            nextStep != meaning &&
            nextStep != implication

        let showCertainty = false

        return TrajectoryPresentationPolicy(
            showTechnicalSummary: showTechnicalSummary,
            showPatientMeaning: showPatientMeaning,
            showImplication: showImplication,
            showNextStep: showNextStep,
            showCertainty: showCertainty
        )
    }

    private func normalized(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(
                of: "[^a-z0-9 ]",
                with: "",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
