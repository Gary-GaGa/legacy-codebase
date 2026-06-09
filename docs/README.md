# docs 索引（分類導覽）

> 本 repo＝**規劃/規格/backlog**（無原始碼）。下表把文件按用途分類；**逐頁狀態與排程以 `status/feature-inventory.md` 為權威**。
> 實體資料夾：活躍規劃文件平鋪於 `docs/`（彼此交叉引用密集，刻意不拆資料夾以免斷連結）；**已消化的歷史**收進 `build-tasks/done/`、`archive/`。

## 🟢 狀態 / SSOT（先看這裡）
| 檔 | 用途 |
|---|---|
| **`feature-inventory.md`** | ⭐ **權威**：舊→新逐頁對應 + 前後端狀態 + 剩餘事項 + R1–R8 track + 建議排程 |
| `completion-ledger.md` | 桶別總盤點（A 完成 / B 待驗 / C 未實作）；明細以 feature-inventory 為準 |
| `decisions.md` | 決策與事實紀錄（逐輪更新） |

## 🗺 舊→新 對應 / 規劃
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
| `SETUP-codex.md` | Codex CLI 設定/用法 |
| `vision-pipeline.md` | 願景與漸進落地 |
| `env/` | gitignore / yarnrc / maven-settings / codex 設定 |

## 📚 參考 / 樣板
| 檔 | 用途 |
|---|---|
| **`spec-architecture.md`** | ⭐ 規格架構（精煉層級×規格類型×層界契約 + 追溯/驗證）；先讀這份理解「規格怎麼組織、PRD/SRS/設計規格怎麼分」 |
| `db-schema-catalog.md` | DB schema 目錄（JIT 抽） |
| `golden-template/` | 前端黃金樣板 + boundary-bundle |
| `assets/` | ai-workflow 圖 |

## 🛠 任務單 `build-tasks/`
- **進行中（live）**：
  - `a1-funcGetExchangeRate-spec.md`（A-1 換匯 stub 規格，A-1 未實作）+ `phase-d-a1-exchange-stub-investigation.md`（A-1 背景調查）
  - `00800-verification-findings.md`（as-is 證據／SRS as-is 來源；D1–D5 已修注記在內）
  - ＊**Phase F c0 FE 已收工**（容器 + 8 子頁齊）→ 逐頁 prompt 全進 `done/`。
- **`build-tasks/done/`**（已消化的任務 spec / 一次性調查——歷史記錄）：
  - c0 FE 逐頁 prompt（Phase F）：`phase-f-step2-00114/00116/00118/00119`、`phase-f-step2-c0-scoring-fe`、`phase-f-step3-00117/00120`
  - 00800 修正：`00800-fix-step1-tbd-independent`（D1–D5，`88328f9`）；c0 cleanup：`c0-staff-endpoints-cleanup`（`dcd9602`）
  - staff 調查鏈（決策 B 取代）：`00117-00120-old-system-staff-investigation`、`phase-f-step2-00117-00120-staff-investigation`、`phase-f-step3-00117-00120-precheck`
  - 其它：`verify-00800-revised-item-vs-prd`、早期 `B-boundary` / `B-z0-reports` / `EPROC00118`(BE) / `EPROCSU0130` / `EPROZ00700` / `EPROISU0920`

## 🗄 `archive/`（已消化、留存備查）
- `review-c0-prompt.md`（c0 後端審查 prompt）、`phase1-eproz0_0700-spec.md`（Phase 1 切片，已完成）。

---
> 維護：新文件歸到對應分類；文件完成/消化後移 `build-tasks/done/` 或 `archive/` 並修連結；狀態變動回填 `feature-inventory.md`。
