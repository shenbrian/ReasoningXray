import SwiftUI

struct AddVisitView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: VisitStore
    
    @State private var date = Date()
    @State private var doctorName = ""
    @State private var clinic = ""
    @State private var reasonForVisit = ""
    @State private var doctorExplanation = ""
    @State private var evidenceText = ""
    @State private var decision = ""
    @State private var nextSteps = ""
    @State private var questionsText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Visit Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Doctor Name", text: $doctorName)
                    TextField("Clinic (optional)", text: $clinic)
                }
                
                Section("Reasoning Summary") {
                    TextField("Reason for visit", text: $reasonForVisit, axis: .vertical)
                    TextField("Doctor explanation", text: $doctorExplanation, axis: .vertical)
                    TextField("Evidence (separate with commas)", text: $evidenceText, axis: .vertical)
                    TextField("Decision", text: $decision, axis: .vertical)
                    TextField("Next steps", text: $nextSteps, axis: .vertical)
                    TextField("Questions for next visit (separate with commas)", text: $questionsText, axis: .vertical)
                }
            }
            .navigationTitle("New Visit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit()
                    }
                    .disabled(doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              reasonForVisit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveVisit() {
        let evidenceArray = evidenceText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let questionsArray = questionsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let visit = VisitRecord(
            date: date,
            doctorName: doctorName,
            clinic: clinic.isEmpty ? nil : clinic,
            reasonForVisit: reasonForVisit,
            doctorExplanation: doctorExplanation,
            evidence: evidenceArray,
            decision: decision,
            nextSteps: nextSteps,
            questionsForNextVisit: questionsArray
        )
        
        store.addVisit(visit)
        dismiss()
    }
}
