import SwiftUI

struct FocusView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var streakManager: StreakManager
    @Environment(\.colorScheme) var colorScheme
    @State private var animateGradient = false
    @State private var showCompletionBanner = false

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: animateGradient
                    ? [Color(hex: "1A0533"), Color(hex: "0A1628"), Color(hex: "1C0A3C")]
                    : [Color(hex: "0D0D2B"), Color(hex: "1A1035"), Color(hex: "0A1A35")],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)

            // Glow orbs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                timerViewModel.isRunning ? Color.purple.opacity(0.4) : Color.purple.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
                    .animation(.easeInOut(duration: 1.5), value: timerViewModel.isRunning)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.7)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                VStack(spacing: 6) {
                    Text("Focus Session")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(timerViewModel.isRunning ? "Stay focused. You've got this 💪" : "Ready when you are")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .animation(.easeInOut, value: timerViewModel.isRunning)
                }
                .padding(.top, 50)

                Spacer()

                // Timer ring
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color.purple.opacity(timerViewModel.isRunning ? 0.15 : 0.05))
                        .frame(width: 280, height: 280)
                        .blur(radius: 20)

                    // Glass backing
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 240, height: 240)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: timerViewModel.progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .blue, .cyan, .purple]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 230, height: 230)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerViewModel.progress)

                    // Track ring
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 8)
                        .frame(width: 230, height: 230)

                    // Timer text
                    VStack(spacing: 4) {
                        Text(timerViewModel.timeString)
                            .font(.system(size: 56, weight: .thin, design: .monospaced))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring, value: timerViewModel.timeString)

                        Text("minutes")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                }

                Spacer()

                // Session info row
                HStack(spacing: 20) {
                    SessionInfoPill(
                        icon: "checkmark.circle.fill",
                        label: "Today",
                        value: "\(timerViewModel.completedSessionsToday)",
                        color: .green
                    )
                    SessionInfoPill(
                        icon: "flame.fill",
                        label: "Streak",
                        value: "\(streakManager.currentStreak)d",
                        color: .orange
                    )
                    SessionInfoPill(
                        icon: "brain",
                        label: "Total",
                        value: "\(timerViewModel.totalSessions)",
                        color: .cyan
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Controls
                VStack(spacing: 16) {
                    // Main button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            timerViewModel.toggleTimer()
                        }
                    }) {
                        ZStack {
                            // Glow
                            RoundedRectangle(cornerRadius: 28)
                                .fill(timerViewModel.isRunning ? Color.red.opacity(0.3) : Color.purple.opacity(0.3))
                                .blur(radius: 12)
                                .frame(width: 200, height: 64)

                            // Button
                            HStack(spacing: 10) {
                                Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                                    .font(.title3)
                                Text(timerViewModel.isRunning ? "Pause" : "Start Focus")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(
                                LinearGradient(
                                    colors: timerViewModel.isRunning
                                        ? [Color(hex: "FF4D4D"), Color(hex: "CC2222")]
                                        : [Color(hex: "7B3FE4"), Color(hex: "4A1FA8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 28)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(timerViewModel.isRunning ? 1.0 : 1.02)
                    .animation(.spring(response: 0.3), value: timerViewModel.isRunning)

                    // Reset button
                    Button(action: {
                        withAnimation {
                            timerViewModel.resetTimer()
                        }
                    }) {
                        Text("Reset")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 50)
            }

            // Completion banner
            if showCompletionBanner {
                VStack {
                    HStack(spacing: 12) {
                        Text("🎉")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Session Complete!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Great work! Take a short break.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "7B3FE4"), Color(hex: "4A90D9")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
                .padding(.top, 16)
            }
        }
        .onAppear {
            animateGradient = true
        }
        .onChange(of: timerViewModel.sessionJustCompleted) { completed in
            if completed {
                streakManager.recordSession()
                withAnimation(.spring) {
                    showCompletionBanner = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showCompletionBanner = false
                    }
                    timerViewModel.sessionJustCompleted = false
                }
            }
        }
    }
}

struct SessionInfoPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    FocusView()
        .environmentObject(TimerViewModel())
        .environmentObject(StreakManager())
}
