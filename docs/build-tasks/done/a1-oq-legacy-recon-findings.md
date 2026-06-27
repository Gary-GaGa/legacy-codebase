# A-1 OQ legacy recon findings

> Scope: readonly legacy recon for `funcGetExchangeRate` open questions. This file records legacy behavior and implementation-equivalent recommendations only; it does not decide new T24 identity policy.

## OQ-1 - schema identity key

### 舊系統做法
- 舊 `EPROIS_0922_mod#getExchangeRate` 組 `KH_B_FTR37001Tranrq` 時，`InquirKey` 為 `"EPRO" + yyyyMMdd`，`IdNo` 固定為 `OVSLXLON01`，其他 request 條件為 `CcyCode=KHR`、`ExgRateType=CURR`、當日 `000000-240000`、`SeqMax=1`：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1063-1074`。
- 舊 request DTO 欄位名本身是 `InquirKey` 與 `IdNo`：`legacy-epro/JavaSource/com/cathaybk/epro/z0/dto/RESTfulService/KH_B_FTR37001/KH_B_FTR37001Tranrq.java:15-19`、`legacy-epro/JavaSource/com/cathaybk/epro/z0/dto/RESTfulService/KH_B_FTR37001/KH_B_FTR37001Tranrq.java:39-52`。
- 舊 `EPRO_Z0Z010.checkFtr37001(...)` 將 request 送往 `KH_B_FTR37001` / `GET_EXCH_RATE`，未改寫 `IdNo` 或 `InquirKey`：`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z010.java:74-79`。
- 舊 `EPRO_Z0Z009.callRESTfulService(...)` 從 options 取原 `tranrq`，塞入 `RequestTemplate` 後序列化，未改寫 `IdNo` 或 `InquirKey`：`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z009.java:72-79`。
- 舊 batch `EPROZ0_B005` 同樣組 `InquirKey="EPRO"+today`、`IdNo="OVSLXLON01"`，並呼叫同一個 `checkFtr37001`：`legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B005.java:82-91`。
- 新 stub 目前差異點是 `IdNo="OVSLXLON02"`，`InquiryKey` 仍為 `"EPRO" + yyyyMMdd`：`backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java:1173-1184`。

### 舊 named SQL
- `EPROZ0_B005.SQL_INSERT_001` 定義檔在 source/config text 內 `UNFOUND`；只找到 Java 常數本身：`legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B005.java:53`。
- batch insert 欄位以 `DataSet` 注入推斷為 `NEXT_KEY/END_FLAG/EC_RATE_TYPE/CCY_CODE/EX_RATE_BUY/EX_RATE_SELL/VALID_DATE`：`legacy-epro/JavaSource/com/cathaybk/epro/z0/batch/EPROZ0_B005.java:111-121`。

### 對等建議
- 若目標是忠實鏡像舊系統，`KH-B-FTR37001` request 應沿用 `IdNo=OVSLXLON01`、`InquiryKey=EPROyyyyMMdd`。
- 新系統是否刻意改用 `OVSLXLON02` 不可由舊碼裁定。

### 留 T24 確認點
- ✅ **owner 裁定（2026-06-16，先對齊舊系統 parity）：`IdNo=OVSLXLON01`**。原確認點降為**唯一復驗點**——若新環境 `KH-B-FTR37001` 拒收 `01`（schema-diff 證 02=新庫），改 `02` 並回填。
- （原問，留參）請 T24 owner 確認 `KH-B-FTR37001` 在新環境認可的 `IdNo` 是 `OVSLXLON01` 還是 `OVSLXLON02`，以及此值是否等同 schema/key 身份。

## OQ-3 - non-0000 failure code and message

### 舊系統做法
- 舊 `getExchangeRate` 只在 `returnCode == "0000"` 時寫匯率；非 `0000` 直接建立 `ErrorInputException`，錯誤 key 為 `EPROIS0921_UI_RAET_FIND_ERROR`，並 `throw eie`：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1074-1078`、`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1111-1114`。
- `getErrorInputException` 只把傳入字串 append 到 `ErrorInputException`，所以此處可坐實的舊錯誤識別就是 `EPROIS0921_UI_RAET_FIND_ERROR`：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1430-1435`。
- 舊 `authorize` 在 T24/SFTP 前直接呼叫 `getExchangeRate`，trx 層捕捉後回錯，不會吞錯繼續：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:985-1007`、`legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:226`、`legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:247-250`。
- `EPROIS0921_UI_RAET_FIND_ERROR` 的 localized message text 在 source/config text 內 `UNFOUND`；搜尋 `legacy-epro/JavaSource/i18n`、`legacy-epro/WebContent` 及 Java source 只找到上述拋錯點。

### 對等建議
- 新碼不應用泛用 `ReturnEnum.FAILED_E303` 取代舊語意，除非 domain 明確裁定。
- 建議新增或映射一個等價錯誤語意：`EPROIS0921_UI_RAET_FIND_ERROR` / "exchange rate lookup failed"，並保留非 `0000` 中止 authorize 的行為。

## OQ-4 - callApi exception / timeout behavior

