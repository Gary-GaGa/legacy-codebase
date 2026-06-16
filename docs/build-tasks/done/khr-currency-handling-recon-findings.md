# KHR currency handling recon findings

Date: 2026-06-16

Scope: disbursement exchange, fee calculation, and T24 E/G/H output paths.

Mode: read-only code verification. No backend or legacy source code was changed.

## Conclusion

- A-5 should not be recorded as confirmed "new KHR localization" only.
- Legacy code already had broad `non-USD` handling that covered KHR implicitly.
- New backend rewrites several `non-USD` behaviors into explicit `USD` / `KHR` / fallback branches.
- The E21 branch where `non-USD` and `non-KHR` outputs `0` is a parity regression risk unless domain confirms that only USD and KHR are valid disbursement currencies.
- Intent is UNFOUND in the inspected code. Recommended A-5 disposition: **升 domain**. If domain confirms other currencies are still valid, apply **對等修**.

## New backend evidence

### 0921-equivalent fee rounding

File: `backend/src/main/java/khd/svc/epro/service/individual/impl/DataInputServiceImpl.java`

- `DataInputServiceImpl.java:875-880`: `saveIsuDataInput(...)` reads `request.getDisbursementCurrency()`.
- `DataInputServiceImpl.java:897-905`: facility fee and refinancing fee are computed by `getDisburseFee(..., disbursementCurrency)`.
- `DataInputServiceImpl.java:939-940`: computed fees are persisted to `FACILITY_FEE` and `REFINANCING_FEE`.
- `DataInputServiceImpl.java:1149-1156`: `getDisburseFee(...)` branches:
  - USD: `fee.setScale(2, RoundingMode.DOWN)`.
  - KHR: `fee.setScale(0, RoundingMode.DOWN)`.
  - Other currencies: `return null`.

### funcGetExchangeRate / authorize exchange

File: `backend/src/main/java/khd/svc/epro/service/common/impl/FunctionServiceImpl.java`

- `FunctionServiceImpl.java:1157`: `funcGetExchangeRate(...)`.
- `FunctionServiceImpl.java:1176-1183`: KHBFTR37001 request is built with `tranrq.setCcyCode("KHR")`, rate type `CURR`, id `OVSLXLON01`, and seq max `1`.
- `FunctionServiceImpl.java:1185-1186`: calls KHBFTR37001.
- `FunctionServiceImpl.java:1197-1205`: updates `TB_DISBUR_DATE` with `NEXT_KEY`, `EX_RATE_BUY`, and `EX_RATE_SELL`.
- `FunctionServiceImpl.java:1208-1218`: persists exchange rate data, including CCY code and buy/sell rate.

File: `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java`

- `SummaryServiceImpl.java:2318-2322`: authorize sequence calls `commonFunctionService.funcGetExchangeRate(...)`.
- `SummaryServiceImpl.java:2324-2329`: then calls `funcIsuT24Authorize(...)`.

Behavior:

- USD: no separate exchange-rate request branch; the function still requests KHR rate before T24 authorization.
- KHR: KHR exchange rate is requested and stored.
- Other currencies: no separate currency-specific request branch; the function still requests KHR rate.

### T24 E transaction, field 21 charge amount

File: `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java`

- `SummaryServiceImpl.java:2014-2178`: `setApprTrans(...)`.
- `SummaryServiceImpl.java:2024`: transaction application is `LD.LOANS.AND.DEPOSITS`.
- `SummaryServiceImpl.java:2028-2030`: writes disbursement currency and disbursement amount.
- `SummaryServiceImpl.java:2145-2163`: field 21 charge amount branch:
  - USD: writes raw `CBC_FEE`.
  - KHR: computes `(EX_RATE_BUY + EX_RATE_SELL) / 2`, scale 4 `HALF_UP`, then `CBC_FEE * averageRate`, scale 0 `HALF_UP`.
  - Other currencies: writes `"0"`.

### T24 G transaction, legal fee transfer

File: `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java`

