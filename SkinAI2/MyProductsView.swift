//
//  MyProductsView.swift
//  SkinAI2
//
//  Created by Chicherova Natalia2 on 17/12/24.
//

import SwiftUI

struct MyProductsView: View {
    var body: some View {
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
    }
}

#Preview {
    MyProductsView()
}
