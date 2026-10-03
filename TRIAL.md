# Merge Train 试点协议（trial-1）

> 依据：PO 2026-10-04 拍板 + ChatGPT High 试点方案（档位 0 最小可运行试点）。
> 本仓库是「多 Agent 调度机制」独立试验项目，与 Garden-Design-Calculator（GDC）无关；**GDC 全程只读**。

## 1. 硬边界

- 本轮**不创建** `integration-captain.md`、不建插件/marketplace、不建 saved dynamic-workflow、不建新治理系统。
- 拓扑=扁平星型：**只有 Orchestrator（主会话）可派 Agent**；DEV-A/B/C、Captain、Reviewer 全部平级；**Captain 禁止再派任何 Agent**。
- 禁止 `git push`；禁止 `reset/clean/restore/checkout .` 等破坏性命令；每个 Agent 只许在自己的 worktree 里写文件。
- 只有 Orchestrator 可修改 `MERGE_QUEUE.md` 和本协议；DEV/Captain 只读。

## 2. 角色与路径

| 角色 | 载体 | Worktree | Branch |
|---|---|---|---|
| Orchestrator | 主会话 | `D:\AIGC\merge-train-trial` | main |
| DEV-A | general-purpose 子代理 | `D:\AIGC\merge-train-dev-a` | feature/trial-dev-a |
| DEV-B | general-purpose 子代理 | `D:\AIGC\merge-train-dev-b` | feature/trial-dev-b |
| DEV-C | general-purpose 子代理 | `D:\AIGC\merge-train-dev-c` | feature/trial-dev-c |
| Integration Captain | general-purpose 子代理 | `D:\AIGC\merge-train-int` | integration/trial-1 |

- Base commit（main 分岔点）：`2d6c91d1a3c44dbda80d570f9d08a1cb57f94777`
- Captain 只消费 State=READY_FOR_MERGE 的队列项；无权改归属、无权重派 DEV、无权碰 DEV 的 worktree。

## 3. Merge Queue 状态机

```
RUNNING → READY_FOR_MERGE → MERGING → INTEGRATED
                 (DEV完成自测绿)      ├→ MERGE_BLOCKED（语义冲突，Captain 停手回报）
                                     └→ FAST_GATE_FAILED（门禁红，回报证据）
```

- MERGE_BLOCKED / FAST_GATE_FAILED 的处置权在 **Orchestrator**：重派原 DEV 基于当前 candidate 修复，或授权 Captain 修复纯机械冲突。
- 每项从 READY 到 INTEGRATED 的耗时必须记录（试点数据）。

## 4. Captain 职责（固定十条，派单时全文引用）

1. 核验 expected repo root / worktree / branch / candidate SHA；
2. 读取本协议（TRIAL.md）；
3. 按 Merge Queue 顺序消费；
4. diff 初审；
5. 将完成分支合入 integration candidate；
6. 只允许处理：import 并集、配置并集、路由注册并集、自动生成文件重生成、已有规则能唯一裁决的简单冲突；
7. 执行 Fast Gate（§5）；
8. 成功后报告新的 candidate SHA；
9. 不自行扩展产品范围；
10. 不主动修改原 DEV 的业务实现。

遇到无法唯一裁决的语义冲突必须停止，按 §6 报文返回。

## 5. Fast Gate（确定性命令链，逐条全绿才算过）

在 candidate worktree（`D:\AIGC\merge-train-int`）执行：

```
1. sanity:
   git rev-parse --show-toplevel   # 必须 = D:/AIGC/merge-train-int
   git branch --show-current       # 必须 = integration/trial-1
   git rev-parse HEAD              # 必须 = MERGE_QUEUE 登记的当前 candidate SHA
2. syntax:
   node --check src/index.js && node --check src/routes.js && node --check src/config.js
3. unit:
   node --test "tests/unit/**/*.test.js"
4. e2e:
   node --test "tests/e2e/**/*.test.js"
5. pollution:
   git status --porcelain          # 必须为空
```

原则：能用命令判定的不用模型猜；Fast Gate ≠ Full Gate；每合一条只跑 Fast Gate；**全部队列项合完后由 Orchestrator 跑 Full Gate**（`node --test` 全量 + pollution + 三线路由齐活人工核对）。

注意：`node --test <目录>` 在 Node 24 会报 MODULE_NOT_FOUND，必须用 glob 引号形式（见上，2026-10-04 实测）。

## 6. MERGE_BLOCKED 报文格式（Captain 专用）

```text
MERGE_BLOCKED

queue_item:
owner:
candidate_sha:
branch:
conflicting_files:

classification:
- mechanical
- semantic
- owner_bug
- test_contract
- unknown

reason:

evidence:

recommended_next_action:
- captain_can_fix
- return_to_owner
- orchestrator_decision
```

## 7. 通用纪律（引 GDC 2026-10-04 串扰事故沉淀）

- 任何 Agent 在执行 merge/删除/覆盖类操作前，必须核验当前 repo root、worktree 路径与分支名与派单指派一致；不一致立即停止并上报，禁止「顺手修复」。
- 所有子 Agent 不派子代理（平台现状也不允许）；遇阻以 BLOCKED 回 Orchestrator，不自行扩大处置。
- 完成报告必须带：`git rev-parse --show-toplevel`、`git branch --show-current`、`git rev-parse HEAD` 三个核验结果，缺一视为未完成。
