import SwiftUI
import CoreML
import Vision

struct MySkinView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    @State private var showingImagePicker = false
    @State private var showingDescriptionSheet = false
    @State private var tempImage: UIImage?
    @State private var tempDescription: String = ""

    var body: some View {
        // NavigationView is already here from the parent if MySkinView is a destination of NavigationLink
        // If MySkinView is presented as a root of a tab that should have its own nav bar,
        // then a NavigationView here is appropriate. Assuming it's part of MainScreenView's NavStack.

        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                if #available(iOS 16.0, macOS 13.0, *) {
                    SkinTrendChartView() // EnvironmentObject entriesManager will be passed automatically
                        .padding(.bottom) // Add some spacing below the chart
                } else {
                    Text("Skin trend chart requires iOS 16+.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }

                // Comparison text - unchanged
                if entriesManager.entries.count >= 2 {
                    Text("Recent Skin Trend: \(entriesManager.compareLastTwoEntriesConfidence().rawValue)")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.blue)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top)
                } else if !entriesManager.entries.isEmpty {
                    Text("Add one more entry to see skin trend.")
                        .font(.subheadline)
                        .padding()
                        .foregroundColor(.gray)
                }

                List {
                    ForEach(entriesManager.entries) { entry in
                        NavigationLink(destination: SkinEntryDetailView(entry: entry).environmentObject(entriesManager)) {
                            HStack { // Content of the row
                                if let image = entriesManager.loadImage(for: entry) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60) // Smaller thumbnail in list
                                        .cornerRadius(8)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.blue)

                                    Text(entry.description)
                                        .font(.callout)
                                        .foregroundColor(.blue)
                                        .lineLimit(2) // Limit lines in the list view

                                    Text("Confidence: \(String(format: "%.1f%%", entry.confidence * 100))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer() // Pushes content to left, chevron to right
                            }
                            .padding(.vertical, 4)
                        }
                        // Remove custom ZStack and RoundedRectangle for default List row appearance with NavigationLink
                        .listRowBackground(Color.white.opacity(0.8).cornerRadius(10)) // Optional: style the row
                        .padding(.vertical, 4) // Spacing between styled rows
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: entriesManager.deleteEntries)
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle()) // Or InsetGroupedListStyle for more defined rows
            }
        }
        .navigationTitle("My Skin Journal")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "camera")
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $tempImage)
        }
        .onChange(of: tempImage) { oldValue, newValue in
            if newValue != nil {
                showingDescriptionSheet = true
            }
        }
        .sheet(isPresented: $showingDescriptionSheet) {
            DescriptionSheetView(tempImage: $tempImage, tempDescription: $tempDescription, showingDescriptionSheet: $showingDescriptionSheet)
                .environmentObject(entriesManager)
        }
    }
}

struct DescriptionSheetView: View {
    @Binding var tempImage: UIImage?
    @Binding var tempDescription: String // This will be pre-filled and editable
    @Binding var showingDescriptionSheet: Bool
    @EnvironmentObject var entriesManager: SkinEntriesManager
    // The existing analysisManager seems for displaying a list of *other* past analyses.
    // We will add new state for the current image's analysis.
    @StateObject private var localAnalysisManager = SkinAnalysisManager() // Keep if used by the List below

    @State private var mlModel: VNCoreMLModel? = {
        do {
            let modelConfig = MLModelConfiguration()
            // Ensure Condition3 model class is accessible here
            let coreMLModel = try Condition3(configuration: modelConfig)
            return try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print("Error initializing model in DescriptionSheetView: \(error)")
            return nil
        }
    }()
    @State private var analysisResultText: String = "" // For displaying the "Prediction: X - Confidence: Y%" string
    @State private var analysisDerivedConfidence: Double = 0.0 // For saving the 0.0-1.0 confidence
    @State private var isAnalyzing: Bool = false
    @State private var analysisAttempted: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = tempImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(15)
                        .padding()
                    
                    if isAnalyzing {
                        ProgressView("Analyzing image...")
                            .padding()
                    } else if analysisAttempted && !analysisResultText.isEmpty {
                        Text(analysisResultText) // Display full analysis string
                            .font(.caption)
                            .padding([.leading, .trailing, .bottom])
                    } else if analysisAttempted {
                        Text("Could not analyze image. Please add a manual description.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding([.leading, .trailing, .bottom])
                    }
                }
                
