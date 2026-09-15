// Why: rare retention beats only. Keystrokes never construct one of these — that is the
// structural gap the lab is meant to make obvious.

import Foundation

public struct CelebrationEvent: Identifiable, Equatable, Sendable {
    public enum Kind: String, Sendable, Equatable {
        case masteryLeap
        case streak
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
        case .streak: return "连击"
        }
    }

    public var subtitle: String {
        switch kind {
        case .masteryLeap: return "这一词站住了。短光，不占场。"
        case .streak: return "节奏还在。小高潮，不是电影。"
        }
    }

    public static func defaultDuration(for kind: Kind) -> TimeInterval {
        switch kind {
        case .masteryLeap: return 0.95
        case .streak: return 1.0
        }
    }

    public static func clamp(_ raw: TimeInterval) -> TimeInterval {
        min(1.2, max(0.6, raw))
    }
}
