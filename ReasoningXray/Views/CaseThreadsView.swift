import SwiftUI

struct CaseThreadsView: View {
    @EnvironmentObject var store: ReasoningHistoryStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
        
                    ForEach(store.threads) { thread in
                        NavigationLink {
                            ThreadDetailView(thread: thread)
                                .environmentObject(store)
                        } label: {
                            ThreadCardView(
                                thread: thread,
                                visitCount: store.visits(for: thread).count
                            )
                            .environmentObject(store)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("By Issue")
        }
    }
}
