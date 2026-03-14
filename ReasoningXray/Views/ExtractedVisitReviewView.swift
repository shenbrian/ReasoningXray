import SwiftUI

struct ExtractedVisitReviewView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var store: ReasoningHistoryStore
    let extracted: ExtractedReasoning

    @State private var saveError: String?
    @State private var saveSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    safetyNoteSection
                    layer2Section
                    layer1Section
                    saveSection
                }
                .padding()
            }
            .navigationTitle("Review Extracted Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Visit Saved", isPresented: $saveSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("The extracted visit was saved and added to the timeline.")
            }
        }
    }

    private var safetyNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review before saving")
                .font(.headline)

            Text("This summary reflects extracted reasoning from the recorded visit. It is not a diagnosis or medical recommendation.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var layer2Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What This Means For You")
                .font(.title3.bold())

            detailRow("What might be happening", extracted.whatMightBeHappening)
            detailRow("How serious it appears", extracted.howSeriousItAppears)
            detailRow("What the doctor is doing", extracted.whatTheDoctorIsDoing)
            detailRow("What happens next", extracted.whatHappensNext)
            detailList("Questions for next visit", extracted.questionsForNextVisit)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var layer1Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Doctor Reasoning Mirror")
                .font(.title3.bold())

            detailRow("Doctor name", extracted.doctorName)
            detailRow("Clinic", extracted.clinic ?? "Not recorded")
            detailRow("Reason for visit", extracted.reasonForVisit)
            detailRow("Doctor explanation", extracted.doctorExplanation)
            detailList("Evidence", extracted.evidence)
            detailRow("Decision", extracted.decision)
            detailRow("Next steps", extracted.nextSteps)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var saveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save")
                .font(.title3.bold())

            if let saveError {
                Text(saveError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Save as Visit") {
                saveExtractedVisit()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func saveExtractedVisit() {
        guard store.addExtractedReasoningAsVisit(extracted) != nil else {
            saveError = "Could not match this visit to an issue thread."
            return
        }

        saveError = nil
        saveSuccess = true
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.isEmpty ? "Not recorded" : value)
        }
    }

    private func detailList(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            if items.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                }
            }
        }
    }
}
