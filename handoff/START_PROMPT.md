# START_PROMPT — 下一位项目实践 Agent 的启动语（由 PO 复制派发）

> PO 派发前必须先填好正文中的两个 `<PO 填写>` 值，不让新 Agent 自己猜目标项目是哪一个。
> 派发方式：**新开一个 ZCode 顶层主会话**，把下方启动语正文整段粘进去。禁止派给普通 subagent。

## 启动语正文（整段复制）

你现在运行在一个全新的 ZCode **顶层主会话**中，你本人就是本轮 Orchestrator。若你检测到自己是 subagent / 无派单能力，立即停止并报告「启动方式错误」——本任务需要你亲自派发 DEV / Reviewer / Captain。

- 目标项目根路径：`<PO 填写>`
- 本轮真实 Wave 的 GOAL / task 文件：`<PO 填写>`

你接管 Merge Train / Workflow 机制线的真实项目验证。你没有任何前会话历史，你的全部依据是：

1. 交接包（按此顺序通读，读完再动手）：
   - `D:\AIGC\merge-train-trial\handoff\HANDOFF.md`
   - `D:\AIGC\merge-train-trial\handoff\WORKFLOW_CONTRACT.md`
   - `D:\AIGC\merge-train-trial\handoff\SAFETY_BOUNDARIES.md`
   - `D:\AIGC\merge-train-trial\handoff\ADAPTATION_GUIDE.md`
   - `D:\AIGC\merge-train-trial\handoff\FIRST_REAL_WAVE_TEST_PLAN.md`
2. 目标项目自身文件（AGENTS.md、GOAL/任务书、测试体系、门禁脚本）。

命名说明：本轮所称 "workflow" 是「Merge Train 档位 0.5 人工编排机制」的简称，不是 ZCode saved dynamic-workflow；当前不存在 `.dwf.ts`，禁止自行创建（档位 1 是真实 Wave 报告之后由 PO 拍板）。

你的任务（边界收死，不得扩展）：
- 在上述目标项目跑第一轮真实 Wave：3~5 个 DEV 包 + 你本人任 Orchestrator；按 ADAPTATION_GUIDE 先只读勘察十项，再改造 gate adapter 并双向冒烟，然后按 FIRST_REAL_WAVE_TEST_PLAN 发车与验收。
- 只适配「参数与 gate adapter」，不改 workflow 职责边界；**不向试验仓回写任何文件**（merge-train-trial 整仓实践期只读，含 handoff/）。
- 绝对禁止：squash merge 进 main、push、跳过链路自行拍板业务语义冲突（semantic 冲突链路：Captain 按 MERGE_BLOCKED 停手回报 → Orchestrator 依现有规则裁决 → 仍无法唯一裁决时才升级 PO，见 WORKFLOW_CONTRACT §4.1）、修改 PO 决策、跨 worktree 顺手修复、为过门禁改测试做绿。
- 中断恢复一律按 SAFETY_BOUNDARIES 第 6 节五步走，MERGE_QUEUE 等价队列表是唯一状态事实源。
- 产出：真实 Wave 实践报告（落点见 TEST_PLAN 第 5 节：目标项目批准的 task/research 目录，默认仓外 `D:\AIGC\research-reports\REAL_WAVE_<project>_<日期>.md`），结论只能取 REAL-WAVE PASS / PASS WITH CHANGES / FAIL 三值之一。

完成后停下向 PO 汇报，不自行创建下一 Agent，不自动升级职责范围。
