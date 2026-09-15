import Foundation
import Testing
@testable import LoopfolioUI

@MainActor
struct CelebrationStoreTests {
    @Test func durationStaysInSmallClimaxWindow() {
        #expect(CelebrationEvent.clamp(0.2) == 0.6)
        #expect(CelebrationEvent.clamp(3) == 1.2)
        #expect(CelebrationEvent(kind: .masteryLeap).duration == 0.95)
        #expect(CelebrationEvent(kind: .streak).duration == 1.0)
    }

    @Test func queueDoesNotPreemptTheCurrentMoment() {
        let store = CelebrationStore()
        store.enqueue(.masteryLeap)
        store.enqueue(.streak)
        #expect(store.current?.kind == .masteryLeap)
        #expect(store.pendingCount == 1)

        let firstID = store.current!.id
        store.finishCurrent(id: firstID)
        #expect(store.current?.kind == .streak)
        #expect(store.pendingCount == 0)
        #expect(store.playedCount == 1)
    }

    @Test func finishIgnoresStaleIdentifiers() {
        let store = CelebrationStore()
        store.enqueue(.masteryLeap)
        store.finishCurrent(id: UUID())
        #expect(store.isPlaying)
        #expect(store.playedCount == 0)
    }

    @Test func cancelDropsQueuedCinema() {
        let store = CelebrationStore()
        store.enqueue(.masteryLeap)
        store.enqueue(.streak)
        store.cancelAll()
        #expect(store.current == nil)
        #expect(store.pendingCount == 0)
    }
}
