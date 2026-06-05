# Build Task — `EPROC00118` c0 Corporate Scorecard（後端）

> 載具：Codex（後端專案/母資料夾）。**硬規則見 `backend/AGENTS.md` §6**；自走順序見 `docs/runbook-30pct.md`。
> ⚠️ **半自走**：外殼可自走，**算法不准分叉**——見下方煞車。

## 鏡像來源
- i0 `CorporateScorecardController` + `CorporateScorecardServiceImpl`。
- endpoints（i0 → c0 改 `-c0-`）：
  - `epl-sele-i0-corporateScorecard-list` → `epl-sele-c0-corporateScorecard-list`
  - `epl-info-i0-corporateScorecard` → `epl-info-c0-corporateScorecard`
  - `epl-calc-i0-corporateScorecard` → `epl-calc-c0-corporateScorecard`
  - `epl-save-i0-corporateScorecard` → `epl-save-c0-corporateScorecard`
- request DTO：`SeleCorporateScorecardListRequest` / `GetCorporateScorecardInfoRequest` / `CalCorporateScoreCardRequest` / `SaveCorporateScorecardRequest`。
- response DTO：`SeleCorporateScorecardListResponse` / `GetCorporateScorecardInfoResponse` / `CalCorporateScoreCardResponse`。
- entity/repo（重用，不新建）：`TBCorpScrcardEntity`/`TBCorpScrcardRepository`（`findCorpScrcard`）、`TBScoreCardParamDetailRepository`（`findScoreParamsByApplicationDate` / `findRiskLevelByTotalScore`）。
- checkpoint：`TBCheckPointsCs/Cu` = `EPROC00118`，CS/CU 用 `lonAttribute+secureAttribute`，值規則照 i0。

## ⚠️ 煞車（§6.6，最重要）
- c0 的 scorecard 資料/部分計分邏輯**已散在 `CsuCreditEvalAndCreditDecisionServiceImpl`**（會讀寫 `TBCorpScrcardEntity`、更新 `EPROC00118`），`CsuCreditEvaluationOldServiceImpl` 也讀 `findCorpScrcard`。
- **嚴禁**：① 在新 service 另寫一套計分算法（會與既有 `CsuCreditEval*` 分叉）② 改既有 `CsuCreditEval*` 行為。
- 若 `calc` 的計分邏輯**無法 1:1 從 i0 `CorporateScorecardServiceImpl` 複製**、或與既有 `CsuCreditEval*` 衝突 → **停下、產報告、等人審**。先做得出來的部分（sele/info/save 外殼 + DTO），把 `calc` 算法的疑點單獨列出。

## ✅ 人審結論（2026-06-05，Codex recon 後定案）
- **calc 真相**：算法**不在**既有 `CsuCreditEval*`（那些只做讀/submit gate/return 清欄位）。唯一算法在 i0 `FunctionServiceImpl.funcGetRate(...)`（22 欄位 lookup-and-sum → `COR_RISK_LV` 查 riskLevel）；i0 `CorporateScoreCardServiceImpl.calc` 自己也只是薄殼呼叫它。
- **決策 1（calc 引擎）= 注入 `FunctionService`**：c0 calc 直接注入 `individual.FunctionService` 呼叫 `funcGetRate`（§6.1 已核准之唯一例外，循 00114 precedent，避免分叉算法）。**勿**把 funcGetRate 複製/重寫。shell/DTO/checkpoint/save 框架仍全自足鏡像 i0。
- **決策 2（CU return 衝突）= 另案上報、不阻擋本次 build**：既有 `CsuCreditEvalAndCreditDecisionServiceImpl` Return(98) 硬編碼只清 `TB_CHECK_POINTS_CS`、無 CU 分流；§6.1 禁改既有 `Csu*`。→ 先以 Codex 唯讀確認 CU 案件是否真會走到 `00118` checkpoint，列入 `page-mapping.md` §2B escalation，**不在本頁修既有 service**。
- **可直接做**：sele/info/save 外殼 + 4 corporate DTO（+ RiskLevelMap nested）、重用 `TBCorpScrcardEntity`/`TBScoreCardParamDetailRepository`、CS/CU + `EPROC00118` checkpoint（`isFinish?"N":"Y"`）。
- **自動處理項**：`crScoreCardCompleted` 兩碼契約（00114=第1碼 / 00118=第2碼）→ Codex 唯讀確認後照 i0 `substring(1,2)` 寫法；`loanDefDayFlag=Y → Default/-1 score` → 照 i0 1:1 複製、不裁剪。

## 完成判準
照 `runbook-30pct.md` §2 gate：`verify-c0` PASS + build 綠 + 對 i0 自檢 + 回填 `page-mapping.md`。
