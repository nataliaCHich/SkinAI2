import SwiftUI

struct MyProductsView: View {
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var entriesManager: SkinEntriesManager // To get current skin condition

    @State private var showingAddProductSheet = false

    // Get the latest skin condition prediction for analysis
    private var currentSkinPrediction: String {
        // Use the description of the very last skin entry, if available
        // This assumes the description contains the ML model's prediction string like "Acne" or "no issues"
        // You might need a more robust way to get the *current* prevailing skin condition.
        if let lastEntry = entriesManager.entries.sorted(by: { $0.date > $1.date }).first {
            // Extract prediction from "Prediction: Acne - Confidence: XX%"
             let parts = lastEntry.description.components(separatedBy: " - Confidence:")
             if let predictionPart = parts.first {
                 return predictionPart.replacingOccurrences(of: "Prediction: ", with: "")
             }
             return "Normal" // Default if parsing fails
        }
        return "Normal" // Default if no entries
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.pink.opacity(0.0)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

                VStack {
                    List {
                        ForEach(productManager.products) { product in
                            ProductRow(product: product)
                        }
                        .onDelete(perform: productManager.deleteProduct)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)

                    Button("Re-analyze Products for Current Skin") {
                        productManager.reanalyzeAllProducts(currentSkinConditionPrediction: currentSkinPrediction)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("My Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddProductSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddProductSheet) {
                AddProductView(currentSkinPredictionForAnalysis: currentSkinPrediction)
                    .environmentObject(productManager)
            }
        }
    }
}

struct ProductRow: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.name)
                .font(.headline)

            if let advice = product.advice {
                Text("Assessment for \(advice.forSkinCondition.rawValue): \(advice.assessment.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(colorForAssessment(advice.assessment))

                if !advice.positiveNotes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Good For You:").bold()
                        ForEach(advice.positiveNotes, id: \.self) { Text($0).font(.caption) }
                    }
                }
                if !advice.cautionaryNotes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Use with Caution:").bold()
                        ForEach(advice.cautionaryNotes, id: \.self) { Text($0).font(.caption) }
                    }
                }
            } else {
                Text("Not yet analyzed or analysis failed.")
                    .font(.subheadline)
            }

            DisclosureGroup("Parsed Ingredients (\(product.analyzedIngredients?.count ?? 0))") {
                if let ingredients = product.analyzedIngredients, !ingredients.isEmpty {
                    ForEach(ingredients) { recognizedIng in
                        VStack(alignment: .leading) {
                            Text(recognizedIng.ingredientInfo.name)
                                .font(.caption.bold())
                            if let desc = recognizedIng.ingredientInfo.description {
                                Text(desc).font(.caption2)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } else {
                    Text("No ingredients recognized or list was empty.").font(.caption)
                }
            }
            .font(.caption)
        }
        .padding(.vertical)
    }

    func colorForAssessment(_ assessment: ProductAdvice.OverallAssessment) -> Color {
        switch assessment {
        case .good: return .green
        case .neutral: return .gray
        case .useWithCaution: return .orange
        case .potentiallyAvoid: return .red
        }
    }
}

struct AddProductView: View {
    @EnvironmentObject var productManager: ProductManager
    @Environment(\.dismiss) var dismiss

    @State private var productName: String = ""
    @State private var ingredientList: String = "e.g., Aqua, Glycerin, Salicylic Acid, Fragrance"
    
    let currentSkinPredictionForAnalysis: String

    var body: some View {
        NavigationView {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $productName)
                    TextEditor(text: $ingredientList)
                        .frame(height: 200)
                        .foregroundColor(ingredientList == "e.g., Aqua, Glycerin, Salicylic Acid, Fragrance" ? .gray : .primary)
                        .onTapGesture {
                             if ingredientList == "e.g., Aqua, Glycerin, Salicylic Acid, Fragrance" {
                                 ingredientList = ""
                             }
                         }
                }

                Button("Add and Analyze Product") {
                    if !productName.isEmpty && !ingredientList.isEmpty && ingredientList != "e.g., Aqua, Glycerin, Salicylic Acid, Fragrance" {
                        productManager.addProduct(
                            name: productName,
                            ingredientListText: ingredientList,
                            currentSkinConditionPrediction: currentSkinPredictionForAnalysis
                        )
                        dismiss()
                    }
                }
                .disabled(productName.isEmpty || ingredientList.isEmpty || ingredientList == "e.g., Aqua, Glycerin, Salicylic Acid, Fragrance")
            }
            .navigationTitle("Add New Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MyProductsView_Previews: PreviewProvider {
    static var previews: some View {
        MyProductsView()
            .environmentObject(ProductManager())
            .environmentObject(SkinEntriesManager())
    }
}
