import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            FocusView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
                .tag(1)
        }
        .tint(.purple)
    }
}

#Preview {
    MainTabView()
        .environmentObject(StreakManager())
        .environmentObject(TimerViewModel())
}
