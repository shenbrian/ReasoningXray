import Foundation

struct ReasoningPatientNarrator {

    func responseExplanation(
        strength: ReasoningSignalStrength
    ) -> String {

        switch strength {

        case .explicit:
            return "The doctor said the improvement supports the explanation."

        case .inferred:
            return "The improvement may have helped clarify what is happening."

        case .weak:
            return "The doctor reviewed how symptoms changed."

        case .none:
            return "The doctor continued monitoring the situation."
        }
    }
}
