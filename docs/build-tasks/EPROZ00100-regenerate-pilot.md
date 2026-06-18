# EPROZ00100 重產 pilot（砍掉重產 ＋ SoT-precedence Option-1 試點）

> **取代** `EPROZ00100-source-fixpack.md`（patch 路線作廢）。決策：**不 patch 既有 bundle，砍掉 + 用最終 pipeline 重產**，並當作 `docs/spec-architecture.md §5b`「來源優先序」新規則的 **Option-1 試點**（fact-only 不留 Pending、靠強化 N 軸 + 可 grep provenance、先驗一頁再全面）。
> **為何重產不 patch**：既有 `ERPOZ00100/` bundle ＝ typo 命名 + gate② false-positive + 產於 SoT 規則之前；逐項 patch 不如走最終 pipeline 一次產對（`CLAUDE.md`/`spec-architecture §7` 早記「00100 已全清、待母資料夾重產」）。
> **分工**：① 砍掉既有 bundle ＝本 repo 已做（見本 commit）；② 重產需 `docs/db-schema/` snapshot（**母資料夾**、本 repo 無）→ 母資料夾跑 `prd-to-srs`；③ 落地後 verify + backfill ＝我。

## 1. 砍掉（已於本 commit 做）
`git rm -r docs/specs/srs/ERPOZ00100/`（typo bundle）。重產出來的新 bundle 直接正名 `docs/specs/srs/EPROZ00100/`。funcId 引用（feature-inventory/traceability）保留、status＝「重產中」。

## 2. 重產 inputs（母資料夾跑 `prd-to-srs`）
| input | 位置 | 角色 |
|---|---|---|
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md`（本 repo 有）| what |
| db-schema snapshot | `docs/db-schema/02_tables/`（**母資料夾**）| 物理真相 + TBD-001 fact 來源 |
| refactor spec | `docs/refactor/.../EPROZ00100/`（母資料夾）| FE/API 契約 latest |
| 既有裁定 | `decisions`/`pending-register`/`per-page-reinventory-matrix` | 約束、不重議 |

## 3. 重產時吃進的新規則（pilot 重點）
- **SoT 優先序（`docs/spec-architecture.md §5b`）**：refactor 限本層贏（留 `REF-Dn` delta）、不蓋 DB 物理/Bible-PRD 意圖；升級觸發命中→C 類 `@PENDING`。
- **TBD-001 DB-resolvable**：role 字典＝`TB_ROLE_DEFINE(ROLE_ID→ROLE_NAME/DESC)`、授權 matrix＝`TB_API_AUTH(API_ID→ROLE)` → **撈出寫入、不列人工 Pending**；provenance 標 `[DB:TB_ROLE_DEFINE@<date>]`；**authZ matrix 僅作 legacy-state 證據、to-be 沿用待 PRD/升級**（不默認進 to-be 契約）。
- **gate② 正解 mapping**：openapi `role`(3) ↔ `TB_ROLE_DEFINE.ROLE_ID`(3)，**非** `TB_API_AUTH.ROLE`(100)；重產時欄位對映直接對對象，命名碰撞自然消失。

## 4. Option-1 pilot 驗收（這頁要特別盯）
- **機械**：`python3 scripts/check-srs-bundle.py docs/specs/srs/EPROZ00100; echo exit=$?` 必 0。**若 gate② 仍 false-positive**（把 `role`(3) 比到 `TB_API_AUTH.ROLE`(100)）→ 這就是 gate 該修的鐵證、回 `ADR-0002` 後續評估。
- **N 軸 A–G（跨模型）**，本 pilot 重壓：
  - **axis D 安全·授權**：authZ fact 有無被誤當 to-be 契約（守 §5b Rule 1 高風險特例）。
  - **axis B as-is parity**：refactor 贏的每處有無過 `legacy-parity-sop` 三判、非 regression（守 §5b Rule 2）。
  - **axis E DB reconcile**：TBD-001 fact 的 provenance `[DB:table@date]` 齊、可 grep。
- **fact-only 檢核**：role 字典/授權 matrix **不再**佔人工 `@PENDING`；policy（如「`003` to-be 能否 delete」）**仍**列 `@PENDING` 待 PM/SA。
- **provenance 可 grep**：`grep -rn "\[DB:" docs/specs/srs/EPROZ00100/` 每條 DB-derived fact 都有 ref。

## 5. 落地後 backfill（我，一個 PR）
`git fetch` → §4 驗收綠 → backfill：`per-page-reinventory-matrix`（00100 status）、`feature-inventory §2E`、`pending-register`（TBD-001 resolved、policy TBD 仍列）、Status。

## 6. pilot 回饋回路（Option-1 的安全閥）
這頁試點若發現 **fact/policy 誤判** 或 **provenance 漏網**（三模型審點名的「prose 非機械 gate」風險）→ 回頭評估是否把 provenance 格式檢查 / authZ-fact red-flag 補成 `check-srs-bundle` 機械 gate（`ADR-0002 Consequences` 已留伏筆）。**驗過這一頁、確認 Option-1 守得住，再推其餘 funcId**。
