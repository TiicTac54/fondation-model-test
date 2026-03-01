//
//  Tag.swift
//  FoudationModelTest
//
//  Created by Piérik Landry on 2026-02-28.
//
import SwiftUI

struct Tag: View {
    let icon: String
    let text: String
    let tint: Color

    public init(icon: String, text: String, tint: Color) {
        self.icon = icon
        self.text = text
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(text)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(tint.opacity(0.12))
        )
        .foregroundStyle(tint)
    }
}
