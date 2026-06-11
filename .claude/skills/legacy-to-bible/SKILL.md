---
name: legacy-to-bible
description: Reverse-engineer a business Bible (北極星 / 黃金旅程 / user story) from the legacy eProposal system — the "Legacy →(EPRO Expert AI)→ Bible" step of the AI workflow (docs/assets/ai-workflow.mmd). Use when starting a domain from scratch, or to give PRD/SRS an evidence-grounded upstream. Triggers: "反推 Bible", "產 Bible", "Legacy 轉 Bible", "bible for <domain>".
---

# Legacy → Bible（EPRO Expert + AI 步驟）

從舊系統**反推**業務知識，產 **Bible**（敘事特例：不是契約、是讓團隊不分角色一致理解業務）。
產物放 `docs/specs/bible/bible-<domain>.md`，是 PRD 的上游（funcId 骨幹起點）。位置見 `docs/assets/ai-workflow.mmd`、分層見 `docs/specs/README.md`。

## ⚠️ 最重要的鐵則：證據接地（這層最會幻覺）
反推＝從碼推「為何這樣設計」，**AI 最容易在這層 confabulate**。**每個業務主張都要引 legacy `file:line` / 表名 / trx-id**；推不出依據的標「**推測（待業務確認）**」，**絕不寫成既定事實**。寧缺勿假。
> **證據分級（2026-06-11 健檢明文化）**：`[HUMAN]`（業務/系統知識持有人已確認）＝**合格證據層級**，可先支撐主張；legacy `file:line` 為升級項——標 `[CODE-TBD]` 者於 source 驗證階段回填。專案級 Bible（如 `bible-eproposal.md`）先以 `[HUMAN]` 入流＝**合規、非違規**。

## 輸入
1. **Legacy source**（舊碼 `file:line`、JSP、DB schema、SQL）——主來源。
2. **現有分析**（先吃這些，別重做）：`module-is-iu-shell.md`、`module-cs-cu-shell.md`、`module-i0-c0-scoring.md`、`page-mapping.md`、`db-schema-catalog.md`、`decisions.md §「舊系統(EPRO) 架構事實」`。
3. **舊系統事實**（D1–D6 已反推）：HttpDispatcher、SSO/MIS、pageMap 狀態機、≈250 JSP=9 模組×兩流程（申請/覆核）。

## 輸出（`docs/specs/bible/bible-<domain>.md`，一個業務域一檔）
1. **北極星（North Star）**：這個業務**為何存在**、成功長什麼樣（一句話 + 展開）。引證據。
2. **黃金旅程（Golden Journey）**：端到端 happy path（如「案件建檔 → 徵審 → 評分 → 核准 → 撥貸」），標每段對應的舊 funcId / 新頁、角色、狀態轉移（`CASE_PROGRESS`/checkpoint）。
3. **User stories**：`角色 × 目標 × 為何`（如「徵審人員要看 CBC 才能評估往來」）；對到黃金旅程節點。
4. **關鍵業務規則摘要**（非逐條，是「為何有這規則」的敘事；逐條規則留 SRS `Rn`）。
5. **證據註腳**：每主張的 legacy `file:line` / 表 / trx。
6. **未解 / 推測**：推不出依據的，列「待業務確認」。

## 鐵則
1. **證據接地**（見上）——Bible 唯一硬規則。
2. **敘事、非契約**：Bible 講「為何 / 是什麼」；「怎麼做」的可驗證規則留給 SRS（別在 Bible 寫 endpoint/欄位型別）。
3. **一域一檔**：`bible-<domain>.md`（如 `bible-loan-origination.md`、`bible-disbursement.md`、`bible-credit-scoring.md`）。
4. **下游可追溯**：PRD 的 `REQ` 要能追到 Bible 的 story / 黃金旅程節點 → funcId 骨幹從這裡起。
5. **不重做分析**：能引現有 `module-*.md`/`decisions §D1` 就引，Bible 是「收斂成業務敘事」，非重抽碼。
6. **舊系統≠絕對正確**：反推的是「舊系統怎麼做、為何」，不等於「應該怎麼做」；在地化/演進的點標出，留給 PRD 決定保留與否。

## 步驟
1. 選一個業務域（如 loan-origination / disbursement / credit-scoring）。
2. 吃現有分析 + 舊碼 → 抽：主流程狀態機、角色、關鍵表、跨模組關係。
3. 寫北極星 → 黃金旅程（端到端，標 funcId/角色/狀態）→ user stories → 規則摘要 → 證據註腳。
4. 標「待業務確認」的推測項。
5. 回填：在 `docs/specs/bible/README.md` 登錄該域 Bible；PRD 階段用它當上游追溯。

## DoD（Bible「可用」前）
- [ ] 北極星明確（為何存在 + 成功樣貌）。
- [ ] 黃金旅程**端到端**、每段標 funcId/角色/狀態轉移。
- [ ] 每個 user story 有 `角色 × 目標 × 為何`，對到旅程節點。
- [ ] **每個業務主張有證據**（legacy `file:line`/表/trx，**或 `[HUMAN]` 已確認標記**——`file:line` 為 `[CODE-TBD]` 升級項）；無依據者標「待業務確認」。
- [ ] 敘事層（無 endpoint/欄位型別——那是 SRS）。
- [ ] 下游 PRD `REQ` 可追溯到本檔 story/節點。

> 雙軌：Codex 版＝`docs/env/codex/prompts/legacy-to-bible.md`＝**薄殼指標**（內容權威＝本檔；改內容只改本檔，Codex 範本僅差異清單變動才動）。上游 Bible→PRD 之 PRD 撰寫用官方 `/write-spec`；本 skill 專責「反推 Bible」這一步。
