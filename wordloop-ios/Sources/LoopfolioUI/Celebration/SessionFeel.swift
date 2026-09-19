// Why: A/B/C routing for the real typing round — not the lab buttons.
// Keystrokes never construct ClimaxEvent. C is settlement-only, after the keyboard is gone.

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum SessionFeel: Sendable {
    public static let streakMilestones = [5, 10, 20]
    public static let masteryLeapBands = [0.25, 0.50, 0.75]
    public static let majorPowerUpgradeDelta = 0.22

    /// Mid-session only. Never returns cinema.
    public static func smallClimax(
        wordJustCompleted: Bool,
        streak: Int,
        previousMastery: Double,
        currentMastery: Double
    ) -> CelebrationEvent.Kind? {
        guard wordJustCompleted else { return nil }
        if streakMilestones.contains(streak) { return .streak }
        if crossedBand(from: previousMastery, to: currentMastery, bands: masteryLeapBands) {
            return .masteryLeap
        }
        return nil
    }

    /// Settlement / return-home only. Empty unless a rare positive climax happened.
    public static func cinema(
        dailyQueueCleared: Bool,
        alreadyCelebratedClear: Bool,
        sessionMasteryGain: Double
    ) -> [ClimaxEvent.Kind] {
        var kinds: [ClimaxEvent.Kind] = []
        if dailyQueueCleared, !alreadyCelebratedClear {
            kinds.append(.sessionClear)
        }
        if sessionMasteryGain >= majorPowerUpgradeDelta {
            kinds.append(.powerUpgrade)
        }
        return kinds
    }

    public static func crossedBand(from: Double, to: Double, bands: [Double]) -> Bool {
        bands.contains { from < $0 && to >= $0 }
    }
}

public struct SessionTurn: Equatable, Sendable {
    public var outcome: KeystrokeOutcome
    public var smallClimax: CelebrationEvent.Kind?
    public var cinema: [ClimaxEvent.Kind]
    public var fromMastery: Double
    public var toMastery: Double
    public var didSettle: Bool
}

/// Applies one field change and decides A (implicit), B, or C.
public enum SessionDirector {
    public static func ingest(
        _ raw: String,
        session: inout FakeTypingSession,
        alreadyCelebratedClear: Bool
    ) -> SessionTurn {
        let previousMastery = session.mastery
        let from = session.sessionStartMastery
        let outcome = session.ingest(raw)
        let to = session.mastery

        guard outcome == .wordComplete else {
            return SessionTurn(
                outcome: outcome,
                smallClimax: nil,
                cinema: [],
                fromMastery: from,
                toMastery: to,
                didSettle: false
            )
        }

        let streak = session.streak
        switch session.advanceAfterWord() {
        case .nextWord:
            return SessionTurn(
                outcome: outcome,
                smallClimax: SessionFeel.smallClimax(
                    wordJustCompleted: true,
                    streak: streak,
                    previousMastery: previousMastery,
                    currentMastery: to
                ),
                cinema: [],
                fromMastery: from,
                toMastery: session.mastery,
                didSettle: false
            )
        case .settlement:
            return SessionTurn(
                outcome: outcome,
                smallClimax: nil,
                cinema: SessionFeel.cinema(
                    dailyQueueCleared: true,
                    alreadyCelebratedClear: alreadyCelebratedClear,
                    sessionMasteryGain: session.sessionMasteryGain
                ),
                fromMastery: from,
                toMastery: session.mastery,
                didSettle: true
            )
        }
    }

    /// Leaving a round early: C only for a major power upgrade, never 「今日清空」.
    public static func abandonCinema(
        session: FakeTypingSession,
        alreadyCelebratedClear: Bool
    ) -> [ClimaxEvent.Kind] {
        SessionFeel.cinema(
            dailyQueueCleared: false,
            alreadyCelebratedClear: alreadyCelebratedClear,
            sessionMasteryGain: session.sessionMasteryGain
        )
    }
}

enum KeyboardResign {
    static func resign() {
        #if os(iOS)
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        #endif
    }
}
