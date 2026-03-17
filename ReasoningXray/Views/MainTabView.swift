import SwiftUI

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        TabView {

            VisitListView(store: store)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            VisitHistoryView()
                .tabItem {
                    Label("Visits", systemImage: "doc.text")
                }

            CaseThreadsView()
                .tabItem {
                    Label("Issues", systemImage: "square.stack.3d.up")
                }

            ValidationDashboardView()
                .tabItem {
                    Label("Validate", systemImage: "checkmark.seal")
                }
        }
        .environmentObject(store)
    }
}
