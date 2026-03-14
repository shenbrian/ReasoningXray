import SwiftUI

@main
struct ReasoningXrayApp: App {
    @StateObject private var store = ReasoningHistoryStore()

    var body: some Scene {
        WindowGroup {
            MainTabView(store: store)
        }
    }
}
