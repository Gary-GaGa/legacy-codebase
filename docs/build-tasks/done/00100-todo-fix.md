# Build Task — `EPROZ00100` ToDo：popup 測試碼殘留＋stub 處置（F-9/F-10、DIFF-010）

> 載具：Codex（前端）。證據＝`refactor-audit/M8-z0.md`（00100/00101/00102 列）。

## 必修（F-10）
1. `00101`（刪除）/`00102`（結案）popup：`ngOnInit()` 呼叫測試用 `setReasonList()` **以硬編碼 D01–D99 覆蓋 API 回傳的 reason list** → 刪除覆蓋呼叫、保留 API 來源;確認空清單時的 fallback 行為（照既有錯誤處理慣例，不自行發明）。

## 查證＋標註（F-9，不擅自改行為）
2. `E_CREDIT_PROPOSAL` 下載走 `goPath()` 非報表服務：**確認現行為**（goPath 到哪、是否可用）;不可用→在 code 註記 `@PENDING(R2 報表服務)` 並回報，**不自行禁用或改接**。
3. upload handler console stub：同上——確認後標 `@PENDING(檔案上傳 API ⏸)`，回報現狀。

## 鐵則
只修 F-10;F-9 兩項=查證+標註+回報（R2/檔案 API 是 ⏸ 待拍板 track，行為決策不在本卡）。`ng build` 綠;一 commit;報 diff 等審。

## 回報
reason list 修復 diff;F-9 兩項現狀各一句＋@PENDING 落點;build 結果。

> 過了：reason 資料正確性恢復（Phase V 驗值）;F-9 殘餘掛在 R2/檔案 API track;回填 inventory §2E 00100。
