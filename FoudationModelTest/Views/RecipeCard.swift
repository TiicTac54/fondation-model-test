import SwiftUI

struct RecipeCard: View {
    let partial: Recipe.PartiallyGenerated
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(partial.name ?? "Generating recipe…")
                        .font(.title2.weight(.bold))
                    if let servings = partial.servings {
                        Text("Servings: \(servings)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if isGenerating {
                        Text("Servings: …")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isGenerating {
                    Image(systemName: "bolt.horizontal.fill")
                        .foregroundStyle(.tint)
                        .symbolEffect(.pulse)
                }
            }

            if let n = partial.nutrition {
                NutritionGrid(n: n)
            } else if isGenerating {
                NutritionGridSkeleton()
            }

            Divider()

            // Ingredients
            VStack(alignment: .leading, spacing: 8) {
                Label("Ingredients", systemImage: "list.bullet")
                    .font(.headline)

                let ings = partial.ingredients ?? []
                if ings.isEmpty && isGenerating {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.gray.opacity(0.17))
                                    .frame(width: 28, height: 18)
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.gray.opacity(0.13))
                                    .frame(width: 120, height: 18)
                            }
                        }
                    }
                } else if ings.isEmpty {
                    Text("• …").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(ings.enumerated()), id: \.offset) { _, ing in
                        Text("• \((ing.quantity ?? "…")) \(ing.name ?? "…")")
                            .font(.body)
                    }
                }
            }

            Divider()

            // Steps
            VStack(alignment: .leading, spacing: 8) {
                Label("Steps", systemImage: "checklist")
                    .font(.headline)

                let steps = partial.steps ?? []
                if steps.isEmpty && isGenerating {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<3, id: \.self) { idx in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.gray.opacity(0.17))
                                    .frame(width: 18, height: 18)
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.gray.opacity(0.13))
                                    .frame(width: idx == 0 ? 210 : idx == 1 ? 140 : 85, height: 18)
                            }
                        }
                    }
                } else if steps.isEmpty {
                    Text("1. …").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                        Text("\(i + 1). \(step)")
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.regularMaterial)
        )
    }
}

struct NutritionGrid: View {
    let n: Nutrition.PartiallyGenerated

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Nutrition (est.)", systemImage: "chart.bar")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatTile(title: "Calories", value: n.caloriesPerServing.map { "\($0) kcal" } ?? "…")
                StatTile(title: "Protein", value: n.proteinGramsPerServing.map { "\(Int($0.rounded())) g" } ?? "…")
                StatTile(title: "Carbs", value: n.carbsGramsPerServing.map { "\(Int($0.rounded())) g" } ?? "…")
                StatTile(title: "Fat", value: n.fatGramsPerServing.map { "\(Int($0.rounded())) g" } ?? "…")
                StatTile(title: "Sodium", value: n.sodiumMgPerServing.map { "\($0) mg" } ?? "…")
                StatTile(title: "Fiber", value: n.fiberGramsPerServing.map { "\(Int($0.rounded())) g" } ?? "…")
            }
        }
    }
}

struct NutritionGridSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.gray.opacity(0.17))
                    .frame(width: 22, height: 22)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.gray.opacity(0.13))
                    .frame(width: 110, height: 18)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<6, id: \.self) { _ in
                    StatTile(title: "—", value: "…", isPlaceholder: true)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.regularMaterial))
    }
}
