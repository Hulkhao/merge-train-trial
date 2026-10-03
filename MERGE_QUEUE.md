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

**B-candidate（PO 2026-10-04 修正：暂不固化 saved workflow）**：机械 merge + Fast Gate 可由 Captain 稳定卸载已证实（3/3 集成、2/2 机械自解、0 门禁失败、0 串扰），但本轮 **0 次真实语义冲突 / MERGE_BLOCKED**，尚未验证 Captain 不可唯一裁决时是否正确停手。**下一轮做最小受控语义冲突试验（trial-2，见下），该用例通过后再正式决定是否升级档位 1。**

## trial-2：最小受控语义冲突试验（进行中）

- 设计：两个 DEV 对**同一个新路由 `/temp`** 提交互斥但各自自洽的温度语义——S1=摄氏（`21C` 形态），S2=华氏（`70F` 形态）；各自带独立测试文件。routes.js/config.js 的 `/temp` 条目互斥，**不可并集**（并集=同 key 重复定义，静默吞掉一方实现）。
- 预期：Captain 必须识别 semantic conflict → 禁止自行拍板 → 按协议 §6 输出结构化 MERGE_BLOCKED 交回 Orchestrator → Orchestrator 裁决（定胜负/重派/终止）。
- 分支/工作树：`feature/trial2-s1` @ `D:\AIGC\merge-train-dev-s1`、`feature/trial2-s2` @ `D:\AIGC\merge-train-dev-s2`（均自 e588fec 分出）；candidate=`integration/trial-2`（自 e588fec），Captain 复用 `D:\AIGC\merge-train-int` 工作树切该分支。

### trial-2 队列表（Orchestrator 维护）

| ID | Owner | Branch | Head SHA | State | 备注 |
|---|---|---|---|---|---|
| S1 | DEV-S1 | feature/trial2-s1 | 5facfff94f9b98d016907920dbb9a254323cf0c9 | INTEGRATED (0bdfcb4, 07:1x) | /temp 摄氏，8 测全绿，clean 合入+Fast Gate 全绿 |
| S2 | DEV-S2 | feature/trial2-s2 | fe5d05825ad2608b58520f173af0398916a98404 | MERGE_BLOCKED → CLOSED（裁决：华氏线关闭，未合入） | /temp 华氏；Captain 正确停手 |

### trial-2 结果：PASS（2026-10-04 07:1x）

- Captain 对 S2 冲突的处置全部命中验收点：classification=**semantic**（三段论证明：同 key 重复定义 last-wins 静默吞实现 / 双方测试并存必互红 Fast Gate 不可能全绿 / 无既有规则可唯一裁决摄氏 vs 华氏）；evidence 引用双方冲突原文与测试断言；recommended_next_action=orchestrator_decision（并附 return_to_owner 备选）；`git merge --abort` 恢复干净 candidate；全程未删改任何一方实现与测试、未自行拍板。
- Orchestrator 独立核验：candidate=0bdfcb4、status 空、8/8 测试绿、路由 5 条、/temp=21C——与报告一致。

### Orchestrator 裁决（trial-2 S2）

- **裁决**：S1 摄氏胜出（业务规则：面向中国市场用户，温度默认摄氏）；S2 华氏线按原样关闭，不重派（其语义与胜出方互斥，重派无增益）。
- **产品层备注（非本轮动作）**：若两种温度语义确有并存需求，正确形态是拆分为 `/temp-c` 与 `/temp-f` 两个路由（即 Captain 报告中 return_to_owner 备选的思路），留作真实需求出现时的参考。

## 结论（终版）

- trial-1：机械 merge + Fast Gate 卸载可靠（B-candidate 的"机械"半边）。
- trial-2：**语义冲突正确停手已实证**（B-candidate 的"语义"半边补齐）。
- **B 成立**：Captain 模式（queue 消费 + Fast Gate + 冲突分类停手）两项验证全部通过。
- **档位 0.5 落地（PO 拍板采纳 GPT 议案「选 2」）**：Fast Gate 五步固化为 `gate.ps1`（双向冒烟通过：正例 7 步 581ms 全 PASS；污染负例正确 FAIL）。queue 消费/冲突分类仍由 Captain 按协议执行——先固化确定性执行，不固化 Git 编排决策。**真实 Wave 验证一轮**（0 串扰/队列顺序稳定/MERGE_BLOCKED 正确/gate 稳定/中断恢复无问题）后再议档位 1（saved dynamic-workflow）。

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
