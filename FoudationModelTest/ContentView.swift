//
//  ContentView.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: ContentViewModel
    
    var body: some View {
        TabView {
            RecipeGenerator()
               .environmentObject(vm)
               .tabItem {
                   Label("Generate", systemImage: "wand.and.stars")
               }
            RecipeList()
                .environmentObject(vm)
                .tabItem {
                    Label("Your recipes", systemImage: "book")
                }

            
       }
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentViewModel(useMock: true))
        .frame(width: 400)
}
