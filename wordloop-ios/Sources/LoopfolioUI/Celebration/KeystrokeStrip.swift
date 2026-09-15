// Why: A-path only — SensoryFeedback + a <80ms local flash/scale. No overlay, no TimelineView.

import SwiftUI

struct KeystrokeStrip: View {
    @Binding var session: FakeTypingSession
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("看释义，敲英文")
                .font(.caption)
                .foregroundStyle(LoopfolioTheme.muted)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("短暂的，转瞬即逝的")
                    .font(.system(size: 17, weight: .medium, design: .serif))
                Spacer()
                Text(session.target)
                    .font(.caption.monospaced())
                    .foregroundStyle(LoopfolioTheme.muted.opacity(0.7))
                    .accessibilityHidden(true)
            }

            TextField("输入 \(session.target)", text: typedBinding)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                #endif
                .focused($focused)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(LoopfolioTheme.nightRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(LoopfolioTheme.accent.opacity(session.lastOutcome == .wrong ? 0.7 : 0.22), lineWidth: 1)
                }
                .scaleEffect(session.lastOutcome == .correctChar || session.lastOutcome == .wordComplete ? 1.035 : 1)
                .animation(LoopfolioTheme.keystrokeFlash, value: session.flashToken)
                .sensoryFeedback(.selection, trigger: session.flashToken)
                .overlay(alignment: .trailing) {
                    Circle()
                        .fill(LoopfolioTheme.accentSoft.opacity(session.lastOutcome == .correctChar ? 0.55 : 0))
                        .frame(width: 9, height: 9)
                        .padding(.trailing, 14)
                        .animation(LoopfolioTheme.keystrokeFlash, value: session.flashToken)
                }

            MasteryMeter(value: session.mastery)
        }
        .padding(16)
        .background(LoopfolioTheme.nightRaised.opacity(0.7), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onAppear { focused = true }
        .onChange(of: session.lastOutcome) { _, outcome in
            if outcome == .wordComplete {
                session.loadNextWord(LabWordBank.next(after: session.target))
            }
        }
    }

    private var typedBinding: Binding<String> {
        Binding(
            get: { session.typed },
            set: { session.ingest($0) }
        )
    }
}

struct MasteryMeter: View {
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("掌握")
                    .font(.caption2)
                    .foregroundStyle(LoopfolioTheme.muted)
                Spacer()
                Text("\(Int((value * 100).rounded()))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(LoopfolioTheme.accentSoft)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(LoopfolioTheme.accent)
                        .frame(width: max(6, proxy.size.width * value))
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("掌握")
        .accessibilityValue("\(Int((value * 100).rounded())) 百分之")
    }
}

struct WeakToast: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .loopfolioGlass(cornerRadius: 14)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
    }
}
