import SwiftUI

struct SkinCalendarView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    @State private var selectedDate: Date = Date() // Keep track of the date the user picks

    // Group entries by day for faster lookup
    private var entriesByDay: [Date: [SkinEntry]] {
        var grouped: [Date: [SkinEntry]] = [:]
        let calendar = Calendar.current
        for entry in entriesManager.entries {
            let startOfDay = calendar.startOfDay(for: entry.date)
            grouped[startOfDay, default: []].append(entry)
        }
        return grouped
    }
    
    private var entriesForSelectedDate: [SkinEntry] {
        entriesByDay[Calendar.current.startOfDay(for: selectedDate)] ?? []
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                // Display entries for the selected date
                if !entriesForSelectedDate.isEmpty {
                    Text("Entries for \(selectedDate, style: .date)")
                        .font(.headline)
                        .padding(.top)
                    List(entriesForSelectedDate) { entry in
                        HStack {
                            if let image = entriesManager.loadImage(for: entry) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            }
                            VStack(alignment: .leading) {
                                Text(entry.description).font(.caption).lineLimit(1)
                                Text("Confidence: \(String(format: "%.1f%%", entry.confidence * 100))").font(.caption2)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Text("No entries for \(selectedDate, style: .date)")
                        .padding()
                }
                Spacer() // Pushes content to the top
            }
            .navigationTitle("Skin Journal Calendar")
        }
    }
}

struct SkinCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = SkinEntriesManager()
        // Add a dummy entry for preview
        if let dummyImage = UIImage(systemName: "photo") {
             let entry1 = SkinEntry(image: dummyImage, date: Date(), description: "Today's skin", confidence: 0.8)
             let entry2 = SkinEntry(image: dummyImage, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, description: "Skin two days ago", confidence: 0.6)
             manager.addEntry(entry1)
             manager.addEntry(entry2)
        }
       
        return SkinCalendarView()
            .environmentObject(manager)
    }
}
