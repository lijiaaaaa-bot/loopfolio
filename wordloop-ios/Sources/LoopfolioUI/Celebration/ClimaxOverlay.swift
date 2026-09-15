// Why: the 气质 layer. Not a louder EnergyBloom — dim the room, hero the meter,
// scatter ≤24 accent scraps, title, fade. TimelineView lives only while `current` is set.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct ClimaxHost<Content: View>: View {
    @Bindable var store: ClimaxStore
    let content: Content

    public init(store: ClimaxStore, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
            if let event = store.current {
                ClimaxOverlay(event: event) {
                    store.finishCurrent(id: event.id)
                }
                .id(event.id)
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: store.current?.id)
    }
}

struct ClimaxOverlay: View {
    let event: ClimaxEvent
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startedAt = Date()
    @State private var didFinish = false
    @State private var crestFired = false

    var body: some View {
        Group {
            if reduceMotion {
                reducedCard
            } else {
                cinematic
            }
        }
        .onAppear { playStartHaptic() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(event.title)
        .accessibilityValue(event.subtitle)
    }

    private var playDuration: TimeInterval {
        reduceMotion ? ClimaxEvent.reduceMotionDuration : event.duration
    }

    private var reducedCard: some View {
        ZStack {
            Color.black.opacity(0.55)
            VStack(spacing: 16) {
                HeroMasteryRing(value: event.toMastery)
                    .frame(width: 196, height: 196)
                Text(event.title)
                    .font(LoopfolioTheme.screenTitle)
                Text(event.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                continueButton
            }
            .foregroundStyle(.white)
        }
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(for: .milliseconds(Int(ClimaxEvent.reduceMotionDuration * 1000)))
            finishIfNeeded()
        }
    }

    private var cinematic: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let elapsed = context.date.timeIntervalSince(startedAt)
            let duration = event.duration
            climaxFrame(elapsed: elapsed, duration: duration)
                .onChange(of: elapsed) { _, value in
                    if value >= 0.42 { fireCrestIfNeeded() }
                    if value >= duration { finishIfNeeded() }
                }
        }
    }

    private func climaxFrame(elapsed: TimeInterval, duration: TimeInterval) -> some View {
        let dim = ClimaxBeat.dimOpacity(elapsed: elapsed, duration: duration)
        let scale = ClimaxBeat.meterScale(elapsed: elapsed)
        let fill = ClimaxBeat.meterFill(elapsed: elapsed, from: event.fromMastery, to: event.toMastery)
        let title = ClimaxBeat.titleOpacity(elapsed: elapsed, duration: duration)
        let flash = ClimaxBeat.flashOpacity(elapsed: elapsed)
        let veil = ClimaxBeat.overlayOpacity(elapsed: elapsed, duration: duration)

        return ZStack {
            Color.black.opacity(dim)
            if ClimaxBeat.scrapsActive(elapsed: elapsed) {
                ClimaxScrapCanvas(elapsed: elapsed, seed: event.id)
            }
            VStack(spacing: 22) {
                HeroMasteryRing(value: fill)
                    .frame(width: 216, height: 216)
                    .scaleEffect(scale)
                VStack(spacing: 8) {
                    Text(event.title)
                        .font(LoopfolioTheme.screenTitle)
                        .tracking(1.4)
                    Text(event.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .opacity(title)
                continueButton
                    .opacity(title)
            }
            .foregroundStyle(.white)
            Color.white.opacity(flash)
                .allowsHitTesting(false)
        }
        .opacity(veil)
        .ignoresSafeArea()
    }

    private var continueButton: some View {
        Button("继续") { finishIfNeeded() }
            .font(.body.weight(.medium))
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(LoopfolioTheme.accent, in: Capsule())
            .foregroundStyle(.white)
            .padding(.top, 8)
    }

    private func playStartHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: reduceMotion ? .soft : .heavy)
        generator.impactOccurred(intensity: reduceMotion ? 0.5 : 1.0)
        #endif
    }

    private func fireCrestIfNeeded() {
        guard !crestFired, !reduceMotion else { return }
        crestFired = true
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.8)
        #endif
    }

    private func finishIfNeeded() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}

struct HeroMasteryRing: View {
    let value: Double

    var body: some View {
        ZStack {
            Canvas { context, size in
                let inset: CGFloat = 12
                let rect = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
                var track = Path()
                track.addEllipse(in: rect)
                context.stroke(track, with: .color(LoopfolioTheme.powerTrack), lineWidth: 12)
                var fill = Path()
                fill.addArc(
                    center: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: (min(size.width, size.height) / 2) - inset,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + 360 * value),
                    clockwise: false
                )
                context.stroke(
                    fill,
                    with: .color(LoopfolioTheme.powerFill),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
            }
            VStack(spacing: 4) {
                Text("\(Int((value * 100).rounded()))%")
                    .font(LoopfolioTheme.bigNumber)
                    .monospacedDigit()
                Text("已掌握")
                    .font(.footnote)
                    .foregroundStyle(LoopfolioTheme.muted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("掌握")
        .accessibilityValue("\(Int((value * 100).rounded())) 百分之")
    }
}

/// ≤24 accent scraps, outward from the ring, weak gravity, no spin carnival.
struct ClimaxScrapCanvas: View {
    let elapsed: TimeInterval
    let seed: UUID

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
            let ring: CGFloat = 108
            let local = elapsed - 0.40
            for index in 0..<24 {
                let scrap = scrapAt(index)
                let life = min(1.2, scrap.life)
                guard local >= scrap.delay, local - scrap.delay <= life else { continue }
                let t = (local - scrap.delay) / life
                let dist = ring + CGFloat(t) * size.width * 0.38
                let gravity = CGFloat(t * t) * 28
                let point = CGPoint(
                    x: center.x + cos(scrap.angle) * dist,
                    y: center.y + sin(scrap.angle) * dist * 0.86 + gravity
                )
                let rect = CGRect(x: point.x - scrap.w / 2, y: point.y - scrap.h / 2, width: scrap.w, height: scrap.h)
                var ctx = context
                ctx.opacity = 0.92 * (1 - t)
                ctx.fill(Path(roundedRect: rect, cornerRadius: 1.2), with: .color(scrap.color))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func scrapAt(_ index: Int) -> (angle: Double, delay: Double, life: Double, w: CGFloat, h: CGFloat, color: Color) {
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(index)
        let bits = hasher.finalize()
        let u = Double(abs(bits % 1000)) / 1000
        let v = Double(abs((bits / 1000) % 1000)) / 1000
        let colors = [LoopfolioTheme.accent, LoopfolioTheme.accentSoft, LoopfolioTheme.warmLight]
        return (
            angle: Double(index) * (.pi * 2 / 24) + u * 0.2,
            delay: v * 0.18,
            life: 0.7 + u * 0.5,
            w: 5 + CGFloat(index % 3) * 2,
            h: 2 + CGFloat(index % 2),
            color: colors[index % colors.count]
        )
    }
}
