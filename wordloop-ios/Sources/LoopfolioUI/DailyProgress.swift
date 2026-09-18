// Why: home and the typing round share today's mastery / remaining queue.
// Cinema does not live here — RootView owns ClimaxStore.

import Foundation

@MainActor
@Observable
public final class DailyProgress {
    public var mastery: Double
    public var bestStreak: Int
    public var remaining: Int
    public var clearedToday: Bool

    public init(
        mastery: Double = 0.34,
        bestStreak: Int = 0,
        remaining: Int = LabWordBank.words.count,
        clearedToday: Bool = false
    ) {
        self.mastery = min(1, max(0, mastery))
        self.bestStreak = max(0, bestStreak)
        self.remaining = max(0, remaining)
        self.clearedToday = clearedToday
    }

    public var nextPrompt: String {
        LabWordBank.words[0]
    }

    public func apply(_ session: FakeTypingSession) {
        mastery = session.mastery
        bestStreak = max(bestStreak, session.streak)
        remaining = session.remainingCount
        if session.sessionSubmitted, session.upcoming.isEmpty {
            clearedToday = true
            remaining = 0
        }
    }
}
