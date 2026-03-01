//
//  GenerateBar.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//

import SwiftUI

struct GenerateBar: View {
    let isGenerating: Bool
    let canGenerate: Bool
    let hasRecipe: Bool
    let action: () -> Void
    let addAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Primary button
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: "wand.and.stars")
                    Text(isGenerating ? "Generating…" : "Generate Recipe")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(
                RainbowBorderButtonStyle(
                    isGenerating: isGenerating,
                    isInputValid: canGenerate,
                    cornerRadius: 12,
                    borderWidth: 2.5
                )
            )
            .disabled(isGenerating || !canGenerate)
            
            // Secondary Add Button (RIGHT)
            if hasRecipe && !isGenerating {
                Button(action: addAction) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                }
                .buttonStyle(ReversePrimaryButtonStyle(cornerRadius: 10))
            }
        }
    }
}
// Refactored RainbowBorderButtonStyle without internal Button
private struct RainbowBorderButtonStyle: ButtonStyle {
    let isGenerating: Bool
    let isInputValid: Bool
    let cornerRadius: CGFloat
    let borderWidth: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground(isPressed: configuration.isPressed))
            .padding(.horizontal, 18)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background(isPressed: configuration.isPressed))
            )
            .overlay(
                ZStack {
                    if isGenerating {
                        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        AngularGradientView(
                            colors: rainbowColors,
                            isGenerating: isGenerating,
                            borderWidth: borderWidth,
                            shape: shape
                        )
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
    
    private func background(isPressed: Bool) -> Color {
        if isGenerating || !isInputValid {
            return Color.gray.opacity(0.16)
        }
        return Color.accentColor
    }
    
    private func foreground(isPressed: Bool) -> Color {
        if isGenerating || !isInputValid {
            return .secondary
        }
        return .white
    }
    
    private var rainbowColors: [Color] {
        [.red, .orange, .yellow, .mint, .cyan, .blue, .purple, .pink, .red]
    }
    
    private struct AngularGradientView<S: Shape>: View {
        let colors: [Color]
        let isGenerating: Bool
        let borderWidth: CGFloat
        let shape: S
        
        @State private var phase: CGFloat = 0
        
        var body: some View {
            shape
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startAngle: .degrees(360 * phase),
                        endAngle: .degrees(360 * phase + 360.0)
                    ),
                    lineWidth: borderWidth * 2.1
                )
                .blur(radius: 8)
                .opacity(0.45)
                .clipShape(shape)
                .overlay(
                    shape
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: colors),
                                center: .center,
                                startAngle: .degrees(360 * phase),
                                endAngle: .degrees(360 * phase + 360.0)
                            ),
                            lineWidth: borderWidth
                        )
                        .blur(radius: 1)
                        .opacity(0.92)
                        .clipShape(shape)
                )
                .onAppear {
                    phase = 0
                    withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
                .allowsHitTesting(false)
        }
    }
}

private struct ReversePrimaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        configuration.label
            .foregroundStyle(.tint)
            .background(
                shape.fill(.white)
            )
            .overlay(
                shape.stroke(.tint, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}
