// Why: A-path is a tiny, deterministic state machine. Correct keys tick a meter and return a
// flash token; they never enqueue CelebrationEvent. That rule is enforced here so the lab
// cannot accidentally share GPU work with typing.

import Foundation

public enum KeystrokeOutcome: Equatable, Sendable {
    case ignored
    case correctChar
    case wrong
    case wordComplete
}

public struct FakeTypingSession: Equatable, Sendable {
    public let target: String
    public var typed: String
    public var correctCount: Int
    public var wordsCleared: Int
    public var streak: Int
    public var mastery: Double
    public var flashToken: Int
    public var lastOutcome: KeystrokeOutcome
    public var sessionSubmitted: Bool

    public init(
        target: String = "ephemeral",
        typed: String = "",
        correctCount: Int = 0,
        wordsCleared: Int = 0,
        streak: Int = 0,
        mastery: Double = 0.34,
        sessionSubmitted: Bool = false
    ) {
        self.target = target
        self.typed = typed
        self.correctCount = correctCount
        self.wordsCleared = wordsCleared
        self.streak = max(0, streak)
        self.mastery = min(1, max(0, mastery))
        self.flashToken = 0
        self.lastOutcome = .ignored
        self.sessionSubmitted = sessionSubmitted
    }

    /// Apply the field's new string. Only a one-character correct prefix extension flashes.
    public mutating func ingest(_ raw: String) -> KeystrokeOutcome {
        let filtered = String(raw.lowercased().filter(\.isLetter))
        guard filtered != typed else {
            lastOutcome = .ignored
            return .ignored
        }

        if target.hasPrefix(filtered), filtered.count == typed.count + 1 {
            typed = filtered
            correctCount += 1
            flashToken += 1
            mastery = min(1, mastery + 0.018)
            if typed == target {
                lastOutcome = .wordComplete
                wordsCleared += 1
                streak += 1
                return .wordComplete
            }
            lastOutcome = .correctChar
            return .correctChar
        }

        if target.hasPrefix(filtered), filtered.count < typed.count {
            typed = filtered
            lastOutcome = .ignored
            return .ignored
        }

        lastOutcome = .wrong
        return .wrong
    }

    public mutating func loadNextWord(_ word: String) {
        let keepFlash = flashToken
        let keepMastery = mastery
        let keepCorrect = correctCount
        let keepCleared = wordsCleared
        let keepStreak = streak
        self = FakeTypingSession(
            target: word,
            typed: "",
            correctCount: keepCorrect,
            wordsCleared: keepCleared,
            streak: keepStreak,
            mastery: keepMastery
        )
        flashToken = keepFlash
    }

    public mutating func bumpMasteryForWeakToast() {
        mastery = min(1, mastery + 0.06)
    }

    public mutating func surgeMastery(by delta: Double) -> (from: Double, to: Double) {
        let from = mastery
        mastery = min(1, mastery + delta)
        return (from, mastery)
    }

    /// Lab stand-in for 词提交 / 局结束. C may play only after this.
    public mutating func submitSession() {
        sessionSubmitted = true
        if typed == target, !typed.isEmpty {
            wordsCleared += 1
            streak += 1
        }
    }
}

public enum LabWordBank {
    public static let words = ["ephemeral", "lucid", "resonance", "threshold", "aether"]

    public static func next(after current: String) -> String {
        guard let index = words.firstIndex(of: current) else { return words[0] }
        return words[(index + 1) % words.count]
    }
}
