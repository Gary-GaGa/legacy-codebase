# Repo 結構 × AI Flow 對照

> 本 repo＝**規劃/規格/backlog（無原始碼）**。下面把每個檔/資料夾對到「**在 AI flow 的哪一段、做什麼**」。
> flow 圖＝[`assets/ai-workflow.mmd`](assets/ai-workflow.mmd)；方法論＝[`spec-architecture.md`](spec-architecture.md)；逐頁狀態權威＝[`feature-inventory.md`](feature-inventory.md)。
> ⚠️ **PRD 與 RD code 的產物在 repo 外**（PRD＝外部 `CDC-EPRO-*`；產品碼＝另兩個專案，Codex 在母資料夾開發）——本 repo 只放「規格 + 任務單 + 慣例 + 閘門」。

## 0. 先抓三大類
| 類 | 是什麼 | 代表 |
|---|---|---|
| **A 治理/憲法**（always-on，跨所有 flow） | 規則、權限、雙軌對照 | `CLAUDE.md`、`AGENTS.md`、`backend/`+`frontend/AGENTS.md` |
| **B AI flow 工具與產物** | 各階段的 skill/agent/閘門 + 產出的 bundle/任務單 | `.claude/`、`docs/env/codex/`、`scripts/`、`golden-template/`、`build-tasks/` |
| **C 規劃 / 狀態 SSOT**（橫向參考） | 盤點、對應、決策、驗證交接 | `feature-inventory.md` ⭐、`pending-register.md`、`decisions.md`、`legacy/`、`verification/` … |

## 1. 對到 AI flow 各段（核心對照）

| flow 階段 | 角色做什麼 | 工具（Claude ∥ Codex） | 產物 / 檔案 | 閘門 |
|---|---|---|---|---|
| **Legacy → Bible**（反推·知識萃取） | EPRO Expert 反推舊系統 | **`.claude/skills/legacy-to-bible/`** ∥ `docs/env/codex/prompts/legacy-to-bible.md` | 產 `specs/bible/bible-<domain>.md`；原料＝[`legacy/`](legacy/)（module-*/page-mapping/migration-backlog/db-schema-catalog）、`decisions.md §D1` | — |
| **PRD**（what/why） | PM/PO 寫需求 | `/product-brainstorming`、`/write-spec`（官方 plugin，雙軌同） | **PRD 在 repo 外**（如 `CDC-EPRO-0001`）；流程見 `CLAUDE.md §3` | — |
| **SRS**（how） | SA 轉系統規格 | **`.claude/skills/prd-to-srs/SKILL.md`** ∥ `docs/env/codex/prompts/prd-to-srs.md` | **`specs/srs/<funcId>/`**：`spec.md`(Rn)・`openapi.yaml`・`schema.sql`；方法論 `spec-architecture.md`；重大取捨 `adr/ADR-*.md` | ①②⑤（+字母 Ⓑ/Ⓟ/Ⓢ/Ⓔ/Ⓡ；③④⑥ code 階段，見 `specs/srs/README.md §閘門編號對照`）|
| **as-is 驗證**（brownfield loop） | 驗 migrated 碼 vs 舊系統/PRD | 唯讀 audit 任務單 | `build-tasks/<funcId>-verification-findings.md`（如 `00800-verification-findings.md`）、`build-tasks/*-investigation.md` | — |
| **QA cases** | QA 轉可跑驗收 | （隨 SRS） | `specs/srs/<funcId>/qa-cases.md`（每條 `covers: Rn`） | ④⑤ |
| **RD-Agent**（開發+測試） | Codex 照任務單實作 | Codex（母資料夾） | **產品碼在 repo 外**；in-repo＝**任務單** `build-tasks/*.md`（live）、`build-tasks/done/`（歷史 22 份） | ⑥ |
| **DoD 閘門牆** | RD 過 SA/QA 邊界 | — | SRS 機械 pre-gate `scripts/check-srs-bundle.py`（涵蓋見腳本檔頭；與 DoD ①–⑦ 編號對照見 `specs/srs/README.md`）；**③** `scripts/verify-c0.py`；**⑦語意** `.claude/agents/spec-reviewer.md` ∥ `docs/env/codex/spec-reviewer.toml`+`reviewer-c0.toml`；**自動觸發** `.claude/settings.json`(Stop hook) ∥ `docs/env/codex/hooks.json` | ①–⑦ |
| **裁定 / escalation** | 判斷題交人 | — | SRS 的 `@PENDING`；`decisions.md`；`pending-register.md`；`disbursement/disbursement-domain-escalations.md` | — |
| **Done → 回歸** | 回填狀態 + bug→回歸 case | — | `feature-inventory.md` 回填；bug → 新 `qa-cases.md` case | — |
| **盤點 / 校正**（drift loop，非主線一站）| zero-based 重推總量、對 SSOT 做 diff（只報不改）| **`.claude/skills/refactor-audit/`** ∥ `docs/env/codex/prompts/refactor-audit.md` | `build-tasks/refactor-audit/`（diff-vs-inventory + QC 日誌）；回填 `feature-inventory.md` §1「audit 驗證」欄 | — |

