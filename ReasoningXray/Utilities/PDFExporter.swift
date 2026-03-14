import Foundation
import PDFKit
import UIKit

struct PDFExporter {
    
    static func createVisitPDF(for visit: VisitRecord) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ReasoningXray",
            kCGPDFContextAuthor: "ReasoningXray",
            kCGPDFContextTitle: "Visit Summary"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("VisitSummary-\(visit.id).pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24)
                ]
                
                let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16)
                ]
                
                let bodyAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12)
                ]
                
                var y: CGFloat = 40
                
                func draw(_ text: String, attributes: [NSAttributedString.Key: Any], spacing: CGFloat = 24) {
                    let rect = CGRect(x: 40, y: y, width: pageRect.width - 80, height: 1000)
                    let attributed = NSAttributedString(string: text, attributes: attributes)
                    attributed.draw(with: rect, options: .usesLineFragmentOrigin, context: nil)
                    
                    let size = attributed.boundingRect(
                        with: CGSize(width: pageRect.width - 80, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        context: nil
                    )
                    
                    y += size.height + spacing
                }
                
                draw("ReasoningXray Visit Summary", attributes: titleAttributes, spacing: 30)
                
                draw("Doctor: \(visit.doctorName)", attributes: bodyAttributes, spacing: 10)
                draw("Date: \(visit.date.formatted(date: .long, time: .omitted))", attributes: bodyAttributes, spacing: 10)
                
                if let clinic = visit.clinic, !clinic.isEmpty {
                    draw("Clinic: \(clinic)", attributes: bodyAttributes, spacing: 20)
                } else {
                    y += 10
                }
                
                draw("Reason for Visit", attributes: sectionTitleAttributes, spacing: 8)
                draw(visit.reasonForVisit, attributes: bodyAttributes, spacing: 20)
                
                draw("Doctor Explanation", attributes: sectionTitleAttributes, spacing: 8)
                draw(visit.doctorExplanation.isEmpty ? "Not recorded" : visit.doctorExplanation, attributes: bodyAttributes, spacing: 20)
                
                draw("Evidence Considered", attributes: sectionTitleAttributes, spacing: 8)
                let evidenceText = visit.evidence.isEmpty
                    ? "Not recorded"
                    : visit.evidence.map { "• \($0)" }.joined(separator: "\n")
                draw(evidenceText, attributes: bodyAttributes, spacing: 20)
                
                draw("Decision", attributes: sectionTitleAttributes, spacing: 8)
                draw(visit.decision.isEmpty ? "Not recorded" : visit.decision, attributes: bodyAttributes, spacing: 20)
                
                draw("Next Steps", attributes: sectionTitleAttributes, spacing: 8)
                draw(visit.nextSteps.isEmpty ? "Not recorded" : visit.nextSteps, attributes: bodyAttributes, spacing: 20)
                
                draw("Questions for Next Visit", attributes: sectionTitleAttributes, spacing: 8)
                let questionsText = visit.questionsForNextVisit.isEmpty
                    ? "Not recorded"
                    : visit.questionsForNextVisit.map { "• \($0)" }.joined(separator: "\n")
                draw(questionsText, attributes: bodyAttributes, spacing: 20)
            }
            
            return tempURL
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }
}
