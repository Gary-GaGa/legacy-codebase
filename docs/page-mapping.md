# 舊→新 頁面對應 & 補完清單（控制中心）

> 重構專案（前後端兩個獨立專案）已完成 **~70%**；目標 = 補完剩餘 **30%**。
> ⚠️ 原始碼**不外流、不上 GitHub**：本 repo 只放**對應/規格/backlog**；實作在前/後端專案內（Copilot 或本機 Claude Code），以本檔規格 + 既有 70% 模式為準。

## 0. 合併規律（新頁如何由舊頁合併）
- **有擔(S) + 無擔(U) → 單一新頁(SU)**：`EPROCS_*`+`EPROCU_*`→`EPROCSU*`；`EPROIS_*`+`EPROIU_*`→`EPROISU*`。
- **新案/增貸 + 展期/展變 → 同一新頁**：`_01x0`(申請) + `_02x0`(展期/覆核) 合成一頁，以**案件類型**當 mode。
- 新頁名 = 舊 funcId 去底線（`EPROC0_0110`→`EPROC00110`）；主流程 CS+CU→CSU、IS+IU→ISU。
- → 完全對應我們的 shell 設計：**案件類型(新案增貸/展期展變) × 有擔/無擔** 即 PageDescriptor 的 mode/secure 軸（`module-is-iu-shell.md`、`module-cs-cu-shell.md`）。

## 1. 新頁 catalog（= 補完目標；狀態待對兩專案後回填）

### 1A. 個金主流程 `EPROISU*`（IS+IU 合併）
| 新頁 | 合併舊 funcId | 名稱 |
|---|---|---|
| EPROISU0110 | IS/IU_0110 + _0210 | Main Borrower Info |
| EPROISU0120 | IS/IU_0120 + _0220 | Co-Borrower Info |
| EPROISU0130 | IS/IU_0130 + _0230 | Guarantor Info |
| EPROISU0140 | **IS_0190 + 0290** | Collateral Provider Info（佔用舊 0140 槽）|
| EPROISU0150 | IS_0150 + 0250 | Collateral（僅有擔）|
| EPROISU0160 | IS/IU_0160 + _0260 | Loan Condition |
| EPROISU0170 | IS/IU_0170 + _0270 | Credit Evaluation and Credit Decision |
| EPROISU0171 | IS/IU_0171 | Loan Committee Conclusion |
| EPROISU0172 | IS/IU_0172 | Approved Loan Condition |
| EPROISU0173 | IS/IU_0173 | Credit Evaluation Old |
| EPROISU0181 | IS/IU_0181 | TLOD Report（R2 報表）|
| EPROISU0910 | IS_0910 | Contract Preparation（頁框）|
| EPROISU0911 | IS_0911 | Condition Confirmation |
| EPROISU0912 | IS_0912 | Contract Production |
| EPROISU0913 | IS_0913 | Closed Info |
| EPROISU0920 | IS_0920 | Disbursement Process（頁框）|
| EPROISU0921 | IS_0921 | Data Input |
| EPROISU0922 | IS_0922 | Summary |

### 1B. 企金主流程 `EPROCSU*`（CS+CU 合併）
| 新頁 | 合併舊 funcId | 名稱 |
|---|---|---|
| EPROCSU0110 | CS/CU_0110 + _0210 | Main Borrower Info |
| EPROCSU0120 | CS/CU_0120 + _0220 | Co-Borrower Info |
| EPROCSU0130 | CS/CU_0130 + _0230 | Guarantor Info |
| EPROCSU0150 | CS_0150 + 0250 | Collateral（僅有擔）|
| EPROCSU0160 | CS/CU_0160 + _0260 | Loan Condition |
| EPROCSU0170 | CS/CU_0170 + _0270 | Credit Evaluation and Credit Decision |
| EPROCSU0171 | CS/CU_0171 | Loan Committee Conclusion |
| EPROCSU0172 | CS/CU_0172 | Approved Loan Condition |
| EPROCSU0173 | CS/CU_0173 | Credit Evaluation Old |
| （CAD）| CS/CU_0181 | TLOD(CAD) Report → 對映 **EPROISU0181**（與個金共用報表頁）|

