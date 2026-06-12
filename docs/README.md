# docs 索引（分層 × 流程導覽）

> 本 repo＝**規劃/規格/backlog**（無原始碼）。**逐頁狀態與排程以 `feature-inventory.md` 為權威**。
> 完整「檔案 × flow」地圖見 [`repo-structure.md`](repo-structure.md)；規格方法論見 [`spec-architecture.md`](spec-architecture.md)。
> 🗂 **2026-06-10 整理**：頂層平鋪 20 檔 → **6 入口/SSOT + 4 主題資料夾**（`legacy/`·`disbursement/`·`verification/`·`process/`）。

## 🔁 分層 × 流程（由上往下讀＝AI flow；圖＝`assets/ai-workflow.mmd`）

```
Legacy ──反推──▶ ① Bible ──▶ ② PRD ──▶ ③ SRS(+QA) ──▶ ④ RD 任務單 ──▶ ⑤ 驗證/閘門 ──▶ 回填狀態
（repo 外）      specs/bible/  specs/prd/  specs/srs/     build-tasks/    scripts/ +        feature-
                 ＋legacy/*    （外部權威， <funcId>/      （live↔done/）  spec-reviewer     inventory.md
                  原料         此處快照）   bundle×4檔                     ＋verification/*   （SSOT）
```

> 逐層「資料夾 × 工具 × 閘門」對照表＝[`repo-structure.md`](repo-structure.md) §1（**單一出處，本檔不再複寫**）；機械閘門涵蓋範圍＝`../scripts/check-srs-bundle.py` 檔頭。狀態回填→`feature-inventory.md` ⭐（SSOT）。

> **治理/憲法**（always-on，不屬單一層）：根 `CLAUDE.md`（Claude）/ `AGENTS.md`（Codex）/ `.github/`（Copilot）+ `backend/`·`frontend/AGENTS.md`；雙軌範本 `env/codex/`。

## 🟢 狀態 / SSOT（先看這裡｜頂層）
| 檔 | 用途 |
|---|---|
| **`feature-inventory.md`** | ⭐ **權威**：舊→新逐頁對應 + 前後端狀態 + 剩餘事項 + R1–R8 track + 建議排程 |
| **`pending-register.md`** | ⭐ **待決總表**：所有 open `@PENDING`/escalation/OQ（誰欠裁定、卡什麼、多久）；🔴 三項擋主線 |
| `decisions.md` | 決策與事實紀錄（逐輪更新；教訓收斂表＝`spec-architecture.md §9`） |

## 📚 入口 / 方法論（頂層）
| 檔 | 用途 |
|---|---|
| **`repo-structure.md`** | ⭐ Repo 結構 × AI flow 對照（哪個檔在哪段 flow 用） |
| **`spec-architecture.md`** | ⭐ 規格架構（精煉層級×規格類型×層界契約 + 教訓→控制點 §9） |

## 🗺 [`legacy/`](legacy/) — 舊→新對應 / 反推分析（＝Bible 原料）
| 檔 | 用途 |
|---|---|
| `legacy/page-mapping.md` | 舊 funcId → 新頁對應 + 30% backlog |
| `legacy/migration-backlog.md` | 模組地圖（M1–M9）+ 橫向風險 R1–R8 |
| `legacy/module-is-iu-shell.md` / `module-cs-cu-shell.md` | 個金/企金 主流程 shell 分析 |
| `legacy/module-i0-c0-scoring.md` | i0/c0 財報·評分·CBC 結構 |
| `legacy/db-schema-catalog.md` | DB schema 目錄（JIT 抽） |

## 💸 [`disbursement/`](disbursement/) — 撥貸
| 檔 | 用途 |
|---|---|
| `disbursement/disbursement-triage.md` | 0921/0922/T24 綜合 triage（P0–P3 + §7 機械 allowlist M1–M10） |
| `disbursement/disbursement-domain-escalations.md` | 剩餘需 domain/T24/DBA 裁決項（A/B/C/D 組） |

## ✅ [`verification/`](verification/) — 驗證
| 檔 | 用途 |
|---|---|
| `verification/verification-handoff.md` | 殘留驗證項清單（交 dev/uat + owner） |
| `verification/verification-execution.md` | 驗證怎麼分階段跑 |

