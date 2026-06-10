# A-1 `funcGetExchangeRate` — 實作規格（交撥貸 domain）

> 來源：Phase D 唯讀調查（2026-06-06）。`funcGetExchangeRate` 是撥貸 authorize 總開關、金錢核心 → **由撥貸 domain 實作，非 Codex 逕補**。本檔＝可直接施工的規格 + 待裁 open questions。
> 對應 `disbursement-domain-escalations.md` **A-1**。

## 0. 兩個關鍵更正
1. 🟢 **缺口比想像小**：stub **不是空殼**——它已**讀 API key、呼叫 T24 匯率 API、寫 `TB_SVC_LOG`、更新 `TB_DISBUR_DATE`、insert `TB_EXCHANGE_RATE`**；問題只在**方法尾端無條件 `throw new UnsupportedOperationException`（`FunctionServiceImpl:1221`）、無 return**。修＝補成功/失敗分支的 return + 移除尾端 throw + 補交易一致性。
2. 🔴 **不要鏡像 `funcGetRate`**（先前誤指）：live `funcGetRate`（`individual/impl/FunctionServiceImpl:3498`）是 **scorecard 計分**（讀 `TB_SCORE_CARD_PARAM_DETAIL`、回 `GetRateResponse` 分數/風險），**與匯率無關**。要鏡像的是**舊 `EPROIS_0922` 換匯流程**。

## 1. method 合約
- 入參：`FuncGetExchangeRateRequest.applicationNo`（`@NotBlank`、max 30）。
- 回傳：成功時完成 DB side effect 後回 `new FuncGetExchangeRateResponse()`（**不回 null**）。`response` DTO 目前空殼、authorize **不依賴回傳欄位**（只靠 side effect）。
- 失敗：非 `0000` 不寫匯率、拋錯讓 authorize 停止。

## 2. 匯率來源 + request
- 外部 **T24/COMS API `KH-B-FTR37001`**；URL 由 `URIConfig.getT24Url()` 組；API key 從 `TB_SYSTEM_API`（`apiId=KH-B-FTR37001`）查。
- request body：`InquiryKey="EPRO"+yyyyMMdd`、`CcyCode="KHR"`、`ExgRateType="CURR"`、`ExgRateDateSrt=yyyyMMdd000000`、`ExgRateDateEnd=yyyyMMdd240000`、`SeqMax=1`。
- ⚠️ **`IdNo`**：舊 `EPROIS_0922_mod` 與舊 batch 都用 **`OVSLXLON01`**；新 stub 目前是 **`OVSLXLON02`** → **見 OQ-1**。

## 3. 成功 / 失敗
- 成功條件：`mwHeader.returnCode == "0000"`；取第一筆 record（`SeqMax=1`，舊碼亦 `records.get(0)`）。
- 成功寫入：
  - `TB_DISBUR_DATE`（by `APPLICATION_NO`）更新 `NEXT_KEY`、`EX_RATE_BUY`、`EX_RATE_SELL`；
  - `TB_EXCHANGE_RATE` insert `NEXT_KEY`、`END_FLAG`、`EC_RATE_TYPE`、`CCY_CODE`、`EX_RATE_BUY`、`EX_RATE_SELL`、`VALID_DATE`。
- 失敗：舊錯誤 `EPROIS0921_UI_RAET_FIND_ERROR`；新碼目前用 `ReturnEnum.FAILED_E303` → **見 OQ-3**。

## 4. rounding / 精度
- `funcGetExchangeRate` 本身**不套金額 rounding**，只存 API 回的 buy/sell。
- T24 E21 非 USD 金額才用舊語意 `Math.round(CBC_FEE * ((BUY+SELL)/2))`；**不要**套 0921 fee 的 `RoundingMode.DOWN`。
- 精度：`TB_DISBUR_DATE.EX_RATE_*` 新 entity `NUMBER(17,2)`；`TB_EXCHANGE_RATE.EX_RATE_*` `NUMBER(17,4)`；舊 DB2 scale UNKNOWN → **見 OQ-2**。

## 5. transaction（必做）
- 舊系統把 `TB_DISBUR_DATE.update` + `TB_EXCHANGE_RATE.insert` 包**同一交易**。
- 新碼 `caseIsuSummaryAuth` **無 `@Transactional`**，`DynamicUpdateSqlUtils.dynamicUpdate` 自開交易、`JpaRepository.save` 又另一交易 → **實作時至少讓這兩張表「同成同敗」，成功 commit 後才 return**。

## 6. 後續依賴 + 欄名風險
- T24 組檔主要讀 `TB_DISBUR_DATE.EX_RATE_BUY/EX_RATE_SELL`；舊 T24 spec 明確 `TB_EXCHANGE_RATE` **不被組檔直接讀取**。
- 🔴 **欄名不一致風險（連 M1/H8）**：T24 G/H 現碼讀 `EXCHANGR_RATE`（**注意拼字**），**不是本方法寫入的 `EX_RATE_BUY/SELL` 欄名** → 補完 stub 後 G/H 仍可能空值 → **見 OQ-5**。（M1 H8 還原時即沿用 `disburDate.EXCHANGR_RATE` 既有值邏輯。）

## 7. Open Questions（待裁）
| # | 問題 | owner |
|---|---|---|
| OQ-1 | `IdNo` 應改回 `OVSLXLON01` 還是新系統刻意用 `OVSLXLON02` | domain / T24 API owner |
| OQ-2 | `TB_DISBUR_DATE.EX_RATE_*` `NUMBER(17,2)` 對 API 匯率是否掉精度；調 schema 或明確 `setScale` | DBA / domain |
| OQ-3 | 非 `0000` 用 `FAILED_E303` 還是沿用舊錯誤語意（`EPROIS0921_UI_RAET_FIND_ERROR`）| backend / domain |
| OQ-4 | `callApiKHBFTR37001` catch 後回 null 的路徑是否改明確 throw（避免 NPE 被包成泛用 Authorize Fail）| backend / domain |
| OQ-5 | T24 G/H 讀 `EXCHANGR_RATE`（非本方法寫的欄名）→ 是否欄名 bug、補後仍空值 | T24 / domain |

## 8. 結論
- 修法＝**補 return + 移尾端 throw + 兩表交易一致**，並先解 OQ-1/3/4/5（多為一行決策）。
- **鏡像對象＝舊 `EPROIS_0922` 換匯流程**，**非** `funcGetRate`。
