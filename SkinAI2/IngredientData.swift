import Foundation

// Simplified skin conditions for advice mapping
enum AdvisedSkinCondition: String, CaseIterable, Codable {
    case acneProne = "Acne-Prone"
    case dry = "Dry"
    case oily = "Oily"
    case sensitive = "Sensitive"
    case normal = "Normal" // Corresponds to "no issues"
}

struct IngredientInfo: Codable {
    let name: String // Primary name
    let aliases: [String]? // Other common names
    let goodFor: [AdvisedSkinCondition]? // Conditions it might help
    let badFor: [AdvisedSkinCondition]?  // Conditions it might aggravate
    let description: String?
}

// Simple local ingredient database
// This would ideally be much larger and more detailed, possibly from a JSON file or an API.
let ingredientDatabase: [String: IngredientInfo] = [
    "salicylic acid": IngredientInfo(
        name: "Salicylic Acid",
        aliases: ["bha"],
        goodFor: [.acneProne, .oily],
        description: "A Beta Hydroxy Acid (BHA) that exfoliates the skin and can help clear pores."
    ),
    "hyaluronic acid": IngredientInfo(
        name: "Hyaluronic Acid",
        aliases: ["sodium hyaluronate"],
        goodFor: [.dry, .normal, .sensitive],
        description: "A humectant that draws moisture to the skin, helping with hydration."
    ),
    "benzoyl peroxide": IngredientInfo(
        name: "Benzoyl Peroxide",
        aliases: [],
        goodFor: [.acneProne],
        badFor: [.sensitive, .dry], // Can be drying/irritating
        description: "An antibacterial ingredient effective against acne, but can be harsh."
    ),
    "fragrance": IngredientInfo(
        name: "Fragrance",
        aliases: ["parfum"],
        badFor: [.sensitive],
        description: "Can cause irritation or allergic reactions in sensitive individuals."
    ),
    "alcohol denat.": IngredientInfo(
        name: "Alcohol Denat.",
        aliases: ["denatured alcohol"],
        badFor: [.dry, .sensitive],
        description: "Can be drying and irritating for some skin types."
    ),
    "glycerin": IngredientInfo(
        name: "Glycerin",
        aliases: [],
        goodFor: [.dry, .normal, .sensitive, .oily], // Generally good for most
        description: "A common humectant that helps to hydrate the skin."
    ),
    "niacinamide": IngredientInfo(
        name: "Niacinamide",
        aliases: ["vitamin b3"],
        goodFor: [.acneProne, .oily, .sensitive, .normal], // Versatile
        description: "Helps with redness, pore size, and skin barrier function."
    )
    // ... Add more ingredients
]

// Helper to get current skin condition advice category
// This needs to be adapted based on how your ML model output ("Acne", "no issues", etc.)
// maps to these AdvisedSkinCondition categories.
func mapMLPredictionToAdvisedCondition(_ mlPrediction: String) -> AdvisedSkinCondition {
    let lowercasedPrediction = mlPrediction.lowercased()
    if lowercasedPrediction.contains("acne") {
        return .acneProne
    } else if lowercasedPrediction.contains("no issues") { // Assuming "no issues" maps to normal
        return .normal
    }
    // Add more mappings for other ML predictions (e.g., "dryness", "redness")
    // For now, default to normal if no specific match
    return .normal
}