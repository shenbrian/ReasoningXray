import SwiftUI

struct VisitListView: View {
    @ObservedObject var store: ReasoningHistoryStore
    @State private var showRecorder = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(store.allVisitsSorted()) { visit in
                        NavigationLink {
                            VisitDetailView(visit: visit)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.thread(for: visit)?.title ?? visit.reasonForVisit)
                                    .font(.headline)

                                Text("Dr. \(visit.doctorName)")
                                    .foregroundStyle(.secondary)

                                Text(visit.visitDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("ReasoningXray")

                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Button {
                            showRecorder = true
                        } label: {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showRecorder) {
                RecordVisitView(store: store)
            }
        }
    }
}
