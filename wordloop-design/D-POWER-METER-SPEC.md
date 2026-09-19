# WordLoop · D 词力仪表 — 可落地视觉规格

约束：纯 SwiftUI + 现有 `Theme`；组件 `MasteryMeter` / `StreakBadge` / `HitFlash`；`SensoryFeedback`；动效 ≤300ms；Canvas 仪表优先；不上 SpriteKit / 全屏粒子 / 主路径 Metal。  
对齐文件：`Sources/WordLoopUI/Theme.swift`。

---

## 1. Token（扩展 Theme，不另开色盘）

### 1.1 色彩（沿用 DuoColor light/dark）

| Token | 用途 | 建议（扩展名） | 取值 |
|---|---|---|---|
| `Theme.canvas` | 页底 | 已有 | `#F5F3FF` / `#0C0B12` |
| `Theme.surface` | 卡片 | 已有 | `#FFFFFF` / `#1A1823` |
| `Theme.ink` / `inkSoft` | 正文/次文 | 已有 | 保持 |
| `Theme.accent` | 主按钮、能量填充、连击强调 | 已有 | `#6C4CF0` / `#A48BFF` |
| `Theme.accentSoft` | 能量槽底、HitFlash 底晕 | 已有 | 保持 |
| `Theme.onAccent` | 主按钮字 | 已有 | white |
| **`Theme.powerFill`** | MasteryMeter 填充（可 = accent） | 新增别名 | = `accent` |
| **`Theme.powerTrack`** | 能量槽轨道 | 新增 | `hairline` 或 `surfaceMuted` |
| **`Theme.hitFlash`** | 打中一闪 | 新增 | light `#6C4CF0@0.22` / dark `#A48BFF@0.28` |
| **`Theme.streak`** | 连击字色 | 新增别名 | = `accent`（禁止用 danger） |
| `Theme.danger` / `dangerSoft` | 仅破坏性确认；**打错不用满屏 danger** | 已有 | 打错用 `inkSoft` + 轻底，可点深入 |

年级色 `grade` / `kind` / `newWord` 保持现有语义，不进主多巴胺链路。

**Confetti：** 现有 `Theme.confetti` **禁止**用在打字主路径；仅队列结束可选一次，且 ≤300ms、粒子 ≤12、SwiftUI/Canvas。

### 1.2 字号（沿用 Typo + ScaledMetric）

| 用途 | Token | 说明 |
|---|---|---|
| 屏标题 | `Typo.screenTitle` | 首页「词力」 |
| 掌握百分比 | `Typo.bigNumber` | MasteryMeter 中心或旁 |
| 连击数 | `Typo.number` | StreakBadge |
| 打字 headword | `headwordSize` 46 + ScaledMetric | 主路径最大 |
| 按钮 | `Typo.button` | 主 pill |
| 脚注 | `Typo.footnote` | 操作短句 |

### 1.3 圆角 / 间距

| 用途 | Token |
|---|---|
| 主按钮 pill | height 52–56，圆角 = height/2（胶囊）；或 `Radius.inner` 18 若非满宽胶囊 |
| 卡片 | `Radius.card` 24 |
| 能量条轨道 | 高度 10–12，圆角 6（轨道内填充同圆角） |
| Chip / StreakBadge | `Radius.chip` 14 |
| 间距 | `Space` 体系不变；仪表与标题间距 `l`/`xl` |

### 1.4 动效（覆盖/收紧现有 Motion 用于反馈）

现有 `springy` 0.45s **超标**，反馈链路改用：

| Token | 定义 | 用途 |
|---|---|---|
| `Motion.hit` | `easeOut(duration: 0.18)` 或 spring `duration: 0.22, bounce: 0.15` | HitFlash、能量跳格 |
| `Motion.streak` | spring `duration: 0.26, bounce: 0.20` | 连击数字 |
| `Motion.meter` | `easeOut(duration: 0.28)` | MasteryMeter 填充 |
| Reduce Motion | 全部改为 `opacity` 淡入 ≤180ms，无缩放弹跳 |

**硬上限：任何单次反馈可见动效 ≤300ms。**

---

## 2. 三屏结构标注

### 2.1 首页

