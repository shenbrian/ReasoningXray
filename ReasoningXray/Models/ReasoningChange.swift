import Foundation

struct ReasoningChange: Identifiable, Codable, Equatable {

    let id: UUID
    let kind: ReasoningChangeKind

    /// Short traceable reason explaining why this change was detected.
    /// Must always refer to actual visit fields.
    let traceSummary: String

    init(
        id: UUID = UUID(),
        kind: ReasoningChangeKind,
        traceSummary: String
    ) {
        self.id = id
        self.kind = kind
        self.traceSummary = traceSummary
    }
}
