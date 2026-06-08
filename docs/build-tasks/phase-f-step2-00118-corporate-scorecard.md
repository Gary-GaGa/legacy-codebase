# Phase F · Step 2 · 頁 3/7 — `EPROC00118` Corporate Scorecard（c0 FE）

> **前置**：00112 CBC（`7e8aaf7`）、00114 Collateral Assessment（`62ec62f`）已完成。本頁＝Step 2 第 3 頁。
> **啟動位置**：前端專案（母資料夾，可同時讀後端 c0 controller/DTO）。
> **落地**：master-direct；**單一 commit、`ng build` 綠、報 diff 等審**。

## 目標
鏡像 i0 `individual/credit-investigation/components/corporate-scorecard`，建 c0 版於
`corporate/credit-investigation/components/corporate-scorecard/`，改打 `-c0-` endpoint、對齊 c0 BE DTO。
把 c0 nav config 的 `00118` 從 `EmptyComponent` 換成真 component。

## 對接 endpoint（只保留這些）
- `epl-sele-c0-corporateScorecard-list`
- `epl-info-c0-corporateScorecard`
- `epl-calc-c0-corporateScorecard`
- `epl-save-c0-corporateScorecard`
> 對應 BE：`CsuCorporateScorecardController` / `CsuCorporateScorecardServiceImpl`。**讀其 DTO 對齊欄位**。

## ⚠️ 與前兩頁的關鍵差別：這頁 **有 calc**
- 00112/00114 沒有 c0 calc endpoint，所以隱了 calc。**00118 有 `epl-calc-c0-corporateScorecard`** → **Calculate 按鈕要保留、正常接上 c0 calc**，**不要**套前兩頁的「隱 calc / no-op」。
- i0 calc 是把 22 欄 request 餵進 BE 算分（BE 端注入 scorecard 計分邏輯）；FE 只負責**收齊欄位 → 打 c0 calc → 顯示回傳分數/等級**。FE **不要**自己重算分數。

## 鐵則
1. **對齊 c0 BE DTO**——別照抄 i0 DTO；欄位/必填以 c0 為準，有差標出來、不硬套。
2. **清掉 copied component 內的 i0 endpoint / `*.individual.*` import / i0 spec/mock**。
3. `ng build` 綠；**單一 commit**（message 標 `EPROC00118` + 對接 endpoint）；報 diff。

## 知會（FE 不處理、但別誤踩）
- 00118 BE 有 2 條既有 escalation（CU-return checkpoint、`crScoreCardCompleted` 整欄覆寫）——那是 **BE/domain** 的事、**FE 不碰**；FE 只照 endpoint 串接即可，別試圖在前端補償那些行為。

## 回報
- diff 範圍 + 主要檔案；
- c0 DTO 與 i0 差異（若有）；
- **確認 Calculate 按鈕已接上 c0 calc、且能顯示回傳分數/等級**；
- `ng build` 結果 + 新 lazy chunk 名；
- `git status --short`（應乾淨）。

> 過了我就給下一頁（續：`00116` FinStmt GI → `00119` FinStmt FI；**這兩頁也有 calc，保留**。staff 批 `00117/00120` 先回報 c0 staff 判定方式再動手）。
