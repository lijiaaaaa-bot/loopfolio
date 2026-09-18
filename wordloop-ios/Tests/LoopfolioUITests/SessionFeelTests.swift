import Foundation
import Testing
@testable import LoopfolioUI

struct SessionFeelTests {
    @Test func cinemaOnlyOnRarePositiveClimaxes() {
        #expect(
            SessionFeel.cinema(
                dailyQueueCleared: true,
                alreadyCelebratedClear: false,
                sessionMasteryGain: 0.10
            ) == [.sessionClear]
        )
        #expect(
            SessionFeel.cinema(
                dailyQueueCleared: true,
                alreadyCelebratedClear: false,
                sessionMasteryGain: 0.22
            ) == [.sessionClear, .powerUpgrade]
        )
        #expect(
            SessionFeel.cinema(
                dailyQueueCleared: false,
                alreadyCelebratedClear: false,
                sessionMasteryGain: 0.22
            ) == [.powerUpgrade]
        )
        #expect(
            SessionFeel.cinema(
                dailyQueueCleared: true,
                alreadyCelebratedClear: true,
                sessionMasteryGain: 0.10
            ).isEmpty
        )
        #expect(
            SessionFeel.cinema(
                dailyQueueCleared: false,
                alreadyCelebratedClear: false,
                sessionMasteryGain: 0.10
            ).isEmpty
        )
    }

    @Test func smallClimaxIsStreakOrBandNeverCinema() {
        #expect(
            SessionFeel.smallClimax(
                wordJustCompleted: true,
                streak: 5,
                previousMastery: 0.20,
                currentMastery: 0.22
            ) == .streak
        )
        #expect(
            SessionFeel.smallClimax(
                wordJustCompleted: true,
                streak: 2,
                previousMastery: 0.48,
                currentMastery: 0.51
            ) == .masteryLeap
        )
        #expect(
            SessionFeel.smallClimax(
                wordJustCompleted: true,
                streak: 2,
                previousMastery: 0.30,
                currentMastery: 0.32
            ) == nil
        )
        #expect(
            SessionFeel.smallClimax(
                wordJustCompleted: false,
                streak: 5,
                previousMastery: 0.20,
                currentMastery: 0.40
            ) == nil
        )
    }

    @Test func lastWordSettlesWith今日清空() {
        var session = FakeTypingSession(
            target: "lucid",
            mastery: 0.40,
            upcoming: [],
            sessionStartMastery: 0.40
        )
        var turn = SessionTurn(
            outcome: .ignored,
            smallClimax: nil,
            cinema: [],
            fromMastery: 0,
            toMastery: 0,
            didSettle: false
        )
        for end in 1...5 {
            turn = SessionDirector.ingest(
                String("lucid".prefix(end)),
                session: &session,
                alreadyCelebratedClear: false
            )
        }
        #expect(turn.didSettle)
        #expect(turn.outcome == .wordComplete)
        #expect(turn.smallClimax == nil)
        #expect(turn.cinema == [.sessionClear])
        #expect(session.sessionSubmitted)
        #expect(session.wordsCleared == 1)
        #expect(session.remainingCount == 0)
        #expect(ClimaxEvent(kind: turn.cinema[0], fromMastery: turn.fromMastery, toMastery: turn.toMastery).title == "今日清空")
    }

    @Test func fullQueueClearAlsoFires词力提升() {
        var session = FakeTypingSession.dailyRound(mastery: 0.34, remaining: 5)
        var last = SessionTurn(
            outcome: .ignored,
            smallClimax: nil,
            cinema: [],
            fromMastery: 0,
            toMastery: 0,
            didSettle: false
        )
        while !session.sessionSubmitted {
            let next = String(session.target.prefix(session.typed.count + 1))
            last = SessionDirector.ingest(next, session: &session, alreadyCelebratedClear: false)
        }
        #expect(last.didSettle)
        #expect(last.cinema == [.sessionClear, .powerUpgrade])
        #expect(session.wordsCleared == 5)
        #expect(session.sessionMasteryGain >= SessionFeel.majorPowerUpgradeDelta)
        let event = ClimaxEvent(kind: .powerUpgrade, fromMastery: last.fromMastery, toMastery: last.toMastery)
        #expect(event.title == "词力提升")
    }

    @Test func midQueuePlaysBNotC() {
        var session = FakeTypingSession.dailyRound(mastery: 0.49, remaining: 3)
        var last = SessionTurn(
            outcome: .ignored,
            smallClimax: nil,
            cinema: [],
            fromMastery: 0,
            toMastery: 0,
            didSettle: false
        )
        for end in 1...9 {
            last = SessionDirector.ingest(
                String("ephemeral".prefix(end)),
                session: &session,
                alreadyCelebratedClear: false
            )
        }
        #expect(last.didSettle == false)
        #expect(last.cinema.isEmpty)
        #expect(last.smallClimax == .masteryLeap)
        #expect(session.target == "lucid")
        #expect(session.sessionSubmitted == false)
    }

    @Test func abandonOnlyUpgradesWhenGainIsMajor() {
        var low = FakeTypingSession.dailyRound(mastery: 0.34, remaining: 3)
        _ = low.ingest("e")
        #expect(SessionDirector.abandonCinema(session: low, alreadyCelebratedClear: false).isEmpty)

        var high = FakeTypingSession.dailyRound(mastery: 0.34, remaining: 3)
        high.mastery = 0.34 + 0.22
        #expect(SessionDirector.abandonCinema(session: high, alreadyCelebratedClear: false) == [.powerUpgrade])
    }

    @Test func dailyRoundStartsWithRemainingQueue() {
        let session = FakeTypingSession.dailyRound(mastery: 0.34, remaining: 2)
        #expect(session.target == "ephemeral")
        #expect(session.upcoming == ["lucid"])
        #expect(session.remainingCount == 2)
        #expect(session.sessionStartMastery == 0.34)
    }
}

@MainActor
struct SessionSettlementStoreTests {
    @Test func playSettlementMergesClearAndUpgrade() {
        let store = ClimaxStore()
        #expect(
            store.playSettlement(
                kinds: [.sessionClear],
                fromMastery: 0.3,
                toMastery: 0.4,
                keyboardFocused: true
            ) == 0
        )
        #expect(store.refusedWhileFocused == 1)

        #expect(
            store.playSettlement(
                kinds: [.sessionClear, .powerUpgrade],
                fromMastery: 0.3,
                toMastery: 0.6,
                keyboardFocused: false
            ) == 2
        )
        #expect(store.current?.title.contains("今日清空") == true)
        #expect(store.current?.title.contains("词力提升") == true)
    }
}
