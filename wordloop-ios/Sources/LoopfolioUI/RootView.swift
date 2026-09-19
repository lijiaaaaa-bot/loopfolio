import SwiftUI

public struct RootView: View {
    @State private var climax = ClimaxStore()
    @State private var celebration = CelebrationStore()
    @State private var progress = DailyProgress()

    public init() {}

    public var body: some View {
        ClimaxHost(store: climax) {
            CelebrationHost(store: celebration) {
                NavigationStack {
                    HomeView(
                        progress: progress,
                        climax: climax,
                        celebration: celebration
                    )
                }
            }
        }
        .tint(LoopfolioTheme.accent)
    }
}
