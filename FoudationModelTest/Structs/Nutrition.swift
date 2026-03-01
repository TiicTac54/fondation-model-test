//
//  Nutrition.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//
import FoundationModels

@Generable(description: "Estimated nutrition information for the recipe. All values are approximate and based on standard ingredient data.")
struct Nutrition: Sendable {
    
    @Guide(description: "Total calories for the entire recipe in kilocalories (kcal). Provide a realistic whole number estimate.")
    var totalCalories: Int
    
    @Guide(description: "Calories per serving in kilocalories (kcal). Provide a realistic whole number estimate.")
    var caloriesPerServing: Int
    
    @Guide(description: "Protein per serving in grams. Provide a numeric value (e.g., 25.5).")
    var proteinGramsPerServing: Double
    
    @Guide(description: "Carbohydrates per serving in grams. Provide a numeric value.")
    var carbsGramsPerServing: Double
    
    @Guide(description: "Fat per serving in grams. Provide a numeric value.")
    var fatGramsPerServing: Double
    
    @Guide(description: "Sodium per serving in milligrams (mg). Provide a realistic whole number estimate.")
    var sodiumMgPerServing: Int
    
    @Guide(description: "Dietary fiber per serving in grams. Provide a numeric value.")
    var fiberGramsPerServing: Double
    
    @Guide(description: "Sugar per serving in grams. Provide a numeric value.")
    var sugarGramsPerServing: Double
}
