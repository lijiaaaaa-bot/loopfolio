# WordLoop · D 词力仪表 — 高潮特效（电影级）补丁

叠在 `/workspace/wordloop-design/D-POWER-METER-SPEC.md` 之上。  
**原则：** 击键/连击仍是短反馈（≤300ms）；**电影级只给稀有正向高潮**——这是「愿意打开 App」的使用理由，不是每敲一下都放片。

实现：SwiftUI + 可选 **隔离层**（独立 `ClimaxOverlay` / 一次性 `Canvas` 全屏层）。主路径打字 **不上** SpriteKit/Metal；高潮层若日后隔离，也不得阻塞键盘输入结束态。

---

## 1. 分层

| 层 | 何时 | 时长 | 技术 |
|---|---|---|---|
| **A 击键层** | 打对/连击 | ≤300ms | 已有 HitFlash / StreakBadge / 迷你能量 |
| **B 小高潮** | 词掌握跃迁、连击里程碑 | 0.6–1.2s | SwiftUI overlay + Canvas |
| **C 电影高潮** | 今日清完、重大升级 | 1.8–2.8s | 全屏 ClimaxOverlay；可 dim 背景 |

Reduce Motion：B/C 全部降级为静态卡片 + 短 fade（≤400ms），无粒子/强闪。

---

## 2. 触发表（只正向）

| 事件 | 级别 | 屏 | 视觉 | 音/触 | 上限 |
|---|---|---|---|---|---|
| 打对一词 | A | 打字局 | HitFlash | light/success 一次 | 300ms |
| 连击 5/10/20… | B | 打字局 | StreakBadge 爆亮 + 短径向线（Canvas ≤16 条） | impact medium ×1 | **1.0s** |
| 单词「新→掌握」跃迁 | B | 打字局结束该词 / 回首页瞬间 | MasteryMeter 冲格 + 词卡描边扫光 | success | **1.2s** |
| 掌握环跨过 25/50/75% | B | 首页 | 环段填满闪 + 短标题「词力提升」 | success | **1.2s** |
| **今日队列清完** | **C** | 打字局→结算 | 见 §3 | success + 可选短音 | **2.5s** |
| **词力大升级**（如日掌握 +N 达阈值，或解锁新词表段） | **C** | 首页 | 见 §3 | success | **2.8s** |
| 深入材料有效掌握+ | A–B | 深入 | 短 chip；若触发日目标可升 C | selection / success | A≤300ms；升 C 另算 |

**不触发电影级：** 打错、放弃、重置、打开 App、普通返回。

---

## 3. 电影级 C 规格（可交给实现）

### 3.1 构图（2.0–2.5s 时间轴）

1. **0–200ms** 背景 `canvas` 压暗至 55–65% opacity（保留底层可辨，勿纯黑死屏）  
2. **150–900ms** 中央 MasteryMeter **放大至 1.15–1.25**（spring ≤0.35s 段）+ 填充冲到新值  
3. **400–1600ms** Canvas：**≤24** 片 accent/confetti 色屑从环外缘向外缓散（重力弱、无旋转狂欢）；禁止卡通怪、刀剑、金币雨  
4. **900–2000ms** 一行大字：`Typo.screenTitle`「今日清空」/「词力提升」+ 副行短操作句（非 ADR）  
5. **1800–2500ms** 淡出 overlay；露出结算/首页 CTA  

总时长默认 **2.2s**；可设置里关「电影高潮」只留 B。

### 3.2 强度上限

- 全屏闪白 ≤1 帧、opacity ≤0.15  
- 粒子 ≤24，单粒子寿命 ≤1.2s  
- 同时只跑 **1** 个 C；排队则合并文案，不叠两段电影  
- 打字未结束（键盘焦点仍在）**禁止**开 C；等词提交/局结束再播  

### 3.3 隔离层建议

```
ClimaxOverlay(event:)
  · 覆盖 Window / root，allowsHitTesting 仅「继续」按钮
  · 用 SwiftUI TimelineView + Canvas；不引进 SpriteKit 除非工程后批
  · 播放中暂停底层无关键动画即可，勿卡手势返回
```

生产接线（本仓库切片）：`RootView` 用 `ClimaxHost` 包 `NavigationStack`。真局 `TypingSessionView` 在最后一词 `SessionDirector.ingest` 结算后收键盘，再 `ClimaxStore.playSettlement`。「今日清空」= 当日首次队列清空；「词力提升」= 本局掌握涨幅 ≥ 0.22。实验室 `CelebrationCompareLab.triggerC` 只做对照，不是生产路径。

---

## 4. 与三屏关系

| 屏 | A 短反馈 | B/C 高潮 |
|---|---|---|
| 首页 | 无击键 | 开屏不自动 C；从打字返回时若刚清完/升级 → C |
| 打字局 | 每击 A；里程碑 B | 清完队列才 C（离场结算） |
| 深入 | 掌握 chip A/B | 不在阅读中插 C |

---

## 5. 禁区（重申）

- 羞辱、失败电影、倒计时恐吓、段位压迫片  
- 卡通打怪、抽卡、金币商城雨  
- 每键电影级、>3s 过场、主路径 Metal/SpriteKit  

---

## 6. 验收

- [ ] 日常打字仍干脆（A ≤300ms）  
- [ ] 清完/大升级有「值得打开」的高潮（C 1.8–2.8s）  
- [ ] Reduce Motion 不眩晕  
- [ ] 电影层可关  

文件：`/workspace/wordloop-design/D-CINEMATIC-CLIMAX-SPEC.md`
