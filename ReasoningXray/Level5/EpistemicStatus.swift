import Foundation

enum EpistemicStatus: String, CaseIterable, Identifiable {
    case observed
    case inferred
    case provisional
    case evolving
    case stable

    var id: String { rawValue }

    var title: String {
        switch self {
        case .observed:
            return "Observed"
        case .inferred:
            return "Inferred"
        case .provisional:
            return "Provisional"
        case .evolving:
            return "Evolving"
        case .stable:
            return "Stable"
        }
    }

    var shortLabel: String {
        switch self {
        case .observed:
            return "Observed"
        case .inferred:
            return "Inferred"
        case .provisional:
            return "Provisional"
        case .evolving:
            return "Evolving"
        case .stable:
            return "Stable"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .observed:
            return "Directly observed from the visit record"
        case .inferred:
            return "Inferred from the reasoning pattern"
        case .provisional:
            return "Still provisional and not yet settled"
        case .evolving:
            return "Reasoning is still evolving over time"
        case .stable:
            return "Reasoning appears relatively stable"
        }
    }

    var rank: Int {
        switch self {
        case .observed:
            return 0
        case .inferred:
            return 1
        case .provisional:
            return 2
        case .evolving:
            return 3
        case .stable:
            return 4
        }
    }
}
