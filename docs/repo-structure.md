# Repo 結構 × AI Flow 對照

> 本 repo＝**規劃/規格/backlog（無原始碼）**。下面把每個檔/資料夾對到「**在 AI flow 的哪一段、做什麼**」。
> flow 圖＝[`assets/ai-workflow.mmd`](assets/ai-workflow.mmd)；方法論＝[`spec-architecture.md`](spec-architecture.md)；逐頁狀態權威＝[`feature-inventory.md`](feature-inventory.md)。
> ⚠️ **PRD 與 RD code 的產物在 repo 外**（PRD＝外部 `CDC-EPRO-*`；產品碼＝另兩個專案，Codex 在母資料夾開發）——本 repo 只放「規格 + 任務單 + 慣例 + 閘門」。

## 0. 先抓三大類
| 類 | 是什麼 | 代表 |
|---|---|---|
| **A 治理/憲法**（always-on，跨所有 flow） | 規則、權限、雙軌對照 | `CLAUDE.md`、`AGENTS.md`、`backend/`+`frontend/AGENTS.md`、`.github/` |
| **B AI flow 工具與產物** | 各階段的 skill/agent/閘門 + 產出的 bundle/任務單 | `.claude/`、`docs/env/codex/`、`scripts/`、`golden-template/`、`build-tasks/` |
| **C 規劃 / 狀態 SSOT**（橫向參考） | 盤點、對應、決策、驗證交接 | `feature-inventory.md` ⭐、`pending-register.md`、`decisions.md`、`legacy/`、`verification/` … |

## 1. 對到 AI flow 各段（核心對照）

| flow 階段 | 角色做什麼 | 工具（Claude ∥ Codex） | 產物 / 檔案 | 閘門 |
|---|---|---|---|---|
| **Legacy → Bible**（反推·知識萃取） | EPRO Expert 反推舊系統 | **`.claude/skills/legacy-to-bible/`** ∥ `docs/env/codex/prompts/legacy-to-bible.md` | 產 `specs/bible/bible-<domain>.md`；原料＝[`legacy/`](legacy/)（module-*/page-mapping/migration-backlog/db-schema-catalog）、`decisions.md §D1` | — |
| **PRD**（what/why） | PM/PO 寫需求 | `/product-brainstorming`、`/write-spec`（官方 plugin，雙軌同） | **PRD 在 repo 外**（如 `CDC-EPRO-0001`）；流程見 `CLAUDE.md §3` | — |
| **SRS**（how） | SA 轉系統規格 | **`.claude/skills/prd-to-srs/SKILL.md`** ∥ `docs/env/codex/prompts/prd-to-srs.md` | **`specs/srs/<funcId>/`**：`spec.md`(Rn)・`openapi.yaml`・`schema.sql`；方法論 `spec-architecture.md`；重大取捨 `adr/ADR-*.md` | ①②③ |
| **as-is 驗證**（brownfield loop） | 驗 migrated 碼 vs 舊系統/PRD | 唯讀 audit 任務單 | `build-tasks/<funcId>-verification-findings.md`（如 `00800-verification-findings.md`）、`build-tasks/*-investigation.md` | — |
| **QA cases** | QA 轉可跑驗收 | （隨 SRS） | `specs/srs/<funcId>/qa-cases.md`（每條 `covers: Rn`） | ④⑤ |
| **RD-Agent**（開發+測試） | Codex 照任務單實作 | Codex（母資料夾） | **產品碼在 repo 外**；in-repo＝**任務單** `build-tasks/*.md`（live）、`build-tasks/done/`（歷史 22 份） | ⑥ |
| **DoD 閘門牆** | RD 過 SA/QA 邊界 | — | SRS 機械 pre-gate `scripts/check-srs-bundle.py`（涵蓋見腳本檔頭；與 DoD ①–⑦ 編號對照見 `specs/srs/README.md`）；**③** `scripts/verify-c0.py`；**⑦語意** `.claude/agents/spec-reviewer.md` ∥ `docs/env/codex/spec-reviewer.toml`+`reviewer-c0.toml`；**自動觸發** `.claude/settings.json`(Stop hook) ∥ `docs/env/codex/hooks.json` | ①–⑦ |
| **裁定 / escalation** | 判斷題交人 | — | SRS 的 `@PENDING`；`decisions.md`；`pending-register.md`；`disbursement/disbursement-domain-escalations.md` | — |
| **Done → 回歸** | 回填狀態 + bug→回歸 case | — | `feature-inventory.md` 回填；bug → 新 `qa-cases.md` case | — |