## 2. 雙軌對照（同一角色、兩個載具）
> 〔GitHub Copilot 第三軌 2026-06-16 移除（`.github/` 刪）→ 回歸 Claude↔Codex 雙軌；見 `decisions.md`。〕

| 角色 | Claude Code | Codex CLI（範本→部署 `.codex/`） |
|---|---|---|
| 憲法 | `CLAUDE.md` | `AGENTS.md` §Spec workflow |
| PRD→SRS | `.claude/skills/prd-to-srs/` | `docs/env/codex/prompts/prd-to-srs.md` |
| Legacy→Bible | `.claude/skills/legacy-to-bible/` | `docs/env/codex/prompts/legacy-to-bible.md` |
| 進度盤點（zero-based） | `.claude/skills/refactor-audit/` | `docs/env/codex/prompts/refactor-audit.md` |
| spec 審查（唯讀） | `.claude/agents/spec-reviewer.md` | `docs/env/codex/spec-reviewer.toml` |
| c0 鏡像審查 | （用 spec-reviewer/語意） | `docs/env/codex/reviewer-c0.toml` |
| 權限/安全 | `.claude/settings.json` | `docs/env/codex/config-permissions.md` |
| 形式硬閘門 hook | `.claude/settings.json`(hooks) | `docs/env/codex/hooks.json` |
| 機械閘門腳本（共用） | `scripts/check-srs-bundle.py`、`scripts/verify-c0.py` | 同（hooks 掛同腳本） |
| 分層開發規則 | — | `backend/AGENTS.md`、`frontend/AGENTS.md` |
> **鏡像＝薄殼指標**（2026-06-11）：Codex 範本只含指標＋差異清單，**內容權威＝Claude 版**；詳 `CLAUDE.md §2`。

## 3. 治理 / 憲法層（always-on）
- `CLAUDE.md` — Claude 側 spec-workflow constitution（§1 flow、§2 雙軌、§3 生命週期、§4 DoD）。
- `AGENTS.md`（root）— 共用開發規則 + Spec workflow（Codex 側憲法）。
- `backend/AGENTS.md` — 後端鐵則（§6 c0 自足鏡像、§6.1 例外、registry/版本鎖定）。
- `frontend/AGENTS.md` — 前端鐵則（config-driven、cub-* 元件、§5 Adobe XD 設計規格）。

## 4. 規劃 / 狀態 SSOT（橫向參考）
| 檔 | 角色 |
|---|---|
| **`feature-inventory.md`** | ⭐ **逐頁狀態權威**（舊→新對應、FE/BE、剩餘事項①–⑨、排程 Phase 0/F/V/D/E/R） |
| **`pending-register.md`** | ⭐ **待決總表**（所有 open @PENDING/escalation/OQ + owner + 卡什麼；🔴 擋主線者標出） |
| `legacy/page-mapping.md` | 舊 funcId → 新頁對應 + 30% backlog |
| `legacy/migration-backlog.md` | 模組地圖 M1–M9 + 橫向風險 R1–R8 |
| `legacy/module-{is-iu,cs-cu}-shell.md`、`legacy/module-i0-c0-scoring.md` | 舊系統 shell / 評分結構分析 |
| `legacy/db-schema-catalog.md` | DB schema 目錄（JIT 抽） |
| `archive/completion-ledger.md` | 🗄 已凍結（2026-06-11；內容併入 feature-inventory） |
| `decisions.md` | 決策與事實流水帳（失敗教訓的原始紀錄；收斂表見 `spec-architecture.md §9`） |
| `process/vision-pipeline.md` | flow 願景與原則 |
| `process/orchestration-playbook.md` | Codex 多任務編排方法論（A/B/C 三類、依賴 DAG、完成定義、三軸驗證；orchestrator 停在等人審）|

