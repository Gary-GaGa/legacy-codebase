# 30% 補完 — 驗證交付清單（Verification Handoff）

> **程式/build 結構性全到位（2026-06-05）**：c0 評分 `00115–00120` ✅、前端 ✅（含 `CSU0130`）、撥貸後端 `0920/0921/0922` 既有 ✅。
> 本檔彙整**所有殘留「驗證」項**，交 **dev/uat 整合測試 + 各 domain owner**。**非 build 阻擋項**——build 階段不擋，集中於有真資料/真授權時跑。
> 來源：`page-mapping.md` §2B、`decisions.md`、`build-tasks/EPROC00118-*`、boundary bundle `EPROC00118/`。

## 0. 原則
- 程式已到位 → 本階段只驗**正確性 / 授權 / 呈現**，**不再 build、不重寫、不臆測**。
- 驗證 oracle 優先用新系統等價物（`c0`對`i0`、`csu`對`isu`）；無等價物者（撥貸）回對**舊系統 / domain owner**。
- **怎麼跑**（分階段、context-bounded、可重複、含舊系統「抽取→比對」兩步）見 [`verification-execution.md`](verification-execution.md)；每項驗完在本檔對應列標 **☐→✅/⚠️** 並 commit（context window 拋棄式、進度存 doc）。

---

## 1. 🔴 c0 評分 — 2 條 escalation（owner：`CsuCreditEval*` / 信用決策 domain）
> 皆為**既有 `CsuCreditEvalAndCreditDecisionServiceImpl` 行為**、§6.1 禁改 → 非 00118 本體缺陷，須 owner 裁示。

| # | 項目 | 證據 | 怎麼確認 |
|---|---|---|---|
| **E1** | CU-return checkpoint 只清 `TB_CHECK_POINTS_CS`、無 CU 分流 | `CsuCreditEvalAndCreditDecisionServiceImpl:2985` | 確認 CU（無擔企金）是否真走到 `00118` checkpoint；**會**→授權加 CU 分流（破 §6.1 需核可）；**不會**→非 bug、結案 |
| **E2** | `crScoreCardCompleted` 整欄被覆寫成 `"NN"`（與「00114=第1碼/00118=第2碼」雙位元契約並存）| `CsuCreditEvalAndCreditDecisionServiceImpl:2890` | 確認 intended（決策重置）vs latent bug；與 `00118` save 的時序（覆寫前/後）、Y/N 語意是否影響 submit gate 期望值 |

## 2. 🟠 撥貸 `0920` — domain 正確性（owner：撥貸 domain + 整合測試）
> 舊 `EPROIS_0920` source 不在 workspace、無 i0/twin oracle → 既有 `0921 DataInputServiceImpl`/`0922 SummaryServiceImpl` 為實作基準，**正確性須 domain + 整合驗證**（§6.6：不臆測、不重寫）。

| # | 項目 | 證據（既有 service） | 怎麼確認 |
|---|---|---|---|
| **D1** | 撥貸狀態機 `CASE_PROGRESS` 24/25/26/98 + `TB_APP_HISTORY` process code | `DataInputServiceImpl` / `SummaryServiceImpl` | dev/uat 跑完整撥貸流程，對每個狀態轉移與歷程碼 |
| **D2** | T24 授權檔組檔 `funcIsuT24Authorize`（16 張表來源）| `SummaryServiceImpl:876` | domain 驗檔格式 / 欄位來源 / 金額正確 |
| **D3** | SFTP 上傳 + `TB_MESS_UPLOAD_SFTP_RECORD` | `SummaryServiceImpl:2265` | uat 驗上傳成功與記錄 |
| **D4** | mail 通知（submit / return / auth）| `SummaryServiceImpl` / `DataInputServiceImpl` | 驗收件對象與內容 |
| **D5** | checkpoint 走 `CASE_PROGRESS` + `TB_DISBUR_DATE.EPORIS_0921`、**非** `TB_CHECK_POINTS_IS/IU` | 盤點 | 確認此為撥貸流程**正常設計**（非缺漏）|
| **D6** | cleanup：`/epl-case-submit-isu-summary` stub（FE 未用）| `SummaryController:43` | 確認移除或補實作（FE 用的是 `epl-case-isu-summary-submit`）|
| **D7** | `TB_DISBUR_*` 三表未在 `db-schema-catalog` authority 首段 | 盤點 | 以既有 entity/repo 為準，或回補 catalog |
| **D8** | **schema-map 風險**（DB2→Oracle/整併；Step A2 2026-06-05）| `legacy-extract/disbursement-schema-map.md`（本機）| 🔴 **T24 組檔欄位來源**：舊有欄新無（如 `BRANCH_PROFILE.T24_COMPANY`）→ 新 `funcIsuT24Authorize` 漏欄/改源/併欄？🟠 **金額精度**：舊 VO 無 DB2 length/precision（UNKNOWN）→ 需舊 DDL/DBA，非 VO 可定；查新碼有無 `round/truncate/setScale` 🟡 `NOTIFICATION_INFO` `NO`→`No`（同欄 vs quoted-id）🟡 `LON_SUMMARY_INFO` 新增 `PROJECT_CODE`（是否需填）|

## 3. 🟡 授權列（owner：DB / ops）— 新 c0 endpoint 的 `TB_API_AUTH` / `TB_ROLE_TASK`
> `00117` 為既有模組（授權列應已有）；其餘新建 c0 頁的新 `epl-*-c0-*` endpoint 需建授權列。

| 頁 | endpoints |
|---|---|
| `00115` | `epl-{info/save/sele}-c0-borrower-group-exposure` |
| `00116` | `epl-{sele/quer/info/calc/save/ppdf/pxls}-c0-financial-statement-comments` |
| `00118` | `epl-{sele/info/calc/save}-c0-corporateScorecard(-list)` |
| `00119` | `epl-{quer/info/calc/save/ppdf/pxls}-c0-financial-statement-cmts-fi` |
| `00120` | `epl-{info/save}-c0-financial-evaluation-table-fi`、`epl-save-c0-financial-evaluation-staff-fi` |

## 4. 🟡 export 模板 / 報表呈現（owner：整合測試）
- `00116`/`00119`（及 `00118` 若有）export 模板**沿用 i0**（`EPROI00116`/`EPROI00119`）→ 確認可接受 or 需 c0 專屬路徑。
- 報表 `00620–00650` 呈現；⚠️ **`00640` scorecard export**：FE POST blob vs BE GET `@RequestBody` **介面不一致 → 優先對**。
- `EPROZ00610` Credit Reviewer On Hand：CR 呈現 / 資料。

## 5. 契約對齊（整合測試；多已 code review）
- 各 `c0`/`csu` 頁 **FE 送/收欄位 ↔ BE `epl-*` DTO**：以真資料 / 真授權跑一次（`00115` CS/CU 判斷已 code review 確認正確）。

---
> 驗完逐項打勾，回填本檔 + `page-mapping.md` §2B。整合驗證為**獨立後續階段**（`runbook-30pct.md` §5），不影響「程式補完」里程碑。
