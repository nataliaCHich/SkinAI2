import SwiftUI

class ProductManager: ObservableObject {
    @Published private(set) var products: [Product] = [] {
        didSet {
            saveProducts()
        }
    }
    private let productsKey = "userProducts"
    private let analyzer = ProductAnalyzer()

    init() {
        loadProducts()
    }

    func addProduct(name: String, ingredientListText: String, currentSkinConditionPrediction: String) {
        var newProduct = Product(name: name, ingredientListText: ingredientListText)
        analyzer.analyzeProduct(product: &newProduct, currentSkinConditionPrediction: currentSkinConditionPrediction)
        products.append(newProduct)
        // Save happens in didSet
    }

    func reanalyzeAllProducts(currentSkinConditionPrediction: String) {
        for i in products.indices {
            analyzer.analyzeProduct(product: &products[i], currentSkinConditionPrediction: currentSkinConditionPrediction)
        }
        // Trigger an update for views observing products
        objectWillChange.send()
    }
    
    func deleteProduct(at offsets: IndexSet) {
        products.remove(atOffsets: offsets)
        // Save happens in didSet
    }

    private func saveProducts() {
        if let encoded = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(encoded, forKey: productsKey)
        }
    }

    private func loadProducts() {
        if let data = UserDefaults.standard.data(forKey: productsKey),
           let decoded = try? JSONDecoder().decode([Product].self, from: data) {
            products = decoded
            // Optionally, re-analyze products on load if skin condition logic might have changed
            // or if you want to ensure advice is up-to-date with current skin condition.
            // For now, we'll assume skin condition for advice is determined when product is added/re-analyzed.
        }
    }
}