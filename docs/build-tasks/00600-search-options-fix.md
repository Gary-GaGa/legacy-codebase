# Build Task — `EPROZ00600` Search：getSearchOptions body missing 修復（Phase V runtime finding）

> 載具：Codex（母資料夾，FE+BE+legacy-epro 唯讀對照）。**性質＝runtime bug 坐實+修**。
> **發現（2026-06-15 Phase V 本機）**：AO 帳號登入打開 Search 頁即噴 **E999**。後端 stack trace：
> ```
> Required request body is missing: SearchController.getSearchOptions(SearchOptionsRequest)
> org.springframework.http.converter.HttpMessageNotReadableException
> ```
> Search 頁載入時打 `getSearchOptions`（拿篩選下拉選項），請求**無 body**，但 BE 參數被當 `@RequestBody`（required）→ 拋例外 → 前端 E999、整頁掛。
> **疑 regression**：sweep① `48e687f`「00600 search-options FE→GET 對齊 BE」——疑當時把 method 改 GET、但 BE 的 `@RequestBody` 殘留 → GET 無 body + `@RequestBody` 必爆。

## 步驟（坐實→修）
1. **BE as-is**：`SearchController.getSearchOptions` 的 mapping annotation（`@GetMapping`/`@PostMapping`/`@RequestMapping`）＋參數 annotation（是否 `@RequestBody SearchOptionsRequest`）；附 `file:line`。
2. **FE as-is**：Search 頁 service 怎麼呼叫 getSearchOptions——GET 還是 POST、有無帶 body；附 `file:line`。
3. **舊系統/語意**：search-options 是「載入頁面下拉選項」——判定它**該不該帶參數**：
   - 無參數（多數情況）→ **GET 無 body**：BE 拿掉 `@RequestBody`，參數改 query 綁定（`@ModelAttribute`/`@RequestParam`）或若真無參則移除參數；FE 維持 GET。
   - 需帶查詢條件 → **POST 帶 body**：FE 改回帶 body 的 POST；BE 維持 `@RequestBody`。
   - **方向以舊系統 + 同頁其他 search 動作的慣例為準，勿猜**；附依據。
4. 修最小、其他 search 動作（主查詢/匯出）**不波及**；`mvn` + `ng build` 綠；一 commit。

## 鐵則
1. 方向以語意/舊系統定，不猜；GET↔@RequestBody 矛盾是本 bug 核心，修到「method 與 body 契約一致」。
2. 同 controller 其他 endpoint 不誤動；FE 其他 search 功能回歸。
3. 若改 BE，確認沒有其他 caller 依賴舊簽名（grep）。

## 回報
- BE/FE/舊系統三方 as-is 結論＋選定修復方向＋依據；diff；mvn/ng build 結果；commit hash。

> 過了：Search 頁可載入；回填 `verification-handoff.md §6`、`feature-inventory.md`（00600 runtime ✅）；sweep① 對齊補完註記。
