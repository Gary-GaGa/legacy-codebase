# Phase F · Step 2 · 收尾前置 — c0 FinEval（00117/00120）staff-vs-business 判定調查（唯讀）

> **唯讀**，不改碼（結束 `git diff` 空）。產出：c0 前端「怎麼決定 staff 版 vs business 版」+ 兩頁 endpoint 對照，供我寫最後兩份 build prompt。
> **背景**：i0 FinEval 用 `creditInvestigationNav(isStaffLoan)` 切 staff/business 版；但 **c0 容器 DTO 沒有 `isStaffLoan`**，而 c0 BE 有 staff 概念（`CsuFinancialStaffController`、`epl-save-c0-financial-evaluation-staff-fi`、00117 sele 用 `funcIsStaffLoan`）。動手前要先確定 c0 的判定來源,別硬套 i0。

## 要查並回答
1. **i0 怎麼取 `isStaffLoan`**：i0 `credit-investigation` 容器/00117/00120 的 `isStaffLoan` 從哪來（容器 tab API 回傳？某個 info/sele response 欄位？common 呼叫？）+ 它如何切 `financial-evalutaion-gi` ↔ `financial-evaluation-gi-staff`（及 fi 版）。給 `file:line`。
2. **c0 的對應來源**：c0 要決定 staff vs business，前端該**讀哪個欄位 / 打哪個 endpoint**？
   - c0 容器 `epl-info-c0-credit-investigation-tab` 回傳裡有沒有 staff 旗標？
   - 還是要打 `funcIsStaffLoan` 類的 c0/common endpoint？（找 BE `funcIsStaffLoan` 的呼叫點與是否有對應 `epl-*`）
   - `CsuFinancialStaffController` 的 `epl-{info/sele/save}-c0-financial-{staff/business/list}` 回傳/行為怎麼區分 staff/business？
3. **兩頁 endpoint 對照**（確認實際存在的）：
   - **00117 FinEval GI**：`epl-info-c0-financial-staff`、`epl-sele-c0-financial-list`、`epl-info-c0-financial-business`、`epl-save-c0-financial-business`、`epl-save-c0-financial-staff`（逐一確認 + 對應 BE controller method/DTO）。
   - **00120 FinEval FI**：`epl-{info/save}-c0-financial-evaluation-table-fi`（`CsuFinancialEvaluationTableFiController`）、`epl-save-c0-financial-evaluation-staff-fi`（`CsuFinancialEvaluationStaffFiController`）。
4. **i0 範本元件路徑**：00117 = `financial-evalutaion-gi`(+`-staff`)；00120 = `financial-evaluation-fi`(+`-staff`)——確認實際資料夾/component/service 路徑,供鏡像。

## 回報格式
- **一句結論**：c0 前端判 staff-vs-business 的方式（讀什麼 / 打什麼）。
- i0 `isStaffLoan` 來源 + 切版邏輯（file:line）。
- 00117 / 00120 的 endpoint 對照表（FE 要打的 `epl-*` ↔ BE controller:method ↔ DTO）。
- i0 範本元件路徑。
- 判不準 → 標出、別硬猜（這題若不清楚,兩頁先停）。
- 末附 `git diff --name-only`（應空）。

> 你回報後我審判定方式,再給 `00117` + `00120` 的最後兩份 build prompt（含正確的 staff 切版做法）。
