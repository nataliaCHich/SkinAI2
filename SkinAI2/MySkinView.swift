import SwiftUI

struct MySkinView: View {
    @StateObject private var entriesManager = SkinEntriesManager()
    @State private var showingImagePicker = false
    @State private var showingDescriptionSheet = false
    @State private var tempImage: UIImage?
    @State private var tempDescription: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                 List {
                    ForEach(entriesManager.entries) { entry in
                        VStack(alignment: .leading) {
                            if let image = entriesManager.loadImage(for: entry) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(15)
                            }

                            Text(entry.date.formatted())
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text(entry.description)
                                .padding(.top, 4)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .onDelete(perform: entriesManager.deleteEntries) // Add delete functionality
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle()) // Cleaner list style
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Skin Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton() // Adds edit mode for swipe-to-delete
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "camera")
                    }
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
            NavigationView {
                VStack {
                    TextField("Add description", text: $tempDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding()

                    if let image = tempImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
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

    // Function to delete an entry
    private func deleteEntry(at offsets: IndexSet) {
        entriesManager.deleteEntries(at: offsets)
    }
}
