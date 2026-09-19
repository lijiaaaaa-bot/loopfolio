// Why: cinema has its own store and queue, not @State on the typing view. The TextField tree
// never owns a TimelineView or shader; enqueue is a fire-and-forget call from rare product events.

import Foundation

@MainActor
@Observable
public final class CelebrationStore {
    public private(set) var current: CelebrationEvent?
    public private(set) var playedCount: Int = 0

    private var queue: [CelebrationEvent] = []

    public init() {}

    public var isPlaying: Bool { current != nil }

    public func enqueue(_ kind: CelebrationEvent.Kind) {
        enqueue(CelebrationEvent(kind: kind))
    }

    public func enqueue(_ event: CelebrationEvent) {
        if current == nil {
            current = event
        } else {
            queue.append(event)
        }
    }

    /// Called by CelebrationHost when the moment finishes. Drops GPU work before the next frame.
    public func finishCurrent(id: UUID) {
        guard current?.id == id else { return }
        current = nil
        playedCount += 1
        if !queue.isEmpty {
            current = queue.removeFirst()
        }
    }

    public func cancelAll() {
        current = nil
        queue.removeAll()
    }

    public var pendingCount: Int { queue.count }
}