- `SummaryServiceImpl.java:2180-2256`: `setChargeLegalFee(...)`.
- `SummaryServiceImpl.java:2197`: transaction application is `FT.LOAN.FEE`.
- `SummaryServiceImpl.java:2206`: writes `DISBURSEMENT_CURRENCY`.
- `SummaryServiceImpl.java:2212`: writes law firm amount.
- `SummaryServiceImpl.java:2221-2223`: exchange-rate branch uses main borrower account `CURRENCY`:
  - USD account currency: exchange rate is blank.
  - KHR account currency: exchange rate is `EX_RATE_BUY`.
  - Other non-USD account currency: exchange rate is `EX_RATE_BUY`.

### T24 H transactions, EIR facility/refinancing fee transfer

File: `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java`

- `SummaryServiceImpl.java:2262-2288`: `setCalculateFee(...)`.
- `SummaryServiceImpl.java:2267-2269`: writes transaction type, fee amount, and credit account.
- `SummaryServiceImpl.java:2276-2278`: writes disbursement currency and fee amount.
- `SummaryServiceImpl.java:2284-2286`: exchange-rate branch uses main borrower account `CURRENCY`:
  - USD account currency: exchange rate is blank.
  - KHR account currency: exchange rate is `EX_RATE_BUY`.
  - Other non-USD account currency: exchange rate is `EX_RATE_BUY`.

## Legacy evidence

### EPROIS_0921 fee

File: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0921_mod.java`

- `EPROIS_0921_mod.java:431-444`: reads loan amount and fee rate.
- `EPROIS_0921_mod.java:451-459`: facility fee branch:
  - USD: `String.format("%.2f", facilityFee)`.
  - KHR: no explicit KHR branch; covered by `else`, `Math.round(facilityFee)`.
  - Other currencies: covered by the same `else`, `Math.round(facilityFee)`.
- `EPROIS_0921_mod.java:463-477`: refinancing fee branch:
  - USD: `String.format("%.2f", refinancingFee)`.
  - KHR: no explicit KHR branch; covered by `else`, `Math.round(refinancingFee)`.
  - Other currencies: covered by the same `else`, `Math.round(refinancingFee)`.
- `EPROIS_0921_mod.java:480-481`: writes `FACILITY_FEE` and `REFINANCING_FEE`.

### EPROIS_0922_mod exchange

File: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0922_mod.java`

- `EPROIS_0922_mod.java:954-1008`: authorize sequence.
- `EPROIS_0922_mod.java:985-986`: calls `getExchangeRate(APPLICATION_NO)`.
- `EPROIS_0922_mod.java:1006-1007`: calls `EPRO_IS0922.authorize(...)`.
- `EPROIS_0922_mod.java:1058-1116`: `getExchangeRate(...)`.
- `EPROIS_0922_mod.java:1065-1072`: KHBFTR37001 request is built with `tranrq.setCcyCode("KHR")`, rate type `CURR`, id `OVSLXLON01`, and seq max `1`.
- `EPROIS_0922_mod.java:1074`: calls `EPRO_Z0Z010.checkFtr37001(...)`.
- `EPROIS_0922_mod.java:1085-1105`: updates `EPRO_TB_DISBUR_DATE` with `NEXT_KEY`, `EX_RATE_BUY`, `EX_RATE_SELL`, and inserts exchange-rate data.

Behavior:

- USD: no separate exchange-rate request branch; the method still requests KHR rate before T24 authorization.
- KHR: KHR exchange rate is requested and stored.
- Other currencies: no separate currency-specific request branch; the method still requests KHR rate.

### EPRO_IS0922 T24 E transaction, field 21 charge amount

File: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java`

- `EPRO_IS0922.java:810-822`: reads `DISBURSEMENT_CURRENCY`, `EX_RATE_BUY`, and `EX_RATE_SELL`.
- `EPRO_IS0922.java:931-940`: field 21 charge amount branch:
  - USD: `CHRG_AMOUNT = CBC_FEE`.
  - KHR: no explicit KHR branch; covered by `else`, `CBC_FEE * ((EX_RATE_BUY + EX_RATE_SELL) / 2)`, then `Math.round(...)`.
  - Other currencies: covered by the same `else`.
- `EPRO_IS0922.java:994`: appends `CHRG_AMOUNT` as field 21.

### EPRO_IS0922 T24 G transaction, legal fee transfer

File: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java`

