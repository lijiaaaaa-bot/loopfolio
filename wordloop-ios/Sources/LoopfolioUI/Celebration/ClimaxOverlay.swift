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
            Color.black.opacity(0.58)
            VStack(spacing: 16) {
                HeroMasteryRing(value: event.toMastery, glowing: true)
                    .frame(width: 196, height: 196)
                Text(event.title)
                    .font(Typo.screenTitle)
                Text(event.subtitle)
                    .font(Typo.footnote)
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
            ClimaxAtmosphereCanvas(elapsed: elapsed, duration: duration)
            if ClimaxBeat.scrapsActive(elapsed: elapsed) {
                ClimaxScrapCanvas(elapsed: elapsed, seed: event.id)
            }
            VStack(spacing: 22) {
                HeroMasteryRing(value: fill, glowing: true)
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)
                    .shadow(color: Theme.accentSoft.opacity(0.55 * veil), radius: 36, y: 2)
                    .shadow(color: Theme.accent.opacity(0.28 * veil), radius: 16)
                VStack(spacing: 10) {
                    Text(event.title)
                        .font(Typo.screenTitle)
                        .tracking(2.2)
                    Text(event.subtitle)
                        .font(Typo.footnote)
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
            .background(Theme.accent, in: Capsule())
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
    var glowing: Bool = false

    var body: some View {
        ZStack {
            if glowing {
                Circle()
                    .fill(Theme.accentSoft.opacity(0.22))
                    .blur(radius: 28)
                    .padding(18)
            }
            Canvas { context, size in
                let inset: CGFloat = 12
                let rect = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
                var track = Path()
                track.addEllipse(in: rect)
                context.stroke(track, with: .color(Theme.powerTrack), lineWidth: 12)
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
                    with: .color(Theme.powerFill),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
            }
            VStack(spacing: 4) {
                Text("\(Int((value * 100).rounded()))%")
                    .font(Typo.bigNumber)
                    .monospacedDigit()
                Text("已掌握")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("掌握")
        .accessibilityValue("\(Int((value * 100).rounded())) 百分之")
    }
}

/// Room change behind the hero meter: vignette + energy wash + one expanding ring.
/// Canvas only. No Metal, no SpriteKit, no cartoon.
struct ClimaxAtmosphereCanvas: View {
    let elapsed: TimeInterval
    let duration: TimeInterval

    var body: some View {
        Canvas { context, size in
            let veil = ClimaxBeat.overlayOpacity(elapsed: elapsed, duration: duration)
            let center = CGPoint(x: size.width / 2, y: size.height * 0.40)
            let reach = hypot(size.width, size.height)

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .radialGradient(
                    Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.42 * veil)
                    ]),
                    center: center,
                    startRadius: reach * 0.16,
                    endRadius: reach * 0.62
                )
            )

            let bloomR = min(size.width, size.height) * 0.46
            var bloom = context
            bloom.addFilter(.blur(radius: 26))
            bloom.opacity = 0.90 * veil
            bloom.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - bloomR / 2,
                    y: center.y - bloomR / 2,
                    width: bloomR,
                    height: bloomR
                )),
                with: .color(Theme.accentSoft.opacity(0.34))
            )

            let coreR = bloomR * 0.42
            var core = context
            core.addFilter(.blur(radius: 16))
            core.opacity = 0.80 * veil
            core.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - coreR / 2,
                    y: center.y - coreR / 2,
                    width: coreR,
                    height: coreR
                )),
                with: .color(Theme.warmLight.opacity(0.16))
            )

            if elapsed >= 0.32, elapsed <= 1.55 {
                let t = (elapsed - 0.32) / 1.23
                let radius = 96 + CGFloat(ClimaxBeat.easeOut(t)) * min(size.width, size.height) * 0.30
                var ring = Path()
                ring.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                context.stroke(
                    ring,
                    with: .color(Theme.accentSoft.opacity(0.50 * (1 - t) * veil)),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// ≤24 accent scraps, outward from the ring, weak gravity, no spin carnival.
struct ClimaxScrapCanvas: View {
    static let maxScraps = 24

    let elapsed: TimeInterval
    let seed: UUID

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.40)
            let ring: CGFloat = 112
            let local = elapsed - 0.40
            for index in 0..<Self.maxScraps {
                let scrap = scrapAt(index)
                let life = min(1.2, scrap.life)
                guard local >= scrap.delay, local - scrap.delay <= life else { continue }
                let t = (local - scrap.delay) / life
                let dist = ring + CGFloat(t) * size.width * 0.42
                let gravity = CGFloat(t * t) * 32
                let point = CGPoint(
                    x: center.x + cos(scrap.angle) * dist,
                    y: center.y + sin(scrap.angle) * dist * 0.84 + gravity
                )
                let rect = CGRect(
                    x: point.x - scrap.w / 2,
                    y: point.y - scrap.h / 2,
                    width: scrap.w,
                    height: scrap.h
                )
                var ctx = context
                ctx.opacity = 0.96 * (1 - t)
                ctx.fill(Path(roundedRect: rect, cornerRadius: 1.4), with: .color(scrap.color))
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
        let colors = [Theme.accent, Theme.accentSoft, Theme.warmLight]
        return (
            angle: Double(index) * (.pi * 2 / 24) + u * 0.18,
            delay: v * 0.16,
            life: 0.75 + u * 0.40,
            w: 9 + CGFloat(index % 3) * 3,
            h: 2.6 + CGFloat(index % 2),
            color: colors[index % colors.count]
        )
    }
}
