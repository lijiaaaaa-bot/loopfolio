// Why: one C at a time, never while the field still has focus. A second request merges
// copy onto the playing beat; it does not stack TimelineViews.

import Foundation

@MainActor
@Observable
public final class ClimaxStore {
    public private(set) var current: ClimaxEvent?
    public private(set) var playedCount: Int = 0
    public private(set) var refusedWhileFocused: Int = 0

    public init() {}

    public var isPlaying: Bool { current != nil }

    @discardableResult
    public func play(_ event: ClimaxEvent, keyboardFocused: Bool) -> Bool {
        guard !keyboardFocused else {
            refusedWhileFocused += 1
            return false
        }
        if var playing = current {
            playing.merge(with: event)
            current = playing
            return true
        }
        current = event
        return true
    }

    public func finishCurrent(id: UUID) {
        guard current?.id == id else { return }
        current = nil
        playedCount += 1
    }

    public func cancel() {
        current = nil
    }
}
