//
//  RecipeList.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//
import SwiftUI

struct RecipeList: View {
    @EnvironmentObject private var vm: ContentViewModel
    
    var body: some View {
        Group {
            if vm.savedRecipes.isEmpty {
                ContentUnavailableView(
                    "Your recipes",
                    systemImage: "book",
                    description: Text("Recipes you add will appear here.")
                )
            } else {
                List {
                    ForEach(vm.savedRecipes) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.recipe.name)
                                .font(.headline)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { idx in
                        vm.savedRecipes.remove(atOffsets: idx)
                    }
                }
            }
        }
        .navigationTitle("Your recipes")
        .navigationBarTitleDisplayMode(.large)
    }
}