### 1C. 個金評分 `EPROI00*`（i0，新案+展期合併）
`EPROI00110`(Credit Investigation 頁框)、`00111` Financial Evaluation Table、`00112` CBC、`00113` Individual Scorecard、`00114` Collateral Assessment、`00115` Borrower Group Exposure、`00116` Financial Statement GI、`00117` Financial Evaluation GI、`00118` Corporate Scorecard、`00119` Financial Statement FI、`00120` Financial Evaluation FI。

### 1D. 企金評分 `EPROC00*`（c0）
`EPROC00110`(頁框)、`00112` CBC、`00114` Collateral Assessment、`00115` BGE、`00116` FinStmt GI、`00117` FinEval GI、`00118` Corporate Scorecard、`00119` FinStmt FI、`00120` FinEval FI。
- ⚠️ `EPROC0_0211`、`EPROC0_0213`：**「流程中無對應頁籤」** → 待確認（c0 無個人 scorecard/FinEval Table，與 i0 差異）。

### 1E. 共用 `EPROZ00*`
`00100` TO DO LIST、`00200` New Case Application、`00300` Document Checklist、`00400` Case Distribution、`00410` Related Party Information、`00500` Comparison table…CUBC、`00600` Search、`00610` Credit Reviewer On Hand Status、`00620` Application Delete Report(R2)、`00630` Deviation Case Report(R2)、`00640` Scorecard Report(R2)、`00650` Application Cancel Report(R2)、`00660` CAD On Hand Status、**`00700` Assign Substitute（= 我們的 Phase 1）**、`00800` Revised Item。
> 前端狀態：**未做** = `00610`/`00620`/`00630`/`00640`/`00650`/`00660`/`00700`；其餘完成（`00800` 完成）。

### 1F. 特例（不開發）
- **對應重構頁空白**（已合併上去）或標 **「已無使用」** → **不開發**。
- 已無使用（drop）：`EPROCS_0240`、`EPROIS_0140`（Property Info）。
- 待確認：`EPROC0_0211`、`EPROC0_0213`（流程中無對應頁籤）。
- 共用 API：`EPROZZ_0100`（查詢地址欄位選單）。
- `EPROISU0181` 同時是企金 CAD 報表的對映頁（個/企共用）。

## 2. 剩餘 30% 補完 backlog（✅ 前後端 cross-check 已對齊）
> 對齊兩份後，真正缺口 = **前端 8 項 + 後端 7 項**（多為「一邊有殼/API、另一邊缺」）。

### 2A. 前端要補（後端多已就緒）
| 新頁 | 名稱 | FE | BE | 補法（打既有 endpoint）|
|---|---|---|---|---|
| `EPROZ00700` | Assign Substitute | 未做 | ✅ `DeputyController` | 做前端 → `epl-case-deputy-options/-query-deputy/-insert-deputy/-delete-deputy`（任務單已更新）|
| `EPROZ00610` | Credit Reviewer On Hand Status | 未做 | ✅ | → `epl-case-credit-reviewer-onhandstatus-query-list`（任務單 `build-tasks/B-z0-reports-status-frontend.md`）|
| `EPROZ00660` | CAD On Hand Status | 未做 | ✅ | → `epl-case-CAD-onhandstatus-query-list` |
| `EPROZ00620` | Application Delete Report | 未做 | ✅ | → `epl-case-application-delete-report-btn-search/-query-list` |
| `EPROZ00630` | Deviation Case Report | 未做 | ✅（含 download）| → `epl-list-deviation`/`-file-download-deviation`/`-sele-dept-loantype-deviation` |
| `EPROZ00640` | Scorecard Report | 未做 | ✅（含 pdf/excel export）| → `epl-case-mis-report-scorecard-query-list`/`-export-pdf`/`-export-excel` |
| `EPROZ00650` | Application Cancel Report | 未做 | ✅ | → `epl-sele-dept-loantype-canreason`/`epl-list-cancelreport` |
| `EPROCSU0130` | Corporate Guarantor Info | 半成品 | ✅ `CsuGuarantorController` | 清前端 TODO（照個金 `EPROISU0130`）|

