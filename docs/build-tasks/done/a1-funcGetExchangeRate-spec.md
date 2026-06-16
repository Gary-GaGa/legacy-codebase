# A-1 `funcGetExchangeRate` — 實作規格（交撥貸 domain）

> ✅ **已實作＋spec-conformance PASS（product `daae4c3`，2026-06-16，mvn 綠）**：Codex 唯讀碼驗 4/4 PASS（file:line）：
> - **OQ-1** `IdNo=OVSLXLON01` ✅ `FunctionServiceImpl:1181`
> - **OQ-3** 非 0000 拋錯＋authorize 中止（T24 前）✅ `FunctionServiceImpl:1222`、`SummaryServiceImpl:2324/2326/2370/2371`；**錯誤碼＝`FAILED_E304`**（新系統專屬代碼，非 recon 警告的泛用 `E303`；語意對等舊 `EPROIS0921_UI_RAET_FIND_ERROR`）
> - **OQ-4** callApi catch 明確 throw＋null guard throw、唯一成功出口 return ✅ `FunctionServiceImpl:1262/1264/1267/1268/1271`
> - **§5 交易** `TB_DISBUR_DATE.update`＋`TB_EXCHANGE_RATE.insert` 同一 `@Transactional` ✅ `FunctionServiceImpl:1156/1204/1218`、`DynamicUpdateSqlUtils:27`（REQUIRED）
>
> 本檔保留為**規格＋conformance 記錄**（隨 A-1 收 `done/`）。撥貸端到端真完成另需 T24 正確性＋批次層（F-OWN-1/AUD-10）。OQ-5 G/H 欄名 bug 另已修 `581e717`。

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
- ✅ **`IdNo`＝`OVSLXLON01`**（owner 裁定 2026-06-16：撥貸 outbound 參數**先對齊舊系統 parity**）：舊 `EPROIS_0922_mod`＋舊 batch 皆 `OVSLXLON01`；新 stub 現 `OVSLXLON02` → **改回 `OVSLXLON01`**。⚠️ schema-diff 證據（01=舊 app schema、02=新 app schema）略偏「02 為新環境刻意」，故定性「先固定 parity」，**唯一復驗點＝若新環境 T24 拒收 `01`**（見 §7 OQ-1）。

## 3. 成功 / 失敗
- 成功條件：`mwHeader.returnCode == "0000"`；取第一筆 record（`SeqMax=1`，舊碼亦 `records.get(0)`）。
- 成功寫入：
  - `TB_DISBUR_DATE`（by `APPLICATION_NO`）更新 `NEXT_KEY`、`EX_RATE_BUY`、`EX_RATE_SELL`；
  - `TB_EXCHANGE_RATE` insert `NEXT_KEY`、`END_FLAG`、`EC_RATE_TYPE`、`CCY_CODE`、`EX_RATE_BUY`、`EX_RATE_SELL`、`VALID_DATE`。
- 失敗：舊錯誤 `EPROIS0921_UI_RAET_FIND_ERROR`；新碼目前用 `ReturnEnum.FAILED_E303` → **見 OQ-3**。

## 4. rounding / 精度
- `funcGetExchangeRate` 本身**不套金額 rounding**，只存 API 回的 buy/sell。
- T24 E21 非 USD 金額才用舊語意 `Math.round(CBC_FEE * ((BUY+SELL)/2))`；**不要**套 0921 fee 的 `RoundingMode.DOWN`。
- 精度：✅ **已關（06-12 舊庫 DDL 實查）**——舊 `TB_DISBUR_DATE.EX_RATE_*`＝`NUMBER(17,2)`、`TB_EXCHANGE_RATE.EX_RATE_*`＝`NUMBER(17,4)`，與新 entity 完全一致，無精度落差（OQ-2 銷案）。另實查舊 `TB_EXCHANGE_RATE` 欄＝`NEXT_KEY/END_FLAG/EC_RATE_TYPE/CCY_CODE/EX_RATE_BUY/EX_RATE_SELL/VALID_DATE`。

## 5. transaction（必做）
- 舊系統把 `TB_DISBUR_DATE.update` + `TB_EXCHANGE_RATE.insert` 包**同一交易**。
- 新碼 `caseIsuSummaryAuth` **無 `@Transactional`**，`DynamicUpdateSqlUtils.dynamicUpdate` 自開交易、`JpaRepository.save` 又另一交易 → **實作時至少讓這兩張表「同成同敗」，成功 commit 後才 return**。

## 6. 後續依賴 + 欄名風險
- T24 組檔主要讀 `TB_DISBUR_DATE.EX_RATE_BUY/EX_RATE_SELL`；舊 T24 spec 明確 `TB_EXCHANGE_RATE` **不被組檔直接讀取**。
- 🔴 **欄名不一致風險（連 M1/H8）**：T24 G/H 現碼讀 `EXCHANGR_RATE`（**注意拼字**），**不是本方法寫入的 `EX_RATE_BUY/SELL` 欄名** → 補完 stub 後 G/H 仍可能空值 → **見 OQ-5**。（M1 H8 還原時即沿用 `disburDate.EXCHANGR_RATE` 既有值邏輯。）