                TextField("Description", text: $tempDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onAppear {
                        // If description is empty and analysis result is available, pre-fill
                        if tempDescription.isEmpty && !analysisResultText.isEmpty && analysisAttempted {
                            tempDescription = analysisResultText
                        }
                    }

                // This List seems to display other historical analyses.
                // It is separate from the analysis of the current `tempImage`.
                // If it's not relevant to *adding a new entry*, consider removing or clarifying its purpose.
                // For now, I'm leaving it as you had it.
                List(localAnalysisManager.analyses) { analysis in
                    VStack(alignment: .leading, spacing: 10) {
                        if let uiImage = UIImage(data: analysis.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                        Text("Prediction: \(analysis.prediction)")
                            .font(.headline)
                        Text("Confidence: \(analysis.confidence * 100, specifier: "%.1f")%")
                            .font(.subheadline)
                        Text("Date: \(analysis.date.formatted())")
                            .font(.caption)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Skin Analysis Details") // This title might be confusing if sheet is "Add New Skin Entry"

                Spacer()
            }
            .onAppear {
                performAnalysis()
            }
            // If tempImage can change while the sheet is presented (e.g. via another picker inside)
            // .onChange(of: tempImage) { _ in performAnalysis() }
            .navigationTitle("Add New Skin Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        resetSheetState()
                        showingDescriptionSheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let image = tempImage {
                            // Use the derived confidence and the (potentially edited) description
                            let finalDescription = tempDescription.isEmpty ? (analysisResultText.isEmpty ? "Manual Entry" : analysisResultText) : tempDescription
                            let entry = SkinEntry(
                                image: image,
                                date: Date(),
                                description: finalDescription,
                                confidence: analysisDerivedConfidence
                            )
                            entriesManager.addEntry(entry)
                            resetSheetState()
                            showingDescriptionSheet = false
                        }
                    }
                    .disabled(isAnalyzing || tempImage == nil)
                }
            }
        }
    }

    private func performAnalysis() {
        guard let image = tempImage, !isAnalyzing, !analysisAttempted else {
            // If no image, or already analyzing, or analysis already attempted, do nothing.
            // If analysisAttempted is true, it means we won't re-analyze automatically.
            // User can still edit description.
            if tempImage != nil && analysisAttempted && tempDescription.isEmpty && !analysisResultText.isEmpty {
                 // Pre-fill description if it's empty and analysis was done
                tempDescription = analysisResultText
            }
            return
        }
        
        guard let model = mlModel else {
            self.analysisResultText = "ML Model not available."
            self.tempDescription = "ML Model error. Manual description needed."
            self.analysisAttempted = true
            return
        }
        guard let ciImage = CIImage(image: image) else {
            self.analysisResultText = "Could not process image."
            self.tempDescription = "Image processing error. Manual description needed."
            self.analysisAttempted = true
            return
        }
        
        isAnalyzing = true
        // tempDescription = "" // Clear manual description for pre-fill, or let user type while analyzing

        let request = VNCoreMLRequest(model: model) { request, error in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.analysisAttempted = true
                if let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first {
                    let identifier = topResult.identifier
                    let confidenceValue = Double(topResult.confidence)
                    
                    self.analysisResultText = "Prediction: \(identifier) - Confidence: \(String(format: "%.1f", confidenceValue * 100))%"
                    self.analysisDerivedConfidence = confidenceValue
                    // Pre-fill description only if it's currently empty
                    if self.tempDescription.isEmpty {
                        self.tempDescription = self.analysisResultText
                    }
                } else {
                    self.analysisResultText = "Analysis failed or no results. Please add a manual description."
                    self.analysisDerivedConfidence = 0.0
                    if self.tempDescription.isEmpty {
                         self.tempDescription = "Analysis failed."
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.analysisAttempted = true
                    self.analysisResultText = "Error performing analysis: \(error.localizedDescription). Please add a manual description."
                    self.analysisDerivedConfidence = 0.0
                     if self.tempDescription.isEmpty {
                        self.tempDescription = "Analysis error."
                    }
                }
            }
        }
    }
    
    private func resetSheetState() {
        tempImage = nil
        tempDescription = ""
        analysisResultText = ""
        analysisDerivedConfidence = 0.0
        isAnalyzing = false
        analysisAttempted = false
    }
}
