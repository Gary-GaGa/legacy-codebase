# SRS — EPROC00118 c0 Corporate Scorecard（SA 規格層）

> 鏡像來源 i0 `CorporateScorecardController` + `CorporateScoreCardServiceImpl`。完整任務見
> [`../../../build-tasks/done/EPROC00118-corporate-scorecard.md`](../../../build-tasks/done/EPROC00118-corporate-scorecard.md)、硬規則 `backend/AGENTS.md` §6。
> **每條規則一個 `Rn`**；QA case 用 `covers: Rn` 對表（覆蓋率＝DoD 閘門 5）。
> ⚠️ `file:line` 為 Codex recon 結果（產品碼在開發機，不在本 repo）→ 實作時對既有 i0 再核對。

## Endpoints（4）
| verb | endpoint | DTO |
|---|---|---|
| sele | `epl-sele-c0-corporateScorecard-list` | `SeleCorporateScorecardListRequest/Response` |
| info | `epl-info-c0-corporateScorecard` | `GetCorporateScorecardInfoRequest/Response` |
| calc | `epl-calc-c0-corporateScorecard` | `CalCorporateScoreCardRequest/Response` |
| save | `epl-save-c0-corporateScorecard` | `SaveCorporateScorecardRequest`（回 `EPROResponse<Void>`）|

## 業務規則（rule-id）

### R1 — calc 算法 = i0 `FunctionService.funcGetRate`（**不准分叉**）
- calc 注入 `individual.FunctionService` 呼叫 `funcGetRate(...)`（§6.1 **唯一核准例外**，循 00114 precedent；複製/重寫 = 分叉、違反 §6.6）。
- funcGetRate 內容：取 `applicationDate` → **5 個數值欄位** range lookup（`B_V18` curRatio、`B_V10` deRatio、`B_V14` totalAsset、`B_V1` totalLoanAmt、`B_V21` debtRati）+ **17 個代碼欄位** varName+varCode lookup（`B_V4/V5/V20/V19/V9/V6/V7/V8/V2/V3/V22/V15/V16/V17/V11/V12/V13`）→ 22 分相加成 `totalScore` → 用 `COR_RISK_LV` 對 totalScore 找 `riskLevel`。
- i0 證據：`FunctionServiceImpl.java:3504/3548/3573`、`CorporateScoreCardServiceImpl.java:152`。
- calc 回 `riskLevel` + `scoreDatetime`。

### R2 — save 寫回 `TB_CORP_SCRCARD`（AO/CR map，Default 特例）
- save 對 `TBCorpScrcardEntity` 的欄位寫回，含 i0 的 Default 特例處理。i0：`CorporateScoreCardServiceImpl.java:214/607`。

### R3 — checkpoint = `TB_CHECK_POINTS_CS/CU`，欄位 `EPROC00118`
- **CS/CU 判斷用 `lonAttribute + secureAttribute`**（同 `CsuCreditInvestigationServiceImpl`/`CsuMainBorrowerInfoServiceImpl`），**不可**用 i0 的 `secureAttribute=="S"` 單條件。
- 值規則：`isFinish==true → "N"`、`false → "Y"`；寫法用既有 `DynamicUpdateSqlUtils`。

### R4 — `crScoreCardCompleted` 兩碼契約（00118 = 第 2 碼）
- save 在既有值上改**第 2 碼**：`substring(1,2)` 再組 `Y/N + oldSecondChar`（00114 管第 1 碼，互補）。i0：`CorporateScoreCardServiceImpl.java:271`。
- ⚠️ 跨 service 共享狀態。**gate-b 已查（2026-06-05）**：00118 本身正確（只動第 2 碼、保留第 1 碼）；但「無第三者寫第 2 碼」**不成立**——既有 `CsuCreditEvalAndCreditDecisionServiceImpl:2890` 會整欄覆寫 `"NN"`。屬既有碼、§6.1 不改 → 見 R9-PENDING。

### R5 — `loanDefDayFlag == "Y"` → Default / -1 score（**照 i0 1:1，不裁剪**）
- `loanDefDayFlag=Y` 時走 Default、score = -1，**仍呼叫 funcGetRate**。業務規則，照 i0 原樣複製。

### R6 — sele 下拉清單裝配
- sele 用 `CorporateScoreCardEnum` + `CorporateScorecardAssembler` 邏輯（複製進 c0，不 import i0）；或 `TBScoreCardParamDetailRepository.findScoreParamsByApplicationDate(...)`。i0：`CorporateScoreCardServiceImpl.java:61`。

### R7 — info 回填 AO/CR map
- info 讀 `TBCorpScrcardEntity` 回填 AO/CR map。i0：`CorporateScoreCardServiceImpl.java:351`。

## 🚩 escalation（未決，寫成 `@PENDING` QA case）
### R8-PENDING — CU return checkpoint 衝突
- 既有 `CsuCreditEvalAndCreditDecisionServiceImpl` Return(98) **硬編碼只清 `TB_CHECK_POINTS_CS`、無 CU 分流**（`:2985`）；§6.1 禁改既有 `Csu*`。
- → CU（無擔企金）案件 return 會留下錯的 checkpoint。**本頁不修**；先唯讀確認 CU 是否真走到 `00118`，列 `page-mapping.md` §2B escalation。

### R9-PENDING — crScoreCardCompleted 整欄被既有 CreditEval 覆寫（gate-b 2026-06-05 發現）
- 既有 `CsuCreditEvalAndCreditDecisionServiceImpl:2890` 把 `crScoreCardCompleted` **整欄寫成 `"NN"`**（非只動一碼），與「00114=第1碼 / 00118=第2碼」雙位元契約並存。
- 屬企金信用決策生命週期之**既有行為**（非 00118 引入；corporate-flow 特有）；§6.1 禁改既有 `Csu*` → **本頁不修**，00118 自身鏡像 i0 已驗正確。
- **待 CreditEval owner 確認**：整欄 "NN" 覆寫是 intended（決策步驟重置）還是 latent bug；整合驗證時確認與 00118 save 的時序（覆寫前/後、是否影響 submit gate 期望值，含 Y/N 語意）。

## 硬界線
- 不得修改既有 i0 / `Csu*`（含 Return(98)）；只新增。
- 除 `FunctionService` 外不得 import 任何 `*.individual.*`。