### 舊系統做法
- `EPRO_Z0Z010.checkFtr37001(...)` 宣告 `throws Exception`，直接 return `EPRO_Z0Z009.callRESTfulService(...)`，沒有吞錯：`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z010.java:74-79`。
- `EPRO_Z0Z009.callRESTfulService(...)` 也宣告 `throws Exception`；HTTP/HTTPS post 與 JSON 解析位於 try-catch 外，發生 exception 或 timeout 會往外拋：`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z009.java:65-116`。
- 舊 API 層唯一吞掉的是 `TB_SVC_LOG` insert 失敗，會 rollback log transaction 後繼續回傳已取得的 response；這不是 callApi 失敗路徑：`legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z009.java:134-142`。
- 舊 `EPROIS_0922_mod.authorize(...)` 直接呼叫 `getExchangeRate(APPLICATION_NO)`，沒有 catch 後繼續組 T24：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:985-1007`。
- trx 層 `doAuthorize` 捕捉 exception 後回 AJAX error，不會讓 authorize 後段繼續完成：`legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:221-227`、`legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:247-250`。
- 新 stub 目前先設 `response = null`，catch 後只 log/print stack trace，最後 `return response`，因此 exception/timeout 會回 `null` 給呼叫端；呼叫端隨後直接解參考 `result.getMwHeaderResponse()` / `result.getTranRs()`：`backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java:1184-1188`、`backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java:1237-1240`、`backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java:1250-1265`。

### 對等建議
- 新 `callApiKHBFTR37001` catch 應明確 throw `EPROApiException` 或等價 checked failure，不應吞掉後回 null。
- `funcGetExchangeRate` 應讓 API exception/timeout 中止 authorize，避免 NPE 被包成泛用 Authorize Fail，也避免錯誤後續組 T24/SFTP。

## OQ-5 - exchange-rate column name used by T24 composition
> ✅ **已修（2026-06-16，product `581e717`）**：`SummaryServiceImpl:2223` G/H `EXCHANGR_RATE`→`EX_RATE_BUY`（卡 `done/0922-t24-exchrate-colname-fix.md`）。下列為原 recon 證據。

### 舊系統做法
- 舊 `getExchangeRate` 成功後寫 `TB_DISBUR_DATE.EX_RATE_BUY/EX_RATE_SELL` 與 `TB_EXCHANGE_RATE.EX_RATE_BUY/EX_RATE_SELL`：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1085-1106`。
- 舊 `TB_DISBUR_DATE` DAO 欄位清單包含 `EX_RATE_BUY/EX_RATE_SELL/NEXT_KEY`，沒有 `EXCHANGR_RATE`：`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_DISBUR_DATE.java:42-47`。
- 舊 `TB_EXCHANGE_RATE` DAO 欄位清單包含 `EX_RATE_BUY/EX_RATE_SELL/VALID_DATE`，沒有 `EXCHANGR_RATE`：`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_EXCHANGE_RATE.java:47-57`。
- 舊 T24 E 段 `createTransferE` 讀 `TB_DISBUR_DATE.EX_RATE_BUY/EX_RATE_SELL`，非 USD 時用 `(BUY+SELL)/2` 計 CBC fee：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:812-822`、`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:931-940`。
- 舊 T24 G 段 `createTransferGitem` 對非 USD 讀 `TB_DISBUR_DATE.EX_RATE_BUY`，並放入第 10 欄牌告匯率：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:1063-1080`、`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:1088-1096`。
- 舊 T24 H 段 `createTransferH` 對非 USD 讀 `TB_DISBUR_DATE.EX_RATE_BUY`，並放入第 8 欄牌告匯率：`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:1128-1139`、`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java:1151-1166`。
- 新 `funcIsuT24Authorize` 的 E 段等價處已讀 `EX_RATE_BUY/EX_RATE_SELL`：`backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:2146-2161`。
- 新 G/H 對應處卻讀 `EXCHANGR_RATE`：`backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:2221-2224`、`backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:2285-2288`。
- 新 entity 也只映射 `EX_RATE_BUY/EX_RATE_SELL`：`backend/src/main/java/khd/svc/epro/entity/TBDisburDateEntity.java:66-70`。
- 舊/新 DB 實查輸出都沒有 `TB_DISBUR_DATE.EXCHANGR_RATE`，實欄為 `EX_RATE_BUY/EX_RATE_SELL`：`<epro-db>/out/columns_old_OVSLXLON01.psv:1244-1245`、`<epro-db>/out/columns_new_OVSLXLON02.psv:939-940`。

### 舊 named SQL
- `EPRO_TB_DISBUR_DATE.SQL_UPDATE_001` 與 `EPRO_TB_EXCHANGE_RATE.SQL_INSERT_001` SQL 定義檔在 source/config text 內 `UNFOUND`；只找到 DAO 常數：`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_DISBUR_DATE.java:35`、`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_EXCHANGE_RATE.java:34`。
- 欄位推斷來自 DAO `fieldNames_*` 與呼叫端 map/DataSet 注入：`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_DISBUR_DATE.java:42-47`、`legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_EXCHANGE_RATE.java:47-57`、`legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java:1093-1106`。

### 對等建議
- `EXCHANGR_RATE` 應視為 typo / legacy parity bug；舊系統 T24 G/H 正確欄名是 `EX_RATE_BUY`。
- 新碼 G/H 應改讀 `disburDate["EX_RATE_BUY"]`；E 段維持 `EX_RATE_BUY/EX_RATE_SELL` 算中價。
- `TB_EXCHANGE_RATE` 是匯率落表紀錄；T24 組檔直接來源是 `TB_DISBUR_DATE.EX_RATE_BUY/EX_RATE_SELL`。