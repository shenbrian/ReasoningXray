import Foundation

struct TrajectoryLanguageMemory: Codable {
    let threadID: UUID
    let lastTrajectoryState: TrajectoryState?
    let narrowingCount: Int
    let workingExplanationCount: Int
    let confirmationCount: Int

    init(
        threadID: UUID,
        lastTrajectoryState: TrajectoryState? = nil,
        narrowingCount: Int = 0,
        workingExplanationCount: Int = 0,
        confirmationCount: Int = 0
    ) {
        self.threadID = threadID
        self.lastTrajectoryState = lastTrajectoryState
        self.narrowingCount = narrowingCount
        self.workingExplanationCount = workingExplanationCount
        self.confirmationCount = confirmationCount
    }

    func advanced(with state: TrajectoryState) -> TrajectoryLanguageMemory {
        switch state {
        case .exploring:
            return TrajectoryLanguageMemory(
                threadID: threadID,
                lastTrajectoryState: state,
                narrowingCount: narrowingCount,
                workingExplanationCount: workingExplanationCount,
                confirmationCount: confirmationCount
            )

        case .narrowing:
            return TrajectoryLanguageMemory(
                threadID: threadID,
                lastTrajectoryState: state,
                narrowingCount: narrowingCount + 1,
                workingExplanationCount: workingExplanationCount,
                confirmationCount: confirmationCount
            )

        case .workingExplanation:
            return TrajectoryLanguageMemory(
                threadID: threadID,
                lastTrajectoryState: state,
                narrowingCount: narrowingCount,
                workingExplanationCount: workingExplanationCount + 1,
                confirmationCount: confirmationCount
            )

        case .confirmation:
            return TrajectoryLanguageMemory(
                threadID: threadID,
                lastTrajectoryState: state,
                narrowingCount: narrowingCount,
                workingExplanationCount: workingExplanationCount,
                confirmationCount: confirmationCount + 1
            )
        }
    }
}
