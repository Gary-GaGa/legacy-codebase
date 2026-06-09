# Phase F · Step 2 · 頁 4/7 — `EPROC00116` Financial Statement GI（c0 FE）

> **前置**：00112 CBC（`7e8aaf7`）、00114 Collateral Assessment（`62ec62f`）、00118 Corp Scorecard（`39e95dd`）已完成。本頁＝Step 2 第 4 頁。
> **啟動位置**：前端專案（母資料夾，可同時讀後端 c0 controller/DTO）。
> **落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `individual/credit-investigation/components/financial-statement/financial-statement-gi`，建 c0 版於
`corporate/credit-investigation/components/financial-statement/financial-statement-gi/`，改打 `-c0-` endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `00116` 從 `EmptyComponent` 換成真 component。
（`financial-statement` 下分 `-gi`/`-fi` 子夾；本頁只做 **GI**，FI 是下一頁 00119。）

## 對接 endpoint（c0 共 7 條，比照 i0 用法保留）
- `epl-sele-c0-financial-statement-comments`
- `epl-quer-c0-financial-statement-comments`
- `epl-info-c0-financial-statement-comments`
- `epl-calc-c0-financial-statement-comments`
- `epl-save-c0-financial-statement-comments`
- `epl-ppdf-c0-financial-statement-comments`（印 PDF）
- `epl-pxls-c0-financial-statement-comments`（匯 Excel）
> 對應 BE：`CsuFinancialStatementController` / `CsuFinancialStatementServiceImpl`。**讀其 DTO 對齊欄位**（c0 FinStmt 有多個 DTO，逐一對）。

## 兩個本頁重點
1. ✅ **有 calc → 保留接上**（同 00118，**不要**套 00112/00114 的隱 calc）：calc 按鈕 → `epl-calc-c0-financial-statement-comments`，回填 BE 算回的數值，FE 不自算。
2. ✅ **有 export（ppdf/pxls）→ 接上**：export 按鈕打 `epl-ppdf/pxls-c0-financial-statement-comments`。
   - ⚠️ **避免 00640 那類介面不一致**：確認 export 的 **HTTP method + blob 處理**對齊 c0 BE endpoint 簽章（別 FE POST blob 對到 BE GET）。對不上就**標出來、別硬接**。
   - export 模板是否沿用 i0（`EPROI00116`）→ 標為整合測確認點，FE 只負責正確打 endpoint。

## 鐵則
1. **對齊 c0 BE DTO**——別照抄 i0；有差標出、不硬套。
2. **清掉 copied component 內的 i0 endpoint / `*.individual.*` import / i0 spec/mock**。
3. `ng build` 綠；**單一 commit**（標 `EPROC00116` + endpoints）；報 diff。

## 回報
- diff 範圍 + 主要檔案；c0 DTO 與 i0 差異（若有）；
- **確認 calc 接上**、**export ppdf/pxls 接上且 method/blob 與 BE 一致**（或標出不一致）；
- `ng build` 結果 + 新 lazy chunk 名；`git status --short`（應乾淨）。

> 過了續 `00119` FinStmt FI（結構幾乎同本頁、改 `-cmts-fi`）；之後 staff 批 `00117/00120` **先回報 c0 staff 判定方式再動手**。
