# 词力对比实验 — 怎么打开、点什么

## 打开（iOS Debug）

本仓库的 GitHub 源只有隐私页。实验代码在 `wordloop-ios/`。

```bash
cd wordloop-ios
bash scripts/gen_project.sh
# Xcode → 选 iPhone 模拟器 → Run（必须 Debug）
```

然后：

1. 首页点 **打开词力对比实验**，或齿轮 → 设置 → **调试 → 词力对比实验**
2. 分段开关切 **A · 手感** / **B · 电影**
3. 在输入框敲提示词（默认 `ephemeral`）— 两条路径的键程反馈应一样
4. 点 **触发掌握跃迁**、**触发本局清完**

| 模式 | 键程 | 两个触发按钮 |
| --- | --- | --- |
| A | SensoryFeedback + 55ms 闪/缩 + 掌握条 | 弱 toast / 条微动，无全屏 |
| B | 同上，输入树没有 TimelineView | `CelebrationHost` 抽象光 0.8–1.8s，播完拆除 |

Release 构建没有入口（`LabAccess` / `#if DEBUG`）。

## 浏览器对照（本环境无 iOS 模拟器）

打开 `lab/index.html`（Pages 上是 `/lab/`）。手感与光效是网页近似，用来 60 秒内看出差距；产品代码以 SwiftUI 为准。

## 接到现有 App

若本机工程在 `~/Projects/wordloop-ios`：拷贝 `Sources/LoopfolioUI/Celebration/`，在 Settings 的 DEBUG 区挂 `NavigationLink { CelebrationCompareLab() }`。根视图用 `CelebrationHost` 包住打字页，不要把 Host 放进 TextField 子树。

## 工程判断

B 值得做成**稀有独立层**，不值得跟键走。短、抽象、可拆除，就能接近「电影级留存」而不伤打字。
