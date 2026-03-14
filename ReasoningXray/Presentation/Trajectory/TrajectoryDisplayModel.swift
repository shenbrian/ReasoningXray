import Foundation

struct TrajectoryDisplaySection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct TrajectoryDisplayModel {
    let technicalSummary: String?
    let sections: [TrajectoryDisplaySection]
}
