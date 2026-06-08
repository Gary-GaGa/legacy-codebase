# Phase F · Step 2 · 頁 5/7 — `EPROC00119` Financial Statement FI（c0 FE）

> **前置**：00112/00114/00118/00116 已完成。本頁＝Step 2 第 5 頁，**結構幾乎同 00116 GI**——最近的範本就是你剛做的 c0 `financial-statement-gi`。
> **啟動位置**：前端專案（母資料夾）。**落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `financial-statement/financial-statement-fi`（或直接照剛建好的 c0 `financial-statement-gi` 改），建 c0 版於
`corporate/credit-investigation/components/financial-statement/financial-statement-fi/`，改打 `-cmts-fi` endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `00119` 從 `EmptyComponent` 換成真 component。

## 對接 endpoint（c0 FinStmt FI；⚠️ **無 sele**）
- `epl-quer-c0-financial-statement-cmts-fi`
- `epl-info-c0-financial-statement-cmts-fi`
- `epl-calc-c0-financial-statement-cmts-fi`
- `epl-save-c0-financial-statement-cmts-fi`
- `epl-ppdf-c0-financial-statement-cmts-fi`（印 PDF）
- `epl-pxls-c0-financial-statement-cmts-fi`（匯 Excel）
> 對應 BE：`CsuFinancialStatementCmtsFiController`。**讀其 DTO 對齊欄位**。

## 沿用 00116 的兩個已驗做法
1. ✅ **calc 保留接上** `epl-calc-c0-financial-statement-cmts-fi`，FE 只送欄位、回填 BE response，不自算。
2. ✅ **export = POST blob 兩邊一致**：比照 00116——BE 是 POST + `@RequestBody` + `ResponseEntity<byte[]>`，FE 用 `apiPostRequestForBlob()` / `responseType:'blob'`。**沿用 00116 已加進 `report.service.ts` 的方法**（不要再改 i0 既有行為）。

## 鐵則
1. **對齊 c0 BE DTO**（FI 與 GI 的 DTO 可能有差，逐一對；移除 c0 不收的欄位如 isQuery）。
2. **清掉 copied component 內的 i0 endpoint / `*.individual.*` import / i0 spec/mock**。
3. `ng build` 綠；**單一 commit**（標 `EPROC00119` + endpoints）；報 diff。

## 回報
- diff 範圍 + 主要檔案；c0 FI DTO 與 GI/i0 差異；
- **確認 calc 接上 + export POST-blob 一致**；
- 若再動到共用 `report.service.ts`，確認是**加法、無 i0 回歸**；
- `ng build` + 新 chunk 名；`git status --short`（應乾淨）。

> 過了僅剩 **staff 批 `00117` / `00120`**——這兩頁動手前**先回報 c0 怎麼判 staff vs business**（容器無 `isStaffLoan`、BE 有 staff 概念），我看過再給 prompt。
