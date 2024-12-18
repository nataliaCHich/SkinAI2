import Foundation

// Model to store skin analysis data
struct SkinAnalysis: Identifiable, Codable {
    let id: UUID
    let date: Date
    let imageData: Data
    let prediction: String
    let confidence: Double
    
    init(id: UUID = UUID(), imageData: Data, prediction: String, confidence: Double) {
        self.id = id
        self.date = Date()
        self.imageData = imageData
        self.prediction = prediction
        self.confidence = confidence
    }
}

// Manager class to handle skin analyses
class SkinAnalysisManager: ObservableObject {
    @Published var analyses: [SkinAnalysis] = []
    private let saveKey = "SkinAnalyses"
    
    init() {
        loadAnalyses()
    }
    
    func addAnalysis(_ analysis: SkinAnalysis) {
        analyses.append(analysis)
        saveAnalyses()
    }
    
    private func saveAnalyses() {
        if let encoded = try? JSONEncoder().encode(analyses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadAnalyses() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([SkinAnalysis].self, from: data) {
            analyses = decoded
        }
    }
}
