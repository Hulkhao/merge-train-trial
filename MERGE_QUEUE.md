# Merge Queue — trial-1

> 只有 Orchestrator（主会话）可修改本表。Base=`2d6c91d1a3c44dbda80d570f9d08a1cb57f94777`（main）。
> Candidate branch：`integration/trial-1`（初始=Base）。

| ID | Owner | Branch | Worktree | Base SHA | Head SHA | State | Risk | Touched Hot Files | Relevant Tests | Queue Order |
|---|---|---|---|---|---|---|---|---|---|---|
| MQ-1 | DEV-A | feature/trial-dev-a | D:\AIGC\merge-train-dev-a | 2d6c91d | dca1961a84a13254f09b6cc5743c92fd194475ac | INTEGRATED (2a18d7a, 06:39:46) | low | src/routes.js, src/config.js | tests/unit/greet.test.js | 1 |
| MQ-2 | DEV-B | feature/trial-dev-b | D:\AIGC\merge-train-dev-b | 2d6c91d | 4906bdac5f07598083659d8669912d0d4240bdde | INTEGRATED (2d22da1, 06:42:07) | low | src/routes.js, src/config.js | tests/unit/now.test.js | 2 |
| MQ-3 | DEV-C | feature/trial-dev-c | D:\AIGC\merge-train-dev-c | 2d6c91d | 78822ed9f2ffffcf20f4f935d5242ffca83c996d | INTEGRATED (e588fec, 06:43:51) | low | src/routes.js, src/config.js | tests/unit/sum.test.js | 3 |

## Orchestrator 流水记录（试点数据）

- 2026-10-04 ~06:47 三线平行派单；DEV 回报耗时（自报）：DEV-C 2min、DEV-A 3min、DEV-B 5min；回报顺序 C→B→A。
- Orchestrator 抽查三线：branch/HEAD 与自报一致、工作区全净（porcelain=0）✓。
- 2026-10-04 ~06:52 队列三行全部置 READY_FOR_MERGE，Captain 发车（Head SHA 已锁定入单）。
- 2026-10-04 06:38~06:44 Captain 消费完毕：MQ-1 clean（06:39:46）、MQ-2/MQ-3 mechanical-resolved 并集（06:42:07 / 06:43:51），Fast Gate 五步×3 全一次通过；最终 candidate=e588fec。
- 2026-10-04 06:5x Orchestrator Full Gate：全量 node --test 7/7 pass（unit 5 + e2e 2）、pollution=0、路由表 /greet,/hello,/now,/sum 四条齐活、功能抽测 /greet→"Hi, 小明!"、/sum→3、/now→ISO 合法。**试点闭环。**

## 12 项试点数据（收尾登记）

1. DEV 数量：3（平行）
2. Queue 项数：3
3. READY→INTEGRATED 耗时：MQ-1≈1.6min / MQ-2≈2.3min / MQ-3≈1.7min（Captain 自报；merge commit 时间戳 06:39:46/06:42:07/06:43:51 佐证）；Captain 总耗时 5.2min
4. 冲突分布：零冲突 1（MQ-1）/ 机械冲突 2（MQ-2、MQ-3，均为设计内并集）/ 语义冲突 0
5. Captain 自解：2/2 机械冲突（保留全部条目唯一裁决）
6. MERGE_BLOCKED：0
7. 重派 DEV：0
8. Fast Gate 失败：0（五步×3 项全一次通过；单步 94-434ms）
9. worktree 串扰：0（Captain 全程只在 merge-train-int；DEV 各自 worktree；Orchestrator 抽查无越界痕迹）
10. Orchestrator 上下文：merge 细节零进入主会话（仅消费结构化报告与队列编辑），达成卸载目标
11. Full Gate：PASS（7/7 测试 + pollution 0 + 路由齐活 + 功能抽测）
12. 瓶颈转移：DEV 实现与回报为耗时大头（2-5min/线）；合流+Fast Gate 仅 5.2min 且全自动可并行化——瓶颈已从「总管亲手合流」转移到「DEV 实现本身」

## 三问回答

- **Q1 Captain 是否卸载了 Orchestrator 集成工作？** 是。Orchestrator 本轮只做：派单、队列编辑、抽查核验、Full Gate；未执行任何 merge/冲突解决。
- **Q2 机械冲突自解是否可靠？语义冲突是否及时停手？** 机械：2/2 唯一裁决正确（Full Gate 佐证）。语义停手：本轮未自然出现语义冲突（设计内全为并集），该半题**未被真实锻炼**，留待下轮构造语义冲突用例。
- **Q3 哪些步骤稳定到值得脚本化？** Fast Gate 五步全为确定性命令（单步 ≤0.5s），merge+gate 循环结构固定——**merge queue 消费 + Fast Gate 是 saved workflow 的明确候选**；diff 初审与冲突分类保持 Agent 判断。

## 结论（按试点方案 §9 格式）

**B — 升级到档位 1**：Merge Queue / Fast Gate 的确定性步骤已明显稳定（3/3 集成、2/2 机械自解、0 门禁失败、0 串扰），建议下一轮把「queue 消费 + Fast Gate」提炼为脚本或 saved dynamic-workflow；语义冲突归因仍留 Agent。本轮遵约不直接创建 workflow，下一轮方案另行提出。

## 设计的机械冲突点

三条线的 `src/routes.js`（路由注册）与 `src/config.js`（开关注册）追加条目落在同一区域 → 两两合并必产生「注册并集」型机械冲突，可由 Captain 按协议 §4-6 唯一裁决。除此之外无共享文件。

## 试点数据登记（收尾由 Orchestrator 填）

- DEV 数量：3；Queue 项数：3
- 各项 READY→INTEGRATED 耗时：（待填）
- 零冲突 / 机械冲突 / 语义冲突：（待填）
- Captain 自解 / MERGE_BLOCKED / 重派 DEV 次数：（待填）
- Fast Gate 失败次数与原因：（待填）
- worktree 串扰：（必须为 0，待填）
- Orchestrator 上下文占用对比：（待填，主观）
- Full Gate 结果：（待填）
- 瓶颈转移评估：（待填）
