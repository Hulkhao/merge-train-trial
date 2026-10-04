# WORKFLOW_CONTRACT — 把这套机制当接口看

> 本文区分两层：**已实现的合同**（试验仓现行，档位 0.5）与**冻结的设计边界**（PO 2026-10-04 定义，真实 Wave 起生效，载体可以是人工编排或未来 saved workflow）。凡「未实现」标注的能力，不得当作已存在来调用。

## 1. 职责边界（冻结原则，原样传递）

### Workflow 负责

- 读取任务书；
- 将可并行工作拆成执行包；
- 并行派出平级执行 Agent；
- 每包独立验收；
- 失败包进入修复循环；
- 执行确定性 Fast Gate；
- 汇总各包结果；
- 输出「可合并候选」与验收报告。

### Workflow 不负责

- 最终 squash merge 进 main；
- 自动 push main；
- 自主处理业务语义冲突；
- 自主修改 PO 决策；
- 最终 Full Gate 后的发布裁决；
- baseline freeze；
- 需要语义判断的冲突合成。

**原则一句话：Workflow 负责生产可合并候选；Orchestrator 负责决定是否进入 main。**

### 逐条实现现状对照（防止把设计当现实）

| 职责 | 现状 | 证据 |
|---|---|---|
| 读取任务书、拆执行包 | **人工**（Orchestrator 读任务书后手填队列表）；自动拆包未实现 | MERGE_QUEUE.md 表由 Orchestrator 维护 |
| 并行派出平级执行 Agent | 已实现（人工派发，Agent 工具扇出） | trial-1 三线平行 06:47 发车 |
| 每包独立验收 | **部分**：DEV 自测绿 + Orchestrator 抽查（branch/HEAD/porcelain）；独立验收员角色未单独跑过 | MERGE_QUEUE 流水记录 |
| 失败包修复循环 | **未走通**：重派机制已定义（处置权在 Orchestrator），0 次实战 | 12 项数据第 7 条 |
| 确定性 Fast Gate | 已实现（gate.ps1，正反向冒烟） | f3d6d39 |
| 汇总 + 可合并候选 + 验收报告 | 已实现（Captain 结构化报告 + Orchestrator Full Gate） | trial-1/2 记录 |

## 2. 输入合同（以当前真实实现为准）

### 2.1 队列表 schema（MERGE_QUEUE.md 表行 = 执行包定义，Orchestrator 独写）

| 字段 | 含义 | trial 实例 |
|---|---|---|
| ID | 包编号 | MQ-1 / S1 |
| Owner | 平级执行 Agent 名 | DEV-A |
| Branch | 该包 feature 分支 | feature/trial-dev-a |
| Worktree | 该包独占工作树绝对路径 | D:\AIGC\merge-train-dev-a |
| Base SHA | 分岔点 commit | 2d6c91d |
| Head SHA | DEV 完成后锁定入单 | dca1961a... |
| State | 状态机状态（见第 4 节） | INTEGRATED (合入 SHA, 时刻) |
| Risk | 风险标注 | low |
| Touched Hot Files | 预判的冲突热点文件 | src/routes.js, src/config.js |
| Relevant Tests | 该包相关测试 | tests/unit/greet.test.js |
| Queue Order | 消费顺序 | 1 |

### 2.2 启动一项真实 Wave 时 Orchestrator 必须备齐

- target_repo（目标仓库根路径）与 base_sha（本轮 baseline，冻结后不得漂移）；
- task_goal / task_file（任务书路径，如目标项目 GOAL 文档）；
- 执行包清单（按 2.1 schema 逐行填，含 hot files 与 relevant tests）；
- 每包 owner（一个包一个 Agent，不共载）；
- gate adapter（按目标项目门禁重定义的 Fast Gate 脚本，见 ADAPTATION_GUIDE）；
- max_concurrency（第一轮建议 3~5，不追求极限并发）；
- protected paths（目标项目 PO 保护区，原样下发到每一张派单）；
- candidate worktree/branch（如 integration/<wave-id>，与 DEV worktree 物理隔离）。

### 2.3 派单自包含要求（每张 DEV/Captain 单必带）

目标、非目标、硬约束、验收标准、证据要求、protected paths、三核验要求（toplevel/branch/HEAD）。

## 3. 输出合同

### 3.1 DEV 完成回报（每包）

- 三核验结果（`git rev-parse --show-toplevel` / `git branch --show-current` / `git rev-parse HEAD`），缺一视为未完成（TRIAL.md 第 7 节）；
- 实现摘要（改了什么、没改什么）；
- 自测结果（relevant tests 全绿证据）；
- 工作区净检（porcelain=0）；
- 触碰文件清单（与 hot files 比对）。

### 3.2 Captain/Candidate 报告（每包合入后）

- 新 candidate SHA；Fast Gate 五步逐步结果；
- 冲突处置记录（无冲突 / mechanical 自解依据 / semantic 停手）。

### 3.3 MERGE_BLOCKED 报文（semantic/无法唯一裁决时，TRIAL.md 第 6 节原样）

```text
MERGE_BLOCKED
queue_item:
owner:
candidate_sha:
branch:
conflicting_files:
classification:        # mechanical / semantic / owner_bug / test_contract / unknown
reason:
evidence:
recommended_next_action:  # captain_can_fix / return_to_owner / orchestrator_decision
```

### 3.4 Wave 终局（Orchestrator）

- 队列表终态 + 每包 READY→INTEGRATED 耗时；
- Full Gate 结果（全量测试 + pollution + 业务抽测）；
- candidate 终态 SHA（=「可合并候选」，是否进 main 由 Orchestrator/PO 裁决）；
- 实践报告（FIRST_REAL_WAVE_TEST_PLAN 第 5 节格式）。

## 4. 状态模型（真实实现，勿虚构）

### 4.1 现行状态机（TRIAL.md 第 3 节，实战验证过）

```
RUNNING → READY_FOR_MERGE → MERGING → INTEGRATED
                 (DEV完成自测绿)      ├→ MERGE_BLOCKED（语义冲突，Captain 停手回报）
                                     └→ FAST_GATE_FAILED（门禁红，回报证据）
CLOSED（Orchestrator 裁决关闭该包，trial-2 S2 实战使用过）
```

- MERGE_BLOCKED / FAST_GATE_FAILED 处置权在 Orchestrator：重派原 DEV 基于当前 candidate 修复，或授权 Captain 修复纯机械冲突。

### 4.2 真实 Wave 建议扩展名（**非现有实现**，启用须 Orchestrator 在队列表头声明）

若启用「每包独立验收 + 修复循环」，在 READY_FOR_MERGE 前后加两个包级状态：

- `VALIDATING`（独立验收员审包中）；
- `FIX_REQUIRED`（验收发现问题，带问题清单重派 owner，修复后重新走 READY_FOR_MERGE）；
- 全部包 INTEGRATED 且 Full Gate 绿后，candidate 标记 `CANDIDATE_READY`（= 交付 Orchestrator 裁决的终态）。

这三个名字是本交接包给下位 Agent 的命名约定建议，**不是已实现状态**；用不用、叫什么，Orchestrator 发车前在队列表声明即可。
