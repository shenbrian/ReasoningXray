import Foundation

struct Level3TrajectoryValidator {

    static func run(store: ReasoningHistoryStore) {
        print("")
        print("====== LEVEL 3 TRAJECTORY VALIDATION ======")

        var warningCount = 0

        for presentation in store.caseTrajectoryPresentations {
            let summary = presentation.technical
            let patient = presentation.patient

            print("Thread:", summary.threadID)
            print(
                "Path:", summary.overallPath.rawValue,
                "| Certainty:", summary.certaintyTrend.rawValue,
                "| Momentum:", summary.momentum.rawValue,
                "| Active Uncertainty:", summary.activeUncertainty
            )

            print("Technical Summary:", summary.summary)
            print("Patient Narrative:", patient.narrativeMeaning)
            print("Patient Reassurance:", patient.reassuranceFraming)
            print("Patient Expectation:", patient.forwardExpectation)
            print("Patient Safety:", patient.decisionSafetyFraming)

            warningCount += validateStructuralSanity(summary)
            warningCount += validatePatientTranslationSanity(summary, patient: patient)

            print("--------------------------------------")
        }

        if warningCount == 0 {
            print("✅ Level 3 validation passed with no warnings.")
        } else {
            print("⚠️ Level 3 validation finished with \(warningCount) warning(s).")
        }

        print("====== END VALIDATION ======")
        print("")
    }

    @discardableResult
    private static func validateStructuralSanity(
        _ summary: CaseTrajectorySummary
    ) -> Int {
        var warnings = 0

        if summary.overallPath == .reopened &&
            summary.certaintyTrend == .increasing {
            print("⚠️ Inconsistent: reopened path with increasing certainty")
            warnings += 1
        }

        if summary.overallPath == .confirmation &&
            summary.activeUncertainty {
            print("⚠️ Possible mismatch: confirmation while uncertainty still active")
            warnings += 1
        }

        if summary.momentum == .looping &&
            summary.overallPath == .confirmation {
            print("⚠️ Momentum/path conflict: looping while confirmed")
            warnings += 1
        }

        return warnings
    }

    @discardableResult
    private static func validatePatientTranslationSanity(
        _ summary: CaseTrajectorySummary,
        patient: PatientTrajectoryTranslation
    ) -> Int {
        var warnings = 0

        let narrative = patient.narrativeMeaning.lowercased()
        let expectation = patient.forwardExpectation.lowercased()
        let safety = patient.decisionSafetyFraming.lowercased()

        if summary.overallPath == .confirmation &&
            !narrative.contains("clearer explanation") &&
            !narrative.contains("settling") {
            print("⚠️ Translation mismatch: confirmation path should sound more settled")
            warnings += 1
        }

        if summary.overallPath == .reopened &&
            !narrative.contains("reconsider") &&
            !narrative.contains("reopening") {
            print("⚠️ Translation mismatch: reopened path should indicate reconsideration")
            warnings += 1
        }

        if summary.overallPath == .monitoring &&
            !expectation.contains("follow-up") &&
            !expectation.contains("observation") {
            print("⚠️ Translation mismatch: monitoring path should suggest follow-up or observation")
            warnings += 1
        }

        if summary.activeUncertainty &&
            !safety.contains("provisional") &&
            !safety.contains("not yet appear fully settled") &&
            !safety.contains("still developing") {
            print("⚠️ Translation mismatch: active uncertainty should sound non-final")
            warnings += 1
        }

        return warnings
    }
}
