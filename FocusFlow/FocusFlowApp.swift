import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var streakManager = StreakManager()
    @StateObject private var timerViewModel = TimerViewModel()

    init() {
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleDailyReminder()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(streakManager)
                .environmentObject(timerViewModel)
                .preferredColorScheme(.none)
        }
    }
}
