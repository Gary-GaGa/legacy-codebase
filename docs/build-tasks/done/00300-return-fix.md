# Build Task — `EPROZ00300` Document Checklist：FE return 成功導回（修復；DIFF-011/00300-recon）

> ✅ **完成（2026-06-15，審過）**：product `40d931c`（單檔 `shared.service.ts:149`）。實作共用 `goPreviousPage()`＝既有 `addContentOnly('/to-do-list')`+`router.navigate`；Document Checklist return callback 生效。backend 零改、ng build 綠。⚠️ **Phase V 驗**：共用方法由 no-op→一律回 ToDo，連帶 Related Party/Revised Item 三呼叫端語意確認；日後要回原入口再加 `originPage` 分流（sub-agent 已標）。DIFF-011 收。

> 載具：Codex（前端為主）。**依據＝`done/00300-return-recon.md` + `00300-return-recon-findings.md`**：return 後端 side effects 已坐實舊有新無（非缺陷）；**真缺口＝FE `goPreviousPage()` 為 TODO/no-op**——舊系統 return 成功後 submit back `EPROZ0_0100/prompt`（導回 ToDo 清單），新碼按了 return、後端有寫，但畫面停在原頁。

## 目標
補 FE return 成功後的**導回行為**，對齊舊系統「回 ToDo」。改完 `ng build` 綠、一 commit、報 diff 等審。

## 步驟
1. **查既有導回慣例先**：repo 內其他頁「動作成功後導回上一頁/ToDo」怎麼做的（router 導回、`sharedService` 既有方法、ToDo 頁路由 token）——**鏡像既有慣例，勿自創**；附 `file:line`。
   - `sharedService.goPreviousPage()`（`shared.service.ts:146`）是現成掛點：實作它 or 改呼叫既有導回方法，二擇一以「與其他頁一致」為準。
2. **實作導回**：return 成功 callback（`document-checklist.component.ts:300/306`）→ 導回 ToDo（舊 `EPROZ0_0100`＝新對應 ToDo 頁路由）。確認 success toast/狀態與其他動作頁一致。
3. 若 `goPreviousPage()` 被多頁共用 → **改它要回歸其他呼叫端**（grep 呼叫點，逐一確認不破壞）；只此頁要特殊行為則本頁自處理、不動共用方法。

## 範圍外（OUT，留 owner/Phase V，**勿在本卡動**）
- 後端 return 行為（已坐實非缺陷，一行不改）。
- 新多寫 `APP_HISTORY=98`、branch-vs-dept、權限/錯誤訊息等價（findings UNFOUND 節）——**待產品/資料列裁定**，非本卡。

## 鐵則
1. 後端**一行不改**。
2. 導回方式鏡像既有慣例（與其他動作頁一致），勿自創 router 流。
3. `goPreviousPage()` 若共用 → 改完回歸所有呼叫端；`ng build` 綠。

## 回報
- commit hash＋落點；導回實作方式一句＋（若動共用方法）回歸聲明；`ng build` 結果；產品 repo backend `git diff` 空證據。

> 過了：inventory §2E `00300` FE 升 ✅、DIFF-011 收；Phase V 實測「return→導回 ToDo」。
