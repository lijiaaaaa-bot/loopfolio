// Why: B overlay only. Canvas ≤16 rays. No Metal. Reduce Motion → static card ≤400ms.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CelebrationMomentView: View {
    let event: CelebrationEvent
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
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let elapsed = context.date.timeIntervalSince(startedAt)
                    let progress = min(1, elapsed / event.duration)
                    bloom(progress: progress)
                        .onChange(of: progress) { _, value in
                            if value >= 0.42 { fireCrestIfNeeded() }
                            if value >= 1 { finishIfNeeded() }
                        }
                }
            }
        }
        .onAppear { playStartHaptic() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.title)
        .accessibilityValue(event.subtitle)
    }

    private var reducedCard: some View {
        ZStack {
            Theme.canvas.opacity(0.35)
            VStack(spacing: 8) {
                Text(event.title).font(Typo.screenTitle)
                Text(event.subtitle).font(Typo.footnote).foregroundStyle(Theme.inkSoft)
            }
            .foregroundStyle(Theme.ink)
            .padding(24)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .allowsHitTesting(false)
        .task {
            try? await Task.sleep(for: .milliseconds(360))
            finishIfNeeded()
        }
    }

    private func bloom(progress: Double) -> some View {
        ZStack {
            EnergyBloomCanvas(progress: progress, kind: event.kind)
            caption(progress: progress)
        }
    }

    private func caption(progress: Double) -> some View {
        let envelope = EnergyBloomCanvas.envelope(progress)
        return VStack(spacing: 8) {
            Text(event.title)
                .font(Typo.screenTitle)
                .tracking(1.2)
            Text(event.subtitle)
                .font(Typo.footnote)
                .foregroundStyle(Theme.ink.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .foregroundStyle(Theme.ink)
        .opacity(envelope)
        .allowsHitTesting(false)
    }

    private func playStartHaptic() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
        #endif
    }

    private func fireCrestIfNeeded() {
        guard !crestFired else { return }
        crestFired = true
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    private func finishIfNeeded() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
