import SwiftUI

struct WeeklyTrackerView: View {
    // Properties
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var showTip = false
    @State private var checkedDays: Set<String> = [] // Add this property
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Skin Routine Tracker")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.horizontal)
                .transition(.opacity)
            
            HStack(spacing: 20) {
                ForEach(daysOfWeek, id: \.self) { day in
                    VStack(spacing: 5) {
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Replace Circle with Toggle
                        Button(action: {
                            if checkedDays.contains(day) {
                                checkedDays.remove(day)
                            } else {
                                checkedDays.insert(day)
                            }
                        }) {
                            Image(systemName: checkedDays.contains(day) ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Rest of the view remains the same
            Button(action: {
                showTip.toggle()
            }) {
                Text("💡 Daily Tip")
                    .foregroundColor(.blue)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
            }
            
            if showTip {
                Text("Remember to cleanse your face twice daily!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.8))
        .frame(maxWidth: 330)
        .cornerRadius(25)
    }
}


struct WeeklyTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyTrackerView()
    }
}


