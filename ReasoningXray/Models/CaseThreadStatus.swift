import Foundation

enum CaseThreadStatus: String, Codable, CaseIterable {
    case open
    case monitoring
    case closed
}
