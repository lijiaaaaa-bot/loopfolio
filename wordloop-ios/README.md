# Loopfolio / WordLoop — 词力对比实验

这个 GitHub 仓库原先只有 App Store 隐私与支持页（`gh-pages`）。本目录是一份**可单独编译的 SwiftUI 切片**：对照 A 手感、B 小高潮、C 电影高潮，而不是重做整款产品。

真机工程若在 `~/Projects/wordloop-ios`，把 `Sources/LoopfolioUI/Celebration/` 整夹拷进去，并在设置里挂上 `CelebrationCompareLab` 即可。

## 怎么打开实验（60 秒）

1. Mac 上安装 Xcode 16+（有 iOS 26/27 SDK 则 Liquid Glass / `colorEffect` 会亮起来；没有则走材质与 Canvas）。
2. 生成工程并跑 **Debug**：

```bash
cd wordloop-ios
brew install xcodegen   # 若尚未安装
xcodegen generate
xed Loopfolio.xcodeproj
```

选 iPhone 模拟器，Run（Debug）。Release 会编译掉入口（`#if DEBUG`）。

3. 路径任选其一：
   - 首页 → **打开词力对比实验**
   - 右上角齿轮 → 设置 → **调试 → 词力对比实验**
4. **A · 手感**：敲 `ephemeral`。每对一字母 ≤300ms 闪缩。稀有按钮只有弱 toast。
5. **B · 小高潮**：继续打字，点「触发掌握跃迁」「触发连击里程碑」。短 overlay 0.6–1.2s，不改房间。
6. **C · 电影**：点「触发本局清完」或「触发词力大升级」。先收键盘，再播 `ClimaxOverlay`（压暗 → 仪表放大冲格 → ≤24 色屑 → 标题，1.8–2.8s）。

浏览器对照：仓库根目录 `lab/index.html`，或 GitHub Pages `/lab/`。

## 结构

| 路径 | 职责 |
| --- | --- |
| `KeystrokeFeel` + `KeystrokeStrip` | A：局部反馈，不拥有全屏 |
| `CelebrationStore` + `CelebrationHost` | B：短 bloom / 连击确认 |
| `ClimaxStore` + `ClimaxOverlay` | C：气质层；聚焦时不起片；同时一段 |
| `CelebrationCompareLab` | 三段对照 |

打字视图树里没有 `TimelineView` / shader。C 播完拆除。

## 判断

用户要求 **A+B 都留**。B 不够改气质；**C 才是愿意打开 App 的理由**。C 必须隔离、先收键盘、短于 2.8s、抽象光而不是卡通战斗。
