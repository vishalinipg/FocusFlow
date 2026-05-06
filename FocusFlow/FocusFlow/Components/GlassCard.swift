import SwiftUI

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 24
    var shadowRadius: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [Color.white.opacity(0.05), Color.white.opacity(0.02)]
                                    : [Color.white.opacity(0.7), Color.white.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color.white.opacity(0.15), Color.white.opacity(0.05)]
                                : [Color.white.opacity(0.8), Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.4)
                    : Color.purple.opacity(0.08),
                radius: shadowRadius,
                x: 0,
                y: 6
            )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "F0EAFF"), Color(hex: "E8F4FF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassCard {
            VStack(spacing: 12) {
                Text("Glass Card Preview")
                    .font(.headline)
                Text("Content goes here")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(24)
        }
        .padding(40)
    }
}
