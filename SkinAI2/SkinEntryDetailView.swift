import SwiftUI

struct SkinEntryDetailView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    let entry: SkinEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if let image = entriesManager.loadImage(for: entry) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                } else {
                    ContentUnavailableView("Image Not Found", systemImage: "photo.on.rectangle.angled")
                        .frame(height: 200)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date:")
                        .font(.headline)
                    Text(entry.date, style: .date) + Text(" at ") + Text(entry.date, style: .time)
                        .font(.subheadline)

                    Divider()

                    Text("Analysis / Description:")
                        .font(.headline)
                    Text(entry.description)
                        .font(.body)
                    
                    Divider()

                    Text("Confidence:")
                        .font(.headline)
                    Text(String(format: "%.1f%%", entry.confidence * 100))
                        .font(.subheadline)
                }
                .padding()
                .background(Color.gray.opacity(0.1).cornerRadius(10))
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Optional: Preview Provider
// struct SkinEntryDetailView_Previews: PreviewProvider {
//     static var previews: some View {
//         // You'd need a sample entry and a configured entriesManager
//         // For now, we'll skip the complex preview setup for this detail view.
//         // Consider creating one if you frequently work on this view.
//         Text("Preview needs setup")
//     }
// }