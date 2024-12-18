import SwiftUI

struct SkinEntry: Identifiable, Codable {
    let id: UUID
    let imageFileName: String
    let date: Date
    var description: String
    
    init(id: UUID = UUID(), image: UIImage, date: Date, description: String) {
        self.id = id
        self.imageFileName = id.uuidString
        self.date = date
        self.description = description
        
        // Save image to documents directory
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = Self.getDocumentsDirectory().appendingPathComponent(imageFileName)
            try? data.write(to: filename)
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// End of file. No additional code.
