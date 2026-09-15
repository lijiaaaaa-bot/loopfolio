import Foundation
import Testing
@testable import LoopfolioUI

@MainActor
struct CelebrationStoreTests {
    @Test func durationStaysInCinemaWindow() {
        #expect(CelebrationEvent.clamp(0.2) == 0.8)
        #expect(CelebrationEvent.clamp(3) == 1.8)
        #expect(CelebrationEvent(kind: .masteryLeap).duration == 1.15)
        #expect(CelebrationEvent(kind: .sessionClear).duration == 1.65)
    }

    @Test func queueDoesNotPreemptTheCurrentMoment() {
        let store = CelebrationStore()
        store.enqueue(.masteryLeap)
        store.enqueue(.sessionClear)
        #expect(store.current?.kind == .masteryLeap)
        #expect(store.pendingCount == 1)

        let firstID = store.current!.id
        store.finishCurrent(id: firstID)
        #expect(store.current?.kind == .sessionClear)
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
        store.enqueue(.sessionClear)
        store.cancelAll()
        #expect(store.current == nil)
        #expect(store.pendingCount == 0)
    }
}
