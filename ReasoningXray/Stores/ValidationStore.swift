import Foundation
import Combine

final class ValidationStore: ObservableObject {
    @Published private(set) var cases: [ValidationCase]
    @Published private(set) var results: [ValidationResult] = []

    private let evaluator = PilotReadinessEvaluator()

    init(cases: [ValidationCase] = MockValidationCases.starterCases) {
        self.cases = cases
    }

    func runAll() {
        results = cases.map { evaluator.evaluate($0) }
    }

    func run(case validationCase: ValidationCase) -> ValidationResult {
        let result = evaluator.evaluate(validationCase)

        if let index = results.firstIndex(where: { $0.caseTitle == result.caseTitle }) {
            results[index] = result
        } else {
            results.append(result)
        }

        return result
    }

    func result(for validationCase: ValidationCase) -> ValidationResult? {
        results.first(where: { $0.caseTitle == validationCase.title })
    }

    func resetResults() {
        results = []
    }
}