- `EPRO_IS0922.java:1006-1098`: `createTransferGitem(...)`.
- `EPRO_IS0922.java:1076-1079`: exchange-rate branch:
  - USD disbursement currency: exchange rate is blank.
  - KHR disbursement currency: no explicit KHR branch; covered by `!USD`, exchange rate is `EX_RATE_BUY`.
  - Other non-USD disbursement currency: covered by `!USD`, exchange rate is `EX_RATE_BUY`.
- `EPRO_IS0922.java:1082-1085`: reads main borrower account currency.
- `EPRO_IS0922.java:1090-1094`: appends transaction fields, including account currency and exchange rate.

### EPRO_IS0922 T24 H transactions, EIR facility/refinancing fee transfer

File: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java`

- `EPRO_IS0922.java:1107-1172`: `createTransferHitem(...)`.
- `EPRO_IS0922.java:1133-1138`: exchange-rate branch:
  - USD disbursement currency: exchange rate is blank.
  - KHR disbursement currency: no explicit KHR branch; covered by `!USD`, exchange rate is `EX_RATE_BUY`.
  - Other non-USD disbursement currency: covered by `!USD`, exchange rate is `EX_RATE_BUY`.
- `EPRO_IS0922.java:1151-1157`: appends facility fee transaction when `FEE_1` is non-zero.
- `EPRO_IS0922.java:1160-1166`: appends refinancing fee transaction when `FEE_5` is non-zero.

## Comparison tables

### 0921 fee rounding

| Currency | Legacy behavior | New backend behavior | Difference | Nature |
|---|---|---|---|---|
| USD | `EPROIS_0921_mod.java:451-459`, `463-477`: format fee with `String.format("%.2f", ...)`. | `DataInputServiceImpl.java:897-905`, `1149-1156`: `setScale(2, RoundingMode.DOWN)`. | Both keep 2 decimals, but rounding mode changed to truncate/down in new backend. | 改寫 |
| KHR | `EPROIS_0921_mod.java:451-459`, `463-477`: no KHR branch; old `else` rounds whole number with `Math.round(...)`. | `DataInputServiceImpl.java:897-905`, `1149-1156`: explicit KHR branch, `setScale(0, RoundingMode.DOWN)`. | KHR moved from implicit `non-USD` to explicit KHR; rounding changed from `Math.round` to truncate/down. | 改寫 |
| Other | `EPROIS_0921_mod.java:451-459`, `463-477`: all non-USD currencies round whole number with `Math.round(...)`. | `DataInputServiceImpl.java:1149-1156`: returns `null`. | Old had broad non-USD behavior; new drops other currencies to `null`. | 改寫 |

### funcGetExchangeRate / authorize exchange

| Currency | Legacy behavior | New backend behavior | Difference | Nature |
|---|---|---|---|---|
| USD | `EPROIS_0922_mod.java:985-986`, `1058-1116`: authorize calls exchange-rate method; request uses `CcyCode("KHR")`. | `SummaryServiceImpl.java:2318-2322`; `FunctionServiceImpl.java:1157-1222`: authorize calls exchange-rate service; request uses `CcyCode("KHR")`. | Same observed behavior. | 相同 |
| KHR | `EPROIS_0922_mod.java:1065-1072`: requests KHR rate and stores it at `1085-1105`. | `FunctionServiceImpl.java:1176-1183`: requests KHR rate and stores it at `1197-1218`. | Same observed behavior. | 相同 |
| Other | `EPROIS_0922_mod.java:1065-1072`: no per-currency branch; still requests KHR. | `FunctionServiceImpl.java:1176-1183`: no per-currency branch; still requests KHR. | Same observed behavior. | 相同 |

### T24 E transaction, field 21 charge amount

| Currency | Legacy behavior | New backend behavior | Difference | Nature |
|---|---|---|---|---|
| USD | `EPRO_IS0922.java:931-940`, `994`: field 21 uses raw `CBC_FEE`. | `SummaryServiceImpl.java:2145-2163`: field 21 uses raw `CBC_FEE`. | Same observed behavior. | 相同 |
| KHR | `EPRO_IS0922.java:931-940`, `994`: no KHR branch; old `else` uses `CBC_FEE * average(EX_RATE_BUY, EX_RATE_SELL)`, then `Math.round`. | `SummaryServiceImpl.java:2145-2163`: explicit KHR branch uses `CBC_FEE * average(EX_RATE_BUY, EX_RATE_SELL)`, average scale 4 `HALF_UP`, result scale 0 `HALF_UP`. | Same formula family, but KHR became explicit and rounding precision is not byte-for-byte equivalent. | 改寫 |
| Other | `EPRO_IS0922.java:931-940`, `994`: all non-USD currencies use exchange conversion. | `SummaryServiceImpl.java:2145-2163`: writes `"0"`. | Old supported all non-USD via exchange conversion; new suppresses non-USD/non-KHR to zero. | 改寫 |

### T24 G transaction, legal fee transfer

| Currency | Legacy behavior | New backend behavior | Difference | Nature |
|---|---|---|---|---|
| USD | `EPRO_IS0922.java:1076-1079`, `1090-1094`: USD disbursement currency writes blank exchange rate. | `SummaryServiceImpl.java:2221-2223`: USD account currency writes blank exchange rate. | Same if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |
| KHR | `EPRO_IS0922.java:1076-1079`, `1090-1094`: no KHR branch; `!USD` writes `EX_RATE_BUY`. | `SummaryServiceImpl.java:2221-2223`: KHR account currency writes `EX_RATE_BUY`. | Same if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |
| Other | `EPRO_IS0922.java:1076-1079`, `1090-1094`: all non-USD disbursement currencies write `EX_RATE_BUY`. | `SummaryServiceImpl.java:2221-2223`: all non-USD account currencies write `EX_RATE_BUY`. | Same broad non-USD handling if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |

### T24 H transactions, EIR facility/refinancing fee transfer

| Currency | Legacy behavior | New backend behavior | Difference | Nature |
|---|---|---|---|---|
| USD | `EPRO_IS0922.java:1133-1138`, `1151-1166`: USD disbursement currency writes blank exchange rate. | `SummaryServiceImpl.java:2284-2286`: USD account currency writes blank exchange rate. | Same if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |
| KHR | `EPRO_IS0922.java:1133-1138`, `1151-1166`: no KHR branch; `!USD` writes `EX_RATE_BUY`. | `SummaryServiceImpl.java:2284-2286`: KHR account currency writes `EX_RATE_BUY`. | Same if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |
| Other | `EPRO_IS0922.java:1133-1138`, `1151-1166`: all non-USD disbursement currencies write `EX_RATE_BUY`. | `SummaryServiceImpl.java:2284-2286`: all non-USD account currencies write `EX_RATE_BUY`. | Same broad non-USD handling if disbursement currency and account currency match. Branch input changed from disbursement currency to account currency. | 相同 |

## Direct answers

### Is E21 non-USD/non-KHR output 0 intentional or regression?

- Intentionality: **UNFOUND**.
- Behavior parity: regression risk. Legacy E21 converted every non-USD currency with the stored exchange rate; new backend only converts KHR and writes `0` for other currencies.
- This cannot be classified as safe `keep` without domain confirmation that valid disbursement currencies are limited to USD and KHR.

### Are there old-supported currencies missing in new backend?

- Specific currency codes beyond USD/KHR: **UNFOUND** in the inspected branches.
- Category-level gap found:
  - Fee rounding: legacy handled every non-USD currency; new backend returns `null` for non-USD/non-KHR.
  - E21 charge amount: legacy converted every non-USD currency; new backend writes `0` for non-USD/non-KHR.
- G/H exchange-rate field still broadly handles non-USD, but the new branch source is account currency while legacy used disbursement currency.

