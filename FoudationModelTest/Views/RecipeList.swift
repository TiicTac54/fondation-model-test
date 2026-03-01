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
        content
            .navigationTitle("Your recipes")
            .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var content: some View {
        if vm.savedRecipes.isEmpty {
            ContentUnavailableView(
                "Your recipes",
                systemImage: "book",
                description: Text("Recipes you add will appear here.")
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your recipes")
                        .font(.title2).bold()
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    LazyVStack(spacing: 12) {
                        ForEach(vm.savedRecipes) { item in
                            RecipeRow(item: item) {
                                if let index = vm.savedRecipes.firstIndex(where: { $0.id == item.id }) {
                                    vm.savedRecipes.remove(at: index)
                                }
                            }
                        }
                        .animation(.default, value: vm.savedRecipes.count)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

private struct RecipeRow: View {
    let item: SavedRecipe // Assuming the element type of vm.savedRecipes
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.recipe.name)
                .font(.headline)
                .foregroundStyle(.primary)

            // Servings (placeholder until strongly-typed model is wired)
            Text("Servings: \(item.recipe.servings)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            nutritionTags
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                // Base card fill
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))

                // Kind-based radial glow from top-right
                GeometryReader { geo in
                    let size = max(geo.size.width, geo.size.height)
                    RadialGradient(
                        gradient: Gradient(colors: [kindTint(for: item.recipe.kind).opacity(0.25), .clear]),
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            KindBadge(kind: item.recipe.kind)
                .padding(10)
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var nutritionTags: some View {
        HStack(spacing: 6) {
            Tag(icon: "flame",
                 text: "\(item.recipe.nutrition.totalCalories.formatted(.number.precision(.fractionLength(0...2)))) kcal",
                 tint: .orange)
            Tag(icon: "dumbbell",
                 text: "\(item.recipe.nutrition.proteinGramsPerServing.formatted(.number.precision(.fractionLength(0...2)))) g",
                 tint: .blue)
            Tag(icon: "leaf",
                 text: "\(item.recipe.nutrition.carbsGramsPerServing.formatted(.number.precision(.fractionLength(0...2)))) g",
                 tint: .green)
            Tag(icon: "drop",
                 text: "\(item.recipe.nutrition.fatGramsPerServing.formatted(.number.precision(.fractionLength(0...2)))) g",
                 tint: .purple)
        }
    }
}

private struct KindBadge: View {
    let kind: Kind

    var body: some View {
        Image(systemName: kindIcon(for: kind))
            .imageScale(.small)
            .foregroundStyle(.white)
            .padding(6)
            .background(
                Circle().fill(kindTint(for: kind))
            )
            .accessibilityLabel(Text("\(String(describing: kind).capitalized)"))
    }
}

private func kindTint(for kind: Kind) -> Color {
    switch kind {
    case .meal: return .red
    case .dessert: return .teal
    case .breakfast: return .yellow
    case .unspecified: return .gray
    }
}

private func kindIcon(for kind: Kind) -> String {
    switch kind {
    case .meal: return "fork.knife"
    case .dessert: return "birthday.cake"
    case .breakfast: return "cup.and.saucer"
    case .unspecified: return "questionmark"
    }
}

#Preview {
    RecipeList()
        .environmentObject(ContentViewModel(useMock: true))
}

