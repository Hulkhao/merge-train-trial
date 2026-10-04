# FIRST_REAL_WAVE_TEST_PLAN — 第一轮真实 Wave 实践验收计划

> 第一轮不追求极限并发。目标：拿一份真实项目的 0.5 实战报告，验证机制在真实复杂度下是否成立，并回答「dynamic-workflow journal 是否值得升级档位 1」。

## 1. 编制

- 3~5 个 DEV package（真实任务书拆出的可并行工作包）；
- 1 个 Orchestrator（你，主会话）；
- workflow（机制）负责执行与包级验收；每包独立验收由**验收员 Agent**（fresh eyes，未参与该包开发）承担；
- Captain / Reviewer 只在需要时介入（有合流需求才派 Captain）；
- merge main 仍由 Orchestrator 完成（本轮不做，见 SAFETY_BOUNDARIES 第 2 节）。

## 2. 发车前自检（全过才发车）

1. 只读勘察十项完成（ADAPTATION_GUIDE 第 1 节），结论已记录；
2. gate adapter 双向冒烟通过（正例 PASS + 污染负例 FAIL）；
3. 队列表建好：每包 ID/Owner/Branch/Worktree/Base SHA/Risk/Hot Files/Relevant Tests/Queue Order，base_sha 统一冻结；
4. 每张派单自包含（目标/非目标/硬约束/验收标准/证据要求/protected paths/三核验要求）；
5. 目标项目 AGENTS.md 硬约束逐条过目（特别是 protected paths 与破坏性操作核验）。

## 3. 本轮必须观察的 10 项（逐项记录证据，非机械打勾）

1. **queue 顺序是否稳定**（按 Queue Order 消费，无跳号无重排）；
2. **是否发生串扰**（任何 Agent 出现在非派单 worktree / 碰了他人文件 = 串扰，记录现场）;
3. **gate adapter 是否稳定**（误报/漏报/环境性失败各多少次）；
4. **是否出现真实 gate failure**（第一轮最好真实发生一次；不人为制造，但发生了是宝贵样本）;
5. **failure 后修复重入是否正常**（重派 owner → 修复 → 重新过 gate → 状态机推进，全链证据）；
6. **是否出现 semantic conflict**（出现了走 MERGE_BLOCKED 全流程；没出现如实记录「未自然出现」）；
7. **escalation 是否正确**（该停手的停手了、报文格式完整、Orchestrator 裁决链清晰）；
8. **是否发生中途中断**（进程/会话/Agent 失联；发生了就按 SAFETY_BOUNDARIES 第 6 节恢复协议走，全程记录）；
9. **恢复后是否重复执行或漏包**（对账：每个包恰好一次交付，candidate 不乱）；
10. **workflow 是否真正减少 Orchestrator 上下文与机械操作**（主观+客观：Orchestrator 本轮亲手做了哪些事、merge 细节是否进过主上下文、与试验仓基线对比）。

其中第 8、9 项是**重点观察项**（中断恢复）：若真实 Wave 没有中断痛点，dynamic-workflow 的 journal 价值存疑，长期停在档位 0.5 即合理终态——这个结论本身就是有效产出，不是失败。

## 4. 结论三值（只能取其一）

- **REAL-WAVE PASS**：10 项观察全部无重大异常；gate failure（若有）修复重入正常；串扰=0。
- **PASS WITH CHANGES**：机制成立但需修正（如 gate adapter 需改造、验收员粒度需调整、状态机需扩展）；列出修改项。
- **FAIL / 回退档位 0.5**：出现不可控串扰、恢复协议失效、或 gate 体系在真实项目不可运行；记录根因，机制回退到「Orchestrator 亲手合流」。

**不要因为单次实践通过就自动授权「自动 merge main」**——那需要 PO 另行拍板。

## 5. 实践报告格式（交 PO）

> 报告落点在**试验仓之外**：优先写目标项目批准的 task/research 目录；目标项目无合适位置（如只读期）则写仓外 `D:\AIGC\research-reports\REAL_WAVE_<project>_<日期>.md`。**禁止写进 `merge-train-trial/handoff/`**（实践期试验仓整仓只读）；实践完成后是否归档回 trial repo，由 PO 单独授权。

1. 目标项目与勘察结论（十项逐条）；
2. Wave 概况（包数、任务书、base_sha、耗时）；
3. 10 项观察逐项证据；
4. 状态机终态表（每包：状态/branch/HEAD/tests/gate 结果/失败分类/耗时）;
5. candidate 终态与 Full Gate 结果；
6. 偏差与修改建议（PASS WITH CHANGES 时必填）；
7. 结论三值 + 是否建议升级档位 1（含理由；升级=创建 saved dynamic-workflow，由 PO 拍板）。

## 6. 本轮明确不做

- 不自动 merge main、不 push、不做发布；
- 不因本轮顺利而顺手升级职责范围；
- 实践期不向试验仓回写任何文件（整仓只读，含报告与 gate adapter）；归档回仓需 PO 单独授权；
- 报告完成后停下等 PO，不自行创建下一 Agent、不自行开下一轮。
