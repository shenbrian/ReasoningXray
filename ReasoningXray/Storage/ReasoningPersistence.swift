import Foundation

struct ReasoningPersistence {

    private static let fileName = "reasoning_history.json"

    private static var fileURL: URL {
        let manager = FileManager.default

        let folder = manager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        let appFolder = folder.appendingPathComponent("ReasoningXray")

        if !manager.fileExists(atPath: appFolder.path) {
            try? manager.createDirectory(
                at: appFolder,
                withIntermediateDirectories: true
            )
        }

        return appFolder.appendingPathComponent(fileName)
    }

    static func save(
        _ store: ReasoningHistoryStore,
        redactionOptions: RedactionOptions = .safeDefault
    ) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let state = store.exportState()
            let data = try encoder.encode(state)

            let finalData: Data

            if redactionOptions == .none {
                finalData = data
            } else {
                let redactor = TranscriptRedactor()
                let jsonText = String(data: data, encoding: .utf8) ?? ""
                let redactedText = redactor.redact(jsonText, using: redactionOptions)
                finalData = Data(redactedText.utf8)
            }

            try finalData.write(
                to: fileURL,
                options: [.atomic, .completeFileProtection]
            )

        } catch {
            print("Persistence save error:", error)
        }
    }

    static func load() -> ReasoningHistoryStore.State? {

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(ReasoningHistoryStore.State.self, from: data)

        } catch {
            print("Persistence load error:", error)
            return nil
        }
    }
}
