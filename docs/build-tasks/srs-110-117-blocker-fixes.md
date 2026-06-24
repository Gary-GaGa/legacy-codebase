# SRS 110/112/114/116/117 — axis A–F 複審 Blocker 修單（給 dev 機 Codex）

> **來源**：2026-06-24 跨模型 axis A–F 獨立複審（QA 已拔除，G 可測試性不適用）。機械閘門 5 包全 PASS；本單＝**語意層**待修。
> **前置（重要）**：dev 機修前**先 `git pull`**——QA 帳務債（dormant qa-cases 引用、Output files、Traceability QA 欄 banner、00116「through QA」措辭）**已在 planning repo 清掉**（本 commit），勿重複處理、避免分叉。
> **紀律**：審者報、人/dev 機修；改完**重跑 `check-srs-bundle` + axis A–F 再審一輪**；終點 In Review，不自宣 Approved。
> **環境註**：所有「db-diff/refactor-spec/reverify 母夾-local、本 planning repo 搆不到」的 finding＝**雙 repo 環境性、非真缺陷**；修法統一＝SRS 加一句 disclaim「來源以母資料夾 baseline 為準、本 repo 不可複核、待母夾 reconcile」，不需補檔。

---

## 00114 — 0 Blocker（最乾淨，可優先收）
僅 🟡 Should-fix：
- **D-1** `openapi.yaml:291` SaveRequest 收 `reviewComment`（CR-only 欄）但 R10:140 protected-side guard 未明文擋「AO（001/002）送 reviewComment」→ R5/PENDING-009 補一條：AO save 不得寫 CR_COMMENT，BE 忽略或拒絕。
- **E-1** `schema.sql:156-157` `LOW_RANGE NUMBER(11,2)` vs `UP_RANGE NUMBER(12,2)` 精度不對稱無 provenance → 加 reverify 來源註，或對齊。
- **F-1** `openapi.yaml:336` `totalScore` type:string 無 pattern/scale → 補 `^-?\d{1,5}(\.\d{1,2})?$` 或註明 scale=2 對齊 NUMBER(7,2)。
- **C-1** `spec.md:129` R9「Rate no data」措辭易與 R4 的 500 RATE_FAIL 混 → 明指「Rate no-data＝缺前置 application/borrower（404），seed/range 缺＝RATE_FAIL（500）」。

## 00112 — 1 Blocker
- 🔴 **D** Bible 安全網 SC 未承載：`bible-eproposal.md:332/342`「API 權限＝REF_FUNCTION_ID+API_ID+ROLE、前後端對齊、未授權角色呼叫應 BE 拒」。SRS `R9:106`/`SEC-001:112` 只到 edit/query/old-case session 守門，**未承載 role×TB_API_AUTH 的 BE 負向拒絕、也未 disclaim** → 補一條 Rn（強制點 BE：未授權角色呼叫 info/save 一律 403）或明文 disclaim out-of-scope + 指承載位置。
- 🟡：KHR 明細 0 小數（`schema NUMBER(17,2)`+`openapi` pattern 容 2 位 vs `PRD 5.4:151`）；KHR rounding 政策（F-2）；`COMMON_MSG_ONE_DATA/LIMIT` 定位（FE 訊息 vs server error）；info 200 description 誤含 `COMMON_MSG_SAVE_SUCCESS`；`/calculate` 折進 info 的說明（R5）；`guarantorName`↔`BORROWER_NAME` mapping 註。

## 00110 — 3 Blocker
- 🔴 **A** `spec.md:209-211` Pending Register 空表，但 `R14:157`/`R15:165`/`R18:191` 寫「remain pending RD」→ DoD「每 TBD 一條 @PENDING」未滿足、自相矛盾 → 規格已定僅實作待 RD 者標 spec-frozen；仍有未定者補 @PENDING 列（id/owner/impact/status）。
- 🔴 **B** `EPROC00114` 在 `openapi.yaml` PageMap/SourceTabMap（不分 CS/CU、都列）vs `schema.sql:39-48` `TB_CHECK_POINTS_CU` 無此欄 → CS/CU 邊界 schema↔openapi 衝突（`R5:77` 定 CU 不含 0114）→ openapi PageMap/SourceTabMap description 明標「EPROC00114 僅 CS 案件、CU 不得含」。
- 🔴 **C** PRD module-error 路徑（`ReturnCode.ERROR_MODULE`+module message，`PRD 5.4:466`/`8.1:554`）漏承載，靜默併進 `MSG_QUERY_FAIL` → `R11:131` 補承載或明文 disclaim（frame 無 module 查詢→ERROR_MODULE 不適用）。
- 🟡：`switchGeneration`/`confirmationToken` 冗餘（openapi:221-225）；confirm 端點簽發 token 前 BE authz 明文（R7/R18）；NFR latency 量化（R1/R12）；`switchGeneration` 持久化載體/型別（int64↔DB）。

