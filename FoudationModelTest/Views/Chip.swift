import SwiftUI

struct Chip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? .accentColor : Color.white)
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
