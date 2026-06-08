# Build Task — `EPROC00118` c0 Corporate Scorecard（後端）

> 載具：Codex（後端專案/母資料夾）。**硬規則見 `backend/AGENTS.md` §6**；自走順序見 `docs/runbook-30pct.md`。
> ✅ **calc 已定案**（2026-06-05，見下方「人審結論」）：calc 注入 `FunctionService`、不分叉；shell/DTO/checkpoint 自足；CU-return＝已知 escalation（不阻擋本 build）。下方「煞車」仍適用於任何**新出現**的算法分歧。

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

## 🔄 跑這頁前：同步到產品後端專案（你本機 = Codex 執行處）
本 repo 是來源；Codex 跑 00118 前，確認下列**最新版**已在後端專案資料夾（否則跑到舊規則、核准的 `FunctionService` 注入會被舊 gate 擋）：
- `scripts/verify-c0.py`（含 `FunctionService` allowlist + 「0 修改既有檔」檢查）
- `backend/AGENTS.md`（§6.1 例外、§6.5 DoD）
-（若用語意閘門）`docs/archive/review-c0-prompt.md`、`.codex/agents/reviewer-c0.toml`

## 📐 驗收邊界（boundary bundle）
本頁可驗證邊界範本見 [`../golden-template/boundary-bundle/EPROC00118/`](../../golden-template/boundary-bundle/EPROC00118/)：
- `spec.md`（規則 R1–R8）/ `openapi.yaml`（契約·閘門1·TODO 對 i0 DTO 填實）/ `schema.sql`（閘門2）/ `qa-cases.md`（QA1–QA10，含 R8 `@PENDING` = CU-return）。
- 落地方式見該資料夾 `README.md` + `docs/vision-pipeline.md`。

## 完成判準
照 `runbook-30pct.md` §2 gate：`verify-c0` PASS + build 綠 + 對 i0 自檢 + 回填 `page-mapping.md`。對齊「驗收邊界」：openapi 欄位填實、QA1–QA9 可跑綠、R8/R9 留 `@PENDING`。

## ✅ 完成（2026-06-05）
- 閘門 a `verify-c0 --git` **PASS**（含 0-修改既有檔 + UTF-8）；閘門 c `mvn ... -Dmaven.test.skip=true` **綠**。
- 閘門 b 獨立語意審查 **9 PASS / 1 FAIL**；FAIL 在 item 5，經人審判定**不阻擋**：00118 自身鏡像 i0 正確（只動第2碼），FAIL 點是**既有** `CsuCreditEvalAndCreditDecisionServiceImpl:2890` 整欄覆寫 `"NN"` → 既有碼、§6.1 不改 → **升級為 escalation 2**（見 `page-mapping.md §2B` / spec R9-PENDING）。
- 產物：`CsuCorporateScorecardController`/`Service(Impl)`/DTO/enum/assembler，純新增 12 檔、0 改既有。
- **遺留**（待 CreditEval owner + 整合驗證）：escalation 1 CU-return checkpoint、escalation 2 crScoreCardCompleted 整欄覆寫、新 endpoint `TB_API_AUTH`/`TB_ROLE_TASK` 授權列。
