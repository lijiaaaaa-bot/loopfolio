// Why: one palette taken from the public Loopfolio pages (violet on near-black / paper).
// Not a theming system — just enough constants so the lab and the thin host look like the same app.

import SwiftUI

enum LoopfolioTheme {
    static let ink = Color(red: 0.078, green: 0.071, blue: 0.122)
    static let paper = Color(red: 0.961, green: 0.953, blue: 1.0)
    static let night = Color(red: 0.047, green: 0.043, blue: 0.071)
    static let nightRaised = Color(red: 0.09, green: 0.082, blue: 0.145)
    static let accent = Color(red: 0.424, green: 0.298, blue: 0.941)
    static let accentSoft = Color(red: 0.643, green: 0.545, blue: 1.0)
    static let warmLight = Color(red: 1.0, green: 0.86, blue: 0.72)
    static let muted = Color(red: 0.38, green: 0.365, blue: 0.467)
    static let success = Color(red: 0.31, green: 0.72, blue: 0.56)

    /// Keystroke path only: stay under 80ms so the finger still owns the loop.
    static let keystrokeFlash: Animation = .easeOut(duration: 0.055)
    static let toast: Animation = .easeOut(duration: 0.18)
}

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
