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
        badFor: nil,
        description: "A Beta Hydroxy Acid (BHA) that exfoliates the skin and can help clear pores."
    ),
    "hyaluronic acid": IngredientInfo(
        name: "Hyaluronic Acid",
        aliases: ["sodium hyaluronate"],
        goodFor: [.dry, .normal, .sensitive],
        badFor: nil,
        description: "A humectant that draws moisture to the skin, helping with hydration."
    ),
    "benzoyl peroxide": IngredientInfo(
        name: "Benzoyl Peroxide",
        aliases: [],
        goodFor: [.acneProne],
        badFor: [.sensitive, .dry],
        description: "An antibacterial ingredient effective against acne, but can be harsh."
    ),
    "fragrance": IngredientInfo(
        name: "Fragrance",
        aliases: ["parfum"],
        goodFor: nil,
        badFor: [.sensitive],
        description: "Can cause irritation or allergic reactions in sensitive individuals."
    ),
    "alcohol denat.": IngredientInfo(
        name: "Alcohol Denat.",
        aliases: ["denatured alcohol"],
        goodFor: nil,
        badFor: [.dry, .sensitive],
        description: "Can be drying and irritating for some skin types."
    ),
    "glycerin": IngredientInfo(
        name: "Glycerin",
        aliases: [],
        goodFor: [.dry, .normal, .sensitive, .oily],
        badFor: nil,
        description: "A common humectant that helps to hydrate the skin."
    ),
    "niacinamide": IngredientInfo(
        name: "Niacinamide",
        aliases: ["vitamin b3"],
        goodFor: [.acneProne, .oily, .sensitive, .normal],
        badFor: nil,
        description: "Helps with redness, pore size, and skin barrier function."
    ),
    "aqua": IngredientInfo(
        name: "Aqua",
        aliases: ["water"],
        goodFor: [.acneProne, .dry, .oily, .sensitive, .normal], // Generally neutral/base
        badFor: nil,
        description: "Water, the most common skincare ingredient, used as a solvent."
    ),
    "retinol": IngredientInfo(
        name: "Retinol",
        aliases: ["vitamin a"],
        goodFor: [.acneProne, .oily, .normal],
        badFor: [.sensitive, .dry],
        description: "A form of Vitamin A that helps with skin cell turnover, texture, and acne. Can be irritating."
    ),
    "vitamin c": IngredientInfo(
        name: "Vitamin C",
        aliases: ["ascorbic acid", "l-ascorbic acid", "sodium ascorbyl phosphate", "magnesium ascorbyl phosphate"],
        goodFor: [.normal, .oily, .acneProne], // Acne-prone for some forms due to antioxidant properties
        badFor: [.sensitive], // Some forms can be irritating
        description: "An antioxidant that can brighten skin, improve pigmentation, and boost collagen. Stability and irritation vary by form."
    ),
    "ceramides": IngredientInfo(
        name: "Ceramides",
        aliases: [], // Ceramide NP, AP, EOP etc. are specific types
        goodFor: [.dry, .sensitive, .normal],
        badFor: nil,
        description: "Lipids that are naturally found in skin; help restore the skin barrier and retain moisture."
    ),
    "lactic acid": IngredientInfo(
        name: "Lactic Acid",
        aliases: ["aha"],
        goodFor: [.dry, .acneProne], // Good for dry due to humectant properties, acne-prone for exfoliation
        badFor: [.sensitive],
        description: "An Alpha Hydroxy Acid (AHA) that exfoliates the skin, improves texture, and can help with hydration. Milder than glycolic acid."
    ),
    "aloe vera": IngredientInfo(
        name: "Aloe Vera",
        aliases: ["aloe barbadensis leaf juice"],
        goodFor: [.sensitive, .dry, .normal],
        badFor: nil,
        description: "Known for its soothing, calming, and hydrating properties."
    ),
    "squalane": IngredientInfo(
        name: "Squalane",
        aliases: [],
        goodFor: [.dry, .oily, .sensitive, .normal], // Generally well-tolerated and non-comedogenic
        badFor: nil,
        description: "A lightweight, non-comedogenic emollient that mimics skin's natural sebum, providing moisture."
    ),
    "tea tree oil": IngredientInfo(
        name: "Tea Tree Oil",
        aliases: ["melaleuca alternifolia leaf oil"],
        goodFor: [.acneProne, .oily], // Oily due to antibacterial nature
        badFor: [.sensitive, .dry], // Can be drying and irritating, especially undiluted
        description: "Known for its antibacterial and anti-inflammatory properties, often used for acne. Should be used diluted."
    ),
    "coconut oil": IngredientInfo(
        name: "Coconut Oil",
        aliases: ["cocos nucifera oil"],
        goodFor: [.dry], // Very dry skin, not on face for many
        badFor: [.acneProne, .oily, .sensitive], // Highly comedogenic for many, can cause breakouts
        description: "A heavy, occlusive oil that can be very moisturizing but is also highly comedogenic and can clog pores for many individuals."
    ),
    "shea butter": IngredientInfo(
        name: "Shea Butter",
        aliases: ["butyrospermum parkii butter"],
        goodFor: [.dry, .sensitive],
        badFor: [.oily, .acneProne], // Can be too heavy and potentially comedogenic for oily/acne-prone
        description: "A rich emollient that moisturizes and nourishes dry skin. Can be comedogenic for some."
    ),
    "zinc": IngredientInfo(
        name: "Zinc Oxide",
        aliases: ["zinc"],
        goodFor: [.sensitive, .acneProne, .oily, .normal], // Oily due to mattifying properties
        badFor: nil,
        description: "A mineral sunscreen agent that provides broad-spectrum UV protection. Also known for its calming and anti-inflammatory properties."
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
