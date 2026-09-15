// Why: sixty-second feel test. Lane A never touches CelebrationStore. Lane B never puts
// TimelineView under the TextField. Same typing strip, two different rare-event paths.

import SwiftUI

public enum LabLane: String, CaseIterable, Identifiable {
    case keystroke = "A · 手感"
    case cinema = "B · 电影"

    public var id: String { rawValue }

    public var headline: String {
        switch self {
        case .keystroke: return "键程手感（无全屏）"
        case .cinema: return "电影式留存（独立层）"
        }
    }

    public var blurb: String {
        switch self {
        case .keystroke:
            return "每敲对一个字母：触觉 + 55ms 闪/缩。掌握条微动。稀有事件只有弱提示。"
        case .cinema:
            return "字母手感与 A 相同。掌握跃迁 / 本局清完走 CelebrationHost，0.8–1.8s 抽象光。"
        }
    }
}

public struct CelebrationCompareLab: View {
    @State private var lane: LabLane = .keystroke
    @State private var session = FakeTypingSession()
    @State private var toast: String?
    @State private var store = CelebrationStore()

    public init() {}

    public var body: some View {
        CelebrationHost(store: store) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    picker
                    Text(lane.blurb)
                        .font(.footnote)
                        .foregroundStyle(LoopfolioTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    KeystrokeStrip(session: $session)

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
        }
        .animation(LoopfolioTheme.toast, value: toast)
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
                store.cancelAll()
            }
        }
    }

    private var rareEventButtons: some View {
        VStack(spacing: 10) {
            Button {
                trigger(.masteryLeap)
            } label: {
                Label("触发掌握跃迁", systemImage: "arrow.up.right.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LabButtonStyle(emphasis: .primary))

            Button {
                trigger(.sessionClear)
            } label: {
                Label("触发本局清完", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LabButtonStyle(emphasis: .secondary))
        }
    }

    private var isolationNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("结构隔离")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LoopfolioTheme.accentSoft)
            Text("输入框只走 KeystrokeFeel。B 的光在 CelebrationHost 里，播完即拆除 TimelineView。")
                .font(.caption)
                .foregroundStyle(LoopfolioTheme.muted)
        }
        .padding(.top, 8)
    }

    private func trigger(_ kind: CelebrationEvent.Kind) {
        session.bumpMasteryForWeakToast()
        switch lane {
        case .keystroke:
            toast = kind == .masteryLeap ? "掌握 +6%（无全屏）" : "本局记了一笔（无全屏）"
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(1400))
                if toast?.contains("无全屏") == true {
                    toast = nil
                }
            }
        case .cinema:
            toast = nil
            store.enqueue(kind)
        }
    }
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
