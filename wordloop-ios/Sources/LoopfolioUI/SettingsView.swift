// Why: discoverable DEBUG door. Production Settings in the real app should copy only the
// lab row; this thin stand-in exists so the experiment can be opened without the private
// wordloop-ios tree that is not in this GitHub repo.

import SwiftUI

public struct SettingsView: View {
    @State private var exam = "雅思 / GRE 并集"
    @State private var dailyCap = 12.0

    public init() {}

    public var body: some View {
        Form {
            Section("词库") {
                Picker("范围", selection: $exam) {
                    Text("雅思").tag("雅思")
                    Text("GRE").tag("GRE")
                    Text("雅思 / GRE 并集").tag("雅思 / GRE 并集")
                }
                Stepper(value: $dailyCap, in: 4...40, step: 1) {
                    Text("每日新词上限 \(Int(dailyCap))")
                }
            }

            Section {
                Text("打字回合不需要网络。密钥只进本机钥匙串。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("AI 讲解")
            }

            if LabAccess.isEnabled {
                Section {
                    NavigationLink {
                        CelebrationCompareLab()
                    } label: {
                        Label("词力对比实验", systemImage: "film.stack")
                    }
                    Text("对照 A · 手感 / B · 小高潮 / C · 电影。Debug 可见。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("调试")
                }
            }
        }
        .navigationTitle("设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
