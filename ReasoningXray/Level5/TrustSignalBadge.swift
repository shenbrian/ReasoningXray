import SwiftUI

struct TrustSignalBadge: View {
    let status: EpistemicStatus

    var body: some View {
        Text(status.shortLabel)
            .font(.caption2.weight(.medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .overlay(
                Capsule()
                    .strokeBorder(borderColor, lineWidth: 0.6)
            )
            .clipShape(Capsule())
            .accessibilityLabel(status.accessibilityLabel)
    }

    private var foregroundColor: Color {
        switch status {
        case .observed:
            return .blue.opacity(0.75)

        case .inferred:
            return .secondary.opacity(0.85)

        case .provisional:
            return .orange.opacity(0.75)

        case .evolving:
            return .purple.opacity(0.75)

        case .stable:
            return .green.opacity(0.75)
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .observed:
            return Color.blue.opacity(0.06)

        case .inferred:
            return Color.secondary.opacity(0.05)

        case .provisional:
            return Color.orange.opacity(0.06)

        case .evolving:
            return Color.purple.opacity(0.06)

        case .stable:
            return Color.green.opacity(0.06)
        }
    }

    private var borderColor: Color {
        switch status {
        case .observed:
            return Color.blue.opacity(0.25)

        case .inferred:
            return Color.secondary.opacity(0.25)

        case .provisional:
            return Color.orange.opacity(0.25)

        case .evolving:
            return Color.purple.opacity(0.25)

        case .stable:
            return Color.green.opacity(0.25)
        }
    }
}
