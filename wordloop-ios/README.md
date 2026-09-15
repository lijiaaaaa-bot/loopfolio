# Loopfolio / WordLoop — 词力对比实验

这个 GitHub 仓库原先只有 App Store 隐私与支持页（`gh-pages`）。本目录是一份**可单独编译的 SwiftUI 切片**：用来回答「电影式庆祝值不值得、会不会伤打字手感」，而不是重做整款产品。

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
4. 先切 **A · 手感**：敲 `ephemeral`（卡片上有目标词）。每对一个字母只有轻触 + 55ms 闪缩，掌握条微动。再点「触发掌握跃迁」「触发本局清完」——只有弱提示，没有全屏。
5. 再切 **B · 电影**：继续打字（手感应与 A 相同），然后点那两个按钮。全屏是独立的 `CelebrationHost` 抽象光（0.8–1.8s），播完拆除 `TimelineView`。

浏览器里也有一份手感对照（不是产品代码）：仓库根目录 `lab/index.html`，或 GitHub Pages `/lab/`。

## 结构

| 路径 | 职责 |
| --- | --- |
| `KeystrokeFeel` + `KeystrokeStrip` | A：局部反馈，不拥有全屏 |
| `CelebrationStore` + `CelebrationHost` | B：独立队列与 overlay |
| `EnergyBloomCanvas` + `EnergyBloom.metal` | 程序化光；shader 可选 |
| `CelebrationCompareLab` | 分段对照 |

打字视图树里没有 `TimelineView` / shader。

## 判断（工程侧）

B **值得做成稀有层**，不值得跟在每个键后面。A 已经能保住「敲对立刻下一题」的手感；B 只要严格隔离、短于 1.8s、抽象而不是卡通战斗，就可以当留存时刻。把 B 做进键程会立刻伤手感。
