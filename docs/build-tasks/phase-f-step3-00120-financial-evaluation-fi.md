# Phase F · Step 3 · 頁 7/7 — `EPROC00120` Financial Evaluation FI（c0 FE，**business-only**）—— Phase F 收尾

> **前置**：00117 GI 已完成（本批第 1 頁）。本頁＝c0 FinEval 收尾批**最後一頁**，過了 Phase F 整組 8 子頁齊。
> **決策（precheck 已定，B）**：舊 corporate c0 00120 是 **BusinessOwner-only，無 staff 分版/staff save**；新 `funcIsStaffLoan` 對 CS/CU 恆 false 是忠實沿用舊 i0，**非 regression**。→ **只建 business 版，不建 staff-fi，不打 `funcIsStaffLoan`**。
> **啟動位置**：前端專案（母資料夾）。**落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `financial-evaluation-fi`（business 版），建 c0 版於
`corporate/credit-investigation/components/financial-evaluation-fi/`（對齊 c0 sibling 命名），改打 c0 **table-fi** endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `EPROC00120` 從 `loadEmptyComponent`/`EmptyComponent` 換成真 component。

## 對接 endpoint（c0 FinEval FI，**business / table-fi only**）
- `epl-info-c0-financial-evaluation-table-fi` — 讀（`CsuFinancialEvaluationTableFiController.infoFinancialEvaluationTable`，`InfoCsuFinancialEvaluationTableFiRequest -> InfoCsuFinancialEvaluationTableFiResponse`）
- `epl-save-c0-financial-evaluation-table-fi` — 存（`CsuFinancialEvaluationTableFiController.saveFinancialEvaluationTable`，`SaveCsuFinancialEvaluationTableFiRequest -> ?`，**讀 BE 對齊 response**）
- **（條件）** `epl-sele-c0-financial-list` — 若沿用 i0 FI service 的 menu/list pattern 才需要（同 00117 共用；`CsuFinancialStaffController.seleFinancialStaff`）。**先讀 i0 FI service 確認有沒有用 list，再決定接不接**。
> BE controller：`backend/.../controller/corporate/CsuFinancialEvaluationTableFiController.java:25`。**讀其 DTO 對齊欄位**。
> ⚠️ **不要接** `epl-save-c0-financial-evaluation-staff-fi`（`CsuFinancialEvaluationStaffFiController.java:23`）—— staff-fi＝鏡像多餘物，FE 不接。

## 判定方式（重要，別套 i0）
- c0 容器**沒有 `isStaffLoan`**；分頁由 BE `buildPageMap()` 用 `businessType` 控制（`CsuCreditInvestigationServiceImpl.java:261`：F 顯示 00119/00120）。
- 前端**只讀容器回的 `businessType`/`pageMap`**（同 00116/00119 已驗做法），**不打任何 `funcIsStaffLoan` / staff 切版**。00120 在 **F** 分支。

## staff 不建（cleanup，非本頁工作）
- 新 BE `epl-save-c0-financial-evaluation-staff-fi` 確認為鏡像多餘物（舊 c0 無 staff-fi）→ **列 cleanup backlog、本頁不接、不刪 BE**（刪除另案）。

## 鐵則
1. **對齊 c0 BE DTO**（FI 與 GI 的 DTO 可能有差，逐一對；移除 c0 不收的欄位 / staff 專屬欄）。
2. **自足鏡像**（§6.1）：清掉 copied component 內的 i0 endpoint、`*.individual.*` import、i0 spec/mock；**不得 reflection、不得注入/委派 i0 service**（`verify-c0` 會掃）。
3. **新檔存乾淨 UTF-8 / 無 BOM**；中文字串常數逐一驗。
4. `ng build` 綠；**單一 commit**（標 `EPROC00120` + table-fi endpoint）；報 diff。

## 回報
- diff 範圍 + 主要檔案；c0 FI business DTO 與 GI/i0 差異；是否需要 `epl-sele-c0-financial-list`（說明依據）；
- 確認 **nav `EPROC00120` 已換真 component**、**未接 staff-fi**、**未打 funcIsStaffLoan**；
- `ng build` + 新 chunk 名；`git status --short`（應乾淨）。

> 過了 → **Phase F 收工**（c0 credit-investigation 8 子頁齊）。回我這邊更新 `feature-inventory.md`：00117/00120 標 ✅、staff endpoints 入 cleanup backlog。
