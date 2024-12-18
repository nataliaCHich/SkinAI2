import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    // Create a reference to your Core ML model
    var model: VNCoreMLModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the model with error handling
        do {
            let modelConfig = MLModelConfiguration()
            let coreMLModel = try Condition3(configuration: modelConfig)
            model = try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print("Error initializing model: \(error)")
        }
    }
    
    // Action to launch camera for taking a picture
    @IBAction func takePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    // Action for upload button
    @IBAction func uploadPicture(_ sender: UIButton) {
        guard let image = selectedImage else { return }
        
        // Process image with Core ML
        classifyImage(image)
    }
    
    // This variable will hold the selected image
    var selectedImage: UIImage?
    
    // UIImagePickerController delegate method when the picture is taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func classifyImage(_ image: UIImage) {
        // Convert the image to the format your model expects
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to convert UIImage to CIImage")
        }
        
        // Create a request handler with your model
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results, let topResult = results.first as? VNClassificationObservation {
                // Update the UI with the classification result
                DispatchQueue.main.async {
                    self.resultLabel.text = "Prediction: \(topResult.identifier) - Confidence: \(topResult.confidence * 100)%"
                }
            }
        }
        
        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}
