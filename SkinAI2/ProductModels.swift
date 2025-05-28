import Foundation

struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var ingredientListText: String // Raw text from user
    var analyzedIngredients: [RecognizedIngredient]? // Populated after analysis
    var advice: ProductAdvice?

    init(id: UUID = UUID(), name: String, ingredientListText: String) {
        self.id = id
        self.name = name
        self.ingredientListText = ingredientListText
    }
}

struct RecognizedIngredient: Identifiable, Codable {
    var id: String { ingredientInfo.name.lowercased() } // Use normalized name as ID
    let ingredientInfo: IngredientInfo
    let foundInText: String // How it was found in the user's list
}

struct ProductAdvice: Codable {
    enum OverallAssessment: String, Codable {
        case good = "Potentially Good"
        case neutral = "Neutral"
        case useWithCaution = "Use with Caution"
        case potentiallyAvoid = "Potentially Avoid"
    }
    let assessment: OverallAssessment
    let positiveNotes: [String]
    let cautionaryNotes: [String]
    let forSkinCondition: AdvisedSkinCondition
}