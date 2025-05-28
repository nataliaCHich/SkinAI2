import Foundation

enum RecommendationType: String, CaseIterable {
    case ingredientToSeek = "Ingredients to Look For"
    case ingredientToAvoid = "Ingredients to Consider Avoiding"
    case generalTip = "General Skincare Tips"
    // We can add more types later, e.g., productTypeSuggestion
}

struct SkincareRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String // e.g., "Salicylic Acid", "Gentle Cleansing"
    let description: String // e.g., "Helps exfoliate and clear pores.", "Avoid harsh soaps..."
    let relatedSkinCondition: AdvisedSkinCondition // For which condition this advice is relevant
}