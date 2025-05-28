import SwiftUI

class SkinEntriesManager: ObservableObject {
    @Published private(set) var entries: [SkinEntry] = []
    private let entriesKey = "skinEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: SkinEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func loadImage(for entry: SkinEntry) -> UIImage? {
        let filename = SkinEntry.getDocumentsDirectory().appendingPathComponent(entry.imageFileName)
        return UIImage(contentsOfFile: filename.path)
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([SkinEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func deleteEntry(at index: Int) {
        let entry = entries[index]
        // Delete the image file
        let filename = SkinEntry.getDocumentsDirectory().appendingPathComponent(entry.imageFileName)
        try? FileManager.default.removeItem(at: filename)
        
        // Remove the entry from the array
        entries.remove(at: index)
        saveEntries()
    }
    
    func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            deleteEntry(at: index)
        }
    }

    func compareLastTwoEntriesConfidence() -> SkinConditionChange {
        guard entries.count >= 2 else {
            return .notEnoughData
        }

        // Ensure entries are sorted by date to get the actual last two
        let sortedEntries = entries.sorted { $0.date < $1.date }
        let latestEntry = sortedEntries[sortedEntries.count - 1]
        let previousEntry = sortedEntries[sortedEntries.count - 2]

        // Helper function to extract the prediction identifier from the description string
        // e.g., "Prediction: Acne - Confidence: ..." -> "Acne"
        func getPredictionIdentifier(from description: String) -> String {
            let parts = description.components(separatedBy: " - Confidence: ")
            guard let predictionPart = parts.first else {
                // Fallback if description format is unexpected
                return description 
            }
            return predictionPart.replacingOccurrences(of: "Prediction: ", with: "")
        }

        let previousPrediction = getPredictionIdentifier(from: previousEntry.description)
        let latestPrediction = getPredictionIdentifier(from: latestEntry.description)
        
        // Define the string that represents "no issues"
        // This should match the exact identifier output by your ML model for a "no issues" state.
        let noIssuesIdentifier = "no issues" // Make sure this matches your model's output for no issues

        // Rule 1: If the previous condition was not "no issues", and the latest is "no issues" → return .improved
        if previousPrediction.lowercased() != noIssuesIdentifier && latestPrediction.lowercased() == noIssuesIdentifier {
            return .improved
        }

        // Rule 2: If the previous was "no issues", and the latest is not "no issues" → return .worsened
        if previousPrediction.lowercased() == noIssuesIdentifier && latestPrediction.lowercased() != noIssuesIdentifier {
            return .worsened
        }

        // Rule 3: In all other cases → compare based on confidence
        // Check for "small difference" (less than 5% absolute difference, i.e., 0.05 for confidence values 0.0-1.0)
        if abs(latestEntry.confidence - previousEntry.confidence) < 0.05 {
            return .noChange
        }

        // Compare confidence based on your logic: lower confidence is better.
        // if latest.confidence < previous.confidence → .better (mapped to .improved)
        if latestEntry.confidence < previousEntry.confidence {
            return .improved
        } 
        // if latest.confidence > previous.confidence → .worse (mapped to .worsened)
        else if latestEntry.confidence > previousEntry.confidence {
            return .worsened
        } 
        // If confidence scores are identical and not within the <0.05 threshold (should be caught by above)
        else {
            return .noChange 
        }
    }
}
