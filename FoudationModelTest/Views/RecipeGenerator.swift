//
//  RecipeGenerator.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//
import SwiftUI

struct RecipeGenerator: View {
    @EnvironmentObject private var vm: ContentViewModel
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // MARK: Input Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Ingredients", systemImage: "basket")
                                    .font(.headline)
                                Spacer()
                                Button(action: { vm.clearIngredients() }) {
                                    Image(systemName: "trash")
                                }
                                .font(.subheadline)
                                .disabled(vm.ingredientsInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGenerating)
                            }
                            
                            Text("One per line (e.g. pork, honey, corn flakes)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $vm.ingredientsInput)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(10)
                                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                )
                                .disabled(vm.isGenerating)
                            
                            Text("The recipe may not be 100% accurate, but it should get you started! Try again if the results aren't what you're looking for.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.regularMaterial)
                        )
                        
                        // MARK: Style Picker as chips
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Style", systemImage: "sparkles")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(vm.availableStyles, id: \.self) { style in
                                        let title = style.isEmpty ? "Any" : style
                                        Chip(
                                            title: title,
                                            isSelected: vm.selectedStyle == style
                                        ) {
                                            vm.selectedStyle = style
                                            
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            .disabled(vm.isGenerating)
                            
                            GenerateBar(
                                   isGenerating: vm.isGenerating,
                                   canGenerate: vm.canGenerate,
                                   hasRecipe: vm.partiallyGeneratedRecipe != nil && !vm.currentRecipeWasSaved,
                                   action: { Task { await vm.generateRecipes() } },
                                   addAction: { vm.addCurrentRecipe() }
                               )
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.regularMaterial)
                        )
                        
                        // MARK: Result
                        if let errorMessage = vm.errorMessage {
                            ErrorBanner(text: errorMessage)
                        }
                        
                        if vm.isGenerating && vm.partiallyGeneratedRecipe == nil {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Generating your recipe…")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                        }
                        else if !vm.isGenerating && vm.partiallyGeneratedRecipe == nil {
                            VStack(spacing: 14) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.quaternary)
                                Text("No recipe generated yet.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Enter some ingredients and tap Generate Recipe to get started!")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                        }
                        
                        if vm.partiallyGeneratedRecipe != nil {
                            RecipeCard(partial: vm.partiallyGeneratedRecipe!, isGenerating: vm.isGenerating)
                        }

                        // Invisible bottom anchor
                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                    .padding()
                }
                .navigationTitle("Recipe Generator")
                .navigationBarTitleDisplayMode(.large)
                .onReceive(vm.$partiallyGeneratedRecipe) { _ in
                    guard vm.isGenerating else { return }
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
                .onReceive(vm.$isGenerating) { generating in
                    if generating {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("BOTTOM", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

private func scrollToBottom(_ proxy: ScrollViewProxy) {
    withAnimation(.easeOut(duration: 0.25)) {
        proxy.scrollTo("BOTTOM", anchor: .bottom)
    }
}
