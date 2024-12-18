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
}
