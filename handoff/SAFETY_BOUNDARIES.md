# SAFETY_BOUNDARIES — 安全边界（最重要，违反即事故）

> 这些边界来自试验仓 TRIAL.md 冻结裁决、GDC 2026-10-04 串扰事故沉淀、PO 常设授权。冲突时目标项目自身的 AGENTS.md 与 PO 冻结规则优先于本文件。

## 1. 派单权

- **只有 Orchestrator（主会话）有全局派单权。**
- **subagent 不允许再派 subagent**（平台现状也不允许）；遇阻以 BLOCKED 回 Orchestrator，不自行扩大处置。
- 拓扑=扁平星型：DEV、Captain、Reviewer 全部平级；Captain 只消费队列表，无权改归属、无权重派 DEV、无权碰 DEV 的 worktree。

## 2. merge 与 push

- **workflow 不自动 merge main**；squash merge 进 main 由 Orchestrator 逐包裁决执行。
- **禁止 git push**（试验仓无远程；目标项目的 push/部署按该项目 PO 授权执行，默认不授权给 workflow）。
- Captain 只把完成分支合入 integration candidate 分支，这是它唯一允许的 merge。

## 3. 冲突处置

- **semantic conflict 必须 escalation**：无法唯一裁决时按 WORKFLOW_CONTRACT 第 3.3 节报文停手上报，**禁止任何 Agent 自行拍板业务语义**。
- Captain 只允许处理：import 并集、配置并集、路由注册并集、自动生成文件重生成、已有规则能唯一裁决的简单冲突。
- 不主动修改原 DEV 的业务实现。

## 4. 破坏性 git 操作核验（2026-10-04 GDC 串扰事故纪律，原样传递）

任何 Agent 在执行 merge / reset / clean / restore / checkout / 删除 / 覆盖类操作前，必须核验：

- repo root（`git rev-parse --show-toplevel`）
- worktree 路径
- branch（`git branch --show-current`）
- expected SHA（`git rev-parse HEAD` 对照队列表登记值）

与派单指派不一致**立即停止并上报**，禁止「顺手修复」其他 worktree。

**不得跨 worktree「顺手修复」**：每个 Agent 只许在自己的 worktree 里写文件。

## 5. 目标项目优先级

- **目标项目的 protected files 永远优先于 workflow 默认行为**（如 GDC 的 `src/手工笔记.md`、`src/ob素材库/` 为 PO 保护区，只读；任何 reviewer/QA/执行 Agent 同样只读）。
- **Fast Gate 失败不得通过修改测试来「做绿」**，除非测试契约本身被证明过期（证明责任在提出者，且须 Orchestrator 确认）。
- **不允许因为 workflow 需要而放宽目标项目生产守卫**（门禁、类型检查、校验器一律不降档）。
- 目标项目 AGENTS.md / GOAL / confirmed docs / Source of Truth 优先级高于本机制的一切默认行为。

## 6. 中断恢复协议（0.5 载体，队列表=唯一状态事实源）

中断（进程死、会话断、Agent 消失失联）后，接续 Agent 按此五步，禁止凭记忆接续：

1. **不重发任何在途单**（不知道它死前是否已实际发出/写入）；
2. 读 `MERGE_QUEUE.md` 队列表，确认每个包的最后登记状态；
3. 逐 worktree 物理核验：branch、HEAD、porcelain 三项，与队列表和各 Agent 已交报告对账；
4. 把核实后的真态补记进队列表（含时刻与核验人）；
5. 从第一个不一致处接续，已 INTEGRATED 的包绝不重做。

判「某 Agent 已死」必须全输出位核查或等其自己表态——只查部分痕迹就判死并重派，是已发生过的事故（2026-10-04 绘图线双执行器）。

## 7. 同仓同文件域 Agent 接力纪律（原样传递）

同仓库、同文件域 Agent 接力必须：

```
idle 确认
→ git status/diff 审计
→ 前置验收
→ checkpoint commit 或 patch+HEAD/status 留档
→ 下一 Agent 才接续
```

静默 N 分钟不得作为「已完成」判据。

## 8. 报错甄别（试验沉淀的教训）

自动化报「错误」时，必须先区分：**被测对象失败** vs **验收脚本/调用环境自身失败**（试验中两次 parse 错幻影的教训）。gate FAIL 先复核 gate 自身与调用环境，再定性被测对象。

## 9. 报告纪律

- 完成报告必带三核验结果，缺一视为未完成；
- 报告只写真实做过的事：没跑的检查不写「已验证」，修不了的如实标注，不硬造结果；
- 失败证据（命令、输出、SHA）原文带回，不转述。