## 2. 雙軌對照（同一角色、三個載具）
| 角色 | Claude Code | Codex CLI（範本→部署 `.codex/`） | GitHub Copilot |
|---|---|---|---|
| 憲法 | `CLAUDE.md` | `AGENTS.md` §Spec workflow | `.github/copilot-instructions.md` |
| PRD→SRS | `.claude/skills/prd-to-srs/` | `docs/env/codex/prompts/prd-to-srs.md` | — |
| spec 審查（唯讀） | `.claude/agents/spec-reviewer.md` | `docs/env/codex/spec-reviewer.toml` | — |
| c0 鏡像審查 | （用 spec-reviewer/語意） | `docs/env/codex/reviewer-c0.toml` | — |
| 權限/安全 | `.claude/settings.json` | `docs/env/codex/config-permissions.md` | — |
| 形式硬閘門 hook | `.claude/settings.json`(hooks) | `docs/env/codex/hooks.json` | — |
| 機械閘門腳本（共用） | `scripts/check-srs-bundle.py`、`scripts/verify-c0.py` | 同（hooks 掛同腳本） | 同 |
| 分層開發規則 | — | `backend/AGENTS.md`、`frontend/AGENTS.md` | `.github/instructions/{backend,frontend}.instructions.md` |
> **鏡像＝薄殼指標**（2026-06-11）：Codex 範本只含指標＋差異清單，**內容權威＝Claude 版**；詳 `CLAUDE.md §2`。

## 3. 治理 / 憲法層（always-on）
- `CLAUDE.md` — Claude 側 spec-workflow constitution（§1 flow、§2 雙軌、§3 生命週期、§4 DoD）。
- `AGENTS.md`（root）— 共用開發規則 + Spec workflow（Codex 側憲法）。
- `backend/AGENTS.md` — 後端鐵則（§6 c0 自足鏡像、§6.1 例外、registry/版本鎖定）。
- `frontend/AGENTS.md` — 前端鐵則（config-driven、cub-* 元件、§5 Adobe XD 設計規格）。
- `.github/copilot-instructions.md` + `instructions/{backend,frontend}.instructions.md` — Copilot 版（`applyTo` 依資料夾自動套用）。

## 4. 規劃 / 狀態 SSOT（橫向參考）
| 檔 | 角色 |
|---|---|
| **`feature-inventory.md`** | ⭐ **逐頁狀態權威**（舊→新對應、FE/BE、剩餘事項①–⑨、排程 Phase 0/F/V/D/E/R） |
| **`pending-register.md`** | ⭐ **待決總表**（所有 open @PENDING/escalation/OQ + owner + 卡什麼；🔴 擋主線者標出） |
| `legacy/page-mapping.md` | 舊 funcId → 新頁對應 + 30% backlog |
| `legacy/migration-backlog.md` | 模組地圖 M1–M9 + 橫向風險 R1–R8 |
| `legacy/module-{is-iu,cs-cu}-shell.md`、`legacy/module-i0-c0-scoring.md` | 舊系統 shell / 評分結構分析 |
| `legacy/db-schema-catalog.md` | DB schema 目錄（JIT 抽） |
| `process/completion-ledger.md` | 🗄 已凍結（2026-06-11；內容併入 feature-inventory） |
| `decisions.md` | 決策與事實流水帳（失敗教訓的原始紀錄；收斂表見 `spec-architecture.md §9`） |
| `process/vision-pipeline.md` | flow 願景與原則 |

## 5. 子域 / 階段專屬（已分資料夾，2026-06-10）
- **[`disbursement/`](disbursement/)**：`disbursement-triage.md`（0921/0922/T24 triage）、`disbursement-domain-escalations.md`（待 domain/T24/DBA 裁決）；A-1＝`build-tasks/a1-funcGetExchangeRate-spec.md` + `phase-d-a1-exchange-stub-investigation.md`。
- **[`verification/`](verification/)**（Phase V）：`verification-handoff.md`（殘留驗證項清單）、`verification-execution.md`（怎麼分階段跑）。
- **[`process/`](process/)**：`SETUP-codex.md`（dev-box 設定+疑難排解）、`runbook-30pct.md`（Codex 自走順序/煞車）、`vision-pipeline.md`、`completion-ledger.md`。
- **環境 / 設定**：`docs/env/`（`backend.gitignore`/`frontend.gitignore`/`frontend.yarnrc`/`maven-settings.xml` + `codex/`）。
- **樣板**：`golden-template/README.md`（FE 黃金樣板 + JSP→元件對照）；SRS bundle 範本說明＝`specs/srs/README.md`（原 boundary-bundle，2026-06-09 移）。
- **規格 pipeline 家**：`specs/`（`bible/` → `prd/` → `srs/`，分層即 flow；見 `specs/README.md`）。
- **ADR**：`adr/ADR-0001-spec-workflow-dual-stack.md` + `README.md` + `_TEMPLATE.md`。

## 6. `build-tasks/` 生命週期（任務單怎麼流動）
- **live**（還要用）：`00800-verification-findings.md`（SRS as-is 來源）、`00800-rimat-fix.md`（step 2 修復包）、`a1-funcGetExchangeRate-spec.md`、`phase-d-a1-exchange-stub-investigation.md`。
- **`done/`**（22 份歷史）：完成的 build prompt（Phase F 逐頁、00800 修正、c0 cleanup、⑨ sweep×3、staff 調查鏈、早期 B-*/EPROC/EPROISU…）。
- 規則（`README.md` 末）：**任務完成/消化 → `git mv` 到 `done/`，狀態回填 `feature-inventory.md`**。

---
> 導覽入口＝[`docs/README.md`](README.md)（分類索引）。本檔回答「**哪個檔在哪段 flow**」；README 回答「**想找某類文件去哪**」；`feature-inventory.md` 回答「**還剩多少事**」。
