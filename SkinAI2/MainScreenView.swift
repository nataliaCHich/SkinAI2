import SwiftUI

struct MainScreenView: View {
    @AppStorage("storedUserName") private var userName: String = "Beautiful"
    @State private var showProfile = false
    // @State private var showCamera = false 
    @State private var selectedTab = 0
    // @StateObject var entriesManager = SkinEntriesManager()

    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    // First Tab - Home
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.pink.opacity(0.0)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 100)
                            
                            Text("Hi, \(userName)!")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .padding(.bottom, -5)
                           
                            WeeklyTrackerView()
                            
                            VStack(spacing: 20) {
                                NavigationLink(destination: MySkinView()) { // MySkinView will get entriesManager from environment
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
                    CameraView() // CameraView will get entriesManager from environment
                        .tabItem {
                            Image(systemName: "camera.fill")
                            Text("Camera")
                        }
                        .tag(1)
                    
                    // Third Tab - Calendar
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.pink.opacity(0.0)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        
                        Text("This page will be available soon")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                    .tag(2)
                }
                .accentColor(.blue)
                // .environmentObject(entriesManager)
                
                // Profile picture overlay (will be visible on all tabs)
                VStack {
                    HStack {
                        Button(action: {
                            selectedTab = 0 // Set tab to home
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue.opacity(0)) // This seems intentionally transparent
                                .padding(.leading, 20)
                        }
                        
                        Spacer()
                        
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
            .environmentObject(SkinEntriesManager())
    }
}
