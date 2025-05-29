import Foundation
import Vision
import UIKit // For UIImage

class IngredientOCRService {

    enum RecognitionError: Error {
        case imageProcessingError
        case recognitionFailed
        case noTextFound
    }

    func recognizeIngredients(from image: UIImage, completion: @escaping (Result<[String], RecognitionError>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.imageProcessingError))
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                completion(.failure(.recognitionFailed))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                completion(.failure(.noTextFound))
                return
            }

            // Concatenate all recognized text blocks into one string
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string // Get the top candidate
            }
            
            let fullRecognizedText = recognizedStrings.joined(separator: "\n") // Join lines for better parsing context

            // Parse the full text into potential ingredients
            let potentialIngredients = self.parseRecognizedTextForIngredients(fullRecognizedText)
            
            completion(.success(potentialIngredients))
        }

        // Set recognition level - .accurate is slower but better for ingredient lists
        recognizeTextRequest.recognitionLevel = .accurate
        // Optionally, specify languages if you know them, e.g., ["en-US"]
        // recognizeTextRequest.recognitionLanguages = ["en-US"] 

        // Perform the request
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([recognizeTextRequest])
            } catch {
                print("Failed to perform text recognition request: \(error.localizedDescription)")
                completion(.failure(.recognitionFailed))
            }
        }
    }

    private func parseRecognizedTextForIngredients(_ text: String) -> [String] {
        // Basic parsing:
        // 1. Replace common OCR misinterpretations if known (e.g., "I" for "l")
        // 2. Split by common delimiters: comma, semicolon, newline.
        // 3. Trim whitespace and filter out empty strings.
        // 4. Convert to lowercase for consistency.
        // More advanced parsing might involve regex for patterns like "ingredient (active %)" etc.

        var ingredientsText = text
        
        // Example: Normalize common list endings like "Ingredients:", "INCI:" etc.
        // This is very basic; a robust solution would use more advanced text cleaning.
        if let range = ingredientsText.range(of: "Ingredients:", options: .caseInsensitive) {
            ingredientsText = String(ingredientsText[range.upperBound...])
        } else if let range = ingredientsText.range(of: "INCI:", options: .caseInsensitive) {
            ingredientsText = String(ingredientsText[range.upperBound...])
        }
        
        // Split by common delimiters (comma, semicolon, newline)
        let delimiters = CharacterSet(charactersIn: ",;\n")
        let potentialIngredients = ingredientsText.components(separatedBy: delimiters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 1 } // Filter out empty strings and very short ones
            // .map { $0.lowercased() } // Optional: lowercase for consistency with your database
        
        return potentialIngredients
    }
}