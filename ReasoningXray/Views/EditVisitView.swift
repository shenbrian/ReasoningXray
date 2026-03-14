import SwiftUI

struct EditVisitView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: VisitStore
    
    @State var visit: VisitRecord
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Visit Details") {
                    DatePicker("Date", selection: $visit.date, displayedComponents: .date)
                    
                    TextField("Doctor Name", text: $visit.doctorName)
                    
                    TextField("Clinic", text: Binding(
                        get: { visit.clinic ?? "" },
                        set: { visit.clinic = $0 }
                    ))
                }
                
                Section("Reasoning Summary") {
                    TextField("Reason for visit", text: $visit.reasonForVisit)
                    
                    TextField("Doctor explanation", text: $visit.doctorExplanation)
                    
                    TextField("Decision", text: $visit.decision)
                    
                    TextField("Next steps", text: $visit.nextSteps)
                }
            }
            .navigationTitle("Edit Visit")
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateVisit(visit)
                        dismiss()
                    }
                }
            }
        }
    }
}
