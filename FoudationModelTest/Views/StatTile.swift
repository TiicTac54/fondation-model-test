import SwiftUI

struct StatTile: View {
    let title: String
    let value: String
    var isPlaceholder: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isPlaceholder {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 70, height: 12, alignment: .leading)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 50, height: 18, alignment: .leading)
            } else {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                  .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