## 5. 子域 / 階段專屬（已分資料夾，2026-06-10）
- **[`disbursement/`](disbursement/)**：`disbursement-triage.md`（0921/0922/T24 triage）、`disbursement-domain-escalations.md`（待 domain/T24/DBA 裁決）；A-1 ✅ 已實作＋conformance PASS（`daae4c3`）→ 規格/recon 收 `build-tasks/done/`（`a1-funcGetExchangeRate-spec.md` 等）。
- **[`verification/`](verification/)**（Phase V）：`verification-handoff.md`（殘留驗證項清單）、`verification-execution.md`（怎麼分階段跑）。
- **[`process/`](process/)**：`SETUP-codex.md`（dev-box 設定+疑難排解）、`vision-pipeline.md`。
- **[`archive/`](archive/)**（已消化、留存備查）：`review-c0-prompt.md`、`phase1-eproz0_0700-spec.md`、`completion-ledger.md`（2026-06-11 凍結）。〔`runbook-30pct.md` 已刪 2026-06-16：內容被 `build-tasks/`+`STATUS.md` 取代、引用失效〕
- **環境 / 設定**：`docs/env/`（`backend.gitignore`/`frontend.gitignore`/`frontend.yarnrc`/`maven-settings.xml` + `codex/`）。
- **樣板**：`golden-template/README.md`（FE 黃金樣板 + JSP→元件對照）；SRS bundle 範本說明＝`specs/srs/README.md`（原 boundary-bundle，2026-06-09 移）。
- **規格 pipeline 家**：`specs/`（`bible/` → `prd/` → `srs/`，分層即 flow；見 `specs/README.md`）。
- **ADR**：`adr/ADR-0001-spec-workflow-dual-stack.md` + `README.md` + `_TEMPLATE.md`。

## 6. `build-tasks/` 生命週期（任務單怎麼流動）

> **收納判準（2026-06-16 立規則）＝一條機械測試**：對 card / findings / recon 這類「工作痕跡」檔——
> **「這份檔的*結論*是否已回填進某個 SSOT（`pending-register` / `decisions` / `spec.md` / `disbursement-triage` / `feature-inventory`）？」**
> - **是 → 已消化**：`git mv` 到 `done/`（card 與它消化掉的 findings 一起進）。`done/` ＝歸檔非刪除，**open 項照樣可引用 `done/` 的證據**（引用改指 `done/` 路徑即可，不破連結）。
> - **否 → 還活著**：留在 active `build-tasks/`。
>
> 判準演進：~~有無引用~~ → ~~引用死活~~ → ~~資料復驗~~ → **結論是否已進 SSOT**。**「被引用」不再是「該留」的理由**（證據被引很正常）；**「結論已進 SSOT」才是「可收」的理由**。⚠️ 例外：一份 findings 若**被某個 open 項當『來源』長期依賴**（如 as-is 來源、open AUD 的證據），即使其本身 card 已 done 仍**留 live**（如 `00800-verification-findings`＝RP8/RP11 as-is 來源、`legacy-schema-db-reverify-findings`＝open AUD-7 證據）。

