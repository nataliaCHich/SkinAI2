import SwiftUI

struct WeeklyTrackerView: View {
    // Properties
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var showTip = false
    @State private var checkedDays: Set<String> = [] 
    @State private var currentDailyTip: String = "Remember to cleanse your face twice daily!" 

    private let fiveGeneralSkincareTips: [String] = [
        "Stay hydrated by drinking plenty of water.",
        "Always remove makeup before bed.",
        "Get 7-9 hours of sleep for skin regeneration.",
        "Use SPF 30+ sunscreen daily, even indoors.",
        "Moisturize your skin morning and night."
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Skin Routine Tracker")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ForEach(daysOfWeek, id: \.self) { day in
                    VStack(spacing: 5) {
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
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
            
            Button(action: {
                if !fiveGeneralSkincareTips.isEmpty {
                    var newTip = currentDailyTip
                    if fiveGeneralSkincareTips.count > 1 { 
                        while newTip == currentDailyTip {
                            newTip = fiveGeneralSkincareTips.randomElement()! 
                        }
                    } else if !fiveGeneralSkincareTips.isEmpty {
                        newTip = fiveGeneralSkincareTips.first!
                    }
                    currentDailyTip = newTip
                }
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
                Text(currentDailyTip)
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
