import SwiftUI

struct SkinCalendarView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    @State private var selectedDate: Date? = Date() // Keep track of the date the user taps
    @State private var month: Date = Date() // The month the calendar is currently displaying

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

    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 16.0, macOS 13.0, *) {
                    CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture), month: $month) { date in
                        let entriesForDate = entriesByDay[Calendar.current.startOfDay(for: date)] ?? []
                        ZStack(alignment: .bottomTrailing) {
                            Text(String(Calendar.current.component(.day, from: date)))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(6)
                                .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .primary)
                                .background {
                                    if Calendar.current.isDateInToday(date) {
                                        Circle().fill(Color.red)
                                    } else if selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!) {
                                        Circle().fill(Color.blue.opacity(0.3))
                                    }
                                }
                            
                            if !entriesForDate.isEmpty {
                                if let firstEntry = entriesForDate.first, let image = entriesManager.loadImage(for: firstEntry) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20) // Small thumbnail
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                        .offset(x: -2, y: -2) // Adjust position
                                } else {
                                    // Fallback indicator if no image or first entry is problematic
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .offset(x: -2, y: -2)
                                }
                            }
                        }
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal)

                    if let date = selectedDate, let entries = entriesByDay[Calendar.current.startOfDay(for: date)], !entries.isEmpty {
                        Text("Entries for \(date, style: .date)")
                            .font(.headline)
                            .padding(.top)
                        List(entries) { entry in
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
                    } else if let date = selectedDate {
                        Text("No entries for \(date, style: .date)")
                            .padding()
                    } else {
                         Text("Tap a date to see entries.")
                            .padding()
                    }


                } else {
                    Text("CalendarView requires iOS 16+ or macOS 13+.")
                        .foregroundColor(.red)
                        .padding()
                }
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