- **active（依「結論未進 SSOT／仍為 open 項長期來源」留 live；2026-06-18 重盤＝19 份；上次校 2026-06-16＝11 份漏記後續增量）**：
  1. **open 工單／進行中 sweep**：`get-body-contract-sweep.md`+`-findings.md`（#3 待修）、`local-phase-v-bringup.md`、`phase-v-api-selfverify-harness.md`+`phase-v-harness-manifest-v1.md`（Phase V 自驗 harness v1）、`c0-legacy-parity-recheck.md`（企金線 18 頁 parity reopen）。
  2. **ops artifact**：`c0-authz-sql-findings.md`（授權列對照——**SQL 已套+DBA 驗 `OVSLXLON02` 2026-06-25**〔pxls==ppdf〕；service-guard 層仍 code-stage）。
  3. **長青參考／SSOT**：`schema-diff-findings.md`（schema SSOT，AUD-7/8 還開）、`full-refactor-audit.md`+`refactor-audit/`（audit 工作集，待 AUD 收口）、`refactor-audit-qc.md`（QC 日誌）。
  4. **進行中里程碑 evidence／open 項長期來源（card 雖 done 仍留 live）**：`00800-verification-findings.md`（RP8/RP11 as-is 來源）、`legacy-schema-db-reverify-findings.md`（open AUD-7 證據）、`00800-spec-review-findings.md`（SR-B1/B2→00800 重產輸入）、`00800-rp8-rp11-rd-closeout.md`（RP8/RP11 RD 派工）、`aud11-closeout-dba-rd.md`（AUD-11 DBA/RD）、`c0-crediteval-e1-e2-escalation.md`（E1/E2 信用決策 domain）。
  5. **PRD→SRS pipeline（live，2026-06-18 起）**：`prd-to-srs-codex-dispatch.md`（per-page worker）、`prd-to-srs-orchestrator-drain.md`（orchestrator 批量迴圈；pilot 卡已歸檔 `done/`）、`n-axis-findings-ledger.md`（N 軸度量、驅動軸配置）、`EPROZ00100-EPROC00118-nfix-card.md`（**修正完成、待 Approved 收納**：N 軸 Blocker 已修 06-19 owner、opus×2 複審 PASS、結論進 SSOT；留 active 追 bundle In Review→Approved 迴圈）。
- **2026-06-16 收納批**（A-1 落地＋conformance PASS `daae4c3` 後）：`a1-funcGetExchangeRate-spec.md`（含 conformance 記錄）、`a1-oq-legacy-recon-findings.md`、`phase-d-a1-exchange-stub-investigation.md` → `done/`（A-1 全結，三份證據已消化）。
- **2026-06-18 收納批**（結論已進 SSOT／own work done，非被 tangential 依賴卡住）：`t24-bgroup-legacy-parity-fix.md`+`-findings.md`（fix pushed `3d6f446`、結論進 STATUS/decisions/triage；UAT 屬 Phase V 另軌、非本卡工作）、`aud11-cu0160-page-reverify.md`（reverify done、findings 已在 `done/`、UNFOUND 進 STATUS；closeout 另卡）、`EPROZ00100-regenerate-pilot.md`（pilot 跑完、結果進 `decisions`+卡內 §7；00100 餘事＝`nfix-card`）→ `done/`。
- **`done/`**（完成歸檔，含 card + 已消化 findings）：Phase F 逐頁、00800 修正、c0 cleanup、⑨ sweep、staff 調查鏈、早期 B-*/EPROC/EPROISU…；**2026-06-16 收納批**：`00300-return-recon-findings`、`00800-pending-recon-findings`、`langtype-data-filter-sweep-findings`、`bible-gap-recon-findings`、`00700-deputy-pk-reverify-findings`、`00100-todo-empty-recon-findings`、`epl-method-convention-findings`（結論皆已進 SSOT、card 已 done → 隨 card 歸檔，引用已 rewire 至 `done/`）；**AUD-10 結後**：`aud10-batch-layer-reverify.md`+`-findings.md`（批次層 app 層完整、B005 銷案）；**A-5 結後**：`khr-currency-handling-recon.md`+`-findings.md`（幣別坐実、owner 裁 keep）。
- 規則（`README.md` 末同步）：**任務完成/消化 → `git mv` 到 `done/`、引用 rewire、狀態回填 `feature-inventory.md`**。

---
> 導覽入口＝[`docs/README.md`](README.md)（分類索引）。本檔回答「**哪個檔在哪段 flow**」；README 回答「**想找某類文件去哪**」；`feature-inventory.md` 回答「**還剩多少事**」。
