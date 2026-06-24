# SRS - <funcId> <Title>

<!--
  SRS spec.md 結構單一出處（canonical）。新 bundle 複製本檔起手。
  權威語意＝prd-to-srs SKILL.md §spec.md 結構；本檔＝可複製骨架 + lint 對照基準。
  結構檢查＝scripts/check-srs-bundle.py「structure」段（warn 級）；新包應 warn-clean。

  ── 一檔兩半（2026-06-24 可讀性演進）──
  上半 Contract＝「做什麼」：to-be only，實作者純掃這半即可開發。
  下半 Appendix＝「為什麼/出處/風險」：as-is、REF-Dn、provenance、決策 ID 全收這裡。
  契約 Rn 不內嵌佐證；用 [ev→Rn] 指到下半 Rule Evidence（1:1）。資訊不刪、只搬位。

  規則：① 段標題用英文、不編號（勿 `## 1.`）② 同概念用 canonical 唯一名（見下）
       ③ 強制點關鍵詞統一中文「強制點」④ 敘述中英混可接受
       ⑤ Contract 半的 Rn body 不放 as-is/current code/RPxx closes/@SHA/file:line（移附錄）。
  既有包標準定版前產出、漂移為已知（grandfathered），本範本只規範新包。
-->

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| funcId | <funcId> |
| Status | 規格定版: In Review（定版前；勿自宣 Approved）; 實作完成: not-started |
| Owner | <SA / domain / RD…> |
| PRD | `docs/specs/prd/PRD-...-<funcId>-v1.0.md` |
| Bundle | `docs/specs/srs/<funcId>/` |
| Source baseline | PRD + Bible + db-diff + refactor-spec + bounded source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | <選用：複審結果摘要> |

## Scope
- In scope: <本 SRS 規格化 PRD 的哪些 REQ/功能>。
- Out of scope（Non-Goals）: <非本期，防 scope creep>。

## Assumptions / Dependencies / Constraints
- <成立前提、依賴服務/團隊、tech stack/法規限制>。

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-<verb>-c0-<feature>` | POST | <用途> | R1, R2 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 Rule Evidence，用 `[ev→Rn]` 指過去。

### R1 <規則簡述> - 強制點: both
covers-prd: REQ-001

<EARS 行為敘述：普通「系統應…」/事件「當…時，系統應…」/狀態「在…期間…」/非預期「若…」>。
完整性/安全的驗證 BE 必須有且為權威（FE 同款＝UX，永不信前端）。 [ev→R1]

### R2 <規則簡述> - 強制點: BE
covers-prd: REQ-002

<to-be 契約敘述>。 [ev→R2]

## NFR
- <量化：perf p95<Xms / 可用性 / 安全 / 觀測 / 交易一致性>。

## Hard Boundaries
- 可先修（as-is ✅/⚠️、與 @PENDING 無關）：<列 Rn 範圍>。
- 待 TBD（涉 @PENDING）：<列 Rn 範圍 + 擋住的 TBD/PENDING id>。
- 摘要：<RD 可先動的邊界一句>。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | `...:line` | Carried by R1-Rn |
| Legacy | `...:line` | as-is baseline |
| Current | `...:line` | 現行實作 grounding |
| DB diff | `docs/db-diff/02_tables/TB_*.md` | schema 權威（規劃 repo 不可達時標「待母資料夾複核」） |

## Trade-offs
- <重大取捨；重大者另開 `docs/adr/ADR-NNNN-<funcId>.md`>。

## DB Reconcile / Delta
| Delta | 來源 | 影響 Rn | 三判 | 處理 |
|---|---|---|---|---|
| <新舊欄/型別差> | db-diff `...:line` / decisions 列 / parity `file:line` | Rn | (a)regression/(b)演進/(c)結構差 | carried(Rn) / @PENDING |

## @PENDING
| Id | TBD | Owner | Blocking? | Status |
|---|---|---|---|---|
| PENDING-<funcId>-<簡述> | 待關 TBD-xxx | <owner> | Yes/No | Open |

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy）、REF-Dn delta、provenance（`file:line`/`@SHA`）、決策 ID（RP/P）；鍵到 Rn，與上半 `[ev→Rn]` 1:1。verbose 者可改用 `#### Rn` 子段。
| Rn | as-is（現況/legacy；含疑似 bug） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | <legacy 行為 / current code 現況> | <REF-D1；RPxx/Pxx closes…> | `legacy:line` / `refactor-spec:line` `@<sha>` |
| R2 | <…> | <…> | `…` |
