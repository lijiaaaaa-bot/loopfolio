# Loopfolio / WordLoop — 词力对比实验

规格：`../wordloop-design/D-POWER-METER-SPEC.md`、`../wordloop-design/D-CINEMATIC-CLIMAX-SPEC.md`。

本目录是可单独编译的 SwiftUI 切片。生产路径：首页「开始打字」走 `TypingSessionView`；队列清空 / 词力大升级由根上的 `ClimaxHost` 播 C。实验室三段（Debug）：**A · 手感 / B · 小高潮 / C · 电影**，打开默认落在 C。

## 本地 Mac 模拟器

```bash
cd wordloop-ios
brew install xcodegen   # 若尚未安装
bash scripts/gen_project.sh
xed Loopfolio.xcodeproj
```

- Scheme：Loopfolio
- 模拟器：任意 iPhone
- 配置：**Debug**（Release 没有实验室入口）
- Run 后：首页 **开始打字** 是真局；**打开词力对比实验** 或 设置 → 调试 仍是 A/B/C QA

## 点什么

1. **A · 手感** — 敲 `ephemeral`。HitFlash + 迷你条 + StreakBadge，≤300ms。稀有按钮只有 toast。
2. **B · 小高潮** — 掌握跃迁 / 连击里程碑。0.6–1.2s，Canvas ≤16 条径向线。
3. **C · 电影** — 「触发今日清完」「触发词力大升级」。先提交本局、收键盘，再 `ClimaxOverlay` 1.8–2.8s。

生产路径：首页 **开始打字**，打完今日队列会先收键盘再播 C「今日清空」；本局掌握 +0.22 再叠「词力提升」。局中掌握跃迁 / 连击里程碑走 B。实验室入口仍在 Debug。

主路径打字不上 SpriteKit / Metal。C 用隔离 TimelineView + Canvas，播完拆除。
