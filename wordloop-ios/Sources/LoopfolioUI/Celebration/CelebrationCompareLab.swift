// Why: A vs C is the experiment. B is an optional middle control per
// D-CINEMATIC-CLIMAX-SPEC.md. Typing never owns ClimaxOverlay.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum LabLane: String, CaseIterable, Identifiable {
    case keystroke = "A 击键层"
    case cinema = "C 电影高潮"

    public var id: String { rawValue }

    public var headline: String {
        switch self {
        case .keystroke: return "A 击键层"
        case .cinema: return "C 电影高潮"
        }
    }

    public var blurb: String {
        switch self {
        case .keystroke:
            return "打对：HitFlash + 迷你掌握条 + StreakBadge，≤300ms。从不是全屏电影。"
        case .cinema:
            return "仅「今日清完 / 词力大升级」。先提交本局、收键盘，再播 ClimaxOverlay 1.8–2.8s。"
        }
    }
}

public struct CelebrationCompareLab: View {
    @State private var lane: LabLane = .keystroke
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
                optionalBControl

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
            toast = nil
            celebration.cancelAll()
            climax.cancel()
            fieldFocused = (newLane == .keystroke)
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

    private var optionalBControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("可选中间层")
                .font(Typo.footnote.weight(.semibold))
                .foregroundStyle(Theme.inkSoft)
            Button {
                triggerB(.masteryLeap)
            } label: {
                Label("B 小高潮 · 掌握跃迁", systemImage: "circle.hexagonpath")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LabButtonStyle(emphasis: .secondary))
            Button {
                triggerB(.streak)
            } label: {
                Label("B 小高潮 · 连击里程碑", systemImage: "flame")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LabButtonStyle(emphasis: .secondary))
            Text("0.6–1.2s，Canvas ≤16 条径向线。不是电影。")
                .font(Typo.footnote)
                .foregroundStyle(Theme.inkSoft)
        }
    }

    private var isolationNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("规格")
                .font(Typo.footnote.weight(.semibold))
                .foregroundStyle(Theme.accentSoft)
            Text("对照 D-POWER-METER-SPEC.md 与 D-CINEMATIC-CLIMAX-SPEC.md。A 用 HitFlash / StreakBadge / 迷你条。C 用隔离 ClimaxOverlay（TimelineView + Canvas，无 SpriteKit / 主路径 Metal）。键盘未收、词未提交则不起 C。")
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
        #if os(iOS)
        resignKeyboard()
        #endif
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

    #if os(iOS)
    private func resignKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    #endif
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
