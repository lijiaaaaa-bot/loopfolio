// Why: production home — mastery, start the real typing round, C lives on RootView.
// The compare lab stays a Debug door, not the settlement path.

import SwiftUI

public struct HomeView: View {
    @Bindable var progress: DailyProgress
    var climax: ClimaxStore
    var celebration: CelebrationStore

    public init(progress: DailyProgress, climax: ClimaxStore, celebration: CelebrationStore) {
        self.progress = progress
        self.climax = climax
        self.celebration = celebration
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("词力 / 今日")
                    .font(Typo.screenTitle)

                MasteryMeter(value: progress.mastery, size: .hero)
                    .frame(maxWidth: 280)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    StreakBadge(count: progress.bestStreak)
                    Text(progress.clearedToday ? "今日队列已清空" : "下一可亮词 · \(LabWordBank.gloss(for: progress.nextPrompt))")
                        .font(Typo.footnote)
                        .foregroundStyle(Theme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !progress.clearedToday {
                    Text("还剩 \(progress.remaining) 词")
                        .font(Typo.footnote)
                        .foregroundStyle(Theme.inkSoft)
                }

                NavigationLink {
                    TypingSessionView(
                        progress: progress,
                        climax: climax,
                        celebration: celebration
                    )
                } label: {
                    Text(progress.clearedToday ? "再来一局" : "开始打字")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(LabButtonStyle(emphasis: .primary))

                if LabAccess.isEnabled {
                    NavigationLink {
                        CelebrationCompareLab()
                    } label: {
                        Label("打开词力对比实验", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LabButtonStyle(emphasis: .secondary))
                }
            }
            .padding(24)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .foregroundStyle(Theme.ink)
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
