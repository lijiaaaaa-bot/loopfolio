// Why: the real typing round. A is the field. B is CelebrationHost at root.
// C is ClimaxHost at root, played only after resign + SessionDirector settlement.

import SwiftUI

public struct TypingSessionView: View {
    @Bindable var progress: DailyProgress
    var climax: ClimaxStore
    var celebration: CelebrationStore

    @State private var session: FakeTypingSession
    @State private var settled = false
    @FocusState private var fieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    public init(progress: DailyProgress, climax: ClimaxStore, celebration: CelebrationStore) {
        self.progress = progress
        self.climax = climax
        self.celebration = celebration
        let remaining = progress.remaining > 0 ? progress.remaining : LabWordBank.words.count
        _session = State(initialValue: .dailyRound(mastery: progress.mastery, remaining: remaining))
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 12)
            if settled {
                settlementCard
            } else {
                prompt
                field
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .foregroundStyle(Theme.ink)
        .navigationTitle("打字")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .onAppear {
            if !settled { fieldFocused = true }
        }
        .onDisappear {
            persistAndMaybeUpgradeCinema()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(settled ? "本局收束" : "还剩 \(max(1, session.remainingCount)) 词")
                .font(Typo.footnote)
                .foregroundStyle(Theme.inkSoft)
            Spacer()
            MasteryMeter(value: session.mastery, size: .mini)
            StreakBadge(count: session.streak)
        }
    }

    private var prompt: some View {
        HitFlash(token: session.flashToken, armed: session.lastOutcome == .wordComplete) {
            VStack(alignment: .leading, spacing: 10) {
                Text(LabWordBank.gloss(for: session.target))
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(session.lastOutcome == .wrong ? Theme.inkSoft : Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(session.target)
                    .font(.caption.monospaced())
                    .foregroundStyle(Theme.inkSoft.opacity(0.55))
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
    }

    private var field: some View {
        TextField("输入 \(session.target)", text: typedBinding)
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            .keyboardType(.asciiCapable)
            #endif
            .focused($fieldFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.inner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
                    .stroke(Theme.accent.opacity(0.22), lineWidth: 1)
            }
            .sensoryFeedback(.selection, trigger: session.flashToken)
            .sensoryFeedback(.success, trigger: session.wordsCleared)
    }

    private var settlementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(progress.clearedToday ? "今日队列已清空" : "本局已提交")
                .font(Typo.screenTitle)
            Text("可以停，也可以再来一局。")
                .font(Typo.footnote)
                .foregroundStyle(Theme.inkSoft)
            Button("回到首页") { dismiss() }
                .buttonStyle(LabButtonStyle(emphasis: .primary))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var typedBinding: Binding<String> {
        Binding(
            get: { session.typed },
            set: { applyInput($0) }
        )
    }

    private func applyInput(_ raw: String) {
        let turn = SessionDirector.ingest(
            raw,
            session: &session,
            alreadyCelebratedClear: progress.clearedToday
        )
        progress.apply(session)

        if let kind = turn.smallClimax {
            celebration.enqueue(kind)
        }

        guard turn.didSettle else { return }
        playCinema(turn.cinema, from: turn.fromMastery, to: turn.toMastery)
    }

    private func playCinema(_ kinds: [ClimaxEvent.Kind], from: Double, to: Double) {
        settled = true
        fieldFocused = false
        KeyboardResign.resign()
        guard !kinds.isEmpty else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            guard !fieldFocused else { return }
            climax.playSettlement(
                kinds: kinds,
                fromMastery: from,
                toMastery: to,
                keyboardFocused: fieldFocused
            )
        }
    }

    private func persistAndMaybeUpgradeCinema() {
        progress.apply(session)
        guard !settled else { return }
        let kinds = SessionDirector.abandonCinema(
            session: session,
            alreadyCelebratedClear: progress.clearedToday
        )
        guard kinds.contains(.powerUpgrade) else { return }
        fieldFocused = false
        KeyboardResign.resign()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            guard !fieldFocused else { return }
            climax.playSettlement(
                kinds: kinds,
                fromMastery: session.sessionStartMastery,
                toMastery: session.mastery,
                keyboardFocused: fieldFocused
            )
        }
    }
}
