import SwiftUI

struct ContentView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Environment(\.colorScheme) var colorScheme

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning ☀️"
        case 12..<17: return "Good Afternoon 🌤️"
        case 17..<21: return "Good Evening 🌇"
        default: return "Good Night 🌙"
        }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "0D0D1A"), Color(hex: "1A0D2E"), Color(hex: "0D1A2E")]
                    : [Color(hex: "F0EAFF"), Color(hex: "E8F4FF"), Color(hex: "F5F0FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative blobs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -100, y: -50)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(x: geo.size.width - 160, y: geo.size.height - 300)
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("FocusFlow")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        Spacer()
                        // Streak badge
                        HStack(spacing: 6) {
                            Text("🔥")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(streakManager.currentStreak)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                Text("streak")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Progress Ring Card
                    GlassCard {
                        VStack(spacing: 20) {
                            Text("Today's Progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)

                            ProgressRing(
                                progress: timerViewModel.completedSessionsToday > 0
                                    ? min(Double(timerViewModel.completedSessionsToday) / 4.0, 1.0)
                                    : 0,
                                size: 180,
                                lineWidth: 16
                            )

                            HStack(spacing: 30) {
                                StatBadge(
                                    value: "\(timerViewModel.completedSessionsToday)",
                                    label: "Sessions",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                StatBadge(
                                    value: String(format: "%.1f", Double(timerViewModel.completedSessionsToday) * 25.0 / 60.0),
                                    label: "Hours",
                                    icon: "clock.fill",
                                    color: .blue
                                )
                                StatBadge(
                                    value: "\(streakManager.currentStreak)",
                                    label: "Day Streak",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                            }
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 20)

                    // Quick stats row
                    HStack(spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    Spacer()
                                }
                                Text("\(streakManager.longestStreak)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Best Streak")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                    Spacer()
                                }
                                Text("\(timerViewModel.totalSessions)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .indigo],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Total Sessions")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Weekly Analytics
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Weekly Activity")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                                Text("This Week")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.15), in: Capsule())
                            }
                            AnalyticsView()
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(StreakManager())
        .environmentObject(TimerViewModel())
}
