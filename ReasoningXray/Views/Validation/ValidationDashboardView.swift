import SwiftUI

struct ValidationDashboardView: View {

    @StateObject private var store = ValidationStore()

    var body: some View {
        NavigationStack {
            List {
                Section("Tools") {
                    Button("Run Validation Cases") {
                        store.runAll()
                    }

                    NavigationLink {
                        RedactionPreviewView()
                    } label: {
                        Label("Privacy Redaction Preview", systemImage: "eye.slash")
                    }
                }

                Section("Validation Results") {
                    if store.results.isEmpty {
                        Text("No validation results yet.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(store.results) { result in
                        NavigationLink(destination: ValidationResultDetailView(result: result)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.caseTitle)
                                    .font(.headline)

                                Text(result.evaluatorSummary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Validation")
        }
    }
}
