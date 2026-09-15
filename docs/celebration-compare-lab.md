# 词力对比实验 — 怎么打开、点什么

规格源：`wordloop-design/D-POWER-METER-SPEC.md`、`wordloop-design/D-CINEMATIC-CLIMAX-SPEC.md`。

主对照是 **A 击键层 vs C 电影高潮**。B 小高潮是可选中间按钮，不是主分段。

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

## 点什么（约 60 秒）

1. 分段切 **A 击键层**：敲 `ephemeral`。打对应有 HitFlash（释义区）、迷你掌握条、StreakBadge。≤300ms，无全屏。点「触发掌握跃迁 / 本局清完」只有弱 toast。
2. 切 **C 电影高潮**：点 **触发今日清完** 或 **触发词力大升级**。实验室会先 `submitSession` 并收键盘，再播 `ClimaxOverlay`（压暗 55–65% → 仪表 1.15–1.25 冲格 → ≤24 色屑 → `Typo.screenTitle`「今日清空」/「词力提升」，1.8–2.8s）。键盘仍聚焦则不起片。
3. 可选：点 **B 小高潮 · 掌握跃迁 / 连击里程碑**（0.6–1.2s，Canvas ≤16 条径向线）。

| 层 | 规格时长 | 实现 |
| --- | --- | --- |
| A 击键层 | ≤300ms | `HitFlash` / `StreakBadge` / `MasteryMeter` mini |
| B 小高潮 | 0.6–1.2s | `CelebrationHost` + Canvas ≤16 rays；Reduce Motion 静态卡 ≤400ms |
| C 电影高潮 | 1.8–2.8s | `ClimaxOverlay`；同时一段；合并文案；无 SpriteKit / 主路径 Metal |

Reduce Motion：B/C 都降为静态卡 ≤400ms。

## 浏览器对照

`lab/index.html`（Pages `/lab/`）是网页近似，不是产品代码。

## 接到 `~/Projects/wordloop-ios`

拷贝 `wordloop-ios/Sources/LoopfolioUI/Celebration/` 与 `Theme.swift`。根视图：`ClimaxHost { CelebrationHost { 打字页 } }`。C 只在词提交 / 局结束后 `play(..., keyboardFocused: false)`。
