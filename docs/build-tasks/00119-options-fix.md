# Build Task — `EPROC00119` FinStmt FI：FE 空 select options 修復（F-8/DIFF-008）

> 載具：Codex（前端）。證據＝`refactor-audit/M7b-c0-00116-00120-rest.md`（0119/0219 列）：FE `getMenu()` 回空 `currencyList`/`currencyUnitList`/`typeOfYearList`，但必填 select 欄位（field-item-config）有消費 → 下拉空、表單填不了。疑誤套 00120 的「不接 options」模式（00120 頁不消費、00119 有消費）。

## 步驟
1. **先查證再修**：確認 options 是否由 info 回應另路供給（component 是否從 `epl-info-...-cmts-fi` 取 options）——是→FE 改吃該路、關此案;否→步驟 2。
2. 對照 `00116` GI 的 `getMenu()` 實作（同型頁、options 有接），把 00119 的 menu 來源接回對應 BE 端點;DTO 以 BE 為準。
3. `ng build` 綠;一 commit;報 diff 等審。

## 回報
查證結論（哪一路供給）;diff;build 結果;Phase V 補實測（下拉有值＋save 帶值）。

> 過了：回填 inventory §2D 00119 FE → ✅;本卡進 `done/`。
