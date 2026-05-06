import Foundation
import Combine

class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var remainingSeconds: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var sessionJustCompleted: Bool = false
    @Published var completedSessionsToday: Int = 0
    @Published var totalSessions: Int = 0
    @Published var weeklySessionData: [Int] = []

    // MARK: - Constants
    private let sessionDuration: Int = 25 * 60

    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private let defaults = UserDefaults.standard

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let completedToday = "completedSessionsToday"
        static let totalSessions = "totalSessions"
        static let lastSessionDate = "lastSessionDate"
        static let weeklyData = "weeklySessionData"
    }

    // MARK: - Computed Properties
    var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        1.0 - Double(remainingSeconds) / Double(sessionDuration)
    }

    // MARK: - Init
    init() {
        loadData()
        checkNewDay()
    }

    // MARK: - Timer Control
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.completeSession()
                }
            }
    }

    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        remainingSeconds = sessionDuration
    }

    // MARK: - Session Completion
    private func completeSession() {
        pauseTimer()
        completedSessionsToday += 1
        totalSessions += 1
        sessionJustCompleted = true
        remainingSeconds = sessionDuration
        saveData()
        updateWeeklyData()
    }

    // MARK: - Persistence
    private func saveData() {
        defaults.set(completedSessionsToday, forKey: Keys.completedToday)
        defaults.set(totalSessions, forKey: Keys.totalSessions)
        defaults.set(Date(), forKey: Keys.lastSessionDate)
    }

    private func loadData() {
        totalSessions = defaults.integer(forKey: Keys.totalSessions)
        weeklySessionData = defaults.array(forKey: Keys.weeklyData) as? [Int] ?? defaultWeeklyData()

        // Check if last session was today
        if let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date,
           Calendar.current.isDateInToday(lastDate) {
            completedSessionsToday = defaults.integer(forKey: Keys.completedToday)
        } else {
            // New day – reset today's count but keep total
            completedSessionsToday = 0
            defaults.set(0, forKey: Keys.completedToday)
        }
    }

    private func checkNewDay() {
        guard let lastDate = defaults.object(forKey: Keys.lastSessionDate) as? Date else { return }
        if !Calendar.current.isDateInToday(lastDate) {
            completedSessionsToday = 0
        }
    }

    private func updateWeeklyData() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Convert: 1=Sun->6, 2=Mon->0, 3=Tue->1, etc.
        let index = weekday == 1 ? 6 : weekday - 2

        var data = weeklySessionData
        if index < data.count {
            data[index] = completedSessionsToday
        }
        weeklySessionData = data
        defaults.set(data, forKey: Keys.weeklyData)
    }

    private func defaultWeeklyData() -> [Int] {
        // Sample data for a fresh install so the chart looks populated
        return [3, 5, 2, 4, 6, 1, 0]
    }
}
