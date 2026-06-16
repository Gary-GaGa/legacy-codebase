# Build Task — legacy/ 早期 schema 推斷 vs DB 全面復驗（A 類唯讀 recon）

> ✅ **完成（2026-06-16，審過，findings `legacy-schema-db-reverify-findings.md`）**：96 表斷言查證、93 證實、**7 🔴 推翻 + 2 ⚠️ 未涵蓋**。7 推翻已回填 legacy 內文（db-schema-catalog ×6：71→142 表／CROSS_CHARGE 表名／SCORE_CARD MAIN-SUB 舊有新無／EMP_PROXY 複合 PK／T24_BRANCH_CODE(20)／FUNCTION_AUTH FUNCTION_ID(50)；migration-backlog ×2：TB_FUNCTION_INFO 移除/EMP_PROXY PK；module-i0-c0-scoring ×1：SCORE_CARD）。連動：EMP_PROXY 複合 PK→`00700-deputy-pk-reverify.md`（deputy 已完成頁潛在 bug）;SCORE_CARD→AUD-7。findings 留 live。

> 載具：Codex＋DB 唯讀 wrapper（或先用既有 `schema-diff-findings.md` 對照）。**A 類**（唯讀產 findings，可進 orchestration）。
> **背景**：`legacy/` 多檔的 schema/entity 斷言產於 **DB 未通時代（曾誤判 DB2）**——已抓到錯：`TB_BRANCH_PROFILE`「無 `T24_COMPANY`」實為**有**（`schema-diff-findings.md:246`，連動撥貸 B-1/A-1 OQ-1）。**系統性復驗**：把所有「資料事實」推斷對 DB DDL 校正,一次掃乾淨「DB 未通時代的誤判」（別逐檔踩雷）。
> **判準（DB 通後重驗什麼）**：只驗「**資料事實**」（entity 欄位/PK/型別/長度/schema/表存在性）——DB 是更高權威;**不驗「方法/規格/流程」**（那些 DB 不取代）。

## 掃描範圍（legacy/ 的資料事實斷言）
1. **`db-schema-catalog.md`（主）**：§2 三表、§3 後續抽取批次、全域學習——所有 `TB_*` 表/欄/PK/型別/長度/「無 X 欄」斷言。
2. **`module-i0-c0-scoring.md`**：評分/財報相關表欄斷言（如財評精度——對 AUD-6 `TB_FINANCIAL_EVALUATION_INFO` 精度）。
3. **`module-is-iu-shell.md`/`module-cs-cu-shell.md`**：流程內提及的表/欄（多為結構,schema 斷言較少,有才驗）。
4. **`page-mapping.md`/`migration-backlog.md`**：零星 entity/schema 斷言（如 phase1 理想化 REST 已標,schema 斷言才驗）。

## 方法（context 衛生：分批、先用既有 diff、DB 只補查未涵蓋）
1. **主對照＝`schema-diff-findings.md`**（已是 DB 全量 diff／schema 事實 SSOT）：legacy 斷言能對到 schema-diff 的,直接判。
2. **DB 唯讀補查**：schema-diff 未涵蓋的表/欄,用 wrapper `describe`/查 `ALL_TAB_COLUMNS`（`OVSLXLON02` 為主、必要時 `OVSLXLON01`）。spool 到本機、只讀檔做 diff、不貼全量進 context。
3. **逐斷言分類**：✅ DB 證實 ／ 🔴 DB 推翻（附正確值）／ ⚠️ DB 未涵蓋（標 UNFOUND）。

## 鐵則
1. 唯讀（產品/legacy 內文不改）；以 **DB DDL 為準**；findings 只列校正清單,**實際回填 legacy 內文由人審後做**（同 T24_COMPANY 校正流程）。
2. file:line 必附（legacy 斷言處 + schema-diff/DB 證據）；UNFOUND 必標。
3. 分批（一檔一批或一主題一批）、結果寫回 findings,不靠單次 context。

## 回報
- 校正清單表：`legacy 檔:line 斷言 ↔ DB 實況 ↔ ✅證實/🔴推翻/⚠️未涵蓋 ↔ 正確值`。
- 🔴 推翻者另列「連動影響」（如 T24_COMPANY 連 B-1/A-1）。
- findings 寫 `docs/build-tasks/legacy-schema-db-reverify-findings.md`。

> 過了：legacy/ schema 斷言全部對 DB 校準;🔴 推翻項我審後回填 legacy 內文 + 標連動;db-schema-catalog 全面改指 DB SSOT。
