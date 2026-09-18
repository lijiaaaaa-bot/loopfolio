// Why: A / B / C QA rooms. Production settlement is TypingSessionView + SessionDirector,
// not these buttons. A never owns a TimelineView. B is a short bloom. C is ClimaxOverlay.

import SwiftUI

public enum LabLane: String, CaseIterable, Identifiable {
    case keystroke = "A · 手感"
    case smallClimax = "B · 小高潮"
    case cinema = "C · 电影"

    public var id: String { rawValue }

    public var headline: String {
        switch self {
        case .keystroke: return "A · 手感"
        case .smallClimax: return "B · 小高潮"
        case .cinema: return "C · 电影高潮"
        }
    }

    public var blurb: String {
        switch self {
        case .keystroke:
            return "打对：HitFlash + 迷你掌握条 + StreakBadge，≤300ms。从不是全屏电影。"
        case .smallClimax:
            return "掌握跃迁 / 连击里程碑。0.6–1.2s，Canvas ≤16 条径向线。改不了 App 气质。"
        case .cinema:
            return "今日清完 / 词力大升级。先交局、收键盘，再播 ClimaxOverlay：压暗 55–65%、仪表 1.15–1.25、≤24 色屑、Typo.screenTitle「今日清空」/「词力提升」，1.8–2.8s。"
        }
    }
}

public struct CelebrationCompareLab: View {
    @State private var lane: LabLane = .cinema
    @State private var session = FakeTypingSession()
    @State private var toast: String?
    @State private var celebration = CelebrationStore()
    @State private var climax = ClimaxStore()
    @FocusState private var fieldFocused: Bool

    public init() {}

    public var body: some View {
        ClimaxHost(store: climax) {
            CelebrationHost(store: celebration) {
                labContent
            }
        }
        .animation(Motion.toast, value: toast)
        .onAppear { enterLane(lane, playDemo: true) }
    }

    private var labContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                picker
                Text(lane.blurb)
                    .font(Typo.footnote)
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                KeystrokeStrip(
                    session: $session,
                    focus: $fieldFocused,
                    autoFocus: lane == .keystroke
                )

                rareEventButtons

                if let toast {
                    WeakToast(text: toast)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                isolationNote
            }
            .padding(20)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .foregroundStyle(Theme.ink)
        .navigationTitle("词力对比实验")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .onChange(of: lane) { _, newLane in
            enterLane(newLane, playDemo: true)
        }
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lane.headline)
                .font(.title3.weight(.semibold))
            Picker("路径", selection: $lane) {
                ForEach(LabLane.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private var rareEventButtons: some View {
        switch lane {
        case .keystroke:
            VStack(spacing: 10) {
                labButton("触发掌握跃迁", icon: "arrow.up.right.circle", emphasis: .primary) {
                    triggerA(toast: "掌握 +6%（无全屏）")
                }
                labButton("触发本局清完", icon: "checkmark.circle", emphasis: .secondary) {
                    triggerA(toast: "本局记了一笔（无全屏）")
                }
            }
        case .smallClimax:
            VStack(spacing: 10) {
                labButton("触发掌握跃迁", icon: "circle.hexagonpath", emphasis: .primary) {
                    triggerB(.masteryLeap)
                }
                labButton("触发连击里程碑", icon: "flame", emphasis: .secondary) {
                    triggerB(.streak)
                }
            }
        case .cinema:
            VStack(spacing: 10) {
                labButton("触发今日清完", icon: "checkmark.circle", emphasis: .primary) {
                    triggerC(.sessionClear, surge: 0.12)
                }
                labButton("触发词力大升级", icon: "sparkles", emphasis: .secondary) {
                    triggerC(.powerUpgrade, surge: 0.22)
                }
            }
        }
    }

    private var isolationNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("规格")
                .font(Typo.footnote.weight(.semibold))
                .foregroundStyle(Theme.accentSoft)
            Text("三段对照：A 手感 / B 小高潮 / C 电影。A 用 HitFlash / StreakBadge / 迷你条。B 用 CelebrationHost + ≤16 径向线。C 用隔离 ClimaxOverlay（TimelineView + Canvas，无 SpriteKit / 主路径 Metal）。键盘未收、词未提交则不起 C。")
                .font(Typo.footnote)
                .foregroundStyle(Theme.inkSoft)
        }
        .padding(.top, 8)
    }

    private func labButton(_ title: String, icon: String, emphasis: LabButtonStyle.Emphasis, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(LabButtonStyle(emphasis: emphasis))
    }

    private func enterLane(_ next: LabLane, playDemo: Bool) {
        toast = nil
        celebration.cancelAll()
        climax.cancel()
        switch next {
        case .keystroke:
            fieldFocused = true
        case .smallClimax:
            fieldFocused = false
            KeyboardResign.resign()
            if playDemo {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(80))
                    guard lane == .smallClimax else { return }
                    triggerB(.masteryLeap)
                }
            }
        case .cinema:
            fieldFocused = false
            KeyboardResign.resign()
            if playDemo {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(160))
                    guard lane == .cinema, !fieldFocused else { return }
                    triggerC(.sessionClear, surge: 0.12)
                }
            }
        }
    }

    private func triggerA(toast text: String) {
        session.bumpMasteryForWeakToast()
        toast = text
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1400))
            if toast == text { toast = nil }
        }
    }

    private func triggerB(_ kind: CelebrationEvent.Kind) {
        toast = nil
        session.bumpMasteryForWeakToast()
        celebration.enqueue(kind)
    }

    private func triggerC(_ kind: ClimaxEvent.Kind, surge: Double) {
        toast = nil
        session.submitSession()
        fieldFocused = false
        KeyboardResign.resign()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            guard session.sessionSubmitted, !fieldFocused else { return }
            let range = session.surgeMastery(by: surge)
            climax.play(
                ClimaxEvent(kind: kind, fromMastery: range.from, toMastery: range.to),
                keyboardFocused: fieldFocused
            )
        }
    }
}

struct LabButtonStyle: ButtonStyle {
    enum Emphasis { case primary, secondary }
    let emphasis: Emphasis

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typo.button)
            .padding(.vertical, 14)
            .foregroundStyle(Theme.onAccent)
            .background(background, in: Capsule())
            .opacity(configuration.isPressed ? 0.82 : 1)
    }

    private var background: Color {
        switch emphasis {
        case .primary: return Theme.accent
        case .secondary: return Theme.surface
        }
    }
}
