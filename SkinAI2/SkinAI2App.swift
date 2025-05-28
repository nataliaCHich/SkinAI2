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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entriesManager)
        }
    }
}
