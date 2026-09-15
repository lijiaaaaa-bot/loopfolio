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

    /// B is a small climax (0.6–1.2s). Keep the room readable; C owns the atmosphere.
    static func envelope(_ progress: Double) -> Double {
        let p = min(1, max(0, progress))
        if p < 0.18 { return p / 0.18 }
        if p > 0.72 { return max(0, 1 - (p - 0.72) / 0.28) }
        return 1
    }

    private func drawVeil(context: inout GraphicsContext, size: CGSize, envelope: Double) {
        let alpha = (kind == .streak ? 0.22 : 0.28) * envelope
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(LoopfolioTheme.night.opacity(alpha))
        )
    }

    private func drawBloom(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let layers: [(Double, Color, Double)] = [
            (0.72, LoopfolioTheme.accent, kind == .streak ? 0.22 : 0.28),
            (0.40, LoopfolioTheme.accentSoft, 0.32),
            (0.16, LoopfolioTheme.warmLight, 0.40),
        ]
        for (scale, color, opacity) in layers {
            let r = radius * scale * (0.50 + 0.50 * envelope)
            var ctx = context
            ctx.addFilter(.blur(radius: 18 * envelope + 6))
            ctx.fill(
                Path(ellipseIn: CGRect(x: center.x - r / 2, y: center.y - r / 2, width: r, height: r)),
                with: .color(color.opacity(opacity * envelope))
            )
        }
    }

    private func drawFilaments(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let count = kind == .streak ? 5 : 7
        for i in 0..<count {
            var path = Path()
            let phase = Double(i) * 0.7 + progress * 2.1
            let inner = radius * 0.03
            path.move(to: center)
            for step in 1...22 {
                let t = Double(step) / 22.0
                let angle = phase + t * 1.35 + sin(progress * 6.0 + Double(i)) * 0.35
                let dist = inner + CGFloat(t) * radius * (0.16 + 0.14 * envelope)
                let point = CGPoint(
                    x: center.x + cos(angle) * dist,
                    y: center.y + sin(angle) * dist * 0.9
                )
                path.addLine(to: point)
            }
            context.stroke(
                path,
                with: .color(LoopfolioTheme.accentSoft.opacity(0.40 * envelope)),
                style: StrokeStyle(lineWidth: 1.3, lineCap: .round)
            )
        }
    }

    private func drawMotes(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let count = kind == .streak ? 10 : 14
        for i in 0..<count {
            let seed = Double(i) * 1.618
            let angle = seed + progress * (1.2 + Double(i % 5) * 0.15)
            let dist = radius * (0.10 + 0.42 * ((seed * 0.13).truncatingRemainder(dividingBy: 1)))
            let expand = dist * (0.55 + 0.40 * envelope)
            let point = CGPoint(x: center.x + cos(angle) * expand, y: center.y + sin(angle) * expand)
            let mote = 1.8 + CGFloat((i % 3)) * 1.0
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - mote / 2, y: point.y - mote / 2, width: mote, height: mote)),
                with: .color(LoopfolioTheme.warmLight.opacity(0.50 * envelope))
            )
        }
    }
}
