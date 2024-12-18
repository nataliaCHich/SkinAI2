// Imports remain the same
import SwiftUI

struct MySkinView: View {
    @StateObject private var entriesManager = SkinEntriesManager()
    @State private var showingImagePicker = false
    @State private var showingDescriptionSheet = false
    @State private var tempImage: UIImage?
    @State private var tempDescription: String = ""
    
    var body: some View {
        NavigationView {
            List(entriesManager.entries) { entry in
                VStack(alignment: .leading) {
                    if let image = entriesManager.loadImage(for: entry) {
                        Image(uiImage: image)
                            .resizable()
                        
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    Text(entry.date.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(entry.description)
                        .padding(.top, 4)
                }
                .padding(.vertical)
            }
            .navigationTitle("My Skin Journal")
            .toolbar {
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
        .onChange(of: tempImage) { _ in
            if tempImage != nil {
                showingDescriptionSheet = true
            }
        }
        .sheet(isPresented: $showingDescriptionSheet) {
            NavigationView {
                VStack {
                    TextField("Add description", text: $tempDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    if let image = tempImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
                .navigationTitle("Add Description")
                .toolbar {
                    Button("Save") {
                        if let image = tempImage {
                            let entry = SkinEntry(
                                image: image,
                                date: Date(),
                                description: tempDescription
                            )
                            entriesManager.addEntry(entry)
                            tempImage = nil
                            tempDescription = ""
                            showingDescriptionSheet = false
                        }
                    }
                }
            }
        }
    }
}

// Preview remains the same
#Preview {
    MySkinView()
}

// End of file. No additional code.
