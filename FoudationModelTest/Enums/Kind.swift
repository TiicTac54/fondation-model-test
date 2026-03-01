//
//  Kind.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//
import FoundationModels

@Generable(description: "Represent what kind of recipe it is")
enum Kind: String, Codable, Sendable, Hashable {
    case meal
    case dessert
    case breakfast
    case unspecified
}
