import Foundation
import Testing
@testable import LoopfolioUI

struct ClimaxBeatTests {
    @Test func dimPeaksInTheSpecWindow() {
        #expect(ClimaxBeat.dimOpacity(elapsed: 0, duration: 2.2) == 0)
        let mid = ClimaxBeat.dimOpacity(elapsed: 1.0, duration: 2.2)
        #expect(mid >= 0.55 && mid <= 0.65)
        #expect(ClimaxBeat.dimOpacity(elapsed: 2.2, duration: 2.2) == 0)
    }

    @Test func meterHeroScaleStaysInRange() {
        let peak = ClimaxBeat.meterScale(elapsed: 0.6)
        #expect(peak >= 1.15 && peak <= 1.25)
        #expect(ClimaxBeat.meterScale(elapsed: 0) == 1)
    }

    @Test func fillSurgesBetweenEndpoints() {
        let from = 0.34
        let to = 0.56
        #expect(ClimaxBeat.meterFill(elapsed: 0, from: from, to: to) == from)
        #expect(ClimaxBeat.meterFill(elapsed: 0.90, from: from, to: to) == to)
        let mid = ClimaxBeat.meterFill(elapsed: 0.40, from: from, to: to)
        #expect(mid > from && mid < to)
    }

    @Test func scrapsStayInsideTheBeat() {
        #expect(ClimaxBeat.scrapsActive(elapsed: 0.2) == false)
        #expect(ClimaxBeat.scrapsActive(elapsed: 0.9) == true)
        #expect(ClimaxBeat.scrapsActive(elapsed: 1.8) == false)
    }

    @Test func flashIsASingleSoftFrame() {
        #expect(ClimaxBeat.flashOpacity(elapsed: 0.40) <= 0.15)
        #expect(ClimaxBeat.flashOpacity(elapsed: 0.40) > 0)
        #expect(ClimaxBeat.flashOpacity(elapsed: 1.0) == 0)
    }
}

@MainActor
struct ClimaxStoreTests {
    @Test func durationStaysInCinemaWindow() {
        #expect(ClimaxEvent.clamp(0.5) == 1.8)
        #expect(ClimaxEvent.clamp(4) == 2.8)
        #expect(ClimaxEvent(kind: .sessionClear, fromMastery: 0.3, toMastery: 0.4).duration == 2.2)
        #expect(ClimaxEvent(kind: .powerUpgrade, fromMastery: 0.3, toMastery: 0.5).duration == 2.5)
        #expect(ClimaxEvent.reduceMotionDuration <= 0.4)
    }

    @Test func refusesWhileKeyboardFocused() {
        let store = ClimaxStore()
        let event = ClimaxEvent(kind: .sessionClear, fromMastery: 0.3, toMastery: 0.4)
        #expect(store.play(event, keyboardFocused: true) == false)
        #expect(store.current == nil)
        #expect(store.refusedWhileFocused == 1)
    }

    @Test func onlyOneMovieMergesCopy() {
        let store = ClimaxStore()
        let first = ClimaxEvent(kind: .sessionClear, fromMastery: 0.3, toMastery: 0.4)
        let second = ClimaxEvent(kind: .powerUpgrade, fromMastery: 0.4, toMastery: 0.6)
        #expect(store.play(first, keyboardFocused: false))
        #expect(store.play(second, keyboardFocused: false))
        #expect(store.current?.id == first.id)
        #expect(store.current?.title.contains("今日清空") == true)
        #expect(store.current?.title.contains("词力提升") == true)
    }

    @Test func finishTearsDown() {
        let store = ClimaxStore()
        let event = ClimaxEvent(kind: .powerUpgrade, fromMastery: 0.2, toMastery: 0.5)
        store.play(event, keyboardFocused: false)
        store.finishCurrent(id: event.id)
        #expect(store.current == nil)
        #expect(store.playedCount == 1)
    }
}
