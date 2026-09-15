// Why: procedural cinema — no video, no SpriteKit loop. Drawn only while CelebrationHost
// has a current event; the parent tears this view down so TimelineView / shaders die with it.

import SwiftUI

struct EnergyBloomCanvas: View {
    let progress: Double
    let kind: CelebrationEvent.Kind

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.46)
            let envelope = Self.envelope(progress)
            let radius = min(size.width, size.height)

            drawVeil(context: &context, size: size, envelope: envelope)
            drawBloom(context: &context, center: center, radius: radius, envelope: envelope)
            drawFilaments(context: &context, center: center, radius: radius, envelope: envelope)
            drawMotes(context: &context, center: center, radius: radius, envelope: envelope)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Ease in, hold a bright crest, ease out — 0.8–1.8s feels like a cut, not a loop.
    static func envelope(_ progress: Double) -> Double {
        let p = min(1, max(0, progress))
        if p < 0.18 { return p / 0.18 }
        if p > 0.72 { return max(0, 1 - (p - 0.72) / 0.28) }
        return 1
    }

    private func drawVeil(context: inout GraphicsContext, size: CGSize, envelope: Double) {
        let alpha = (kind == .sessionClear ? 0.42 : 0.28) * envelope
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(LoopfolioTheme.night.opacity(alpha))
        )
    }

    private func drawBloom(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let layers: [(Double, Color, Double)] = [
            (0.92, LoopfolioTheme.accent, kind == .sessionClear ? 0.34 : 0.26),
            (0.55, LoopfolioTheme.accentSoft, 0.40),
            (0.22, LoopfolioTheme.warmLight, 0.55),
        ]
        for (scale, color, opacity) in layers {
            let r = radius * scale * (0.55 + 0.45 * envelope)
            var ctx = context
            ctx.addFilter(.blur(radius: 28 * envelope + 8))
            ctx.fill(
                Path(ellipseIn: CGRect(x: center.x - r / 2, y: center.y - r / 2, width: r, height: r)),
                with: .color(color.opacity(opacity * envelope))
            )
        }
    }

    private func drawFilaments(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let count = kind == .sessionClear ? 7 : 5
        for i in 0..<count {
            var path = Path()
            let phase = Double(i) * 0.73 + progress * 2.1
            let inner = radius * 0.04
            path.move(to: center)
            for step in 1...18 {
                let t = Double(step) / 18.0
                let angle = phase + t * 1.25 + sin(progress * 6.0 + Double(i)) * 0.35
                let dist = inner + CGFloat(t) * radius * (0.18 + 0.22 * envelope)
                let point = CGPoint(
                    x: center.x + cos(angle) * dist,
                    y: center.y + sin(angle) * dist * 0.86
                )
                path.addLine(to: point)
            }
            context.stroke(
                path,
                with: .color(LoopfolioTheme.accentSoft.opacity(0.45 * envelope)),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
            )
        }
    }

    private func drawMotes(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let count = kind == .sessionClear ? 28 : 18
        for i in 0..<count {
            let seed = Double(i) * 1.618
            let angle = seed + progress * (1.2 + Double(i % 5) * 0.15)
            let dist = radius * (0.08 + 0.38 * ((seed * 0.13).truncatingRemainder(dividingBy: 1)))
            let expand = dist * (0.65 + 0.55 * envelope)
            let point = CGPoint(x: center.x + cos(angle) * expand, y: center.y + sin(angle) * expand)
            let mote = 2.0 + CGFloat((i % 3)) * 1.2
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - mote / 2, y: point.y - mote / 2, width: mote, height: mote)),
                with: .color(LoopfolioTheme.warmLight.opacity(0.55 * envelope))
            )
        }
    }
}
