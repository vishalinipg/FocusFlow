import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var size: CGFloat = 200
    var lineWidth: CGFloat = 18
    @State private var animatedProgress: Double = 0

    private var circumference: CGFloat {
        2 * .pi * (size / 2 - lineWidth / 2)
    }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .purple, location: 0),
                            .init(color: .blue, location: 0.4),
                            .init(color: .cyan, location: 0.7),
                            .init(color: .purple, location: 1)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: .purple.opacity(0.5), radius: 8)

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                    .animation(.spring, value: animatedProgress)

                Text("Complete")
                    .font(.system(size: size * 0.07, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        ProgressRing(progress: 0.75, size: 200, lineWidth: 18)
    }
}
