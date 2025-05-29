import SwiftUI
import PhotosUI // For PhotosPicker

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
                    Color.appBlue.opacity(0.3),
                    Color.appPink.opacity(0.0)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.standard) {
                    List {
                        ForEach(productManager.products) { product in
                            ProductRow(product: product)
                                .appCardStyle()
                                .listRowBackground(Color.clear) 
                                .listRowSeparator(.hidden) 
                                .padding(.bottom, DesignSystem.Spacing.medium)
                        }
                        .onDelete(perform: productManager.deleteProduct)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden) 

                    Button("Re-analyze Products for Current Skin") {
                        productManager.reanalyzeAllProducts(currentSkinConditionPrediction: currentSkinPrediction)
                    }
                    .buttonStyle(DesignSystem.AppPrimaryButtonStyle())
                    .padding(.horizontal) 
                    .padding(.bottom) 
                }
                .padding(.top)
            }
            .navigationTitle("My Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(Color.accent) 
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddProductSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.accent) 
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(product.name)
                .font(.headline)
                .foregroundColor(Color.primaryText)

            if let advice = product.advice {
                Text("Assessment for \(advice.forSkinCondition.rawValue): \(advice.assessment.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(colorForAssessment(advice.assessment)) 

                if !advice.positiveNotes.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                        Text("Good For You:").font(.caption.bold()).foregroundColor(Color.primaryText)
                        ForEach(advice.positiveNotes, id: \.self) { Text($0).font(.caption).foregroundColor(Color.secondaryText) }
                    }
                    .padding(.top, DesignSystem.Spacing.extraSmall)
                }
                if !advice.cautionaryNotes.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                        Text("Use with Caution:").font(.caption.bold()).foregroundColor(Color.primaryText)
                        ForEach(advice.cautionaryNotes, id: \.self) { Text($0).font(.caption).foregroundColor(Color.secondaryText) }
                    }
                    .padding(.top, DesignSystem.Spacing.extraSmall)
                }
            } else {
                Text("Not yet analyzed or analysis failed.")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
            }

            DisclosureGroup("Parsed Ingredients (\(product.analyzedIngredients?.count ?? 0))") {
                if let ingredients = product.analyzedIngredients, !ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                        ForEach(ingredients) { recognizedIng in
                            VStack(alignment: .leading) {
                                Text(recognizedIng.ingredientInfo.name)
                                    .font(.caption.bold())
                                    .foregroundColor(Color.primaryText)
                                if let desc = recognizedIng.ingredientInfo.description {
                                    Text(desc)
                                        .font(.caption2)
                                        .foregroundColor(Color.secondaryText)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } else {
                    Text("No ingredients recognized or list was empty.")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
            .font(.caption)
            .accentColor(Color.accent) 
        }
    }

    func colorForAssessment(_ assessment: ProductAdvice.OverallAssessment) -> Color {
        switch assessment {
        case .good: return Color.skinGood
        case .neutral: return Color.secondaryText 
        case .useWithCaution: return Color.orange 
        case .potentiallyAvoid: return Color.destructive 
        }
    }
}

struct AddProductView: View {
    @EnvironmentObject var productManager: ProductManager
    @Environment(\.dismiss) var dismiss

    @State private var productName: String = ""
    @State private var ingredientList: String = ""
    @State private var placeholderText: String = "e.g., Aqua, Glycerin, Salicylic Acid"
    
    let currentSkinPredictionForAnalysis: String

    @State private var showingCameraSheet = false
    @State private var imageForOCR: UIImage? = nil

    @State private var showScanIndicator = false
    @State private var scanErrorMessage: String? = nil

    private let ocrService = IngredientOCRService()

    var body: some View {
        NavigationView {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $productName)
                        .textFieldStyle(DesignSystem.AppTextFieldStyle())
                    
                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showingCameraSheet = true
                        } else {
                            scanErrorMessage = "Camera is not available on this device."
                        }
                    } label: {
                        Label("Scan Ingredients with Camera", systemImage: "camera")
                    }
                    .buttonStyle(DesignSystem.AppSecondaryButtonStyle()) 
                    
                    if showScanIndicator {
                        HStack {
                            ProgressView()
                            Text("Analyzing ingredients...")
                                .font(.subheadline) 
                                .foregroundColor(Color.secondaryText)
                        }
                    }
                    
                    if let errorMessage = scanErrorMessage {
                        Text(errorMessage)
                            .foregroundColor(Color.destructive) 
                            .font(.caption)
                    }

                    ZStack(alignment: .topLeading) {
                        if ingredientList.isEmpty {
                            Text(placeholderText)
                                .foregroundColor(Color(UIColor.placeholderText))
                                .font(.subheadline) 
                                .padding(DesignSystem.Spacing.medium) 
                                .padding(.leading, 5) 
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $ingredientList)
                            .frame(height: 200)
                            .font(.subheadline) 
                            .padding(DesignSystem.Spacing.small) 
                            .background(Color.subtleBackground)
                            .cornerRadius(DesignSystem.CornerRadius.standard)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.standard)
                                    .stroke(Color.subtleBorder, lineWidth: 1)
                            )
                    }
                    .padding(.top, DesignSystem.Spacing.small) 
                }

                Button("Add and Analyze Product") {
                    if !productName.isEmpty && !ingredientList.isEmpty {
                        productManager.addProduct(
                            name: productName,
                            ingredientListText: ingredientList,
                            currentSkinConditionPrediction: currentSkinPredictionForAnalysis
                        )
                        dismiss()
                    }
                }
                .buttonStyle(DesignSystem.AppPrimaryButtonStyle()) 
                .disabled(productName.isEmpty || ingredientList.isEmpty)
            }
            .navigationTitle("Add New Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.accent)
                }
            }
            .sheet(isPresented: $showingCameraSheet) {
                CustomImagePicker(image: $imageForOCR, sourceType: .camera)
            }
            .onChange(of: imageForOCR) { oldValue, newImage in
                 if let image = newImage {
                    scanErrorMessage = nil 
                    scanIngredients(from: image)
                    DispatchQueue.main.async { 
                        self.imageForOCR = nil
                    }
                }
            }
        }
    }

    private func scanIngredients(from image: UIImage) {
        showScanIndicator = true
        scanErrorMessage = nil
        ingredientList = ""

        ocrService.recognizeIngredients(from: image) { result in
            DispatchQueue.main.async {
                showScanIndicator = false
                
                switch result {
                case .success(let ingredients):
                    if ingredients.isEmpty {
                        scanErrorMessage = "No ingredients found in the image."
                        ingredientList = "" 
                    } else {
                        ingredientList = ingredients.joined(separator: ", ")
                    }
                case .failure(let error):
                    switch error {
                    case .imageProcessingError:
                        scanErrorMessage = "Error processing image."
                    case .recognitionFailed:
                        scanErrorMessage = "Ingredient recognition failed."
                    case .noTextFound:
                        scanErrorMessage = "No text found in the image to analyze."
                    }
                    ingredientList = "" 
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
            .preferredColorScheme(.light) 
        MyProductsView()
            .environmentObject(ProductManager())
            .environmentObject(SkinEntriesManager())
            .preferredColorScheme(.dark) 
    }
}
