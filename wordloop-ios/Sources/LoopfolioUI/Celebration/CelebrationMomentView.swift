// Why: the only place TimelineView / optional colorEffect live. Host removes this view
// when the store clears `current`, so heavy GPU work cannot linger on the typing frame.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CelebrationMomentView: View {
    let event: CelebrationEvent
    let onFinished: () -> Void

    @State private var startedAt = Date()
    @State private var didFinish = false
    @State private var crestFired = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let elapsed = context.date.timeIntervalSince(startedAt)
            let progress = min(1, elapsed / event.duration)
            bloom(progress: progress)
                .onChange(of: progress) { _, value in
                    if value >= 0.42 { fireCrestIfNeeded() }
                    if value >= 1 { finishIfNeeded() }
                }
        }
        .onAppear { playStartHaptic() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.title)
        .accessibilityValue(event.subtitle)
    }

    @ViewBuilder
    private func bloom(progress: Double) -> some View {
        let canvas = EnergyBloomCanvas(progress: progress, kind: event.kind)
        let caption = caption(progress: progress)

        ZStack {
            if #available(iOS 17.0, *) {
                canvas
                    .colorEffect(
                        ShaderLibrary.energyTint(
                            .float(Float(progress * event.duration)),
                            .float(Float(EnergyBloomCanvas.envelope(progress)))
                        )
                    )
            } else {
                canvas
            }
            caption
        }
    }

    private func caption(progress: Double) -> some View {
        let envelope = EnergyBloomCanvas.envelope(progress)
        return VStack(spacing: 8) {
            Text(event.title)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .tracking(1.2)
            Text(event.subtitle)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .foregroundStyle(.white)
        .opacity(envelope)
        .scaleEffect(0.96 + 0.04 * envelope)
        .allowsHitTesting(false)
    }

    private func playStartHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.7)
        #endif
    }

    private func fireCrestIfNeeded() {
        guard !crestFired else { return }
        crestFired = true
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    private func finishIfNeeded() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
