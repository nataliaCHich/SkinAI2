import SwiftUI
import UIKit
import CoreML
import Vision

struct CameraView: View {
    @State private var showingCamera = false
    @State private var image: UIImage?
    @State private var predictionText: String = ""
    @State private var classifiedIdentifier: String? = nil
    @State private var classifiedConfidence: Double? = nil // Store as 0.0-1.0
    
    private var model: VNCoreMLModel? = {
        do {
            let modelConfig = MLModelConfiguration()
            let coreMLModel = try Condition3(configuration: modelConfig)
            return try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print("Error initializing model: \(error)")
            return nil
        }
    }()
    
    @StateObject private var analysisManager = SkinAnalysisManager()
    @EnvironmentObject var entriesManager: SkinEntriesManager
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color.blue.opacity(0.3),
                Color.pink.opacity(0.0)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(15)
                        
                    
                    Text(predictionText)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Button("Analyze Image") {
                        if let model = model {
                            classifyImage(image, model: model)
                        }
                    }
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(maxWidth: 330)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                    
                    if classifiedIdentifier != nil && classifiedConfidence != nil {
                        Button("Save Analysis & Add to Journal") {
                            saveAnalysis(image)
                        }
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(maxWidth: 330)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .padding()
                    }
                }
                
                Button("Take Photo") {
                    self.image = nil
                    self.predictionText = ""
                    self.classifiedIdentifier = nil
                    self.classifiedConfidence = nil
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showingCamera = true
                    } else {
                        print("Camera is not available on this device.")
                    }
                }
                .font(.title2)
                .foregroundColor(.blue)
                .frame(maxWidth: 330)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .padding()
                .sheet(isPresented: $showingCamera) {
                    CustomImagePicker(image: $image, sourceType: .camera)
                }
            }
        }
    }
    
    private func classifyImage(_ image: UIImage, model: VNCoreMLModel) {
        guard let ciImage = CIImage(image: image) else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                DispatchQueue.main.async {
                    let identifier = topResult.identifier
                    let confidenceValue = Double(topResult.confidence) // This is 0.0-1.0
                    
                    self.classifiedIdentifier = identifier
                    self.classifiedConfidence = confidenceValue
                    
                    // predictionText is just for display
                    self.predictionText = "Prediction: \(identifier) - Confidence: \(String(format: "%.1f", confidenceValue * 100))%"
                }
            } else {
                DispatchQueue.main.async {
                    self.predictionText = "Analysis failed or no results."
                    self.classifiedIdentifier = nil
                    self.classifiedConfidence = nil
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                predictionText = "Error performing analysis: \(error.localizedDescription)"
                self.classifiedIdentifier = nil
                self.classifiedConfidence = nil
            }
        }
    }
    
    private func saveAnalysis(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let prediction = self.classifiedIdentifier,
              let confidenceForStorage = self.classifiedConfidence else {
            print("Cannot save analysis: classification data is missing or image data is invalid.")
            return
        }
        
        // prediction (String) and confidenceForStorage (Double 0.0-1.0) are now directly from state, no parsing needed.

        let analysis = SkinAnalysis(imageData: imageData,
                                    prediction: prediction,
                                    confidence: confidenceForStorage)
        analysisManager.addAnalysis(analysis)
        
        // Construct description for SkinEntry from the reliable data
        let skinEntryDescription = "Prediction: \(prediction) - Confidence: \(String(format: "%.1f", confidenceForStorage * 100))%"
        
        let newSkinEntry = SkinEntry(image: image,
                                     date: Date(),
                                     description: skinEntryDescription,
                                     confidence: confidenceForStorage)
        self.entriesManager.addEntry(newSkinEntry)

        // Optionally, provide feedback and clear results
        self.predictionText = "Saved!"
        // self.image = nil // You might want to clear the image or navigate away
        // self.classifiedIdentifier = nil // Cleared when taking a new photo or if analysis fails
        // self.classifiedConfidence = nil
    }
}

// Renamed to CustomImagePicker to avoid ambiguity
struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomImagePicker
        
        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Preview provider
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .environmentObject(SkinEntriesManager())
    }
}
