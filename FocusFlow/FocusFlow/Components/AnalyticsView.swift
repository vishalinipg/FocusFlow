import SwiftUI

struct DayData: Identifiable {
    let id = UUID()
    let day: String
    let sessions: Int
    let isToday: Bool
}

struct AnalyticsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var animateBars = false

    private var weekData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon, ...
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        // Convert weekday: 1=Sun -> index 6, 2=Mon -> 0, etc.
        let todayIndex: Int = weekday == 1 ? 6 : weekday - 2

        // Merge stored history with today's live count
        var sessionsHistory = timerViewModel.weeklySessionData

        return days.enumerated().map { (index, day) in
            let isToday = index == todayIndex
            let sessions: Int
            if isToday {
                sessions = timerViewModel.completedSessionsToday
            } else {
                // Past days: use stored history, capped at 8
                sessions = index < sessionsHistory.count ? sessionsHistory[index] : 0
            }
            return DayData(day: day, sessions: sessions, isToday: isToday)
        }
    }

    private var maxSessions: Int {
        max(weekData.map { $0.sessions }.max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekData) { dayData in
                    BarColumn(
                        dayData: dayData,
                        maxSessions: maxSessions,
                        animate: animateBars
                    )
                }
            }
            .frame(height: 130)
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                animateBars = true
            }
        }
    }
}

struct BarColumn: View {
    let dayData: DayData
    let maxSessions: Int
    let animate: Bool

    private var fillFraction: Double {
        guard maxSessions > 0 else { return 0 }
        return animate ? min(Double(dayData.sessions) / Double(maxSessions), 1.0) : 0
    }

    private var barColor: [Color] {
        if dayData.isToday {
            return [.purple, .blue]
        } else if dayData.sessions > 0 {
            return [.purple.opacity(0.6), .blue.opacity(0.6)]
        } else {
            return [.gray.opacity(0.25), .gray.opacity(0.15)]
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            // Session count label
            Text(dayData.sessions > 0 ? "\(dayData.sessions)" : "")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(dayData.isToday ? .purple : .secondary)
                .frame(height: 14)

            // Bar
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: barColor,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            height: max(geo.size.height * fillFraction, dayData.sessions > 0 ? 6 : 3)
                        )
                        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: fillFraction)
                        .overlay(
                            // Glow for today
                            dayData.isToday && dayData.sessions > 0
                                ? AnyView(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.purple.opacity(0.3))
                                        .blur(radius: 4)
                                )
                                : AnyView(EmptyView())
                        )
                }
            }
            .frame(height: 90)

            // Day label
            Text(dayData.day)
                .font(.system(size: 11, weight: dayData.isToday ? .bold : .medium))
                .foregroundColor(dayData.isToday ? .purple : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        AnalyticsView()
            .environmentObject(TimerViewModel())
            .padding(20)
    }
}
