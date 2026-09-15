# 词力对比实验 — 怎么打开、点什么

用户判断：**A 和 B 都留**；当前 B 的 bloom **不够改气质**。C 才是「愿意打开 App」的电影高潮。

## 打开（iOS Debug）

本仓库的 GitHub 源只有隐私页。实验代码在 `wordloop-ios/`。

```bash
cd wordloop-ios
bash scripts/gen_project.sh
# Xcode → 选 iPhone 模拟器 → Run（必须 Debug）
```

然后：

1. 首页点 **打开词力对比实验**，或齿轮 → 设置 → **调试 → 词力对比实验**
2. 分段开关切 **A · 手感** / **B · 小高潮** / **C · 电影**
3. 在输入框敲提示词（默认 `ephemeral`）— 三条路径的键程反馈应一样（≤300ms）
4. 按当前 lane 点稀有按钮

| 模式 | 键程 | 稀有按钮 |
| --- | --- | --- |
| A · 手感 | SensoryFeedback + 55ms 闪/缩 + 掌握条 | 「触发掌握跃迁」「触发本局清完」→ 弱 toast，无全屏 |
| B · 小高潮 | 同上，输入树没有 TimelineView | 「触发掌握跃迁」「触发连击里程碑」→ `CelebrationHost` 0.6–1.2s |
| C · 电影 | 按钮先收键盘 | 「触发本局清完」「触发词力大升级」→ `ClimaxOverlay` 1.8–2.8s（默认 2.2 / 2.5） |

C 时间轴：压暗 55–65% → MasteryMeter 放大 1.15–1.25 并冲格 → ≤24 片 accent 色屑外散 → 大字「今日清空」/「词力提升」→ 淡出。Reduce Motion 降为静态卡 ≤400ms。同时只跑一段 C；键盘仍聚焦则不起片。

Release 构建没有入口（`LabAccess` / `#if DEBUG`）。

## 浏览器对照（本环境无 iOS 模拟器）

打开 `lab/index.html`（Pages 上是 `/lab/`）。手感与光效是网页近似，产品以 SwiftUI 为准。

## 接到现有 App

若本机工程在 `~/Projects/wordloop-ios`：拷贝 `Sources/LoopfolioUI/Celebration/`，Settings DEBUG 区挂 `CelebrationCompareLab`。根上用 `ClimaxHost` 包打字页（里面再套 `CelebrationHost`），不要把任一层放进 TextField 子树。

## 工程判断

A + B 留下：A 保手感，B 给词跃迁 / 连击一个短确认。C 才改房间气质——压暗、仪表英雄、重触觉、短标题。C 必须隔离、先收键盘、播完拆除。不要把 C 挂进键程。
