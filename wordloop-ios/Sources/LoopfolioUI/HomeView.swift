// Why: a one-screen host so Settings (and the lab) are reachable. Not a product rebuild.

import SwiftUI

public struct HomeView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("看释义，敲英文")
                .font(.system(size: 32, weight: .semibold, design: .serif))
            Text("一局几十秒。对了立刻下一题。这个仓库里的可运行切片只带 A / B / C 词力对比实验。")
                .foregroundStyle(LoopfolioTheme.muted)
            Spacer()
            if LabAccess.isEnabled {
                NavigationLink {
                    CelebrationCompareLab()
                } label: {
                    Label("打开词力对比实验", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(LabButtonStyle(emphasis: .primary))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LoopfolioTheme.night.ignoresSafeArea())
        .foregroundStyle(.white)
        .navigationTitle("Loopfolio")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("设置")
            }
        }
        #else
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        #endif
    }
}
