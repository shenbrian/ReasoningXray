import SwiftUI

struct RecordVisitView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: ReasoningHistoryStore

    @StateObject private var recorder = AudioRecorder()
    @StateObject private var transcriber = SpeechTranscriber()
    @StateObject private var remoteExtractor = RemoteReasoningExtractor()

    private let safetyGuard = MedicalSafetyGuard()

    @State private var isTranscribing = false
    @State private var showingReview = false
    @State private var extracted: ExtractedReasoning?
    @State private var errorMessage: String?
    @State private var safetyWarnings: [String] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Spacer()

                Image(systemName: recorder.isRecording ? "mic.circle.fill" : "mic.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(recorder.isRecording ? .red : .accentColor)

                Text(recorder.isRecording ? "Recording in progress…" : "Ready to record")
                    .font(.title2)
                    .fontWeight(.semibold)

                if let url = recorder.recordedFileURL, !recorder.isRecording {
                    Text("Saved: \(url.lastPathComponent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if isTranscribing {
                    ProgressView("Transcribing…")
                }

                if !transcriber.transcript.isEmpty {
                    ScrollView {
                        Text(transcriber.transcript)
                            .font(.body)
                            .padding()
                    }
                    .frame(height: 160)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                if remoteExtractor.isExtracting {
                    ProgressView("Extracting reasoning…")
                }

                if let helperMessage {
                    Text(helperMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if !safetyWarnings.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(safetyWarnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    if recorder.isRecording {
                        recorder.stopRecording()

                        if let url = recorder.recordedFileURL {
                            isTranscribing = true
                            transcriber.transcribe(url: url)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isTranscribing = false
                            }
                        }
                    } else {
                        resetWorkflowState()
                        recorder.startRecording()
                    }
                } label: {
                    Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(recorder.isRecording ? Color.red : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                Button("Extract Reasoning") {
                    let cleanedTranscript = transcriber.transcript
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !cleanedTranscript.isEmpty else {
                        errorMessage = "Transcript is empty."
                        return
                    }

                    errorMessage = nil
                    safetyWarnings = []
                    extracted = nil
                    showingReview = false

                    print("=== RECORD VIEW EXTRACT BUTTON TAPPED ===")
                    remoteExtractor.extract(from: cleanedTranscript)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    transcriber.transcript
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty || remoteExtractor.isExtracting
                )

                Spacer()
                Spacer()
            }
            .navigationTitle("Record Visit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        }
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showingReview) {
                reviewDestination
            }
            .onReceive(remoteExtractor.$extracted) { remoteExtracted in
                guard let remoteExtracted else { return }

                let reviewed = safetyGuard.review(remoteExtracted)
                extracted = reviewed.sanitized
                safetyWarnings = reviewed.warnings

                if reviewed.blocked {
                    errorMessage = nil
                    showingReview = false
                } else {
                    errorMessage = nil
                    showingReview = true
                }
            }
            .onReceive(remoteExtractor.$errorMessage) { remoteError in
                if let remoteError {
                    errorMessage = remoteError
                    showingReview = false
                }
            }
        }
    }

    private var helperMessage: String? {
        if let errorMessage, !errorMessage.isEmpty {
            return errorMessage
        }

        if !transcriber.transcript.isEmpty &&
            !remoteExtractor.isExtracting &&
            extracted == nil &&
            safetyWarnings.isEmpty {
            return "We could not find clear medical reasoning yet. Try recording when the doctor explains what might be happening, what tests or treatments are planned, or what changed since the last visit."
        }

        return nil
    }

    @ViewBuilder
    private var reviewDestination: some View {
        if let extracted {
            ExtractedVisitReviewView(store: store, extracted: extracted)
        } else {
            EmptyView()
        }
    }

    private func resetWorkflowState() {
        transcriber.transcript = ""
        extracted = nil
        errorMessage = nil
        safetyWarnings = []
        showingReview = false
    }
}
