---
name: prd-to-srs
description: Convert a PRD (產品需求, "what") into an SRS bundle (系統開發規格, "how") for this eProposal refactor. Use when the user has a PRD (e.g. CDC-EPRO-*, or a page's PRD) and wants the SA-level SRS — endpoints, rule-ids, OpenAPI, DB schema, QA cases — i.e. the "SA + AI → SRS" step of the AI workflow (docs/assets/ai-workflow.mmd). Triggers: "PRD 轉 SRS", "產 SRS", "把 PRD 變規格", "SRS bundle for <funcId>".
---

# PRD → SRS（SA + AI 步驟）

把 PRD（what）轉成 **SRS bundle（how）**，產物餵 QA + DoD 閘門 ①②③④⑤。位置見 `docs/assets/ai-workflow.mmd`。
範本＝worked example `docs/golden-template/boundary-bundle/EPROZ00800/`（PRD 來源）。

## 輸入
1. **PRD**（主來源；如 `CDC-EPRO-0001` 00800）。
2. **Bible**（若有，取北極星/黃金旅程當上游追溯）。
3. **既有碼**（若該頁已實作 → 做 as-is vs to-be；用該頁的 verification findings）。
4. **慣例**：`backend/AGENTS.md` §6、`page-mapping.md`（真實 API 慣例＝RPC `epl-{verb}-{scope}-{feature}`）。

## 輸出（bundle，放 `docs/golden-template/boundary-bundle/<funcId>/`）
| 檔 | 內容 | 餵閘門 |
|---|---|---|
| `spec.md` | SRS 主檔：endpoints + 業務規則 `Rn` + @PENDING + 硬界線 + as-is/to-be | ③ |
| `openapi.yaml` | 真實 `epl-*` endpoint 的 request/response schema | ① |
| `schema.sql` | 涉及 DB 表/欄位 DDL（型別/長度/PK/nullable） | ② |
| `qa-cases.md` | 可跑驗收，每條 `covers: Rn`（含 @PENDING） | ④⑤ |

## `spec.md` 結構（必含 — 吸收自通用 SRS 範本）
1. **Metadata header**（表格）：`Status`（Draft / In Review / **Approved**；可標 `Draft (blocked on RP1/TBD-xxx)`）、`Owner`、`Slug`（＝funcId）、`版本`、`最後更新`、`上游 PRD`、`as-is 來源`。
2. **概述 / Scope + Non-Goals**：本 SRS 規格化哪個 PRD 的哪些 REQ；**本期 / 非本期**（防 scope creep）。
3. **Assumptions / Dependencies / Constraints**：成立前提、依賴服務/團隊、tech stack/法規限制。
4. **Endpoints**：真實 `epl-*`（method / as-is / DTO）。
5. **業務規則 `Rn`**：每條 `covers-prd:` + 狀態（as-is ✅/⚠️/🔴 + to-be）。
6. **NFR**：量化（perf/可用性/安全/觀測/交易一致性）。
7. **Trade-offs**（重大取捨）→ 連 `docs/adr/ADR-NNNN-<funcId>.md`。
8. **@PENDING**（每個 TBD 一條 + owner）。
9. **Traceability Matrix**：`PRD REQ → Rn → QA`（一張表，gate⑤ 顯性化）。
10. **硬界線** + **as-is→to-be 摘要**（給 RD：可先修 vs 待 TBD）。

## SRS 撰寫鐵則
1. **rule-id 粒度**：一條業務規則 = 一個 `Rn`；複雜規則拆細。
2. **雙向追溯**：每個 `Rn` 標 **`covers-prd:`**（上游對到 PRD 的 REQ-id / 章節）；QA case 標 `covers: Rn`（下游）。funcId 串 Bible→PRD→SRS→QA→code。
3. **TBD → `@PENDING`**：PRD 未關的 TBD **不可自行裁定**；寫成 `R?-PENDING` 規則 + **owner** + 「待關 TBD-xxx」。**不把 legacy 行為當已核准需求**（守 PRD §13）。
4. **理想化 REST → 真實 RPC**：PRD §6 的 `/api/...` 多為理想化（同 phase1 `/api/emp-proxy`）→ SRS endpoints 寫**實際 `epl-*`**；method 以 PRD 語意定（mutate=POST）。
5. **as-is vs to-be**（頁已存在時）：SRS 標 to-be（PRD 要的），並列 as-is（現碼實況，引 verification findings + `file:line`），差異即 RD 待補。
6. **不臆造**：`file:line`/欄位若未證 → 標「待 RD 核對」。
7. **NFR/錯誤碼/DB 矩陣**：PRD 的非功能/錯誤碼/DB mapping → 落進 `Rn` + openapi/schema。

## 步驟
1. 讀 PRD，抽：endpoints、REQ 清單、規則、DB 表、錯誤碼、NFR、TBD、測試案例。
2. （頁已存在）讀現碼/findings → 標 as-is。
3. 產 `spec.md`：endpoints 表（epl-*）→ `Rn`（每條 `covers-prd:` + 證據/狀態）→ `@PENDING`（每 TBD）→ 硬界線 → as-is/to-be。
4. 產 `qa-cases.md`：把 PRD 測試案例（Given/When/Then）轉成 case，每條 `covers: Rn`；TBD 相關標 `@PENDING`。
5. 產 `openapi.yaml` + `schema.sql`（從 PRD §6/§7；未定處標 RD-TBD）。
6. 回填：bundle 連到 `feature-inventory.md` 該頁 + 列出仍未關的 TBD（給 PM/SA）。

## DoD（`Status: Approved` 前必過）
- [ ] 有明確 **Non-Goals / Scope**（防 scope creep）。
- [ ] 每個 PRD `REQ` 都有 ≥1 個 `Rn` 對上（或明確標非本期）。
- [ ] 每條 `Rn` 有可獨立驗證的 **acceptance**（Given/When/Then 或 checklist），且 ≥1 個 QA case `covers`。
- [ ] 涵蓋 **happy / error / edge**。
- [ ] 每個 PRD `TBD` 都有一條 `@PENDING` + **owner + 是否 blocking**。
- [ ] **Traceability Matrix** 完整（PRD REQ → Rn → QA），funcId 串到底。
- [ ] endpoints 是真實 `epl-*`、method 符 PRD 語意（mutate=POST）；`openapi.yaml`/`schema.sql` 與 `Rn` 一致。
- [ ] 頁已存在 → **as-is/to-be** 差異清楚。
- [ ] 模糊詞已量化（NFR 可量測）。
- [ ] **已用 `spec-reviewer`（Claude subagent / Codex `spec-reviewer.toml`）審過、無未解 Blocker**。

> 上游 Bible→PRD 可用官方 knowledge-work plugins（`/product-brainstorming`、`/write-spec`）；SRS 這步用本 skill（領域專屬）。
