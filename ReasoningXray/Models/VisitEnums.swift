import Foundation

enum VisitType: String, Codable, CaseIterable {
    case gp
    case specialist
    case telehealth
    case followUp
    case urgent
}

enum ThreadStatus: String, Codable, CaseIterable {
    case open
    case monitoring
    case resolved
    case unclear
}

