# Merge Queue — trial-1

> 只有 Orchestrator（主会话）可修改本表。Base=`2d6c91d1a3c44dbda80d570f9d08a1cb57f94777`（main）。
> Candidate branch：`integration/trial-1`（初始=Base）。

| ID | Owner | Branch | Worktree | Base SHA | Head SHA | State | Risk | Touched Hot Files | Relevant Tests | Queue Order |
|---|---|---|---|---|---|---|---|---|---|---|
| MQ-1 | DEV-A | feature/trial-dev-a | D:\AIGC\merge-train-dev-a | 2d6c91d | (待DEV回报) | RUNNING | low | src/routes.js, src/config.js | tests/unit/greet.test.js | 1 |
| MQ-2 | DEV-B | feature/trial-dev-b | D:\AIGC\merge-train-dev-b | 2d6c91d | (待DEV回报) | RUNNING | low | src/routes.js, src/config.js | tests/unit/now.test.js | 2 |
| MQ-3 | DEV-C | feature/trial-dev-c | D:\AIGC\merge-train-dev-c | 2d6c91d | (待DEV回报) | RUNNING | low | src/routes.js, src/config.js | tests/unit/sum.test.js | 3 |

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
