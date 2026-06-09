# Build Task — c0 FinEval staff 端點 cleanup（鏡像 i0 多餘物，決策 B 後）

> 載具：Codex（後端）。**背景**：決策 B 已坐實——舊 corporate c0 00117/00120 是 BusinessOwner-only、**無 staff 路徑**；c0 staff 端點是鏡像 i0 時帶進來的多餘物，**FE 從未接**（00117=`b14ae05`、00120=`6b084fb` 皆確認未接 staff）。
> **落地**：master-direct；**單一 commit、build 綠、報 diff 等審**。
> ⚠️ **這是「移除既有碼」，比新增危險**——**先查全引用確認 dead，再移**；KEEP/REMOVE 界線要精準（見下，別誤刪 business）。

## 🎯 精準界線（最重要）

### REMOVE（staff-only，確認 dead 後移除）
| 端點 | controller:method | DTO |
|---|---|---|
| `epl-info-c0-financial-staff` | `CsuFinancialStaffController.infoFinancialStaff` | `InfoCsuFinancialStaffResponse`（+ request 若 staff 專用）|
| `epl-save-c0-financial-staff` | `CsuFinancialStaffController.saveFinancialStaff` | `SaveCsuFinancialStaffRequest` |
| `epl-save-c0-financial-evaluation-staff-fi` | `CsuFinancialEvaluationStaffFiController.saveFinancialEvaluationStaffFi`（**整個 controller 都是 staff-fi**）| `SaveCsuFinancialEvaluationStaffFiRequest` |
- 連帶：上述 method 專屬的 service / serviceImpl method、staff-only DTO、shared model 裡的 staff option 欄（00117 build 已從 FE 移除對應欄，BE 端對應清掉）。

### KEEP（business / list，**00117 FE 正在用，絕不可刪**）
- ⚠️ `CsuFinancialStaffController` **名字叫 Staff、但同時握 business＋list 方法** → **不准刪整個 controller**，只刪上面兩個 staff method：
  - `seleFinancialStaff`（`epl-sele-c0-financial-list`）— **00117 用** → KEEP
  - `getFinancialBusinessInfo`（`epl-info-c0-financial-business`）— **00117 用** → KEEP
  - `saveFinancialBusiness`（`epl-save-c0-financial-business`）— **00117 用** → KEEP
- `CsuFinancialEvaluationTableFiController` 全部（`epl-info/save-c0-financial-evaluation-table-fi`）— **00120 用** → KEEP（與 staff-fi controller 是不同檔，別搞混）。

## 步驟
1. **先查引用（read-only）**：grep 全 repo（FE + BE + route config + 測試 + OpenAPI/合約）對三個 staff 端點字串、三個 controller method、三個 staff DTO 的所有引用。**確認除了要刪的檔本身、無其他生產碼依賴**（FE 應為 0，已驗）。把結果列出來。
2. **若確認 dead** → 移除 REMOVE 清單（method + 專屬 DTO + serviceImpl 對應 + `CsuFinancialEvaluationStaffFiController` 整檔）。**不動 KEEP 清單**。
3. build 綠（**含確認前端 00117/00120 仍 build 綠**——它們依賴的 business/list/table-fi 端點未被動到）。

## 鐵則
1. **investigate-then-remove**：步驟 1 沒確認 dead 的，**不准刪**；有任何非預期引用 → 停、回報、別硬刪。
2. KEEP 清單（seleFinancialStaff / getFinancialBusinessInfo / saveFinancialBusiness / table-fi）一個都不能掉。
3. 不碰 i0、不碰 `*.individual.*`（本來就不該有）；`verify-c0` 仍應綠。
4. **單一 commit**（標 c0 staff cleanup + 移除的 3 端點）；報 diff。

## 回報
- 步驟 1 的引用查詢結果（確認三 staff 端點/method/DTO 無生產碼依賴）；
- REMOVE 實際移除清單（檔/method/DTO）+ 確認 KEEP 清單未動；
- backend build 綠 + **前端 00117/00120 build 仍綠**；
- `git status --short`（應乾淨）。

> 過了：c0 鏡像多餘物清除，Phase F c0 評分模組收得更乾淨。
