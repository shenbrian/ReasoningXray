import Foundation

final class LanguageRenderSessionContext {

    private var cache: [TrajectoryState: String] = [:]

    func phrase(
        for state: TrajectoryState,
        generator: () -> String
    ) -> String {

        if let cached = cache[state] {
            return cached
        }

        let value = generator()
        cache[state] = value
        return value
    }
}
