import Foundation

struct VisitRecord: Identifiable, Codable {
    
    var id: UUID = UUID()
    
    var date: Date
    
    var doctorName: String
    
    var clinic: String?
    
    var reasonForVisit: String
    
    var doctorExplanation: String
    
    var evidence: [String]
    
    var decision: String
    
    var nextSteps: String
    
    var questionsForNextVisit: [String]
}
