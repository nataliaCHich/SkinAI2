import SwiftUI

struct SkinEntry: Identifiable, Codable {
    let id: UUID
    let imageFileName: String
    let date: Date
    var description: String
    var confidence: Double
    
    // Existing init
    init(id: UUID = UUID(), image: UIImage, date: Date, description: String, confidence: Double = 0.0) {
        self.id = id
        self.imageFileName = id.uuidString
        self.date = date
        self.description = description
        self.confidence = confidence
        
        // Save image to documents directory
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = Self.getDocumentsDirectory().appendingPathComponent(imageFileName)
            try? data.write(to: filename)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, imageFileName, date, description, confidence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        imageFileName = try container.decode(String.self, forKey: .imageFileName)
        date = try container.decode(Date.self, forKey: .date)
        description = try container.decode(String.self, forKey: .description)
        // Provide a default value if 'confidence' is missing
        confidence = (try? container.decodeIfPresent(Double.self, forKey: .confidence)) ?? 0.0
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
