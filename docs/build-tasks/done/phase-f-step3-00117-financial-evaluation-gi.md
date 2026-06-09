# Phase F · Step 3 · 頁 6/7 — `EPROC00117` Financial Evaluation GI（c0 FE，**business-only**）

> **前置**：00112/00114/00118/00116/00119 已完成。本頁＝c0 FinEval 收尾批第 1 頁。
> **決策（precheck 已定，B）**：舊 corporate c0 00117 是 **BusinessOwner-only，無 staff 分版/staff save**；新 `funcIsStaffLoan` 對 CS/CU 恆 false 是忠實沿用舊 i0（IS+03 / IU+01），**非 regression**。→ **只建 business 版，不建 staff，不打 `funcIsStaffLoan`**。
> **啟動位置**：前端專案（母資料夾）。**落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `financial-evalutaion-gi`（business 版；注意 i0 資料夾名就是這個 typo），建 c0 版於
`corporate/credit-investigation/components/financial-evaluation-gi/`（對齊你已建的 c0 sibling 命名慣例，如 `financial-statement-gi`），改打 c0 **business** endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `EPROC00117` 從 `loadEmptyComponent`/`EmptyComponent` 換成真 component。

## 對接 endpoint（c0 FinEval GI，**business only**）
- `epl-sele-c0-financial-list` — 清單/menu（`CsuFinancialStaffController.seleFinancialStaff`，`SeleCsuFinancialStaffRequest -> Map`）
- `epl-info-c0-financial-business` — 讀（`CsuFinancialStaffController.getFinancialBusinessInfo`，`GetCsuFinancialBusinessInfoRequest -> GetCsuFinancialBusinessInfoResponse`）
- `epl-save-c0-financial-business` — 存（`CsuFinancialStaffController.saveFinancialBusiness`，`SaveCsuFinancialBusinessRequest -> List`）
> BE controller：`backend/.../controller/corporate/CsuFinancialStaffController.java:31`。**讀其 DTO 對齊欄位**。
> ⚠️ **不要接** `epl-info-c0-financial-staff`、`epl-save-c0-financial-staff`（staff 版＝鏡像 i0 的多餘物，FE 不接；見下「staff 不建」）。

## 判定方式（重要，別套 i0）
- c0 容器**沒有 `isStaffLoan`**；分頁由 BE `buildPageMap()` 用 `businessType` 控制（`CsuCreditInvestigationServiceImpl.java:261`：G 顯示 00116/00117、F 顯示 00119/00120）。
- 前端**只讀容器回的 `businessType`/`pageMap`**（同 00116/00119 已驗做法），**不要為 c0 FE 打任何 `funcIsStaffLoan` / staff 切版**。00117 在 **G** 分支。

## staff 不建（cleanup，非本頁工作）
- 新 BE `epl-info-c0-financial-staff` / `epl-save-c0-financial-staff` 確認為鏡像 i0 時的多餘物（舊 c0 無對應）→ **列 cleanup backlog、本頁不接、不刪 BE**（刪除另案）。

## 鐵則
1. **對齊 c0 BE DTO**（移除 c0 不收的欄位如 `isQuery`/staff 專屬欄）；business response 形狀以 `GetCsuFinancialBusinessInfoResponse` 為準。
2. **自足鏡像**（§6.1）：清掉 copied component 內的 i0 endpoint、`*.individual.*` import、i0 spec/mock；**不得 reflection、不得注入/委派 i0 service**（`verify-c0` 會掃）。
3. **新檔存乾淨 UTF-8 / 無 BOM**；中文字串常數逐一驗（曾在 00116 壞 400+ 處）。
4. `ng build` 綠；**單一 commit**（標 `EPROC00117` + 3 個 business endpoint）；報 diff。

## 回報
- diff 範圍 + 主要檔案；c0 GI business DTO 與 i0 差異（移除了哪些 staff/isQuery 欄）；
- 確認 **nav `EPROC00117` 已換真 component**、**未接任何 staff endpoint**、**未打 funcIsStaffLoan**；
- `ng build` + 新 chunk 名；`git status --short`（應乾淨）。

> 過了接 **最後一頁 `00120` FI**（同為 business-only）。
