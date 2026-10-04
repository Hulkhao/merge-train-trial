# HANDOFF — Merge Train / Workflow 机制线交接包

> 交接日期：2026-10-04。交接人：上一任项目主管（ZCode 主会话）。
> 接收人：项目实践 Agent（全新上下文）。本包自足，不依赖任何会话历史。
> 第一阅读顺序：HANDOFF.md（本文件） → WORKFLOW_CONTRACT.md → SAFETY_BOUNDARIES.md → ADAPTATION_GUIDE.md → FIRST_REAL_WAVE_TEST_PLAN.md。

## A. 背景：为什么做这件事，原始瓶颈是什么

1. **原始瓶颈**：多 Agent 并行开发时，只有主 Agent（Orchestrator）能派单；子 Agent 返回后，所有子 Agent 的产出都要主 Agent 亲自再核一遍（merge、冲突、门禁、验收），核验工作全堆在主 Agent 上下文里——主 Agent 成为吞吐与质量的单点瓶颈。
2. **解法方向**（PO 2026-10-04 拍板 + ChatGPT High 试点方案）：把「机械 merge + 确定性门禁 + 冲突分类停手」卸载给平级子 Agent（Captain 模式），主 Agent 只做派单、裁决、队列维护。拓扑=扁平星型：只有 Orchestrator 可派 Agent，DEV/Captain/Reviewer 全部平级。
3. **试验仓**：`D:\AIGC\merge-train-trial`（独立小项目，与 Garden-Design-Calculator 无关；GDC 全程只读）。已完成 trial-1（3 DEV 并行 + 机械冲突合流）与 trial-2（受控语义冲突停手）两轮受控试验。
4. **PO 已冻结的职责边界一句话**：**Workflow 负责生产可合并候选；Orchestrator 负责决定是否进入 main。**
5. **下一步（即你的任务）**：把这套机制接入一个真实项目跑第一轮真实 Wave，产出实战报告，供 PO 决定是否升级档位 1（saved dynamic-workflow）。

## B. 当前成熟度

### 已证明（试验仓实测，证据见 MERGE_QUEUE.md 12 项数据）

- **机械 merge 卸载**：trial-1 三线并行，Captain 合流 3/3 INTEGRATED，机械冲突自解 2/2（并集型唯一裁决），Full Gate 7/7 绿。
- **Fast Gate**：五步确定性命令链（sanity/syntax/unit/e2e/pollution），单步 94-434ms，五步×3 项全一次通过。
- **Captain 对 semantic conflict 停手**：trial-2 受控构造摄氏/华氏互斥语义，Captain 正确分类=semantic、不自行拍板、按报文格式交回、`git merge --abort` 恢复干净 candidate。
- **MERGE_BLOCKED**：报文格式（第 6 节）实战验证一次，字段完整可用。
- **gate.ps1 正反向验证**：正例 7 步 581ms 全 PASS；人为污染负例正确 FAIL。档位 0.5 落地。
- **串扰隔离**：0 串扰（Captain 全程只在 candidate worktree，DEV 各自 worktree，Orchestrator 抽查无越界）。
- **Orchestrator 上下文卸载**：merge 细节零进入主会话，仅消费结构化报告与队列编辑。

### 尚未证明（你的真实 Wave 要观察的重点）

- **真实项目复杂 Wave**（试验仓是 3 条玩具路由，真实项目文件域/测试体系复杂得多）。
- **长队列**（试验最多 3+2 项；真实 Wave 建议 3~5 包）。
- **真实 gate failure → 修复 → 重入**（试验 0 次门禁失败，此路径从未走过）。
- **中断恢复**（试验 0 次中断；这是 dynamic-workflow journal 价值的试金石，重点观察项）。
- **saved workflow 在生产项目里的长期稳定性**（saved dynamic-workflow 尚未创建，见 C 节）。
- **自动 merge（当前明确不做）**：squash merge 进 main / push 由 Orchestrator 完成，不自动化。

## C. 当前版本（具体 SHA 与路径，禁止用「最新版本」搪塞）

