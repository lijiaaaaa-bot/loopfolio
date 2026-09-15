import SwiftUI

public struct RootView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            HomeView()
        }
        .tint(LoopfolioTheme.accent)
    }
}
