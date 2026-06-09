# Phase F · Step 2 — c0 企金評分前端：其餘 7 子頁（FE build）

> **前置**：Step 1 已完成（c0 容器 BE 驅動動態 tab + `00115` BGE pilot，`ng build` 綠）。本步補完其餘 7 子頁。
> **啟動位置**：前端專案（母資料夾啟動，可同時讀後端 c0 controller/DTO）。
> **落地**：master-direct；**每子頁各自 commit、`ng build` 綠、報 diff 等審**（低風險但金融頁，逐頁過）。

---

## 目標
照 i0 `individual/credit-investigation` 對應子頁**鏡像**，建 c0 版於
`frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/<name>/`，
改打 `-c0-` endpoint、**欄位對齊 c0 BE DTO**。c0 **無 00111 / 00113 → 不建**。
（目前這 7 頁在 c0 nav config 是 `EmptyComponent` 佔位，本步換成真 component。）

## 子頁對照表
| 子頁 | 鏡像 i0 component | 對接 c0 endpoint | 對應 c0 BE controller（讀其 DTO）|
|---|---|---|---|
| 00112 CBC | `components/banking-relationship` | `epl-{info/save}-c0-cbc-banking-relationship` | `CbcBankingCorpRelationshipController` |
| 00114 Collateral Assessment | `components/collateral-assessment` | `epl-{sele/info/save}-c0-collateral-assessment` | `CsuCollateralAssessmentController` |
| 00116 FinStmt GI | `components/financial-statement/financial-statement-gi` | `epl-*-c0-financial-statement-comments` | `CsuFinancialStatementController` |
| 00117 FinEval GI | `components/financial-evalutaion-gi`（+staff variant）| `epl-{info/save}-c0-financial-{staff/business}`、`epl-sele-c0-financial-list` | `CsuFinancialStaffController` |
| 00118 Corp Scorecard | `components/corporate-scorecard` | `epl-{sele(-list)/info/calc/save}-c0-corporateScorecard` | `CsuCorporateScorecardController` |
| 00119 FinStmt FI | `components/financial-statement/financial-statement-fi` | `epl-*-c0-financial-statement-cmts-fi` | `CsuFinancialStatementCmtsFiController` |
| 00120 FinEval FI | `components/financial-evaluation-fi`（+staff-fi save）| `epl-{info/save}-c0-financial-evaluation-table-fi`、`epl-save-c0-financial-evaluation-staff-fi` | `CsuFinancialEvaluationTableFiController`、`CsuFinancialEvaluationStaffFiController` |

## 鐵則（每一子頁都遵守）
1. **讀對應 c0 BE controller 的 DTO 對齊欄位**——**別照抄 i0 DTO**，c0 可能有差（Step 1 已證容器 DTO 不同）。有差異**標出來、不硬套**。
2. 各自 `ng build` 綠。
3. **一子頁一 commit**（commit message 標 funcId + 對接 endpoint）。
4. **報 diff 給我逐頁審**，過了才下一頁。

## Watch-points
1. 🔑 **staff variant（00117 / 00120）— 動手前先查、先回報**：i0 用 `creditInvestigationNav(isStaffLoan)` 驅動 FinEval staff 版；但 **c0 容器 DTO 沒有 `isStaffLoan`**，而 c0 BE 有 staff 概念（`CsuFinancialStaffController`、`epl-save-c0-financial-evaluation-staff-fi`、00117 sele 用 `funcIsStaffLoan`）。→ **先查清 c0 怎麼分 staff vs business**（BE 在 financial endpoint 回傳帶旗標？還是另打 `funcIsStaffLoan`？），**回報後我看過再動手做 00117/00120 的 staff 版**。判不準就停手，別硬套 i0 的 isStaffLoan。
2. **G/F 切換要實跑驗證**：容器依 BE `pageMap` 顯隱（G→移除 00119/00120、F→移除 00116/00117）。Step 1 用 EmptyComponent 測不到；**等 00116/117/119/120 真元件就緒，實跑一次 G/F 切換確認顯示/隱藏正確**。
3. **結構**：`financial-statement` GI/FI 在同資料夾下分 `-gi`/`-fi` 子夾；`00120` = `table-fi` + `staff-fi` save 兩塊。
4. export（00116/00119 的 pdf/xls）模板沿用 i0 是否可接受 → 標為整合測確認點，不在本步糾結。

## 建議順序（先非-staff、後 staff）
1. **非 staff 批**：`00112` CBC → `00114` Collateral Assessment → `00118` Corp Scorecard → `00116` FinStmt GI → `00119` FinStmt FI。
2. **staff 批**（先回報 staff 判定方式）：`00117` FinEval GI → `00120` FinEval FI。
3. 全部就緒後實跑 G/F 切換（watch-point 2），回報整體 `ng build` + lazy chunk 清單。
