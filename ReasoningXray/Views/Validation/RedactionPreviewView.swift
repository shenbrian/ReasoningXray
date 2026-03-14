import SwiftUI

struct RedactionPreviewView: View {
    @StateObject private var privacyStore = PrivacyStore()

    @State private var originalText: String =
"""
Dr Smith reviewed the patient at Harbour Family Clinic, Sydney NSW.
Follow up was arranged with Dr Patel at Riverside Medical Centre.
"""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Redaction Preview")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Redact doctor names", isOn: $privacyStore.redactionOptions.redactDoctorName)
                    Toggle("Redact clinic names", isOn: $privacyStore.redactionOptions.redactClinicName)
                    Toggle("Redact location-like terms", isOn: $privacyStore.redactionOptions.redactLocationLikeTerms)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Original")
                        .font(.headline)

                    TextEditor(text: $originalText)
                        .frame(minHeight: 140)
                        .padding(8)
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Redacted")
                        .font(.headline)

                    Text(privacyStore.redact(originalText))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}
