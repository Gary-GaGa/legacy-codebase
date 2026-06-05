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

## 完成判準
照 `runbook-30pct.md` §2 gate：`verify-c0` PASS + build 綠 + 對 i0 自檢 + 回填 `page-mapping.md`。
