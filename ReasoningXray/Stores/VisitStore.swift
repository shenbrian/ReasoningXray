import Foundation
import Combine

class VisitStore: ObservableObject {
    
    @Published var visits: [VisitRecord] = []
    
    private let saveKey = "ReasoningXrayVisits"
    
    init() {
        loadVisits()
    }
    
    func addVisit(_ visit: VisitRecord) {
        visits.append(visit)
        saveVisits()
    }
    
    func deleteVisit(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            visits.remove(at: index)
        }
        saveVisits()
    }
    
    private func saveVisits() {
        if let encoded = try? JSONEncoder().encode(visits) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadVisits() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([VisitRecord].self, from: data) {
            visits = decoded
        }
    }
    
    func updateVisit(_ visit: VisitRecord) {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index] = visit
            saveVisits()
        }
    }
}
