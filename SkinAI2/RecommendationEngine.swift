import Foundation

class RecommendationEngine {

    // Hardcoded general tips for now. This could be expanded or moved to a separate data source.
    private let generalTips: [AdvisedSkinCondition: [String: String]] = [
        .acneProne: [
            "Regular Cleansing": "Cleanse your face twice a day to remove excess oil and impurities.",
            "Avoid Picking": "Resist the urge to pick or squeeze blemishes, as it can worsen inflammation and lead to scarring.",
            "Non-Comedogenic Products": "Look for makeup and skincare products labeled 'non-comedogenic' to avoid clogging pores."
        ],
        .dry: [
            "Hydrate Well": "Use a gentle, hydrating cleanser and a rich moisturizer daily.",
            "Lukewarm Water": "Wash your face with lukewarm, not hot, water.",
            "Humidifier": "Consider using a humidifier in dry environments."
        ],
        .oily: [
            "Lightweight Moisturizer": "Even oily skin needs hydration; use a lightweight, oil-free moisturizer.",
            "Blotting Papers": "Use blotting papers throughout the day to manage excess shine.",
            "Avoid Over-Washing": "Washing too frequently can strip the skin, causing it to produce more oil."
        ],
        .sensitive: [
            "Patch Test": "Always patch test new products on a small area of skin before applying to your entire face.",
            "Fragrance-Free": "Choose fragrance-free and hypoallergenic products when possible.",
            "Gentle Ingredients": "Look for soothing ingredients like aloe vera, chamomile, or calendula."
        ],
        .normal: [
            "Maintain Balance": "Focus on maintaining your skin's natural balance with a consistent routine.",
            "Sun Protection": "Use sunscreen daily to protect against UV damage.",
            "Listen to Your Skin": "Pay attention to how your skin reacts to different products or environmental changes."
        ]
    ]

    func generateRecommendations(for skinCondition: AdvisedSkinCondition) -> [SkincareRecommendation] {
        var recommendations: [SkincareRecommendation] = []

        // 1. Ingredient-based recommendations
        for (_, ingredientInfo) in ingredientDatabase {
            if let goodFor = ingredientInfo.goodFor, goodFor.contains(skinCondition) {
                recommendations.append(SkincareRecommendation(
                    type: .ingredientToSeek,
                    title: ingredientInfo.name,
                    description: ingredientInfo.description ?? "Beneficial for \(skinCondition.rawValue) skin.",
                    relatedSkinCondition: skinCondition
                ))
            }
            if let badFor = ingredientInfo.badFor, badFor.contains(skinCondition) {
                recommendations.append(SkincareRecommendation(
                    type: .ingredientToAvoid,
                    title: ingredientInfo.name,
                    description: ingredientInfo.description ?? "May be problematic for \(skinCondition.rawValue) skin. Consider avoiding or using with caution.",
                    relatedSkinCondition: skinCondition
                ))
            }
        }

        // 2. General tips
        if let tipsForCondition = generalTips[skinCondition] {
            for (title, description) in tipsForCondition {
                recommendations.append(SkincareRecommendation(
                    type: .generalTip,
                    title: title,
                    description: description,
                    relatedSkinCondition: skinCondition
                ))
            }
        }
        
        // Sort recommendations for consistent display: General Tips, Seek, Avoid
        recommendations.sort {
            if $0.type.rawValue != $1.type.rawValue {
                // Define a custom order for types
                let order: [RecommendationType: Int] = [.generalTip: 0, .ingredientToSeek: 1, .ingredientToAvoid: 2]
                return (order[$0.type] ?? 99) < (order[$1.type] ?? 99)
            }
            return $0.title < $1.title // Alphabetical within type
        }

        return recommendations
    }
}