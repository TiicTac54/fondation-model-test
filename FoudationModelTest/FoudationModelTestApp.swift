//
//  FoudationModelTestApp.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//

import SwiftUI

@main
struct FoudationModelTestApp: App {
    @StateObject private var vm = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}

