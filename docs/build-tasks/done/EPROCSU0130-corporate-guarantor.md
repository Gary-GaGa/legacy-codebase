# Build Task — `EPROCSU0130` Corporate Guarantor Info（前端收尾）

> 載具：Codex（前端專案）。**規範見 `frontend/AGENTS.md`**。
> 後端已就緒（`CsuGuarantorController`）；本頁是**前端半成品收尾**，非從零。

## 做法
- **照個金 `EPROISU0130`（Guarantor Info）** 清前端 TODO：對齊查詢/表單/表格的 config-driven 寫法（`app-search-item` + `search-item-config`、`app-table-search`、`popup-add-*` + `field-item-config`/`form-config`、`validate-rule`）。
- 先盤點現有 `EPROCSU0130` 前端完成度（哪些 TODO/缺口），對照 `EPROISU0130` 補齊差異——**非重建**。
- API 對齊後端 `CsuGuarantorController` 的 `epl-*` endpoint 與 DTO（在母資料夾啟動 Codex 可直接讀後端 DTO 對齊欄位）。

## 完成判準
- `yarn ng build` 綠（獨立終端機，Codex 勿自跑 `ng serve`/`--watch`）。
- 新檔/改檔若含中文：strict-UTF-8 + No BOM（同後端紀律）。
- 回填 `page-mapping.md` §2A 該列狀態。

## 煞車
- 若 `EPROISU0130` 與 `EPROCSU0130` 的欄位/流程有企/個金實質差異拿不準 → 停下回報，不臆測。
