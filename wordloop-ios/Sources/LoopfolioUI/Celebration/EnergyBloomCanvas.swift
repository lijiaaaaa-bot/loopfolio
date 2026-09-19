// Why: B 小高潮 only — SwiftUI Canvas, ≤16 radial rays, no Metal, no SpriteKit.

import SwiftUI

struct EnergyBloomCanvas: View {
    static let maxRays = 16

    let progress: Double
    let kind: CelebrationEvent.Kind

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.46)
            let envelope = Self.envelope(progress)
            let radius = min(size.width, size.height)

            drawVeil(context: &context, size: size, envelope: envelope)
            drawBloom(context: &context, center: center, radius: radius, envelope: envelope)
            drawRays(context: &context, center: center, radius: radius, envelope: envelope)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    static func envelope(_ progress: Double) -> Double {
        let p = min(1, max(0, progress))
        if p < 0.18 { return p / 0.18 }
        if p > 0.72 { return max(0, 1 - (p - 0.72) / 0.28) }
        return 1
    }

    private var rayCount: Int {
        min(Self.maxRays, kind == .streak ? 16 : 12)
    }

    private func drawVeil(context: inout GraphicsContext, size: CGSize, envelope: Double) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(Theme.canvas.opacity(0.22 * envelope))
        )
    }

    private func drawBloom(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        let r = radius * 0.42 * (0.55 + 0.45 * envelope)
        var ctx = context
        ctx.addFilter(.blur(radius: 14 * envelope + 4))
        ctx.fill(
            Path(ellipseIn: CGRect(x: center.x - r / 2, y: center.y - r / 2, width: r, height: r)),
            with: .color(Theme.accentSoft.opacity(0.28 * envelope))
        )
    }

    private func drawRays(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, envelope: Double) {
        for i in 0..<rayCount {
            var path = Path()
            let phase = Double(i) * (.pi * 2 / Double(rayCount))
            let outer = radius * (0.18 + 0.10 * envelope)
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + cos(phase) * outer, y: center.y + sin(phase) * outer))
            context.stroke(
                path,
                with: .color(Theme.accent.opacity(0.42 * envelope)),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
            )
        }
    }
}