## ⚙️ [`process/`](process/) — 流程 / 控制 / 環境
| 檔 | 用途 |
|---|---|
| `process/vision-pipeline.md` | 願景與漸進落地 |
| `process/SETUP-codex.md` | Codex CLI 設定/用法 + dev-box 疑難排解 |
| `env/` | gitignore / yarnrc / maven-settings / **db-ro-wrappers**（DB 唯讀部署）/ **codex 雙軌範本**（prompts/agents/hooks/權限） |

## 🧩 樣板 / 規格家 / 圖
| 檔 | 用途 |
|---|---|
| `specs/` | **規格 pipeline 家**（bible/prd/srs 分層，見 `specs/README.md`） |
| `golden-template/` | 前端黃金樣板（JSP→元件對照）；SRS bundle 已移 `specs/srs/` |
| `assets/` | ai-workflow 圖（`.mmd`＝權威來源） |
| `adr/` | 架構決策紀錄（ADR-0001 雙軌 spec workflow…） |

## 🛠 任務單 [`build-tasks/`](build-tasks/)（flow 第 ④ 層）
- **進行中（live）**：
  - `a1-funcGetExchangeRate-spec.md`（A-1 換匯 stub 規格，A-1 未實作）+ `phase-d-a1-exchange-stub-investigation.md`（A-1 背景調查）
  - `00800-verification-findings.md`（as-is 證據／SRS as-is 來源；D1–D5 已修注記在內）
  - ✅ `00800-rimat-fix.md` **F1–F9 已落地**（product `5580eb7`，06-12 審過）→ 歸檔 done/
  - `00300-return-recon.md`（00300 return 坐實，待派工）、`c0-authz-sql.md`（c0 授權列 SQL 預產，待派工）
  - `schema-diff-recon.md`（**新舊庫 schema 全量 diff**，agent 自查首任務，待派工）
  - `full-refactor-audit.md` + `refactor-audit/`（**全量 zero-based 盤點 ✅ 完成 2026-06-11**：166 列，diff 報告=`refactor-audit/diff-vs-inventory.md`、QC=`refactor-audit-qc.md`；歸檔待 AUD-1~5 收口）
  - `phase-g-csu-mainflow-fe.md`（**Phase G：企金主流程 FE 後半段補建**，audit F-1 頭條；待派工）
  - audit 修復包：✅ 已修×3 歸檔 done/（00660/00100/00119）；餘 `00640-pdf-export-fix.md`（待派工）+ `bible-gap-recon.md`（AUD-5 取證，待派工）
  - ＊**Phase F c0 FE 已收工**、**⑨ 靜態 sweep 三批已收齊** → prompt 全進 `done/`。
- **`build-tasks/done/`**（已消化——歷史記錄）：c0 FE 逐頁（Phase F）、00800 修正、c0 cleanup、⑨ sweep×3、staff 調查鏈、早期 B-*/EPROC/EPROISU…
- **live 任務單命名（2026-06-11 起）**：`<funcId>-<type>.md`（如 `00800-verification-findings.md`）；`done/` 歷史檔名不回溯改。
- **done/・archive/ 清理規則（2026-06-11 訂）**：平時不刪（audit trail）；**里程碑後批次清**（如 Phase V 收口）——刪前逐檔跑引用檢查，仍被 live 文件引用者（如 `archive/review-c0-prompt.md` 語意審查模板、`archive/phase1-eproz0_0700-spec.md` entity 定稿）續留。
- **大卡 tasks checklist（2026-06-12 訂，SDD 技巧）**：多頁/多步的卡（如 phase-g）內含 checkbox tasks 段＋斷點欄（沿 `refactor-audit/master.md` 模式）——session 中斷從斷點續查、不靠 compact 記憶；單頁小修卡免。

## 🗄 [`archive/`](archive/)（已消化、留存備查）
- `review-c0-prompt.md`（c0 後端審查 prompt）、`phase1-eproz0_0700-spec.md`（Phase 1 切片，已完成）。
- `completion-ledger.md`（30% 總盤點；內容併入 feature-inventory，2026-06-11 凍結）、`runbook-30pct.md`（30% 自走控制文件；c0 結清、撥貸改走 triage/A-1 專屬文件，2026-06-11 凍結）。

---
> 維護：規格三層放 `specs/`；舊系統分析→`legacy/`、撥貸→`disbursement/`、驗證→`verification/`、流程→`process/`；任務完成→ `build-tasks/done/`；狀態變動回填 `feature-inventory.md`。