| 项 | 值 |
|---|---|
| 试验仓 branch | `main`（无远程仓库，纯本地；push 概念不存在） |
| 试验仓 HEAD | `77a37fb`（docs: design freeze per GPT ruling — 档位 0.5 验收通过 + 真实 Wave 观察期冻结令） |
| 试验 Base commit | `2d6c91d1a3c44dbda80d570f9d08a1cb57f94777`（trial-1 分岔点） |
| gate.ps1 定版 commit | `f3d6d39`（feat(gate): Fast Gate 固化，双向冒烟） |
| **workflow 文件（.dwf.ts）** | **不存在。** 档位 1（saved dynamic-workflow）按冻结令未创建；现行载体=协议三件套（下两行） |
| 协议文件 | `D:\AIGC\merge-train-trial\TRIAL.md`（角色/边界/状态机/Captain 十条/Fast Gate/报文格式/冻结裁决） |
| 队列文件 | `D:\AIGC\merge-train-trial\MERGE_QUEUE.md`（Orchestrator 独写；trial-1/trial-2 队列表+12 项数据+结论） |
| gate 脚本 | `D:\AIGC\merge-train-trial\gate.ps1`（注意：内部硬编码 candidate worktree=`D:/AIGC/merge-train-int`，接真实项目必须改造成 gate adapter，见 ADAPTATION_GUIDE） |
| DECISIONS.md | **不存在**于试验仓；决策记录在 TRIAL.md 结论节 + commit 历史 |
| 本交接包 | `D:\AIGC\merge-train-trial\handoff\`（5 个文件，自身 commit=`c194a39`，盖章于其后的 stamp commit） |

**残留 worktree 清单（试验遗留，非活跃任务；处置需 Orchestrator 同意）**：

| Worktree | Branch | HEAD | 性质 |
|---|---|---|---|
| D:\AIGC\merge-train-dev-a | feature/trial-dev-a | dca1961 | trial-1 成品（已 INTEGRATED） |
| D:\AIGC\merge-train-dev-b | feature/trial-dev-b | 4906bda | trial-1 成品（已 INTEGRATED） |
| D:\AIGC\merge-train-dev-c | feature/trial-dev-c | 78822ed | trial-1 成品（已 INTEGRATED） |
| D:\AIGC\merge-train-dev-s1 | feature/trial2-s1 | 5facfff | trial-2 胜出线（已 INTEGRATED） |
| D:\AIGC\merge-train-dev-s2 | feature/trial2-s2 | fe5d058 | trial-2 被裁决关闭线 |
| D:\AIGC\merge-train-int | integration/trial-2 | 0bdfcb4 | 最终 candidate（trial-2 终态） |

**依赖能力**：ZCode Agent 工具（general-purpose 子代理，平级派单）；PowerShell 7（pwsh，gate.ps1 有版本守卫，exit 42=解释器过旧）；git；Node.js（`node --test` 必须用 glob 引号形式，Node 24 目录形式会 MODULE_NOT_FOUND，2026-10-04 实测）。dynamic-workflows skill（journal/断点恢复）属档位 1 能力，**当前未使用**；gstack 非必需。

## D. 给全新 Agent 的快速答（fresh-context 自检八问）

1. **从哪个文件开始读？** 本文件（HANDOFF.md），按顶部阅读顺序读完五件套再动手。
2. **运行什么？** 先按 ADAPTATION_GUIDE 在目标项目做只读勘察 → 写 gate adapter → 正反双向冒烟（干净树 PASS + 人为污染 FAIL）→ 按 FIRST_REAL_WAVE_TEST_PLAN 发车真实 Wave。
3. **绝对不能做什么？** SAFETY_BOUNDARIES.md 全部条目。最硬的五条：不自动 merge main、不 push、semantic conflict 必须停手上报、破坏性 git 操作前必须核验 root/worktree/branch/SHA、不因 workflow 需要放宽目标项目生产守卫。
4. **我的输入是什么？** 目标项目 + 其任务书（GOAL/task 文档）+ 按 WORKFLOW_CONTRACT 输入节定义的执行包清单（owner/branch/worktree/base/head/relevant tests/queue order）。
5. **我的输出是什么？** 队列表终态（每包状态/branch/worktree/HEAD/tests/gate 结果/失败分类）+ candidate 信息 + 实践报告 `handoff/REAL_WAVE_REPORT_<日期>.md`，交 PO。
6. **第一轮真实项目实践怎样算通过？** FIRST_REAL_WAVE_TEST_PLAN.md 的三值结论：REAL-WAVE PASS / PASS WITH CHANGES / FAIL（回退档位 0.5），判定标准在该文件第 4 节。
7. **出现 semantic conflict 怎么办？** 停手。按 TRIAL.md 第 6 节 MERGE_BLOCKED 报文格式（classification=semantic + evidence + recommended_next_action）交回 Orchestrator 裁决；**任何 Agent 不得自行拍板业务语义**。
8. **workflow 跑到一半中断后，去哪里恢复状态？** `MERGE_QUEUE.md` 队列表是唯一状态事实源。恢复五步（详见 SAFETY_BOUNDARIES.md 第 6 节）：不重发在途单 → 读队列表 → 逐 worktree git 核验（branch/HEAD/porcelain）→ 与各 Agent 已交报告对账 → 补记状态后接续。若未来升级档位 1（dynamic-workflow），另有 journal 断点恢复，但那是升级后才存在的能力。

## E. 你的任务边界（重复一遍，防止跑偏）

1. 完整理解设计目标与职责边界（WORKFLOW_CONTRACT.md）；
2. 在指定真实项目做一次实际运行（FIRST_REAL_WAVE_TEST_PLAN.md）；
3. 按目标项目 AGENTS.md / GOAL / 测试体系适配**参数与 gate adapter**；
4. 不突破已冻结的自动化边界（SAFETY_BOUNDARIES.md）；
5. 产出真实项目实践报告。

**不要**：继续设计 workflow、新增功能、修改档位裁决、创建 saved dynamic-workflow（那是真实 Wave 报告之后 PO 拍板的事）、进入真实项目直接写业务代码。
