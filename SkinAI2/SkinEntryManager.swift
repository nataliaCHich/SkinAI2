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
}

// End of file. No additional code.

