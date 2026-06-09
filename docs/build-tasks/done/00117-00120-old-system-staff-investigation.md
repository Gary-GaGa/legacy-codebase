# 調查 — 舊 c0 FinEval（00117/00120）是否有 staff 版 + 舊系統怎麼對 corporate 判 staff（唯讀）

> **唯讀**，不改碼（結束 `git diff` 空）。**目的**：對**舊系統 source** 驗證——新 `funcIsStaffLoan`（corporate 恆 false）是「對」還是「regression」，以決定 c0 `00117`/`00120` 要不要建 staff 版。
> **背景/矛盾**：新 BE 有 c0 staff save 端點（`epl-save-c0-financial-evaluation-staff-fi`、`CsuFinancialStaffController`），但新 `funcIsStaffLoan`（`service/common/impl/FunctionServiceImpl:346-359`，`lonAttribute=="I"` 且 (S,03)/(U,01)）對 corporate 恆回 false → c0 staff 版永不觸發。**這是只讀新碼的推論，未對舊系統驗。**
> 舊 source 位置（依先前稽核）：`legacy-epro/JavaSource/com/cathaybk/epro/c0/...`、`legacy-epro/WebContent/.../c0/...`、`legacy-epro/SQL/...`。

## 要查並回答
1. **舊 c0 FinEval 頁有沒有 staff 版**：找舊 c0 FinEval GI（對應 `00117`）與 FinEval FI（對應 `00120`）的 trx/module/jsp（舊 funcId 約 `EPROC0_0117` / `EPROC0_0120`，或 review 端 `0217`/`0220`）。
   - 舊 i0 FinEval 有 staff vs business 分版——**舊 c0 也有嗎?** 還是 c0 只有 business 一種?
2. **舊系統怎麼對 corporate 判 staff**：找舊版「isStaffLoan / staff 判定」邏輯（舊 `funcIsStaffLoan` 或等價）。
   - 它**對 corporate（CS/CU / `lonAttribute` 企金）會不會回 true**?判定條件是什麼?
   - 跟新碼 `lonAttribute=="I" && (S,03)/(U,01)` 比——新碼是**忠實移植**還是**漏了 corporate-staff 分支**?
3. **舊 c0 staff save 是否存在**：舊 c0 FinEval 有沒有「staff 版的存檔/流程」對應新的 `epl-save-c0-financial-evaluation-staff-fi`?
   - 有 → corporate-staff 是舊系統真功能 → 新 `funcIsStaffLoan` 漏接＝**regression**。
   - 無 → 新 c0 staff 端點是鏡像 i0 時的多餘物（cleanup 候選）。

## 產出（決策導向）
**一句結論二選一**：
- **A：舊 c0 有 staff 路徑** → 新 funcIsStaffLoan 是 regression（漏 corporate-staff）。**建 00117/00120 兩版 + 標 BE 修 funcIsStaffLoan**。附舊 staff 判定邏輯（file:line）+ 舊 c0 staff 頁/存檔證據。
- **B：舊 c0 staff loan 嚴格只在個金、corporate 無 staff** → 新 funcIsStaffLoan 正確。**00117/00120 只建 business**；新 c0 staff 端點＝多餘物（列 cleanup）。附「舊 corporate 不走 staff」的證據。
- 判不準 → 標出、別硬判（保守回報舊碼實況即可）。

附：舊 staff 判定 `file:line`、舊 c0 FinEval 頁結構、與新碼差異點。末附 `git diff --name-only`（應空）。

> 回報後我據此決定最後兩頁怎麼建（含是否要 BE 修 funcIsStaffLoan），Phase F 收工。
