// Why: C is a different product moment than B's short bloom. Duration, copy, and meter
// endpoints live here so the overlay cannot invent a second movie or a shame beat.

import Foundation

public struct ClimaxEvent: Identifiable, Equatable, Sendable {
    public enum Kind: String, Sendable, Equatable {
        case sessionClear
        case powerUpgrade
    }

    public let id: UUID
    public let kind: Kind
    public let duration: TimeInterval
    public let fromMastery: Double
    public let toMastery: Double
    public var title: String
    public var subtitle: String

    public init(
        id: UUID = UUID(),
        kind: Kind,
        duration: TimeInterval? = nil,
        fromMastery: Double,
        toMastery: Double
    ) {
        self.id = id
        self.kind = kind
        self.duration = Self.clamp(duration ?? Self.defaultDuration(for: kind))
        self.fromMastery = min(1, max(0, fromMastery))
        self.toMastery = min(1, max(self.fromMastery, toMastery))
        self.title = kind == .sessionClear ? "今日清空" : "词力提升"
        self.subtitle = kind == .sessionClear
            ? "这一轮收束。可以停，也可以再来一局。"
            : "词力上了一个台阶。没有对手，只有光线。"
    }

    public static let reduceMotionDuration: TimeInterval = 0.36

    public static func defaultDuration(for kind: Kind) -> TimeInterval {
        switch kind {
        case .sessionClear: return 2.2
        case .powerUpgrade: return 2.5
        }
    }

    public static func clamp(_ raw: TimeInterval) -> TimeInterval {
        min(2.8, max(1.8, raw))
    }

    public mutating func merge(with other: ClimaxEvent) {
        guard kind != other.kind else { return }
        title = "\(title) · \(other.title)"
        subtitle = other.subtitle
    }
}

/// Beat sheet in seconds. Overlay reads this; it does not invent a second timeline.
public enum ClimaxBeat {
    public static func dimOpacity(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        let peak = 0.60
        if elapsed < 0.20 { return peak * (elapsed / 0.20) }
        let fadeStart = max(1.80, duration - 0.40)
        if elapsed >= fadeStart {
            return peak * max(0, 1 - (elapsed - fadeStart) / (duration - fadeStart))
        }
        return peak
    }

    public static func meterScale(elapsed: TimeInterval) -> Double {
        if elapsed < 0.15 { return 1 }
        if elapsed < 0.50 {
            let t = (elapsed - 0.15) / 0.35
            return 1 + 0.20 * easeOut(t)
        }
        if elapsed < 0.90 { return 1.20 }
        if elapsed < 1.80 { return 1.18 }
        return 1.12
    }

    public static func meterFill(elapsed: TimeInterval, from: Double, to: Double) -> Double {
        if elapsed < 0.15 { return from }
        if elapsed >= 0.90 { return to }
        let t = (elapsed - 0.15) / 0.75
        return from + (to - from) * easeOut(t)
    }

    public static func titleOpacity(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        if elapsed < 0.90 { return 0 }
        if elapsed < 1.20 { return (elapsed - 0.90) / 0.30 }
        let fadeStart = max(1.80, duration - 0.40)
        if elapsed >= fadeStart {
            return max(0, 1 - (elapsed - fadeStart) / max(0.01, duration - fadeStart))
        }
        return 1
    }

    public static func flashOpacity(elapsed: TimeInterval) -> Double {
        (elapsed >= 0.38 && elapsed <= 0.42) ? 0.12 : 0
    }

    public static func scrapsActive(elapsed: TimeInterval) -> Bool {
        elapsed >= 0.40 && elapsed <= 1.60
    }

    public static func overlayOpacity(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        if elapsed <= 0 { return 0 }
        if elapsed < 0.16 { return elapsed / 0.16 }
        let fadeStart = max(1.80, duration - 0.40)
        if elapsed >= fadeStart {
            return max(0, 1 - (elapsed - fadeStart) / max(0.01, duration - fadeStart))
        }
        return 1
    }

    public static func easeOut(_ t: Double) -> Double {
        let x = min(1, max(0, t))
        return 1 - pow(1 - x, 3)
    }
}
