# Phase F · Step 2 · 頁 2/7 — `EPROC00114` Collateral Assessment（c0 FE）

> **前置**：00112 CBC 已完成（`7e8aaf7`）。本頁＝Step 2 第 2 頁。
> **啟動位置**：前端專案（母資料夾，可同時讀後端 c0 controller/DTO）。
> **落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `individual/credit-investigation/components/collateral-assessment`，建 c0 版於
`corporate/credit-investigation/components/collateral-assessment/`，改打 `-c0-` endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `00114` 從 `EmptyComponent` 佔位換成真 component。

## 對接 endpoint（只保留這些）
- `epl-sele-c0-collateral-assessment`
- `epl-info-c0-collateral-assessment`
- `epl-save-c0-collateral-assessment`
> 對應 BE：`CsuCollateralAssessmentController` / `CsuCollateralAssessmentServiceImpl`。**讀其 DTO 對齊欄位**。

## 鐵則
1. **對齊 c0 BE DTO**——別照抄 i0 DTO；c0 可能有更嚴的 `@NotNull` 或欄位差異（00112 即如此）。有差**標出來、不硬套**。
2. **清掉 copied component 內的 i0 endpoint / `*.individual.*` import**（比照 00112）。
3. ⚠️ **不要捏造打 i0 endpoint**：若 i0 collateral-assessment 用到 c0 **沒有**的 endpoint（如某個 `calc`/`comm`/`sele` i0 專屬），**不要改打 `*-i0-*`**——改本地處理或省略,並在回報標出（同 00112「c0 無 calc → 本地加總」的處理原則）。
4. `ng build` 綠；**單一 commit**（message 標 `EPROC00114` + 對接 endpoint）；報 diff。

## Watch
- collateral-assessment 通常會引用案件的擔保品資料——確認 c0 的資料來源/欄位是從 `epl-*-c0-collateral-assessment` 來，**不要混到 corporate 既有的 `collateral-provider` 基本頁**（那是不同頁）。
- 若 i0 版有評分/計算邏輯（assessment 分數），確認 c0 是 BE 算（save 回傳）還是 FE 算；以 c0 BE 行為為準。

## 回報
- diff 範圍 + 主要檔案路徑；
- c0 DTO 與 i0 的差異（若有）；
- 有沒有「i0 有、c0 無」的 endpoint 而你改成本地/省略的決策；
- `ng build` 結果 + 新 lazy chunk 名；
- `git status --short`（應乾淨）。

> 過了我就給下一頁（建議續：`00118` Corp Scorecard → `00116` FinStmt GI → `00119` FinStmt FI；**staff 批 00117/00120 先回報 c0 staff 判定方式再動手**）。
