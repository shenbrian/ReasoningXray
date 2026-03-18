import Foundation

final class TrajectoryLanguageMemoryStore {
    private var memories: [UUID: TrajectoryLanguageMemory] = [:]

    func memory(for threadID: UUID) -> TrajectoryLanguageMemory {
        memories[threadID] ?? TrajectoryLanguageMemory(threadID: threadID)
    }

    func advance(
        threadID: UUID,
        with state: TrajectoryState
    ) {
        let current = memory(for: threadID)
        memories[threadID] = current.advanced(with: state)
    }
}
