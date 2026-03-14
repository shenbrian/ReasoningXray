import Foundation

struct CaseThread: Identifiable, Codable {
    let id: UUID
    let title: String
    let primaryConcern: String
    let status: CaseThreadStatus
    let currentUnderstanding: String
    let stillUncertain: String
    let nextLikelyStep: String
    let visitIds: [UUID]
}
