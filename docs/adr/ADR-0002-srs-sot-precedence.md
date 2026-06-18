# ADR-0002：SRS 來源優先序（PRD/舊系統/db-schema/refactor 多源合成的裁準）

| 欄位 | 內容 |
|---|---|
| Status | **Accepted** |
| 日期 | 2026-06-18 |
| Slug | srs-sot-precedence |
| 相關 | `docs/spec-architecture.md §5b`（內容權威）、`.claude/skills/prd-to-srs/SKILL.md` §DoD、`docs/process/orchestration-playbook.md §1`、`CLAUDE.md §4` / `AGENTS.md`、`docs/process/legacy-parity-sop.md`；先例 `REF-D2`/`DB-D6`（EPROZ00100 bundle） |

## Context
- SRS 現由 **PRD + 舊系統 + db-schema snapshot + refactor spec** 四源合成，來源**會不一致**：
  - refactor＝舊系統重構後、可能含調整需求的「最終意圖版」（owner 說明），但只在它那層權威；
  - db-schema snapshot＝新 DB 物理真相；
  - 不少被列「人工 `@PENDING`」的項，其實是 DB **可查的 fact**（如 TBD-001 的 role 字典/授權矩陣＝`TB_ROLE_DEFINE`/`TB_API_AUTH`），不該佔人裁。
- 既有實踐已隱含此精神（`REF-D2` keep-refactor-latest、`DB-D6` win-by-layer、`legacy-parity-sop` regression 三判、`spec-architecture §9#2`「舊系統≠絕對正確」），但**無單一明文裁準**，易各判各的、把 fact 誤列 Pending、或讓 refactor 越層蓋物理 schema。

## Decision
1. **來源優先序梯（依「問的是什麼」選權威）**：業務意圖 `Bible>PRD`；需求驗收 `PRD`；FE/API 行為與契約 `refactor(latest)>legacy`；物理結構 `new DB snapshot>refactor doc>legacy DDL`；既有資料/字典 `new DB query`。
2. **Rule 1（DB-resolvable fact 不留 Pending）**：可由 `docs/db-schema/` 判定的 fact 直接撈出寫入、不佔 `@PENDING`；**三護欄**＝只解 fact 非 policy、強制 provenance（source＋snapshot date＋decision 列）、與 PRD/Bible 矛盾則升級；讀不到 snapshot 則退回 `@PENDING`。
3. **Rule 2（refactor 限本層優先）**：refactor 只在 FE/API 契約層贏（留 `REF-Dn` delta），**不蓋** db-schema 物理 / Bible-PRD 意圖。
4. **升級觸發 → C 類 `@PENDING`**：命中 Bible/PRD 衝突、regression/破業務規則、高風險面（authZ/金額/刪改/安全/交易）、同層無 upstream 可裁——即不自決、停交人裁。
5. **內容權威＝`docs/spec-architecture.md §5b`**；constitution（`CLAUDE.md`/`AGENTS.md`）、`prd-to-srs` DoD、`orchestration-playbook §1` 皆薄殼指回；`來源優先序` 列入 `check-dualtrack-parity.py` anchor。

## Consequences
- ＋ 把「誰是權威」從各判各的收斂成單表；fact 自動解（少假 Pending）、policy 仍逼人裁（right-size Pending）。
- ＋ refactor 越層蓋物理 schema 的危險被 layer-scope 擋掉（gate② 命名碰撞即活例）。
- － DB-resolvable 需「轉換讀得到 db-schema snapshot」；目前 spec repo 無此層（在母資料夾）→ 讀不到時仍退回 Pending（前提已寫入 Rule 1）。
- 後續：`refactor-audit` 回路負責抓 snapshot 漂移；fact 的 snapshot date 為其依據。

## Alternatives considered
- **blanket「refactor 一律贏」**：簡單但會讓 FE 文件蓋物理 schema/業務意圖 → 改為 layer-scoped。
- **一律列 `@PENDING` 等人裁**：最安全但把可查 fact 也塞給人 → 違 right-size、拖慢轉換。
- **DB 一律鏡像為 to-be**：把 legacy 髒資料/bug 寫進規格、且混淆 fact 與 policy → 加三護欄與升級觸發限制。
