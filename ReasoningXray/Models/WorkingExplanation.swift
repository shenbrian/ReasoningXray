import Foundation

struct WorkingExplanation: Codable, Equatable {
    let title: String
    let explanation: String
    let confidenceNote: String
    let traceSummary: String
}
