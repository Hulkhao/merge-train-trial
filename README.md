# merge-train-trial — 多 Agent 调度机制试点（已冻结归档）

> 状态：**试验线已冻结**（GPT 终审裁决 + PO 2026-10-04 确认）。档位 0.5 验收通过，进入真实场景观察期。本仓库不再活跃开发，作为机制验证记录与重启起点归档保存。

## 它是干嘛的

这是一个**独立的多 Agent 调度机制（Merge Train）试验项目**，用一个玩具 Node 项目（3 条路由 + node --test）验证以下机制在多 Agent 并行开发时是否可靠：

- **拓扑**：扁平星型——只有 Orchestrator（主会话）可派 Agent；DEV-A/B/C 各占一个 git worktree 并行开发；Captain 平级负责消费合并队列（MERGE_QUEUE.md），禁止再派 Agent。
- **流程**：DEV 提交到自己的 feature 分支 → 队列标记 READY_FOR_MERGE → Captain 按 GUI 协议逐项 merge 到 integration 分支 → Fast Gate（`gate.ps1`）把关（HEAD 校验 / 语法 / unit / 污染检测）→ 语义冲突时正确停手上报 Orchestrator（MERGE_BLOCKED），不擅自裁决。
- **验证结果**：
  - trial-1：机械合并 + Fast Gate 卸载可靠（3 条机械冲突全部由 Captain 按协议自解）。
  - trial-2：语义冲突正确停手实证（不猜测意图、不强行合并）。
  - 档位 0.5 落地：Fast Gate 五步固化为 `gate.ps1`，双向冒烟通过（正例 7 步 581ms 全 PASS；污染负例正确 FAIL）。
- **冻结位置**：机制冻结在档位 0.5。是否升级档位 1（saved dynamic-workflow），等第一轮真实项目 Wave 的实战报告之后再议（见 `handoff/FIRST_REAL_WAVE_TEST_PLAN.md`）。

## 为什么建在 D:\AIGC

2026-10-04 由 PO 拍板 + ChatGPT High 出试点方案（档位 0 最小可运行试点）后创建。建在 `D:\AIGC` 独立顶层目录是**刻意隔离**：试验需要自由创建多个 worktree、演练合并冲突甚至中断恢复，不能碰任何真实项目（试验全程 GDC 只读）。它与 user-chrome-bridge skill 无功能关系——唯一联系是渠道：试点方案是当时经 user-chrome-bridge 驱动 ChatGPT High 咨询所得。

## 仓库导览

| 路径 | 内容 |
|---|---|
| `TRIAL.md` | 试点协议（硬边界、角色与 worktree 分配、merge/Gate 流程） |
| `MERGE_QUEUE.md` | 合并队列 + 终版结论（状态板、职责切分、两条保留纪律、真实 Wave 观察项） |
| `gate.ps1` | Fast Gate 脚本（试验仓验证版；接入真实项目须按其门禁重定义，禁止照搬） |
| `handoff/` | 交接包五件套（fresh-context 自足）：HANDOFF / WORKFLOW_CONTRACT / SAFETY_BOUNDARIES / ADAPTATION_GUIDE / FIRST_REAL_WAVE_TEST_PLAN / START_PROMPT |
| `src/` `tests/` | 玩具被测项目（3 条路由 + unit/e2e 基线） |

## 如何重启这条线

`git clone` 本仓库 → 读 `handoff/START_PROMPT.md` 与 `handoff/HANDOFF.md` → 按 `ADAPTATION_GUIDE.md` 对目标项目做只读勘察并改造 gate adapter → 按 `FIRST_REAL_WAVE_TEST_PLAN.md` 执行第一轮真实 Wave。历史分支（feature/trial-*、integration/trial-*）已全部保留在远端。
