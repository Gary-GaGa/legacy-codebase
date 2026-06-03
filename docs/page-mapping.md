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

### 1F. 特例
- **已無使用（drop，不做）**：`EPROCS_0240`、`EPROIS_0140`（Property Info）。
- **待確認**：`EPROC0_0211`、`EPROC0_0213`（流程中無對應頁籤）。
- **共用 API**：`EPROZZ_0100`（查詢地址欄位選單）→ 共用 API。
- `EPROISU0181` 同時是企金 CAD 報表的對映頁（個/企共用）。

## 2. 剩餘 30% 補完 backlog（待「對兩專案」後產出）
> 以 §3 cross-check 結果，挑出「未做/半成品」新頁，排優先序（共用件先、報表 R2 / CBC R8 另track）。

## 3. 下一步：對照兩專案找出未完成（cross-check）
在**前端專案**與**後端專案**各跑一次（prompt 見對話），用 §1 新頁代碼逐一確認「已實作/半成品/未做 + 對應 component/route 或 controller/endpoint」→ 回填本檔狀態欄、彙整 §2 backlog。

### 已知關聯（前面盤點可直接餵入）
- 新頁內部結構（頁籤/區塊/狀態）：主流程見 `module-is-iu-shell.md`/`module-cs-cu-shell.md`；評分見 `module-i0-c0-scoring.md`。
- 權限：每頁 funcId → `TB_FUNCTION_AUTH`/`TB_API_AUTH`（R7，`db-schema-catalog.md` §4）。
- schema：JIT 抽（`db-schema-catalog.md`）。
