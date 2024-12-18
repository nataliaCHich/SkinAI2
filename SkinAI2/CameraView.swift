import SwiftUI
import UIKit
import CoreML
import Vision

struct CameraView: View {
    @State private var showingCamera = false
    @State private var image: UIImage?
    @State private var predictionText: String = ""
    
    // Create a reference to  Core ML model
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
    
    // Add SkinAnalysisManager
    @StateObject private var analysisManager = SkinAnalysisManager()
    
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
                    
                    if !predictionText.isEmpty {
                        Button("Save Analysis") {
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
                    showingCamera = true
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
                    predictionText = "Prediction: \(topResult.identifier) - Confidence: \(topResult.confidence * 100)%"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
    
    // Add function to save analysis
    private func saveAnalysis(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Parse prediction text to get confidence
        let components = predictionText.components(separatedBy: "- Confidence: ")
        let prediction = components[0].replacingOccurrences(of: "Prediction: ", with: "")
        let confidenceString = components[1].replacingOccurrences(of: "%", with: "")
        let confidence = Double(confidenceString) ?? 0.0
        
        let analysis = SkinAnalysis(imageData: imageData,
                                    prediction: prediction,
                                    confidence: confidence/100.0)
        
        analysisManager.addAnalysis(analysis)
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
    }
}