```
[ 安全区 ]
  标题「词力 / 今日」 Typo.screenTitle
  MasteryMeter（大）——宽 min(屏幕-32, 280)，环线宽 10–12
    · Canvas 环形或胶囊条皆可；优先 Canvas 环
    · 中心：掌握 % bigNumber + 脚注「已掌握」
  次行：StreakBadge（若今日有连击纪录）+ 「下一可亮词」短句
  主 CTA：「开始打字」满宽/近满宽 accent pill，高 52–56
  词表入口：surface 卡片列表，无段位墙
[ Tab / 系统 ]
```

- **能量条位置：** 首页最上视觉焦点 = MasteryMeter（不是底部）。  
- **连击：** 首页只展示「今日最佳连击」小徽章，不实时跳动。  
- **打中反馈：** 首页无 HitFlash。

### 2.2 打字局（主路径）

```
[ 顶栏薄 ]
  左：系统返回/收起
  中：本局 MasteryMeter 迷你条（高 8，宽 120–160）或省略环改用细条
  右：StreakBadge（当前连击，默认隐藏 0）
[ 中央 ]
  headword 大号
  输入区
[ 键盘 ]
```

- **打中 HitFlash：** 覆盖 headword 区域轻紫闪（`hitFlash` 色），**不要**全屏遮罩；缩放 1.0→1.04→1.0。  
- **能量：** 迷你条 +1 格跳变，与 HitFlash 同时起。  
- **打错：** 无 HitFlash；字色短暂 `inkSoft`；可出「深入」轻 chip；**禁用**满屏 danger、禁止重震动惩罚。  
- **深入底栏**（若本屏可进）：不在此屏；进深入页见下。

### 2.3 深入

```
[ 材料可读区 — 最大 ]
[ 轻：「试着补几个空」 ]
[ 底栏 ]
  左 50%：「先这样」soft（surface + ink，描边 hairline）
  右 50%：「再要材料」accent pill 主按钮
```

- **升级感：** 完成一段材料 / 有效点词 → 顶部或底栏上方弹出 **掌握 +N** 收入条（走 MasteryMeter 小增量），≤300ms 滑入滑出。  
- **无** 大连击 HUD；连击不在深入页累积（避免抢阅读）。  
- 主按钮在右，贴 iOS。

---

## 3. 反馈时长与强度上限

| 事件 | 视觉 | 时长 | Haptics（SensoryFeedback） | 禁止 |
|---|---|---|---|---|
| 打对一词 | HitFlash + 迷你能量跳格 | 视觉 **180–220ms** | `.success` 或 `.impact(light)` 一次 | 全屏闪、音效堆叠 |
| 连击 +1 | StreakBadge 数字切换 + 微缩放 | **220–260ms** | `.selection` 或 light impact | 每击重震 |
| 连击里程碑（如 5/10） | Badge 短亮 accentSoft | **≤300ms** | light impact ×1 | 烟花、全屏 |
| MasteryMeter 涨格 | 填充 easeOut | **≤280ms** | 无（或仅首页结算一次 success） | 环旋转 360° |
| 深入掌握+ | 顶部 chip 滑入 | 入 180ms / 留 ≤1.2s / 出 180ms | selection | 打断阅读弹窗 |
| 打错 | 无闪红满屏；可选 hairline 颤 1 次 | **≤150ms** | `.error` **禁止**；最多 `.selection` | danger 满屏、重震 |
| 队列结束 | 可选 confetti ≤12 | **≤300ms** | success ×1 | 长庆祝 |

**60fps：** 仅动画 `opacity` / `scale` / `trim`（Canvas 环进度）；避免逐帧阴影模糊动画。

---

## 4. 组件职责（给实现）

| 组件 | 职责 | 不负责 |
|---|---|---|
| `MasteryMeter` | 0…1 进度；大/迷你两种 size | 文案业务、网络 |
| `StreakBadge` | 显示 Int 连击；0 时 hidden | 计算连击规则 |
| `HitFlash` | 对指定区域播一次闪白/紫 | 判断对错 |

---

## 5. 验收

- [ ] 打对反馈体感「打中了」，且 ≤300ms  
- [ ] 首页一眼看到掌握进度  
- [ ] 打错无羞辱红屏  
- [ ] 无 SpriteKit / 主路径 Metal / 全屏粒子  
- [ ] Reduce Motion 仍可读进度  

文件：`/workspace/wordloop-design/D-POWER-METER-SPEC.md`
