// Why: tokens from D-POWER-METER-SPEC.md. No second palette. A-path motion stays ≤300ms.

import SwiftUI

enum Theme {
    static let canvas = Color(red: 0.047, green: 0.043, blue: 0.071) // #0C0B12
    static let surface = Color(red: 0.102, green: 0.094, blue: 0.137) // #1A1823
    static let ink = Color(red: 0.953, green: 0.945, blue: 0.996)
    static let inkSoft = Color(red: 0.655, green: 0.639, blue: 0.741)
    static let accent = Color(red: 0.424, green: 0.298, blue: 0.941) // #6C4CF0
    static let accentSoft = Color(red: 0.643, green: 0.545, blue: 1.0) // #A48BFF
    static let onAccent = Color.white
    static let powerFill = accent
    static let powerTrack = Color.white.opacity(0.10)
    static let hitFlash = accentSoft.opacity(0.28)
    static let streak = accent
    static let danger = Color(red: 0.75, green: 0.28, blue: 0.32)
    static let dangerSoft = danger.opacity(0.18)
    /// Queue-end only. Never on the typing path.
    static let confetti = accentSoft
    static let warmLight = Color(red: 1.0, green: 0.86, blue: 0.72)

    static let night = canvas
    static let nightRaised = surface
    static let muted = inkSoft
}

enum Typo {
    static let screenTitle = Font.system(size: 34, weight: .semibold, design: .serif)
    static let bigNumber = Font.system(size: 44, weight: .semibold, design: .rounded)
    static let number = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let footnote = Font.footnote
    static let button = Font.system(size: 17, weight: .semibold)
}

enum Motion {
    static let hit: Animation = .easeOut(duration: 0.18)
    static let streak: Animation = .spring(duration: 0.26, bounce: 0.20)
    static let meter: Animation = .easeOut(duration: 0.28)
    static let toast: Animation = .easeOut(duration: 0.18)
}

enum Radius {
    static let card: CGFloat = 24
    static let chip: CGFloat = 14
    static let inner: CGFloat = 18
    static let meter: CGFloat = 6
}

typealias LoopfolioTheme = Theme

extension View {
    /// Liquid Glass when the SDK has it; material fallback otherwise. Never applied to TextField.
    @ViewBuilder
    func loopfolioGlass(cornerRadius: CGFloat = 20) -> some View {
        #if swift(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        #else
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
}
