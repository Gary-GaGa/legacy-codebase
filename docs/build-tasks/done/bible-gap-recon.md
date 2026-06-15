# Build Task — BIBLE-GAP 驗證（唯讀 recon;AUD-5）

> ✅ **完成（2026-06-15，審過）**：五項全收斂、審計總量不變。findings＝`bible-gap-recon-findings.md`；`diff-vs-inventory.md` BIBLE-GAP-1~5 改 recon-closed。00670 舊源全無→收斂 0181/TLOD；0180→z0 ToDo(00100)/Search(00600) downloadFile 承載；0182/0183/0184→Summary(0922) 三 download 承載。AUD-5 銷案。

> 載具：Codex（母資料夾，唯讀）。**依據**＝`refactor-audit/diff-vs-inventory.md` §3：Bible 點名 `EPROZ00670`、`EPROISU0180/0182/0183/0184` 五個報表頁，S1–S9 審計無承載列。二選一結論：舊源真有 → S2/S3/S9 窮盡聲明有漏，補列;舊源沒有 → Bible 錨點收斂。

## 取證項
1. 舊源搜 `EPROZ0_0670`、`EPROIS_0180/0182/0183/0184`（含 IU/CS/CU 變體）的 JSP／trx action／dispatcher 註冊——**逐個列存在/不存在＋路徑證據**;注意它們可能不是獨立頁而是 Jasper 報表 id（搜舊 report 設定/`.jasper`/`.jrxml` 引用）。
2. 存在者：補進對應模組檔（`M2-is.md`/`M8-z0.md`）為正式列（含 FE/BE 狀態判定＋四錨點）、更新小計＋`master.md`＋窮盡聲明＋`diff-vs-inventory.md` 總量表。
3. 不存在者（或僅為報表 id）：寫結論「Bible 錨點應收斂至 `EPROISU0181` 列／`EPROISU0922` 列」＋依據。

## 鐵則
唯讀（產品 repo 不改）;結論附 file:line;findings 寫本資料夾新檔 `bible-gap-recon-findings.md`（產出後才存在）;審計檔的補列/修改＝本 recon 唯一例外的寫入範圍。

## 回報
五項逐個結論;審計檔異動清單（若有）;`git status --short`。

> 過了：BIBLE-GAP-1~5 關閉（補列 or 收斂）;AUD-5 從 `pending-register.md` 銷案。
