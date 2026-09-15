// Why: sixty-second feel test. A never owns an overlay. B is a short isolated bloom.
// C is a different overlay (ClimaxOverlay) that can change the room's 气质.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum LabLane: String, CaseIterable, Identifiable {
    case keystroke = "A · 手感"
    case smallClimax = "B · 小高潮"
    case cinema = "C · 电影"

    public var id: String { rawValue }

    public var headline: String {
        switch self {
        case .keystroke: return "键程手感（无全屏）"
        case .smallClimax: return "小高潮（短 overlay）"
        case .cinema: return "电影高潮（气质层）"
        }
    }

    public var blurb: String {
        switch self {
        case .keystroke:
            return "每敲对一个字母 ≤300ms：触觉 + 闪/缩。稀有按钮只有弱 toast。"
        case .smallClimax:
            return "键程与 A 相同。掌握跃迁 / 连击走 CelebrationHost，0.6–1.2s，不改房间气质。"
        case .cinema:
            return "先收键盘再播 ClimaxOverlay：压暗 → 仪表放大冲格 → ≤24 色屑 →「今日清空」/「词力提升」。1.8–2.8s。"
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
        .animation(LoopfolioTheme.toast, value: toast)
    }

    private var labContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                picker
                Text(lane.blurb)
                    .font(.footnote)
                    .foregroundStyle(LoopfolioTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                KeystrokeStrip(session: $session, focus: $fieldFocused)

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
        .background(LoopfolioTheme.night.ignoresSafeArea())
        .foregroundStyle(.white)
        .navigationTitle("词力对比实验")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
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
            .onChange(of: lane) { _, _ in
                toast = nil
                celebration.cancelAll()
                climax.cancel()
            }
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
                labButton("触发掌握跃迁", icon: "arrow.up.right.circle", emphasis: .primary) {
                    triggerB(.masteryLeap)
                }
                labButton("触发连击里程碑", icon: "flame", emphasis: .secondary) {
                    triggerB(.streak)
                }
            }
        case .cinema:
            VStack(spacing: 10) {
                labButton("触发本局清完", icon: "checkmark.circle", emphasis: .primary) {
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
            Text("结构隔离")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LoopfolioTheme.accentSoft)
            Text("A 只走 KeystrokeFeel。B 是 CelebrationHost。C 是 ClimaxOverlay：键盘未收不起片，同时只跑一段，播完拆除 TimelineView。")
                .font(.caption)
                .foregroundStyle(LoopfolioTheme.muted)
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
        fieldFocused = false
        #if os(iOS)
        resignKeyboard()
        #endif
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            let range = session.surgeMastery(by: surge)
            let event = ClimaxEvent(kind: kind, fromMastery: range.from, toMastery: range.to)
            climax.play(event, keyboardFocused: fieldFocused)
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
            .font(.body.weight(.medium))
            .padding(.vertical, 13)
            .foregroundStyle(.white)
            .background(background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }

    private var background: Color {
        switch emphasis {
        case .primary: return LoopfolioTheme.accent
        case .secondary: return LoopfolioTheme.nightRaised
        }
    }
}
