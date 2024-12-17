//
//  firstScreenView.swift
//  SkinAI
//
//  Created by Chicherova Natalia2 on 15/12/24.
//


import SwiftUI

struct ContentView: View {

    @State private var showMainScreen = false
    
    var body: some View {
        
        ZStack {
     
            LinearGradient(gradient: Gradient(colors: [
                Color.blue.opacity(0.3),
                Color.blue.opacity(0.0)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
          
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                Text("Welcome to SkinAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(.top, -20)
                    .padding(.bottom, 30)
                
                Text("Smart skincare analysis,\ntailored just 4U!")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.blue.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 0)
                    .padding(.bottom, -100)
                
                Image("drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 600)
                    .padding(.bottom, -100)
                
                Button {
                    showMainScreen = true
                } label: {
                    Text("Let's Go!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.blue.opacity(0.4))
                        .cornerRadius(25)
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showMainScreen) {
            MainScreenView()
        }
    }
}

// Preview remains the same
#Preview {
    ContentView()
}
