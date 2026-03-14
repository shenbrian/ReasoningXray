import Foundation
import Combine

final class PrivacyStore: ObservableObject {
    @Published var redactionOptions: RedactionOptions

    private let redactor = TranscriptRedactor()

    init(redactionOptions: RedactionOptions = .safeDefault) {
        self.redactionOptions = redactionOptions
    }

    func redact(_ text: String) -> String {
        redactor.redact(text, using: redactionOptions)
    }
}
