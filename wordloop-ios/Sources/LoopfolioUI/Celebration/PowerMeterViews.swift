// Why: D-POWER-METER-SPEC components. HitFlash / StreakBadge / MasteryMeter stay on
// the typing tree and never own a TimelineView.

import SwiftUI

struct HitFlash<Content: View>: View {
    var token: Int
    var armed: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .scaleEffect(armed ? 1.04 : 1)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
                    .fill(Theme.hitFlash.opacity(armed ? 1 : 0))
            }
            .animation(Motion.hit, value: token)
    }
}

struct StreakBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("连击 \(count)")
                .font(Typo.number)
                .foregroundStyle(Theme.streak)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Theme.accentSoft.opacity(0.18), in: Capsule())
                .animation(Motion.streak, value: count)
        }
    }
}

struct MasteryMeter: View {
    enum Size { case mini, hero }

    let value: Double
    var size: Size = .mini

    var body: some View {
        switch size {
        case .mini: miniBar
        case .hero: HeroMasteryRing(value: value)
        }
    }

    private var miniBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("掌握")
                    .font(Typo.footnote)
                    .foregroundStyle(Theme.inkSoft)
                Spacer()
                Text("\(Int((value * 100).rounded()))%")
                    .font(Typo.footnote.monospacedDigit())
                    .foregroundStyle(Theme.accentSoft)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.powerTrack)
                    Capsule()
                        .fill(Theme.powerFill)
                        .frame(width: max(6, proxy.size.width * value))
                }
            }
            .frame(width: 148, height: 8)
        }
        .animation(Motion.meter, value: value)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("掌握")
        .accessibilityValue("\(Int((value * 100).rounded())) 百分之")
    }
}

struct WeakToast: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Typo.footnote.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .loopfolioGlass(cornerRadius: Radius.chip)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
    }
}
