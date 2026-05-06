import Foundation

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let currentStreak = "currentStreak"
        static let longestStreak = "longestStreak"
        static let lastActiveDate = "lastActiveDate"
        static let completedToday = "streakCompletedToday"
    }

    init() {
        loadStreak()
        checkStreakIntegrity()
    }

    // MARK: - Record a completed session
    func recordSession() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = defaults.object(forKey: Keys.lastActiveDate) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)

            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                // Already recorded today — no streak change
                return
            }

            let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else {
                // Missed one or more days
                currentStreak = 1
            }
        } else {
            // First ever session
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        defaults.set(today, forKey: Keys.lastActiveDate)
        saveStreak()
    }

    // MARK: - Load
    private func loadStreak() {
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
    }

    // MARK: - Save
    private func saveStreak() {
        defaults.set(currentStreak, forKey: Keys.currentStreak)
        defaults.set(longestStreak, forKey: Keys.longestStreak)
    }

    // MARK: - Integrity check (reset streak if a day was missed)
    private func checkStreakIntegrity() {
        guard let lastDate = defaults.object(forKey: Keys.lastActiveDate) as? Date else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastDate)
        let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if daysBetween > 1 {
            currentStreak = 0
            saveStreak()
        }
    }
}
