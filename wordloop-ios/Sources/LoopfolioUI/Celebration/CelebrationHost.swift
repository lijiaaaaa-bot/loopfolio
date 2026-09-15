// Why: sibling overlay, not a child of the TextField. Isolated store. When `current` is nil
// the TimelineView / shader tree is gone — typing never shares that GPU work.

import SwiftUI

public struct CelebrationHost<Content: View>: View {
    @Bindable var store: CelebrationStore
    let content: Content

    public init(store: CelebrationStore, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
            if let event = store.current {
                CelebrationMomentView(event: event) {
                    store.finishCurrent(id: event.id)
                }
                .id(event.id)
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .animation(.easeOut(duration: 0.2), value: store.current?.id)
    }
}
