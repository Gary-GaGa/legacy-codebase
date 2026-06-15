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

## 執行結果（2026-06-15）

### as-is 坐實
- **BE（pre-fix baseline：`97096be`）**：`SearchController.getSearchOptions` 是 `@RequestMapping(value = "/epl-case-search-options", method = RequestMethod.GET)`，但參數仍是 `@Validated @RequestBody SearchOptionsRequest request`（`97096be:backend/src/main/java/khd/svc/epro/controller/common/SearchController.java:37-38`）。
- **FE（pre-fix baseline：`97096be`）**：Search service 以 GET 呼叫 `epl-case-search-options`，且透過 `apiGetRequestWithBody(..., postData)` 帶 body（`97096be:frontend/src/app/pages/search/service/api.service.ts:23-31`）；頁面載入只提供 `langType`（`97096be:frontend/src/app/pages/search/search.component.ts:272-276`）。
- **舊系統語意**：`EPROZ0_0600/doInitQuery` 是頁面初始化下拉 action，直接呼叫 `new EPROZ0_0600_mod().initQuery()`，不讀 request 查詢條件（`legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:91-97`）；`initQuery()` 只用 `LocaleUtil.getCurrentLocale()` 與固定條件取下拉/預設日期（`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0600_mod.java:93-115`）。主查詢才走 `query(VOTool.requestToMap(req), user)`（`legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:128-137`）。

### 修復方向
- search-options 維持 **GET 無 body**。
- `langType` 改走 query string，BE 以 `@ModelAttribute SearchOptionsRequest` 綁定；主查詢 `/epl-list-search` 維持 POST body，不波及。
- grep 確認 `SearchOptionsRequest` 的有效 caller 僅 Search controller/service/test 與 Search FE service；無其他 caller 依賴 GET body。

### 變更
- `SearchController.getSearchOptions`：移除 `@RequestBody`，改 `@ModelAttribute`。
- `frontend/src/app/pages/search/service/api.service.ts`：由 `apiGetRequestWithBody` 改為 `apiGetRequest("epl-case-search-options?langType=...")`。
- `SearchControllerTest`：改測真正的 GET query param，並驗證 service 收到相同 `langType`。
- `verification-handoff.md §6.1`、`feature-inventory.md` 已回填 00600 runtime ✅ 與 sweep① follow-up。

### 驗證
- `mvn -Dtest=SearchControllerTest test`：PASS。
- `mvn clean package`：命令 wrapper 5 分鐘 timeout，但 Maven/Surefire process 後續完成；`backend/build/epro-svc.jar` 於 2026-06-15 14:41 產出，`build/surefire-reports` 全部 `Failures: 0, Errors: 0`。
- `mvn -DskipTests package`：BUILD SUCCESS。
- `node v16.20.2` + `node_modules/.bin/ng.cmd build`：PASS；首次 sandbox 內因 `esbuild-wasm spawn EPERM` 失敗，提升權限重跑成功。保留既有 bundle budget/CUB selector warnings。