## 00117 — 1 Blocker（+1 環境）
- 🔴 **F** `openapi.yaml:145-171` SaveRequest/`FinancialInfo` **缺 DSR 核心金額欄**（EBIT、DEBT/EXISTING/ESTIMATE/OTHER payment、DSR），與 `schema.sql:44-60 TB_FINANCIAL_EVALUATION_INFO_CORP` + `PRD §5.2/§6.1/GOAL-002` 的 DSR 公式斷裂；`financialList` 落 INFO vs INFO_CORP 未釐清 → 補 INFO_CORP 欄位群進契約，或明示「本頁 save 只寫 INFO、INFO_CORP 由他途維護」並 reconcile。
- 🟡（環境，降級）**E** db-diff/refactor-spec/reverify 母夾-local 不可複核、SRS 未 disclaim → 加 disclaim。
- 🟡：status/code 分流（`MSG_QUERY_FAIL` 5xx vs 驗證 4xx 同 200 envelope，建議 code 前綴區分）；per-item currency enforcement（RP32 講 reject 非 USD item currency，但契約無 per-item currency 欄→規則空轉，對齊契約）。
- ✅ 健康：RP26-38 待決**未隨 qa-cases 遺失**（仍在 §@PENDING）；授權/audit/tamper guard 承載完整。

## 00116 — 多 Blocker（最重，建議最後收）
- 🔴 **C** `openapi.yaml:201` enum 含 `E130`，但 spec/R10/PRD 全無來源 → 補 Rn 說明語意+觸發 endpoint，或移除。
- 🔴 **C** `R10:152` 列 `MSG_OVER_COUNT_LIMIT`/`MSG_QUERY_FAIL`，但 `openapi.yaml:204-218` BusinessErrorEnvelope enum **漏這兩碼**（PRD 5.7:604-605 點名）→ 補 enum 或 R10 disclaim。
- 🔴 **D** pxls 授權矛盾：`spec.md:146/156/179/192` 宣稱「2026-06-24 recheck 發現 i0 source row 存在」並 supersede 舊註，但本 repo `c0-authz-sql-findings.md:192` 白紙黑字「i0 source 也缺」、新 recheck 證據**不落檔不可驗** → 把 recheck 落檔（或標「待母夾複核，現有 repo 證據相反」）；證據相反消解前不得當已解。
- 🟡：七 endpoint `TB_API_AUTH` 逐條列（尤其 calc 的 i0 source 缺）；金額精度策略（NUMBER(17,2) vs (19,2) 混用、DIFFERENCE 溢位）；金額 string 無 format/rounding；`DIFFERENCE=0`/`END_BALANCE==CASH_EQUIVALENT` 比較容差未定；`CCY_UNIT`↔`currencyUnit` mapping 註；`DATA_SEQ` INCOME 裸 NUMBER vs 其他 NUMBER(2,0)；IncomeRow 缺 canonical incomeDate 欄（openapi:536）；明細 Row `additionalProperties:true` vs Main `false` 不一致；E-axis provenance disclaim（環境）。
- ✅ 健康：service-level authz（R10）、R7 Finished balance gate BE 權威、typo 欄 mapping、highlight split、KHR FE-only 格式、export persisted-data 權威——皆正確承載。

---

## 收尾順序建議（黃仁勳「先收確定的」）
1. **00114**（0 Blocker，清 4 🟡 即可進 owner 審）
2. **00112**（1 Blocker：補 RBAC 承載/disclaim）
3. **00110**（3 Blocker：Pending Register、CS/CU 邊界、module-error）
4. **00117**（1 Blocker：DSR 金額欄契約——影響資料模型，較重）
5. **00116**（多 Blocker：E130、enum 漏碼、pxls 證據矛盾——最重）

每包修完：`python scripts/check-srs-bundle.py docs/specs/srs/<funcId>` exit 0 → axis A–F 跨模型再審一輪 → 無 Blocker 才交 owner 蓋 Approved。
