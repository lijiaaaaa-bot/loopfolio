// Why: A 击键层 only — HitFlash + StreakBadge + mini meter, ≤300ms, never fullscreen.

import SwiftUI

struct KeystrokeStrip: View {
    @Binding var session: FakeTypingSession
    var focus: FocusState<Bool>.Binding
    var autoFocus: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("看释义，敲英文")
                    .font(Typo.footnote)
                    .foregroundStyle(Theme.inkSoft)
                Spacer()
                StreakBadge(count: session.streak)
            }

            HitFlash(token: session.flashToken, armed: session.lastOutcome == .wordComplete) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(LabWordBank.gloss(for: session.target))
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundStyle(session.lastOutcome == .wrong ? Theme.inkSoft : Theme.ink)
                    Spacer()
                    Text(session.target)
                        .font(.caption.monospaced())
                        .foregroundStyle(Theme.inkSoft.opacity(0.7))
                        .accessibilityHidden(true)
                }
            }

            TextField("输入 \(session.target)", text: typedBinding)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                #endif
                .focused(focus)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.inner, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
                        .stroke(Theme.accent.opacity(0.22), lineWidth: 1)
                }
                .sensoryFeedback(.selection, trigger: session.flashToken)
                .sensoryFeedback(.success, trigger: session.wordsCleared)

            MasteryMeter(value: session.mastery, size: .mini)
        }
        .padding(16)
        .background(Theme.surface.opacity(0.92), in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .onAppear { if autoFocus { focus.wrappedValue = true } }
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
