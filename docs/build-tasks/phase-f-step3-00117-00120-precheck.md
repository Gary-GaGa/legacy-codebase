# Phase F · Step 3 · c0 FinEval 00117/00120 — 收尾前置 precheck（唯讀，單跑出全部）

> **唯讀**：只讀/搜尋新碼 + 舊 source，**不改任何檔**（結束 `git diff --name-only` 應空）。
> **目的**：一次跑出我寫**最後兩份 build prompt（00117 GI + 00120 FI）**所需的全部判定，解掉這兩頁的封鎖。
> **本檔合併並取代**：`phase-f-step2-00117-00120-staff-investigation.md`（新碼 staff 機制）＋ `00117-00120-old-system-staff-investigation.md`（舊系統 regression）。跑這份即可，那兩份可歸檔。
> **為何要這關**：c0 BE 同時有 staff 與 business 端點，但新 `funcIsStaffLoan`（`service/common/impl/FunctionServiceImpl:346-359`，`lonAttribute=="I"` 且 (S,03)/(U,01)）對 corporate 恆 false → c0 staff 版**永不觸發**。動手前要確認 (a) 這是 bug 還是設計、(b) 前端怎麼判 staff/business，否則會把 regression 當需求建錯。

---

## Part 1 — 新碼：c0 怎麼判 staff vs business + endpoint/範本對照

1. **i0 怎麼取 `isStaffLoan` + 切版**：i0 `credit-investigation` 容器/00117/00120 的 `isStaffLoan` 從哪來（容器 tab API 回傳？某 info/sele response 欄位？common 呼叫？），如何切 `financial-evalutaion-gi` ↔ `-gi-staff`（及 fi 版）。給 `file:line`。
2. **c0 的對應來源**（前端該讀哪欄/打哪端點）：
   - c0 容器 `epl-info-c0-credit-investigation-tab` 回傳裡有沒有 staff 旗標 / `businessType` / `pageMap`？
   - 還是要打 `funcIsStaffLoan` 類 c0/common endpoint？（找 BE `funcIsStaffLoan` 呼叫點 + 有無對應 `epl-*`）
   - `CsuFinancialStaffController` 的 `epl-{info/sele/save}-c0-financial-{staff/business/list}` 回傳/行為怎麼區分 staff/business？
3. **G/F businessType 容器分頁**（feature-inventory §「G/F businessType 分頁」）：c0 容器吃 BE 回的 `businessType`+`pageMap` 決定顯示哪些子頁——確認 00117 / 00120 各落在哪個 businessType 分支、nav config 怎麼掛（對齊 i0 動態 tabControl）。
4. **兩頁 endpoint 對照**（逐一確認**實際存在**的 `epl-*` ↔ BE controller:method ↔ DTO）：
   - **00117 FinEval GI**：`epl-info-c0-financial-staff`、`epl-sele-c0-financial-list`、`epl-info-c0-financial-business`、`epl-save-c0-financial-business`、`epl-save-c0-financial-staff`。
   - **00120 FinEval FI**：`epl-{info/save}-c0-financial-evaluation-table-fi`（`CsuFinancialEvaluationTableFiController`）、`epl-save-c0-financial-evaluation-staff-fi`（`CsuFinancialEvaluationStaffFiController`）。
5. **i0 範本元件路徑**（供鏡像）：00117 = `financial-evalutaion-gi`(+`-staff`)；00120 = `financial-evaluation-fi`(+`-staff`)——確認實際資料夾/component/service 路徑。

## Part 2 — 舊 source：corporate 到底有沒有 staff 路徑 → A/B 決策

> 對**舊系統 source**（依稽核：`legacy-epro/JavaSource/com/cathaybk/epro/c0/...`、`legacy-epro/WebContent/.../c0/...`、`legacy-epro/SQL/...`）驗，新碼只是推論、不可當真相。

6. **舊 c0 FinEval 有沒有 staff 版**：找舊 c0 FinEval GI（對應 00117）與 FI（對應 00120）的 trx/module/jsp（舊 funcId 約 `EPROC0_0117`/`EPROC0_0120`，或 review 端 `0217`/`0220`）。舊 i0 FinEval 有 staff vs business 分版——**舊 c0 也有嗎，還是只有 business 一種？**
7. **舊系統怎麼對 corporate 判 staff**：找舊版 staff 判定（舊 `funcIsStaffLoan` 或等價）。它對 corporate（CS/CU / 企金 `lonAttribute`）**會不會回 true**？條件是什麼？跟新碼 `lonAttribute=="I" && (S,03)/(U,01)` 比——新碼是**忠實移植**還是**漏了 corporate-staff 分支**？
8. **舊 c0 staff save 是否存在**：舊 c0 FinEval 有沒有 staff 版存檔/流程，對應新的 `epl-save-c0-financial-evaluation-staff-fi` / `epl-save-c0-financial-staff`？

## 產出（決策導向，一次給齊）
- **結論一（前端判定）**：c0 前端判 staff-vs-business 的方式（讀什麼欄 / 打什麼端點 / 容器 businessType）。
- **結論二（A/B，二選一）**：
  - **A — 舊 c0 有 staff 路徑** → 新 `funcIsStaffLoan` 是 regression（漏 corporate-staff）。**00117/00120 建 staff+business 兩版 + 標 BE 修 `funcIsStaffLoan`**。附舊 staff 判定 `file:line` + 舊 c0 staff 頁/存檔證據。
  - **B — 舊 corporate 嚴格無 staff、只個金有** → 新 `funcIsStaffLoan` 正確。**00117/00120 只建 business**；新 c0 staff 端點＝鏡像 i0 的多餘物（列 cleanup）。附「舊 corporate 不走 staff」證據。
  - **判不準** → 標出、別硬判（保守回報舊碼實況，這兩頁先停）。
- **endpoint 對照表**（00117 / 00120：FE 打的 `epl-*` ↔ BE controller:method ↔ DTO）。
- **i0 範本元件路徑**。
- 末附 `git diff --name-only`（應空）。

> 你回報結論一+二後，我**立刻**寫 `00117` + `00120` 最後兩份 build prompt（含正確 staff 切版做法、A→兩版 / B→單版、是否附 BE `funcIsStaffLoan` 修正），Phase F 收工。
