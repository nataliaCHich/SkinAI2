import SwiftUI

struct MainScreenView: View {
    @AppStorage("storedUserName") private var userName: String = "Beautiful"
    @State private var showProfile = false
    @State private var showCamera = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            // Main ZStack to hold both TabView and profile picture
            ZStack {
                // TabView content remains the same but add selection binding
                TabView(selection: $selectedTab) {
                    // First Tab - Timeline
                    ZStack {
                        // Gradient remains the same
                        LinearGradient(gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.pink.opacity(0.0)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        
                    
                    //HOME VIEW CONTENT
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 100)
                            
                            Text("Hi, \(userName)!")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .padding(.bottom, -5)
                           
                            WeeklyTrackerView()
                            
                            // Buttons with matching width
                            VStack(spacing: 20) {
                                NavigationLink(destination: MySkinView()) {
                                    Text("My Skin")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: 330)
                                        .padding(.vertical, 15)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(15)
                                }
                                
                                NavigationLink(destination: MyProductsView()) {
                                    Text("My Products")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: 330)
                                        .padding(.vertical, 15)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }

                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    // Second Tab - Camera
                    ZStack {
                        // Gradient remains the same
                        LinearGradient(gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.pink.opacity(0.0)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        
                        // Add your camera content here
                       
                    }
                    .tabItem {
                        Image(systemName: "camera.fill")
                        Text("Camera")
                    }
                    .tag(1)
                    
                    // Third Tab - Calendar
                    ZStack {
                        // Gradient remains the same
                        LinearGradient(gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.pink.opacity(0.0)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        
                        // Add your calendar content here
                        Text("Calendar View")
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                    .tag(2)
                }
                .accentColor(.blue)
                
                // Profile picture overlay (will be visible on all tabs)
                VStack {
                    HStack {
                        // Home button
                        Button(action: {
                            selectedTab = 0 // Set tab to home
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue.opacity(0))
                                .padding(.leading, 20)
                        }
                        
                        Spacer()
                        
                        // Convert profile image to button
                        Button(action: {
                            showProfile = true
                        }) {
                            Image("drop")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.blue)
                                .padding(.trailing, -50)
                        }
                    }
                    .padding(.top, -40)
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

struct mainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
