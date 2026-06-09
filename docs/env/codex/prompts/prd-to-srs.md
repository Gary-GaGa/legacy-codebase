# Codex custom prompt — prd-to-srs（= Claude skill .claude/skills/prd-to-srs 的 Codex 版）
# 放置：本機 ~/.codex/prompts/prd-to-srs.md 或專案 .codex/prompts/prd-to-srs.md → 互動介面打 /prd-to-srs <PRD 或 funcId>
# ⚠️ 確切 prompt 變數語法（$ARGUMENTS / $1）以官方為準：developers.openai.com/codex/prompts

把 PRD（what）轉成 **SRS bundle（how）**，產物餵 QA + DoD 閘門 ①②③④⑤。對象＝ `$ARGUMENTS`（PRD 路徑或 funcId）。
位置見 `docs/assets/ai-workflow.mmd`；worked example＝ `docs/golden-template/boundary-bundle/EPROZ00800/`。

## 輸入
PRD（主來源）＋ Bible（若有）＋ 既有碼/verification findings（頁已存在→ as-is/to-be）＋ 慣例 `backend/AGENTS.md` §6、真實 API＝RPC `epl-{verb}-{scope}-{feature}`。

## 輸出（bundle → `docs/golden-template/boundary-bundle/<funcId>/`）
- `spec.md`（SRS 主檔）→ 閘門③｜`openapi.yaml`（真實 epl-* 契約）→ ①｜`schema.sql`（表/欄/約束）→ ②｜`qa-cases.md`（`covers: Rn`）→ ④⑤

## `spec.md` 必含
Metadata（Status/Owner/Slug=funcId/版本/最後更新/上游PRD/as-is來源）→ Scope+Non-Goals → Assumptions/Dependencies/Constraints → Endpoints(epl-*) → 業務規則 `Rn`(每條 `covers-prd:` + as-is/to-be) → NFR(量化) → Trade-offs(連 ADR) → `@PENDING`(每 TBD + owner) → Traceability Matrix(PRD REQ→Rn→QA) → 硬界線 + as-is→to-be 摘要。

## 鐵則
1 rule-id 粒度：一規則一 `Rn`。
2 雙向追溯：`Rn` 標 `covers-prd:`（上游 PRD REQ）；QA 標 `covers: Rn`（下游）。
3 TBD → `@PENDING` + owner，**不自行裁定**；不把 legacy 行為當已核准需求。
4 PRD 的 `/api/...` REST 多為理想化 → 寫**真實 `epl-*`**；mutate=POST。
5 頁已存在 → 標 as-is（引現碼/findings `file:line`）vs to-be。
6 不臆造；未證標「待 RD 核對」。

## Brownfield 鐵則（70% 既有碼專屬 — 教訓回填，見 `docs/spec-architecture.md §9`）
- 動手前先唯讀盤點：① 該頁實際完成度（防「未做其實已完成」）② mirror/算法正確來源（防假設錯，如換匯 stub≠`funcGetRate`）。
- as-is 驗證 ≠ 看有沒有 controller/service：**結構在≠行為對等**；對舊系統/PRD 行為比，分 **regression vs 刻意演進**（舊系統≠絕對正確），引 `file:line`。
- **PRD 內帶的 legacy 也要 reconcile**：PRD 可能寫進現行 key 名/method/欄寬 → 不可原樣搬進 `openapi`/`schema`，標 to-be 或 `@PENDING`（B1 教訓）。
- Oracle native query：未加引號 alias → JDBC label 大寫（M7 `LOANAMOUNT` 靜默 null），schema/DTO/Rn 對映注意大小寫。

## DoD（Status:Approved 前）
Non-Goals 有 / 每 REQ≥1 Rn / 每 Rn 有 acceptance+≥1 QA covers / happy+error+edge / 每 TBD 一條 @PENDING+owner+blocking / Traceability 完整 / endpoints 真實 epl-* / 頁已存在則 as-is/to-be 清楚 / 模糊詞量化 / **已過 spec-reviewer.toml 無 Blocker**。

完成後回填 `feature-inventory.md` 該頁 + 列未關 TBD 給 PM/SA。
