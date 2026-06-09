# docs 索引（分層 × 流程導覽）

> 本 repo＝**規劃/規格/backlog**（無原始碼）。**逐頁狀態與排程以 `feature-inventory.md` 為權威**。
> 完整「檔案 × flow」地圖見 [`repo-structure.md`](repo-structure.md)；規格方法論見 [`spec-architecture.md`](spec-architecture.md)。

## 🔁 分層 × 流程（由上往下讀＝AI flow；圖＝`assets/ai-workflow.mmd`）

```
Legacy ──反推──▶ ① Bible ──▶ ② PRD ──▶ ③ SRS(+QA) ──▶ ④ RD 任務單 ──▶ ⑤ 驗證/閘門 ──▶ 回填狀態
（repo 外）      specs/bible/  specs/prd/  specs/srs/     build-tasks/    scripts/ +        feature-
                 ＋module-*.md （外部權威， <funcId>/      （live↔done/）  spec-reviewer     inventory.md
                  原料         此處快照）   bundle×4檔                     ＋verification-*  （SSOT）
```

| flow 層 | 資料夾 / 檔 | 說明 |
|---|---|---|
| **① Bible** 業務聖經 | [`specs/bible/`](specs/bible/)（正式檔待建；原料＝`module-*.md`、`page-mapping.md`、`db-schema-catalog.md`） | Legacy 反推：北極星·黃金旅程·user story，證據接地 |
| **② PRD** what/why | [`specs/prd/`](specs/prd/)（外部權威、此處放快照） | PM + AI；REQ-nnn、TBD |
| **③ SRS（含 QA）** how | [`specs/srs/<funcId>/`](specs/srs/)（spec/openapi/schema/qa-cases） | SA + AI（`/prd-to-srs`）；`Rn`+契約+covers |
| **④ RD 任務單** | [`build-tasks/`](build-tasks/)（live；完成 → `done/`） | 交 Codex 實作的 prompt；產品碼在 repo 外 |
| **⑤ 驗證 / 閘門** | `../scripts/check-srs-bundle.py`（①②⑤）、`../scripts/verify-c0.py`（③）、spec-reviewer（語意）；`verification-handoff.md` / `verification-execution.md`（Phase V） | 機械先、語意後 |
| **狀態回填** | **`feature-inventory.md`** ⭐ | 每事收尾必回填（SSOT） |

> **治理/憲法**（always-on，不屬單一層）：根 `CLAUDE.md`（Claude）/ `AGENTS.md`（Codex）/ `.github/`（Copilot）+ `backend/`·`frontend/AGENTS.md`；雙軌範本 `env/codex/`。

## 🟢 狀態 / SSOT（先看這裡）
| 檔 | 用途 |
|---|---|
| **`feature-inventory.md`** | ⭐ **權威**：舊→新逐頁對應 + 前後端狀態 + 剩餘事項 + R1–R8 track + 建議排程 |
| `completion-ledger.md` | 桶別總盤點（A 完成 / B 待驗 / C 未實作）；明細以 feature-inventory 為準 |
| `decisions.md` | 決策與事實紀錄（逐輪更新；教訓收斂表＝`spec-architecture.md §9`） |

## 🗺 舊→新 對應 / 規劃（＝Bible 原料）
| 檔 | 用途 |
|---|---|
| `page-mapping.md` | 舊 funcId → 新頁對應 + 30% backlog |
| `migration-backlog.md` | 模組地圖（M1–M9）+ 橫向風險 R1–R8 |
| `module-is-iu-shell.md` / `module-cs-cu-shell.md` | 個金/企金 主流程 shell 分析 |
| `module-i0-c0-scoring.md` | i0/c0 財報·評分·CBC 結構 |

## 💸 撥貸（disbursement）
| 檔 | 用途 |
|---|---|
| `disbursement-triage.md` | 0921/0922/T24 綜合 triage（P0–P3 + §7 機械 allowlist M1–M10） |
| `disbursement-domain-escalations.md` | 剩餘需 domain/T24/DBA 裁決項（A/B/C/D 組） |

## ✅ 驗證
| 檔 | 用途 |
|---|---|
| `verification-handoff.md` | 殘留驗證項清單（交 dev/uat + owner） |
| `verification-execution.md` | 驗證怎麼分階段跑 |

## ⚙️ 流程 / 控制 / 環境
| 檔 | 用途 |
|---|---|
| `runbook-30pct.md` | Codex 自走補完的順序/閘門/煞車 |
| `SETUP-codex.md` | Codex CLI 設定/用法 + dev-box 疑難排解 |
| `vision-pipeline.md` | 願景與漸進落地 |
| `env/` | gitignore / yarnrc / maven-settings / **codex 雙軌範本**（prompts/agents/hooks/權限） |

## 📚 參考 / 樣板
| 檔 | 用途 |
|---|---|
| **`repo-structure.md`** | ⭐ Repo 結構 × AI flow 對照（哪個檔在哪段 flow 用） |
| **`spec-architecture.md`** | ⭐ 規格架構（精煉層級×規格類型×層界契約 + 教訓→控制點 §9） |
| `specs/` | **規格 pipeline 家**（bible/prd/srs 分層，見 `specs/README.md`） |
| `db-schema-catalog.md` | DB schema 目錄（JIT 抽） |
| `golden-template/` | 前端黃金樣板（JSP→元件對照）；SRS bundle 已移 `specs/srs/` |
| `assets/` | ai-workflow 圖（`.mmd`＝權威來源） |
| `adr/` | 架構決策紀錄（ADR-0001 雙軌 spec workflow…） |

## 🛠 任務單 `build-tasks/`（flow 第 ④ 層）
- **進行中（live）**：
  - `a1-funcGetExchangeRate-spec.md`（A-1 換匯 stub 規格，A-1 未實作）+ `phase-d-a1-exchange-stub-investigation.md`（A-1 背景調查）
  - `00800-verification-findings.md`（as-is 證據／SRS as-is 來源；D1–D5 已修注記在內）
  - ＊**Phase F c0 FE 已收工**、**⑨ 靜態 sweep 三批已收齊** → prompt 全進 `done/`。
- **`build-tasks/done/`**（已消化的任務 spec / 一次性調查——歷史記錄）：
  - c0 FE 逐頁 prompt（Phase F）：`phase-f-step2-00114/00116/00118/00119`、`phase-f-step2-c0-scoring-fe`、`phase-f-step3-00117/00120`
  - 00800 修正：`00800-fix-step1-tbd-independent`（D1–D5，`88328f9`）；c0 cleanup：`c0-staff-endpoints-cleanup`（`dcd9602`）
  - ⑨ 靜態 sweep：`tech-debt-sweep-1/2/3`（HTTP method `48e687f` / map-key `709f65c` / Logback `bbc4492`）
  - staff 調查鏈（決策 B 取代）：`00117-00120-old-system-staff-investigation`、`phase-f-step2-00117-00120-staff-investigation`、`phase-f-step3-00117-00120-precheck`
  - 其它：`verify-00800-revised-item-vs-prd`、早期 `B-boundary` / `B-z0-reports` / `EPROC00118`(BE) / `EPROCSU0130` / `EPROZ00700` / `EPROISU0920`

## 🗄 `archive/`（已消化、留存備查）
- `review-c0-prompt.md`（c0 後端審查 prompt）、`phase1-eproz0_0700-spec.md`（Phase 1 切片，已完成）。

---
> 維護：新文件歸到對應分類（規格三層放 `specs/`）；文件完成/消化後移 `build-tasks/done/` 或 `archive/` 並修連結；狀態變動回填 `feature-inventory.md`。
