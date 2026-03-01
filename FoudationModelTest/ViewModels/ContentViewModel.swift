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
    @Published var selectedKind: String = ""
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentRecipeWasSaved: Bool = false

    /// This is what your UI renders while streaming
    @Published var partiallyGeneratedRecipe: Recipe.PartiallyGenerated? = nil
    
    @Published var savedRecipes: [SavedRecipe] = []

    let availableKinds = ["", "Meal", "Dessert", "Breakfast"]

    // MARK: - Init
    init(useMock: Bool = false) {
        if useMock {
            partiallyGeneratedRecipe = Self.mockRecipe.asPartiallyGenerated()
            savedRecipes = [.init(recipe: Self.mockRecipe)]
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

        let kindValue = selectedKind.isEmpty ? "unspecified" : selectedKind

        let prompt = """
        You are generating a SAFE cooking recipe.
        You must respect the kind.
        Use ONLY edible grocery ingredients and normal kitchen steps. You can add your own ingredients. Use as much as possible the provided ingredients.
        Ingredients: \(ingredients.joined(separator: ","))
        Kind: \(kindValue)
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

        Include a "kind" field with one of: "meal", "dessert", "breakfast", or "unspecified".
        - If the prompt provides a Kind other than "unspecified", you MUST use that exact value. Do not infer or change it.
        - Only if the prompt Kind is "unspecified", infer the most appropriate kind from the recipe and set it accordingly.
        
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
            let steps = partial.steps, !steps.isEmpty,
            let servings = partial.servings,
            let kind = partial.kind
        else {
            errorMessage = "Recipe isn’t complete yet — generate until ingredients, steps, and servings appear."
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

        // Convert nutrition (required: all fields must be present)
        let nutrition: Nutrition
        if let n = partial.nutrition,
           let caloriesPerServing = n.caloriesPerServing,
           let protein = n.proteinGramsPerServing,
           let carbs = n.carbsGramsPerServing,
           let fat = n.fatGramsPerServing,
           let sodium = n.sodiumMgPerServing {

            let totalCalories = n.totalCalories ?? (caloriesPerServing * servings)
            let fiber = n.fiberGramsPerServing ?? 0
            let sugar = n.sugarGramsPerServing ?? 0

            nutrition = Nutrition(
                totalCalories: totalCalories,
                caloriesPerServing: caloriesPerServing,
                proteinGramsPerServing: protein,
                carbsGramsPerServing: carbs,
                fatGramsPerServing: fat,
                sodiumMgPerServing: sodium,
                fiberGramsPerServing: fiber,
                sugarGramsPerServing: sugar
            )
        } else {
            errorMessage = "Nutrition isn’t complete yet — wait until calories, protein, carbs, fat, and sodium appear."
            return
        }

        // Build final Recipe
        let final = Recipe(
            name: name,
            servings: servings,
            nutrition: nutrition,
            ingredients: ingredients,
            steps: steps,
            kind: kind
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
            totalCalories: 4 * 420,
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
        ],
        kind: .meal
    )
}

