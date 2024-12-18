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
                         ZStack {
                             RoundedRectangle(cornerRadius: 15) // Rounded corners for the row
                                 .fill(Color.white) // Background color
                                 .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)

                             VStack(alignment: .leading, spacing: 8) {
                                 if let image = entriesManager.loadImage(for: entry) {
                                     Image(uiImage: image)
                                         .resizable()
                                         .scaledToFit()
                                         .frame(height: 200)
                                         .cornerRadius(15) // Rounded corners for images
                                 }

                                 Text(entry.date.formatted())
                                     .font(.caption)
                                     .foregroundColor(.blue)

                                 Text(entry.description)
                                     .foregroundColor(.blue)
                             }
                             .padding()
                         }
                         .padding(.vertical, 8) // Add spacing between rows
                         .listRowSeparator(.hidden) // Optional: Hide separators
                         .listRowBackground(Color.clear) // Clear default list row background
                     }
                     .onDelete(perform: entriesManager.deleteEntries) // Enable delete functionality
                 }
                 .scrollContentBackground(.hidden) // Remove default list background

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
