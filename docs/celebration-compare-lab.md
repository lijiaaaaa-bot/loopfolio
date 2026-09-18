# 词力对比实验 — 怎么打开、点什么

规格源：`wordloop-design/D-POWER-METER-SPEC.md`、`wordloop-design/D-CINEMATIC-CLIMAX-SPEC.md`。

实验室是 **三段**：A · 手感 / B · 小高潮 / C · 电影。B 改不了 App 气质；要看房间变了，切 C。

## 本地 Mac 模拟器（真实验）

需要 Xcode 16+、iPhone 模拟器。此 Cloud 环境没有 iOS SDK。

```bash
git clone https://github.com/lijiaaaaa-bot/loopfolio.git
cd loopfolio
git checkout cursor/celebration-compare-lab-4538

cd wordloop-ios
# 若未装 xcodegen：brew install xcodegen
bash scripts/gen_project.sh
xed Loopfolio.xcodeproj
```

Xcode 里：

1. Scheme **Loopfolio**，任意 iPhone 模拟器。
2. 必须 **Debug**（Release 会 `#if DEBUG` 摘掉入口）。
3. Run（⌘R）。
4. 首页 → **打开词力对比实验**，或齿轮 → 设置 → **调试 → 词力对比实验**。

打开实验室默认落在 **C · 电影**，并先播一段「今日清空」。

## 点什么（约 60 秒）

1. **A · 手感**：敲 `ephemeral`。打对应有 HitFlash（释义区）、迷你掌握条、StreakBadge。≤300ms，无全屏。点「触发掌握跃迁 / 本局清完」只有弱 toast。
2. **B · 小高潮**：掌握跃迁 / 连击里程碑。`CelebrationHost` + Canvas ≤16 条径向线，0.6–1.2s。短光，不是电影。
3. **C · 电影**：点 **触发今日清完** 或 **触发词力大升级**。实验室会先 `submitSession` 并收键盘，再播 `ClimaxOverlay`：压暗 55–65% → 仪表放大 1.15–1.25 并冲格 → ≤24 accent 色屑 → `Typo.screenTitle`「今日清空」/「词力提升」（1.8–2.8s）。键盘仍聚焦则不起片。同时只跑一段 C，排队合并文案。

| 层 | 规格时长 | 实现 |
| --- | --- | --- |
| A · 手感 | ≤300ms | `HitFlash` / `StreakBadge` / `MasteryMeter` mini |
| B · 小高潮 | 0.6–1.2s | `CelebrationHost` + Canvas ≤16 rays；Reduce Motion 静态卡 ≤400ms |
| C · 电影 | 1.8–2.8s | `ClimaxOverlay`（TimelineView + Canvas）；同时一段；合并文案；无 SpriteKit / 主路径 Metal |

Reduce Motion：B/C 都降为静态卡 ≤400ms。

## 浏览器对照（不需 Xcode）

打开 `lab/index.html`（Pages `/lab/`）。默认 **C · 电影**，进页即播「今日清空」：房间压暗、仪表放大冲格、色屑、大字。再切 A / B 对比气质。

- `?lane=A` / `?lane=B` / `?lane=C`
- `?cinema=clear&progress=0.55` 冻结 C 中段
- `?cinema=leap` 冻结 B

## 接到 `~/Projects/wordloop-ios`

拷贝 `wordloop-ios/Sources/LoopfolioUI/Celebration/` 与 `Theme.swift`。根视图：`ClimaxHost { CelebrationHost { 打字页 } }`。C 只在词提交 / 局结束后 `play(..., keyboardFocused: false)`。
