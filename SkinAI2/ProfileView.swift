// Imports remain the same
import SwiftUI

struct ProfileView: View {
    // Environment variable remains the same
    @Environment(\.dismiss) private var dismiss
    
    // State variables
    @AppStorage("storedUserName") private var userName: String = "Beautiful"
    @AppStorage("userAge") private var userAge: String = ""
    @State private var showingSavedAlert = false
    @State private var isEditing = true
    @State private var temporaryName = ""
    @State private var temporaryAge = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient remains the same
                LinearGradient(gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.pink.opacity(0.0)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Profile image remains the same
                    Button(action: {
                        // Image picker action here
                    }) {
                        Image("drop")
                            .resizable()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.blue)
                    }
                    
                    // User info section
                    VStack(alignment: .leading, spacing: 20) {
                        // Name field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                            
                            if isEditing {
                                TextField("Enter your name", text: $temporaryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 5)
                                    .frame(maxWidth: 300)
                            } else {
                                Text(userName)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 5)
                            }
                        }
                        
                        // Age field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Age")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                            
                            if isEditing {
                                TextField("Enter your age", text: $temporaryAge)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 5)
                                    .frame(maxWidth: 300)
                                    .keyboardType(.numberPad)
                            } else {
                                Text(userAge)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 5)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {
                            if !isEditing {
                                temporaryName = userName
                                temporaryAge = userAge
                                isEditing = true
                            }
                        }
                    }
                    
                    // Save button
                    if isEditing {
                        Button(action: {
                            if temporaryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                userName = "Beautiful"
                            } else {
                                userName = temporaryName
                            }
                            userAge = temporaryAge
                            withAnimation {
                                isEditing = false
                                showingSavedAlert = true
                                temporaryName = ""
                                temporaryAge = ""
                            }
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Alert message remains the same
                    if showingSavedAlert {
                        Text("Profile saved!")
                            .foregroundColor(.blue)
                            .font(.callout)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showingSavedAlert = false
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                }
            }
            // Toolbar remains the same
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                isEditing = userName == "Beautiful" && userAge.isEmpty
            }
        }
    }
}

// Preview remains the same
struct profileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// End of file
