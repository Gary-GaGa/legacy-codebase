# SRS - <funcId> <Title>

<!--
  SRS spec.md 結構單一出處（canonical）。新 bundle 複製本檔起手。
  權威語意＝prd-to-srs SKILL.md §spec.md 結構；本檔＝可複製骨架 + lint 對照基準。
  結構檢查＝scripts/check-srs-bundle.py「structure」段（warn 級）；新包應 warn-clean。
  規則：① 段標題用英文、不編號（勿 `## 1.`）② 同概念用 canonical 唯一名（見下）
       ③ 強制點關鍵詞統一中文「強制點」④ 敘述中英混可接受。
  既有 14 包在標準定版前產出、漂移為已知（grandfathered），本範本只規範新包。
-->

## Metadata
| Field | Value |
|---|---|
| funcId | <funcId> |
| Status | In Review / draft-for-review（定版前；勿自宣 Approved） |
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

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | `...:line` | Carried by R1-Rn |
| Legacy | `...:line` | as-is baseline |
| Current | `...:line` | 現行實作 grounding |
| DB diff | `docs/db-diff/02_tables/TB_*.md` | schema 權威 |

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-<verb>-c0-<feature>` | POST | <用途> | R1, R2 |

## Rules

### R1 <規則簡述> - 強制點: both
covers-prd: REQ-001

<EARS 行為敘述：普通「系統應…」/事件「當…時，系統應…」/狀態「在…期間…」/非預期「若…」>。
完整性/安全的驗證 BE 必須有且為權威（FE 同款＝UX，永不信前端）。

Evidence: <file:line>。

### R2 <規則簡述> - 強制點: BE
covers-prd: REQ-002

<...>。

## NFR
- <量化：perf p95<Xms / 可用性 / 安全 / 觀測 / 交易一致性>。

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

## Traceability Matrix
> QA 欄 2026-06-24 隨 QA 暫拔除＝dormant（不得視為已驗證）；REQ↔Rn 仍有效。
| PRD | Rn | QA |
|---|---|---|
| REQ-001 | R1 | （QA 暫拔除） |

## Hard Boundaries
- as-is/to-be 摘要：給 RD「可先修 vs 待 TBD」的硬界線。