## 7. Open Questions（待裁）
> **✅ owner 裁定（2026-06-16）：撥貸 outbound 參數先對齊舊系統 parity** → OQ-1 定 `IdNo=OVSLXLON01`、A-2 匯率源 ID 定 `01`；連同 recon 對等建議，**OQ-1/3/4 全收**（OQ-5 已修 `581e717`、OQ-2 精度已關）→ **A-1 由「卡 owner」轉施工-ready**。
> **✅ 舊系統對等 recon 完成（2026-06-16，審過，findings `a1-oq-legacy-recon-findings.md`）**：OQ-3/4/5 舊系統做法坐實＋對等建議；OQ-1 縮小至 T24 一個身份確認點（已由 parity 裁定取 `01`）。
| # | 問題 | 裁定（對等舊系統）| owner |
|---|---|---|---|
| OQ-1 ✅（06-16 owner）| `IdNo` 用 `OVSLXLON01` 還新系統刻意 `OVSLXLON02` | **裁定＝`OVSLXLON01`（先對齊舊 parity）**：舊固定 `01`（`EPROIS_0922_mod:1063`、batch `EPROZ0_B005:82`），新 stub 現 `02`（`FunctionServiceImpl:1173`）→ **改回 `01`** | ✅ 已裁；⚠️ 唯一復驗點＝新環境 T24 拒收 `01`（schema-diff 證 02=新庫）則改 `02` |
| ~~OQ-2~~ ✅ 已關（06-12 DDL 實查）| 精度新舊一致（`(17,2)`/`(17,4)`）| — | —（已關）|
| OQ-3 ✅（06-16 parity）| 非 `0000` 錯誤碼 | **採對等：映射等價語意 `EPROIS0921_UI_RAET_FIND_ERROR`、非 0000 中止 authorize、勿用泛用 `FAILED_E303`**（`EPROIS_0922_mod:1074/1111`；message text UNFOUND→沿用 key）| ✅ 忠實鏡像舊 0922 |
| OQ-4 ✅（06-16 parity）| catch 回 null 路徑 | **採對等：catch 明確 throw（如 `EPROApiException`）、勿回 null；API exception/timeout 中止 authorize**（舊 `EPRO_Z0Z009/010` throws、trx `doAuthorize` catch 回錯）| ✅ 忠實鏡像舊 0922 |
| OQ-5 | T24 G/H 讀 `EXCHANGR_RATE` | **🔴 坐實 typo/parity bug**：`EXCHANGR_RATE` 舊/新 schema/entity/DB psv **全無**（實欄 `EX_RATE_BUY/SELL`）；舊 T24 G/H 讀 `EX_RATE_BUY`（`EPRO_IS0922:1063/1128`），新 G/H 卻讀 `EXCHANGR_RATE`（`SummaryServiceImpl:2221/2285`）。建議 G/H 改讀 `EX_RATE_BUY`（E 段已對）| T24/domain（確認）|

## 8. 結論
> **方向（2026-06-15，使用者洞察）**：OQ 本質＝**對等舊 `EPROIS_0922` 換匯行為**（非政策發明）→ 走舊系統 recon 坐實舊做法＋附對等建議，owner 僅需確認「忠實對等 vs 刻意演進」。
> - **OQ-3/4/5 舊系統可直接定**：錯誤碼（沿用 `EPROIS0921_UI_RAET_FIND_ERROR`）、失敗 throw 行為、T24 組檔讀的**正確欄名**（坐實 `EXCHANGR_RATE` 是否 typo）。
> - **OQ-1 ✅ 已裁（06-16 owner：先對齊舊 parity）**：`IdNo=OVSLXLON01`。`01/02`＝新舊兩 schema 身份 key（01=舊庫、02=新庫）；schema-diff 證據略偏「02 為新環境刻意」，但 owner 取 parity-first → 用 `01`。**唯一復驗點＝若新環境 T24 拒收 `01`**（屆時改 `02` 並回填）。
> - recon findings＝`a1-oq-legacy-recon-findings.md`（已審）→ 已回填本 §7 表＋`pending-register`（A-1 OQ 移已關區）。
- 修法＝**補 return + 移尾端 throw + 兩表交易一致**；OQ-1/3/4/5 **全已裁**（OQ-1=`01`、OQ-3=映射 `EPROIS0921_UI_RAET_FIND_ERROR`、OQ-4=throw 勿回 null、OQ-5=G/H 讀 `EX_RATE_BUY` 已修）→ **A-1 施工-ready**。
- **鏡像對象＝舊 `EPROIS_0922` 換匯流程**，**非** `funcGetRate`。
