# ADAPTATION_GUIDE — 真实项目接入适配指南

> 给项目实践 Agent。不要假设目标项目和试验仓一样（试验仓=3 条玩具路由 + node --test）。
> **只允许适配「参数和 gate adapter」，不要擅自改 workflow 的职责边界（WORKFLOW_CONTRACT 第 1 节）。**

## 1. 进入目标项目后：先做只读勘察（十项，逐项落成笔记）

1. 读项目根 `AGENTS.md`（工程规则、Source of Truth、治理约束）；
2. 读当前 GOAL / task 任务书（本轮 Wave 做什么、非目标、红线）；
3. 确认测试命令（unit / integration / e2e 分别是什么命令、从哪跑、多久）；
4. 确认 protected paths（PO 保护区、禁改文件清单）；
5. 确认 branch / worktree 规则（分支模型、worktree 分配与端口约定、谁可开）;
6. 确认 Fast Gate 应包含什么（候选：typecheck / unit / 相关集成测试 / lint；选**能快判**的）;
7. 确认 Full Gate 应包含什么（候选：全量测试 / E2E / 构建产物 / pollution；由 Orchestrator 终跑）；
8. 确认哪些文件属于 HOT conflict zone（多包大概率同碰的文件：路由注册、配置、索引、schema、共享组件）；
9. 确认是否允许 commit / merge / push（PO 授权边界；默认：包内 commit 可以，merge main / push 不可以）；
10. 确认已有 gstack 质量门是否必须调用（按目标项目 AGENTS.md 的映射表；本机制不替代它）。

勘察期间**只读**。勘察结论写进实践报告第 1 节。

## 2. gate adapter 改造规则（gate.ps1 是试验仓验证版，禁止机械复制）

试验仓 `gate.ps1`（trial main 根目录，commit f3d6d39）内部硬编码了以下试验专属内容，逐项对照改造：

| 硬编码点 | 试验仓值 | 真实项目做法 |
|---|---|---|
| candidate worktree | `D:/AIGC/merge-train-int` | 改为参数（-CandidateRoot），或按目标项目 worktree 约定重定义 |
| 语法检查 | `node --check src/*.js` | 换成目标项目等价物：TS 项目=tsc（`npm run typecheck` 等） |
| unit | `node --test 'tests/unit/**/*.test.js'` | 换成目标项目 unit 命令（vitest/jest/pytest…） |
| e2e | `node --test 'tests/e2e/**/*.test.js'` | E2E 通常太慢，第一轮建议移出 Fast Gate 放进 Full Gate |
| pollution | `git status --porcelain` 必须空 | 通常可直接保留（通用） |
| sanity | root/branch/HEAD 三核验 | **必须保留**，这是防串扰的核心步骤，且 root 断言改为目标项目 candidate 路径 |
| pwsh7 守卫 | exit 42 | 保留 |

改造后的脚本叫 **gate adapter**，存放位置与命名按目标项目惯例（建议 `gate-<wave-id>.ps1` 或目标项目 scripts 目录），**只放目标项目侧，不回写试验仓**（实践期 merge-train-trial 整仓只读）。

改造后必须做**双向冒烟**（继承试验仓纪律）：

- 正例：干净 candidate → 全步 PASS，`GATE=PASS`（exit 0）；
- 负例：人为制造污染（如 touch 一个未跟踪文件）→ pollution 步 FAIL，`GATE=FAIL`（exit 1）。

两条保留纪律（TRIAL.md 冻结裁决原文）：

1. gate 进任何新项目必须按该项目真实门禁重定义，禁止照搬脚本口径；
2. 自动化报「错误」时必须先区分被测对象失败 vs 验收脚本/调用环境自身失败。

## 3. 参数适配清单（发车前 Orchestrator 逐项确认）

- max_concurrency：第一轮 3~5 包，不追求极限并发；
- 每包 owner 独占 worktree + feature 分支，base_sha 统一（本轮 baseline 冻结点）；
- 队列表（MERGE_QUEUE 等价物）由 Orchestrator 独写，放目标项目或 handoff 侧，表头声明状态机扩展名（若启用 WORKFLOW_CONTRACT 第 4.2 节）；
- protected paths 逐字下发到每张派单；
- hot files 从勘察第 8 项来，用于预判冲突与定 Queue Order（热文件包排后、互斥包排开）。

## 4. 与目标项目治理的接合

- 合并前更新 STATUS/CHANGELOG 等文档义务，属 Orchestrator 合流步骤，不在 workflow 自动化范围内；
- 涉及 ORM/schema 的改动按目标项目规则（如 GDC：一律独立 worktree）——这天然适合本机制的包隔离，但要在派单里显式写明；
- 目标项目若要求 E2E 从真实主入口起步等验收纪律，Full Gate / 验收员派单必须继承，不得因机制方便而省略。

## 5. 明确不在本轮做的事

- 不创建 saved dynamic-workflow（档位 1，真实 Wave 报告后 PO 拍板）；
- 不自动化 squash merge / push / 发布；
- 实践期试验仓整仓只读：不改其裁决与协议，也不回写任何文件（含报告）；归档回仓需 PO 单独授权。
