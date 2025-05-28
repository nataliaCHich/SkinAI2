//
//  SkinAI2App.swift
//  SkinAI2
//
//  Created by Chicherova Natalia2 on 17/12/24.
//

import SwiftUI

@main
struct SkinAI2App: App {
    @StateObject var entriesManager = SkinEntriesManager()
    @StateObject var productManager = ProductManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entriesManager)
                .environmentObject(productManager)
        }
    }
}
