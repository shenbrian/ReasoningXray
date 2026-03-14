import SwiftUI

struct VisitHistoryView: View {
    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(store.allVisitsSorted()) { visit in
                        NavigationLink {
                            VisitDetailView(visit: visit)
                        } label: {
                            VisitCardView(
                                visit: visit,
                                threadTitle: store.thread(for: visit)?.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("All Visits")
        }
    }
}
