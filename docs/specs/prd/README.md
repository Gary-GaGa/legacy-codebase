# `specs/prd/` — 產品需求（PRD）

> flow 第 ② 層：PM/PO + AI 寫 **what / why**（REQ-nnn、業務規則、TBD）。
> ⚠️ **權威版在 repo 外**（公司文管，如 `CDC-EPRO-0001`）；**此處放「工作快照」**——讓 `/prd-to-srs`、`spec-reviewer`、追溯檢查在 repo 內讀得到。

## 放置規則
- 命名：`PRD-<docId>-v<版>-<funcId>.md`（例：`PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md`）。
- 快照頭部標：**來源文號、版本、快照日期、Status（Draft/Approved）、未關 TBD 清單**。
- **版本以外部為準**：外部改版 → 重新快照 + SRS 重跑 `covers-prd` 對齊；不要在快照上直接編需求。
- secrets/個資不得入快照（同 repo 安全規則）。

## 已知 PRD（快照狀態）
| docId | 版本 | funcId | 快照 | 備註 |
|---|---|---|---|---|
| `CDC-EPRO-0001` | v1.1（PM Review Draft） | `EPROZ00800` | ✅ [快照](PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md) | TBD-001~007 未關；SRS 已產（`../srs/EPROZ00800/`）。⚠️ 由 code 反推，未承載 Bible 的案件類型 gating/0173 映射等業務邊界（見 `../../pending-register.md` §Bible→PRD seam）|

## 下游
PRD → `/prd-to-srs`（Claude skill ∥ Codex prompt）→ `../srs/<funcId>/` boundary bundle。
每個 PRD `REQ` ≥1 條 SRS `Rn`（`covers-prd:`）；每個 `TBD` 一條 `@PENDING` + owner。