### 2B. 後端要補（前端多已就緒）
| 新頁 | 名稱 | FE | BE | 補法（鏡像既有）|
|---|---|---|---|---|
| `EPROISU0920` | Disbursement Process | ✅ | **未做** | 建後端 API（只有授權 page-map，無 controller）|
| `EPROC00115` | c0 Borrower Group Exposure | ✅ | 半成品 | 鏡像 i0 `BorrowerGroupExposureController` |
| `EPROC00116` | c0 Financial Statement GI | ✅ | 半成品 | 鏡像 i0 `FinancialStatementController`（含 ppdf/pxls）|
| `EPROC00117` | c0 Financial Evaluation GI | ✅ | 半成品 | 鏡像 i0 `FinancialStaffController` |
| `EPROC00118` | c0 Corporate Scorecard | ✅ | 半成品 | 鏡像 i0 `CorporateScorecardController` |
| `EPROC00119` | c0 Financial Statement FI | ✅ | 半成品 | 鏡像 i0 `FinancialStatementCmtsFiController` |
| `EPROC00120` | c0 Financial Evaluation FI | ✅ | 半成品 | 鏡像 i0 `FinancialEvaluationTableController` |
> c0 半成品已有 service/checkpoint（`TBCheckPointsCs/Cu`）痕跡，只缺對外 controller/endpoint。

### 2C. API 慣例（重要，所有任務遵循）
- 後端 endpoint = **RPC 式 `epl-{verb}-{scope}-{feature}`**（verb：`sele`/`info`/`save`/`case`/`quer`/`calc`/`comm`/`resu`/`list`/`ppdf`(印PDF)/`pxls`(匯Excel)/`file`…），**非 REST 資源路徑**。
- 前端一律打**既有同名 endpoint**；新後端頁**鏡像既有 i0/isu 控制器**的命名與結構。
- ⚠️ `phase1-eproz0_0700-spec.md` 的 `/api/emp-proxy` REST 為理想化版，**實際以 `DeputyController` 的 `epl-*` 為準**。

### 2D. 參考來源原則（每張任務遵循）
| 來源 | 何時用 |
|---|---|
| **既有已完成頁（同專案）** | **主要 pattern**：前端鏡像既有 z0/isu 頁、後端鏡像 i0 controller。Codex 直接看得到。|
| **新後端 `epl-*` DTO** | 前端對接必需。⚠️ FE/BE 為兩專案、Codex 一次只看一個 → **先在後端抓 DTO，再餵前端 Codex**。|
| **新 DB schema** | 後端建 entity（JIT 抽，`db-schema-catalog.md`）。|
| **舊系統 JSP** | **多數不用**（新系統已合併/改過，恐誤導）；僅「**無新範本可鏡像**」的頁（如 `EPROISU0920` 撥貸）需追舊鏈路，其餘僅作業務語意次要參考、**勿當 spec**。|

### 觀察
- 30% 缺口集中在：① **6 個企金評分頁**缺後端 controller（鏡像 i0 即可）② **撥貸 0920** 缺後端 ③ **7 個 z0/共用前端頁**（後端已就緒）。
- 報表 00620–00650 後端**已含 export** → 前端做查詢+觸發既有 export 即可，**R2 對這幾頁影響小**。

## 3. 下一步：對照兩專案找出未完成（cross-check）
在**前端專案**與**後端專案**各跑一次（prompt 見對話），用 §1 新頁代碼逐一確認「已實作/半成品/未做 + 對應 component/route 或 controller/endpoint」→ 回填本檔狀態欄、彙整 §2 backlog。

### 已知關聯（前面盤點可直接餵入）
- 新頁內部結構（頁籤/區塊/狀態）：主流程見 `module-is-iu-shell.md`/`module-cs-cu-shell.md`；評分見 `module-i0-c0-scoring.md`。
- 權限：每頁 funcId → `TB_FUNCTION_AUTH`/`TB_API_AUTH`（R7，`db-schema-catalog.md` §4）。
- schema：JIT 抽（`db-schema-catalog.md`）。
