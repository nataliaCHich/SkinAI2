import SwiftUI

struct MySkinView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    @State private var showingImagePicker = false
    @State private var showingDescriptionSheet = false
    @State private var tempImage: UIImage?
    @State private var tempDescription: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
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
                            ZStack { 
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)

                                VStack(alignment: .center, spacing: 8) { 
                                    if let image = entriesManager.loadImage(for: entry) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(15)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.date.formatted())
                                            .font(.caption)
                                            .foregroundColor(.blue)

                                        Text(entry.description)
                                            .foregroundColor(.blue)
                                            .lineLimit(nil) 
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text("Confidence: \(String(format: "%.1f%%", entry.confidence * 100))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading) 
                                }
                                .padding()
                                .frame(maxWidth: .infinity) 
                            }
                            .padding(.vertical, 8)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: entriesManager.deleteEntries)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
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

    private func deleteEntry(at offsets: IndexSet) {
        entriesManager.deleteEntries(at: offsets)
    }
}

struct DescriptionSheetView: View {
    @Binding var tempImage: UIImage?
    @Binding var tempDescription: String
    @Binding var showingDescriptionSheet: Bool
    @EnvironmentObject var entriesManager: SkinEntriesManager
    @StateObject private var analysisManager = SkinAnalysisManager()

    var body: some View {
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
                List(analysisManager.analyses) { analysis in
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
                .navigationTitle("Skin Analysis Details")
            }
            .navigationTitle("Add New Skin Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        tempImage = nil
                        tempDescription = ""
                        showingDescriptionSheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let image = tempImage {
                            let entry = SkinEntry(
                                image: image,
                                date: Date(),
                                description: tempDescription,
                                confidence: 0.0
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
