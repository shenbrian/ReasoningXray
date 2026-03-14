import Foundation
import Combine

final class RemoteReasoningExtractor: ObservableObject {

    @Published var extracted: ExtractedReasoning?
    @Published var isExtracting = false
    @Published var errorMessage: String?

    private let endpointURL = URL(string: "http://127.0.0.1:3000/extract-reasoning")!

    func extract(from transcript: String) {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Transcript is empty."
            return
        }

        print("=== RX START EXTRACT ===")
        print("Transcript:")
        print(transcript)

        isExtracting = true
        errorMessage = nil
        extracted = nil

        let payload = ["transcript": transcript]

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            isExtracting = false
            errorMessage = "Failed to encode request."
            print("=== RX REQUEST ENCODE ERROR ===")
            print(error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isExtracting = false

                if let error = error {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                    print("=== RX NETWORK ERROR ===")
                    print(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid server response."
                    print("=== RX INVALID RESPONSE ===")
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    print("=== RX EMPTY DATA ===")
                    return
                }

                print("=== RX HTTP STATUS ===")
                print(httpResponse.statusCode)

                if let raw = String(data: data, encoding: .utf8) {
                    print("=== RX RAW RESPONSE ===")
                    print(raw)
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ExtractedReasoning.self, from: data)
                    self.extracted = decoded
                    print("=== RX DECODE SUCCESS ===")
                } catch {
                    self.errorMessage = "Failed to decode server response."
                    print("=== RX DECODE ERROR ===")
                    print(error)
                }
            }
        }.resume()
    }
}
