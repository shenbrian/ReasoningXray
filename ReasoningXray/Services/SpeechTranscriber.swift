import Foundation
import Speech
import Combine

final class SpeechTranscriber: ObservableObject {

    enum TranscriptionLanguage: String, CaseIterable {
        case englishUS = "en-US"
        case chineseSimplified = "zh-CN"

        var locale: Locale {
            Locale(identifier: rawValue)
        }
    }

    @Published var transcript: String = ""
    @Published var selectedLanguage: TranscriptionLanguage = .chineseSimplified

    func transcribe(url: URL) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.transcript = "Speech recognition not authorized."
                }
                return
            }

            guard let recognizer = SFSpeechRecognizer(locale: self.selectedLanguage.locale) else {
                DispatchQueue.main.async {
                    self.transcript = "Speech recognizer unavailable for \(self.selectedLanguage.rawValue)."
                }
                return
            }

            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false

            recognizer.recognitionTask(with: request) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcript = result.bestTranscription.formattedString
                    }
                }

                if let error = error {
                    DispatchQueue.main.async {
                        self.transcript = "Transcription error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    func setLanguage(_ language: TranscriptionLanguage) {
        selectedLanguage = language
    }
}
