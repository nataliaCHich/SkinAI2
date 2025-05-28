import Foundation
import NaturalLanguage

class ProductAnalyzer {

    func parseIngredientList(text: String) -> [String] {
        let cleanedText = text.lowercased()
                              .replacingOccurrences(of: "\n", with: ",") // Replace newlines with commas
                              .replacingOccurrences(of: "/", with: ",")  // Replace slashes
        
        // Basic split by comma. More sophisticated tokenization might be needed for complex lists.
        let potentialIngredients = cleanedText.components(separatedBy: CharacterSet(charactersIn: ",."))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 } // Basic filter for very short strings

        // Further refinement could involve NLP tokenization or regex to handle "Aqua (Water)" etc.
        // For now, this is a simple split.
        return potentialIngredients
    }

    func recognizeIngredients(parsedIngredients: [String]) -> [RecognizedIngredient] {
        var recognized: [RecognizedIngredient] = []
        var recognizedNames: Set<String> = [] // To avoid duplicates if an ingredient is matched by alias and name

        for parsedIng in parsedIngredients {
            let normalizedParsedIng = parsedIng.lowercased()
            
            // Direct match
            if let info = ingredientDatabase[normalizedParsedIng], !recognizedNames.contains(info.name.lowercased()) {
                recognized.append(RecognizedIngredient(ingredientInfo: info, foundInText: parsedIng))
                recognizedNames.insert(info.name.lowercased())
                continue
            }
            
            // Alias match
            for (key, info) in ingredientDatabase {
                if let aliases = info.aliases, aliases.contains(where: { $0.lowercased() == normalizedParsedIng }), !recognizedNames.contains(info.name.lowercased()) {
                    recognized.append(RecognizedIngredient(ingredientInfo: info, foundInText: parsedIng))
                    recognizedNames.insert(info.name.lowercased())
                    break // Found an alias match for this parsedIng
                }
            }
        }
        return recognized
    }
    
    func generateAdvice(recognizedIngredients: [RecognizedIngredient], forCondition: AdvisedSkinCondition) -> ProductAdvice {
        var positiveNotes: [String] = []
        var cautionaryNotes: [String] = []
        var goodIngredientCount = 0
        var badIngredientCount = 0

        for recIng in recognizedIngredients {
            if let goodForConditions = recIng.ingredientInfo.goodFor, goodForConditions.contains(forCondition) {
                positiveNotes.append("\(recIng.ingredientInfo.name): Beneficial for \(forCondition.rawValue).")
                goodIngredientCount += 1
            }
            if let badForConditions = recIng.ingredientInfo.badFor, badForConditions.contains(forCondition) {
                cautionaryNotes.append("\(recIng.ingredientInfo.name): May be problematic for \(forCondition.rawValue).")
                badIngredientCount += 1
            }
        }

        let assessment: ProductAdvice.OverallAssessment
        if badIngredientCount > 0 {
            assessment = .potentiallyAvoid
        } else if goodIngredientCount > 0 && badIngredientCount == 0 {
            assessment = .good
        } else if goodIngredientCount > 0 { // Some good, some neutral/unknown
             assessment = .useWithCaution // Or good, depending on strictness
        }
        else {
            assessment = .neutral
        }
        
        if positiveNotes.isEmpty && cautionaryNotes.isEmpty && !recognizedIngredients.isEmpty {
             positiveNotes.append("No specific strong indicators for or against for your skin type based on recognized ingredients.")
        } else if recognizedIngredients.isEmpty {
            positiveNotes.append("Could not recognize any ingredients to provide advice.")
        }


        return ProductAdvice(assessment: assessment,
                             positiveNotes: positiveNotes,
                             cautionaryNotes: cautionaryNotes,
                             forSkinCondition: forCondition)
    }

    func analyzeProduct(product: inout Product, currentSkinConditionPrediction: String) {
        let parsed = parseIngredientList(text: product.ingredientListText)
        let recognized = recognizeIngredients(parsedIngredients: parsed)
        product.analyzedIngredients = recognized
        
        let advisedCondition = mapMLPredictionToAdvisedCondition(currentSkinConditionPrediction)
        product.advice = generateAdvice(recognizedIngredients: recognized, forCondition: advisedCondition)
    }
}