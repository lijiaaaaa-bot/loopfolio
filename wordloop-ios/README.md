# Loopfolio / WordLoop — 词力对比实验

规格：`../wordloop-design/D-POWER-METER-SPEC.md`、`../wordloop-design/D-CINEMATIC-CLIMAX-SPEC.md`。

本目录是可单独编译的 SwiftUI 切片。主对照 **A 击键层 vs C 电影高潮**；B 小高潮是可选中间按钮。

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
- Run 后：首页「打开词力对比实验」，或 设置 → 调试

## 点什么

1. **A 击键层** — 敲 `ephemeral`。HitFlash + 迷你条 + StreakBadge，≤300ms。稀有按钮只有 toast。
2. **C 电影高潮** — 「触发今日清完」「触发词力大升级」。先提交本局、收键盘，再 `ClimaxOverlay` 1.8–2.8s。
3. 可选 **B 小高潮** — 0.6–1.2s，≤16 条径向线。

主路径打字不上 SpriteKit / Metal。C 用隔离 TimelineView + Canvas，播完拆除。
