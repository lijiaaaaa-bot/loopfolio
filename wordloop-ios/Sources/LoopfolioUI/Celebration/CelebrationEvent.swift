// Why: rare retention beats only. Keystrokes never construct one of these — that is the
// structural gap the lab is meant to make obvious.

import Foundation

public struct CelebrationEvent: Identifiable, Equatable, Sendable {
    public enum Kind: String, Sendable, Equatable {
        case masteryLeap
        case sessionClear
    }

    public let id: UUID
    public let kind: Kind
    public let duration: TimeInterval

    public init(id: UUID = UUID(), kind: Kind, duration: TimeInterval? = nil) {
        self.id = id
        self.kind = kind
        self.duration = Self.clamp(duration ?? Self.defaultDuration(for: kind))
    }

    public var title: String {
        switch kind {
        case .masteryLeap: return "掌握跃迁"
        case .sessionClear: return "本局清完"
        }
    }

    public var subtitle: String {
        switch kind {
        case .masteryLeap: return "词力抬了一档。没有对手，只有光线。"
        case .sessionClear: return "这一轮收束。留下来的是安静的亮。"
        }
    }

    public static func defaultDuration(for kind: Kind) -> TimeInterval {
        switch kind {
        case .masteryLeap: return 1.15
        case .sessionClear: return 1.65
        }
    }

    public static func clamp(_ raw: TimeInterval) -> TimeInterval {
        min(1.8, max(0.8, raw))
    }
}
