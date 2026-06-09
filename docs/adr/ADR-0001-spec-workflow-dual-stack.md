# ADR-0001：spec 工作流＝雙軌（Claude+Codex）+ 機器可驗證 SRS bundle

| 欄位 | 內容 |
|---|---|
| Status | **Accepted** |
| 日期 | 2026-06-09 |
| Slug | spec-workflow |
| 相關 | `CLAUDE.md`、`AGENTS.md` §Spec workflow、`docs/assets/ai-workflow.mmd`、`.claude/skills/prd-to-srs`、`docs/golden-template/boundary-bundle/EPROZ00800/` |

## Context
- AI workflow（Bible→PRD→SRS→QA→RD）需要把「SA+AI→SRS」這步固化、可重複、跨人一致。
- 團隊開發載具是 **Codex CLI**，但也用 **Claude Code** 做規劃/審查 → 工具雙軌。
- 參考通用 `path-a-scaffold`（plugins + 模板 + read-only 審查 agent + constitution）；但我們是 **brownfield**（有舊系統 + 真 codebase），需要比通用範本更強的可驗證性。

## Decision
1. **SRS＝機器可驗證 boundary bundle**（`spec.md` rule-id `Rn` + `openapi.yaml` + `schema.sql` + `qa-cases.md` `covers:Rn`），餵 DoD 6 道 deterministic 閘門；**保留 brownfield 殺手鐧 `as-is/to-be` + PRD `TBD→@PENDING`**。
2. **雙軌工具對等**：每個 spec 工具都有 Claude 版與 Codex 版（constitution、prd-to-srs、spec-reviewer、權限），內容等價、原生格式各異，**改一版同步另一版**。對照表見 `CLAUDE.md` §2。
3. **吸收通用範本的好東西**：read-only `spec-reviewer`、狀態 metadata + DoD checklist、SRS 富化區段（NFR/Non-Goals/Assumptions/Trade-offs/Traceability Matrix）、least-privilege 權限、ADR 逐則。
4. **funcId＝追溯 slug**（取代通用 slug），串 Bible→PRD→SRS→QA→code。

## Consequences
- ＋ SRS 既可機器驗證（gate ①–⑥）又有完整敘事（NFR/trade-off/追溯）；審查 read-only、不污染。
- ＋ Claude/Codex 任一載具都能跑同一流程。
- －維護成本：雙軌需同步（已在 constitution 標「改一版同步另一版」）。
- 後續：上游 Bible→PRD 評估用官方 knowledge-work plugins；ADR 逐則取代 `decisions.md` 之「決策」部分（log 部分保留）。

## Alternatives considered
- **純通用 path-a-scaffold**：可攜但無機器閘門/as-is-to-be，brownfield 不夠 → 只吸收其好部分。
- **單軌（只 Codex 或只 Claude）**：與團隊實況不符（兩個都用）。
- **spec-kit（uv 依賴）**：更重、外部依賴 → 暫不導入（path-A 可無痛共存，日後需要再評估）。
