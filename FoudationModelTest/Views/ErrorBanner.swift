import SwiftUI

struct ErrorBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.red.opacity(0.35), lineWidth: 1)
        )
    }
}
