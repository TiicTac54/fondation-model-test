//
//  ContentViewModel.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//

import Foundation
import FoundationModels
import Combine

struct SavedRecipe: Identifiable, Sendable {
    let id: UUID = UUID()
    let createdAt: Date = Date()
    let recipe: Recipe
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var ingredientsInput: String = ""
    @Published var selectedStyle: String = ""
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentRecipeWasSaved: Bool = false

    /// This is what your UI renders while streaming
    @Published var partiallyGeneratedRecipe: Recipe.PartiallyGenerated? = nil
    
    @Published var savedRecipes: [SavedRecipe] = []

    let availableStyles = ["", "Meal", "Dessert", "Breakfast"]

    // MARK: - Init
    init(useMock: Bool = false) {
        if useMock {
            partiallyGeneratedRecipe = Self.mockRecipe.asPartiallyGenerated()
        }
    }

    // MARK: - Actions
    func clearIngredients() {
        ingredientsInput = ""
    }

    var canGenerate: Bool {
        !isGenerating &&
        !ingredientsInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func generateRecipes() async {
        isGenerating = true
        errorMessage = nil
        partiallyGeneratedRecipe = nil
        currentRecipeWasSaved = false

        let ingredients = ingredientsInput
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }


        let styleNote = selectedStyle.isEmpty ? "" : " The recipes should be inspired by \(selectedStyle) cuisine."

        let prompt = """
        You are generating a SAFE cooking recipe.
        Use ONLY edible grocery ingredients and normal kitchen steps. You can add your own ingredients. Use as much as possible the provided ingredients.
        Ingredients: \(ingredients.joined(separator: ","))
        Style: \(styleNote)
        Do NOT mention chemicals, drugs, weapons, self-harm, or anything unsafe.
        """

        let instructions = """
        You are a helpful assistant that generates SAFE cooking recipes.

        Every ingredient MUST include a quantity with a kitchen measurement (e.g. '1/4 cup', '2 tbsp', '200 g').
        
        Your output MUST include an estimated Nutrition object with calories, protein, carbs, fat, sodium, fiber, and sugar per serving.

        Include nutrition estimates:
        - calories per serving (kcal)
        - protein, carbs, fat per serving (grams)
        - sodium per serving (mg)
        Optional: fiber and sugar per serving.

        If you are unsure, provide your best estimate and keep values reasonable.
        
        When all of steps are done, re-check if all ingredients mentionned in the steps are included. They could be simple as salt. If they are missing add them.
        """

        let session = LanguageModelSession(instructions: instructions)
        
        do {
            // STREAM instead of respond
            let stream = session.streamResponse(to: prompt, generating: Recipe.self)

            for try await partial in stream {
                partiallyGeneratedRecipe = partial.content
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }
    

    func addCurrentRecipe() {
        guard !isGenerating else { return }
        guard let partial = partiallyGeneratedRecipe else { return }

        // Required fields
        guard
            let name = partial.name?.trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty,
            let partialIngredients = partial.ingredients, !partialIngredients.isEmpty,
            let steps = partial.steps, !steps.isEmpty
        else {
            errorMessage = "Recipe isn’t complete yet — generate until ingredients and steps appear."
            return
        }

        // Convert ingredients
        let ingredients: [Ingredient] = partialIngredients.compactMap { pIng in
            guard
                let qty = pIng.quantity?.trimmingCharacters(in: .whitespacesAndNewlines), !qty.isEmpty,
                let ingName = pIng.name?.trimmingCharacters(in: .whitespacesAndNewlines), !ingName.isEmpty
            else { return nil }

            return Ingredient(quantity: qty, name: ingName)
        }

        guard !ingredients.isEmpty else {
            errorMessage = "Ingredients are incomplete — please wait for measurements and names."
            return
        }

        // Convert nutrition (optional)
        var nutrition: Nutrition? = nil
        if let n = partial.nutrition {
            let hasAny =
                n.totalCalories != nil ||
                n.caloriesPerServing != nil ||
                n.proteinGramsPerServing != nil ||
                n.carbsGramsPerServing != nil ||
                n.fatGramsPerServing != nil ||
                n.sodiumMgPerServing != nil ||
                n.fiberGramsPerServing != nil ||
                n.sugarGramsPerServing != nil

            if hasAny {
                nutrition = Nutrition(
                    totalCalories: n.totalCalories,
                    caloriesPerServing: n.caloriesPerServing,
                    proteinGramsPerServing: n.proteinGramsPerServing,
                    carbsGramsPerServing: n.carbsGramsPerServing,
                    fatGramsPerServing: n.fatGramsPerServing,
                    sodiumMgPerServing: n.sodiumMgPerServing,
                    fiberGramsPerServing: n.fiberGramsPerServing,
                    sugarGramsPerServing: n.sugarGramsPerServing
                )
            }
        }

        // Build final Recipe (servings optional)
        let final = Recipe(
            name: name,
            servings: partial.servings!,
            nutrition: nutrition!,
            ingredients: ingredients,
            steps: steps
        )

        savedRecipes.insert(SavedRecipe(recipe: final), at: 0)
        errorMessage = nil
        currentRecipeWasSaved = true   // 🔥 reset
        print("Saved recipe:", final.name)
        print(final)
    }

    // MARK: - Mock
    static let mockRecipe = Recipe(
        name: "Honey Cornflake Crusted Pork",
        servings: 4, nutrition: Nutrition(
            totalCalories: nil,
            caloriesPerServing: 420,
            proteinGramsPerServing: 32,
            carbsGramsPerServing: 28,
            fatGramsPerServing: 18,
            sodiumMgPerServing: 520,
            fiberGramsPerServing: 2,
            sugarGramsPerServing: 10
        ), ingredients: [
            Ingredient(quantity: "4", name: "pork chops"),
            Ingredient(quantity: "2 tbsp", name: "honey"),
            Ingredient(quantity: "2 cups", name: "corn flakes"),
        ],
        steps: [
            "Preheat oven to 375°F (190°C).",
            "Crush corn flakes in a bowl.",
            "Brush pork with honey and coat with flakes.",
            "Bake 25–30 minutes until golden and cooked through."
        ]
    )
}
