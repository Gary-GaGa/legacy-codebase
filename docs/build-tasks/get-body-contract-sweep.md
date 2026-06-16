# Build Task — GET 端配 request body 契約 盤點＋修（Phase V 橫向 sweep；RV-1 起）

> **進度（盤點 06-15＋部分修 06-16，審過）＝3 處**（FE 無直接 `apiGetRequestWithBody`，但 2 處 `apiGetRequestForBlob` GET-body 等價）：
> - ✅ **#1/#2 scorecard export pdf/excel 已修**（`ScorecardReportController:55/73` 改 POST、FE `apiPostRequestForBlob`、`@RequestBody` 保留，product `751f78f`）。
> - ⏸ **#3 `epl-case-query-reviseditem`（`RevisedItemController:38`）=00800 init-query → SRS `@PENDING RP9`**：待全站 `epl-*` method 慣例 grep 坐實→RD/架構裁 RP9，**不逕改**。**本卡因 #3 續留 live**。00600 為已修樣板。

> 載具：Codex（母資料夾，FE+BE+legacy-epro 唯讀對照）。**性質＝橫向 sweep**：先盤點同型、再批量修。
> **背景**：Phase V 坐實 Search（`EPROZ00600`）E999＝**GET endpoint 配 `@RequestBody`**（`getSearchOptions`：`@RequestMapping(GET)` + 參數 `@RequestBody` → 請求無 body 必拋 `HttpMessageNotReadableException`）。成因＝sweep① `48e687f`「FE→GET 對齊 BE」**只改 method、body/binding 沒對齊**；FE 端對應徵狀＝以 `apiGetRequestWithBody`（GET 帶 body）呼叫。已修範例＝`done/00600-search-options-fix.md`（BE `@RequestBody`→`@ModelAttribute`、FE 改 `?param=`）。
> **目的**：回答「**還有多少處同型殘留**」——產盤點清單（＝更動範圍）＋分類＋批量修。

## 步驟
### A. 盤點（grep，只報不改）
1. **FE**：所有 `apiGetRequestWithBody`（或等價「GET 帶 body」呼叫）的呼叫點——逐處 `file:line` + 打哪個 endpoint。
2. **BE**：所有 `@GetMapping` / `@RequestMapping(method=GET)` 的 handler 參數含 `@RequestBody`——逐處 `file:line`。
3. **交叉**：FE GET-body 呼叫 ↔ BE GET handler 配對，標出「body missing 風險」的 endpoint（即 RV-1 同型）。

### B. 分類（每處）
- **語意該帶查詢條件** → 走 **POST body**：FE 改帶 body 的 POST、BE 維持 `@RequestBody` 但 method 改 POST。
- **無需 body／輕參數** → 走 **GET query**：BE `@RequestBody`→`@ModelAttribute`/`@RequestParam`、FE 改 query string（同 00600 修法）。
- **方向以舊系統／語意定，不猜**；附依據 `file:line`。

### C. 清單＋修
- 產表：`endpoint ↔ FE 呼叫位置 ↔ BE handler 位置 ↔ method/binding 現況 ↔ 舊版語意 ↔ 修法（POST body / GET query）`。findings 寫本資料夾新檔 `get-body-contract-sweep-findings.md`。**先報清單給人審，不批量改。**
- 審過後批量修；`00600` 已修為樣板。

## 鐵則
1. **先盤點報清單、不亂改**；修向以語意/舊系統定（00600 範例：search-options 無需 body→GET query）。
2. 同 controller 其他 endpoint 不誤動；改 BE 簽名先 grep 其他 caller。
3. 每修一處 `mvn`／`ng build` 綠；FE 該功能回歸。
4. 主查詢類（本就該 POST body）維持不動，別誤改成 GET。

## 回報
- 盤點清單（= 同型殘留數）＋分類；舊版/語意依據；修了哪些（commit hash）；build 結果。

> 過了：GET-body 契約 regression 全收；回填 handoff §6 + 各頁 `feature-inventory.md`；sweep① 對齊**徹底**補完註記。
