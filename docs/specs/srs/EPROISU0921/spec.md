# SRS - EPROISU0921 Data Input

## Metadata
| Key | Value |
|---|---|
| funcId | `EPROISU0921` |
| Page | Individual Disbursement - Data Input |
| Spec status | In Review |
| Implementation status | Not asserted |
| Risk tier | T1 money/checkpoint/auth |
| Source PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md` |
| Bundle | `docs/specs/srs/EPROISU0921/` |
| Checkpoint | Per-page owner re-open decisions are closed; do not promote to Approved before separate human approval/spec-reviewer sign-off. |

## Scope
This bundle defines the to-be contract for `EPROISU0921` Data Input: select/init data, query, main borrower and co-borrower T24/CIF checks, save/finish, return, page authorization, and EPROISU0920 Summary gating through `EPORIS_0921`.

Included endpoints:

| Endpoint | Method | Rn |
|---|---|---|
| `/epl-sele-isu-data-input` | POST | R1 |
| `/epl-info-isu-data-input` | POST | R2, R5, R12 |
| `/epl-case-isu-data-input-check-mb` | POST | R4 |
| `/epl-case-isu-data-input-check-co` | POST | R5, R8 |
| `/epl-save-isu-data-input` | POST | R6, R7, R8, R10 |
| `/epl-retu-isu-data-input` | POST | R9 |
| `funcIsuDataInputCheckBorInfo` | internal function only | R4, R5, R8 |

Out of scope:

- EPROISU0922 T24 authorize/file generation.
- Changing physical DB table or column names, including legacy typo columns `EPORIS_0921` and `DRAWDOWN_ACCOINT`.
- Re-opening fee M7/M10 or `RECEIVED_DATE` M4; those are carried as regression-fixed constraints.

## Source Inputs
| Source | Use |
|---|---|
| PM PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:40`-`46`, `68`-`72`, `82`-`86`, `96`-`99`, `113`-`120`, `126`-`147`, `167`-`176` | Scope, PRD functional requirements, validation, API legacy mapping, DB touchpoints, acceptance criteria. |
| Dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md:43`-`76` | 0921 re-open direction: old baseline, only intentional `refactor-spec`/`db-diff` delta changes to-be, per-item owner confirm. |
| Source precedence `docs/spec-architecture.md:80`-`117` | SoT ladder and escalation rule for PRD/refactor/db-diff/legacy conflicts. |
| N-axis playbook `docs/process/orchestration-playbook.md:40`-`50`, `81`-`83` | T1 must run A-G; per-page checkpoint; do not self-promote to Approved. |
| Legacy `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPROIS_0921_mod.java` | Old baseline for A-4, M6, address `UPD_DATE`, `DATA_SEQ`, business-section, law firm filter. |
| Legacy FE `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0921_JS.jsp` | Old finish gate, Summary tab gate, payload field names, address and sequence handling. |
| Refactor-spec `docs/refactor-spec/02_modules/EPROISU0921.md:22`-`29` and `docs/refactor-spec/03_artifacts/fe-individual/EPROISU0921/eproisu0921-data-input.md:28`-`34`, `80`-`84`, `134`, `178`-`220` | Latest epl-* contract map, page auth, Summary gate, check buttons, `coCheck` request carriage. |
| DB diff `docs/db-diff/02_tables/*.md` | Physical table/column truth for `schema.sql` and DB reconcile. |
| Current backend `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:43`-`114` | Implemented epl-* route names and methods. |

## Re-Open Checkpoint Summary
| Item | as-is seated result | db-diff/refactor-spec result | To-be proposal | Checkpoint |
|---|---|---|---|---|
| A-4 `CO_CHECK`判定 | Old baseline initializes no-co-borrower as `CO_CHECK=Y`; when co-borrowers exist, count must match T24 rows and each row must not be failed and must have today's `CHECK_DATE` (`EPROIS_0921_mod.java:232`-`242`). Current backend returns blank when no T24 co-borrower rows (`DataInputServiceImpl.java:479`-`485`). | `TB_T24_CO_BORROWER_INFO` keeps `DATA_SEQ`, `CHECK_DATE`, `CHECK_SUCCESS`, `BUSINESS_SEC_CODE` (`docs/db-diff/02_tables/TB_T24_CO_BORROWER_INFO.md:32`, `40`-`48`). Refactor-spec keeps `coCheck` as epl-contract field but gives no intentional no-co-borrower delta. | 照舊 baseline: owner confirmed on 2026-06-22 that no co-borrower = `CO_CHECK=Y`; if co-borrowers exist, `CO_CHECK=Y` requires count parity, every row success, today's `CHECK_DATE`, and `DATA_SEQ` mapping. No `REF-Dn` intentional delta found. | closed 2026-06-22 |
| A-4 `mbCheck` Finished gate | Old FE blocks Finished unless `MB_CHECK=Y` and `CO_CHECK=Y` (`EPROIS0921_JS.jsp:1288`-`1295`) and resets `MB_CHECK` after borrower T24 change (`EPROIS0921_JS.jsp:1100`-`1103`). | Refactor-spec keeps `mbCheck` and check button behavior (`eproisu0921-data-input.md:190`-`210`). T1 DoD requires BE authority for mutating completion. | 照舊 + BE authority: owner confirmed on 2026-06-22 that FE may pre-check, but `/epl-save-isu-data-input` with `isFinish=Y` must independently enforce current-day `mbCheck`/`coCheck` pass before DB mutation. | closed 2026-06-22 |
| A-4 law firm `IS_SHOW` | Old query has a `SYSTEM_VER` branch: non-`02.21` returns all `TB_LAW_FIRM`; only `02.21` filters `IS_SHOW='Y'` (`EPROIS_0921_mod.java:300`-`311`). Current backend repository always filters `WHERE IS_SHOW = 'Y'` (`TBLawFirmRepository.java:16`-`18`). | DB-diff keeps `TB_LAW_FIRM.IS_SHOW` (`docs/db-diff/02_tables/TB_LAW_FIRM.md:42`), and refactor-spec `epl-sele-isu-data-input` specifies `WHERE IS_SHOW='Y'`. | 偏新 `REF-D3`: owner confirmed on 2026-06-22 that to-be select exposes only `IS_SHOW='Y'`; save must reject inactive law firm if supplied directly. | closed 2026-06-22 |
| A-4 address `UPD_DATE` source | Old `CASE_PROGRESS=24` flow updates `DISBURSING_DATE` first, then calls `getdisDate(APPLICATION_NO)` (`EPROIS_0921_mod.java:173`-`177`, `994`-`1002`). `getdisDate` actually parses `APPLICATION_DATE` and queries address `UPD_DATE` through `APP_DATE` (`EPRO_IS0110.java:230`-`242`); district/commune/village consume that `UPD_DATE` (`EPRO_IS0110.java:347`-`381`). Current backend derives `updDate` from a local `disbursingDate` value in this branch (`DataInputServiceImpl.java:293`-`325`). | Refactor-spec requires common address APIs receive `updDate` from `/epl-sele-isu-data-input` (`EPROISU0921_Data_Input_前端系統規格書_v1.8_20251125--4c5f2248.md:1152`-`1153`, `1194`-`1195`, `1236`-`1237`). No source-changing delta found. | 照舊 source: owner confirmed on 2026-06-22 that address `updDate` must be derived from `TB_LON_SUMMARY_INFO.APPLICATION_DATE` through old `getdisDate` semantics. The separate `CASE_PROGRESS=24` `DISBURSING_DATE` initialization side effect remains, but it is not the address `UPD_DATE` source. | closed 2026-06-22 |
| A-4 `DATA_SEQ` and business-section | Old code keys co-borrower comparison by `DATA_SEQ`, persists T24 co-borrower `BUSINESS_SEC_CODE`, and compares CIF income sector to stored business-section (`EPROIS_0921_mod.java:72`-`75`, `858`-`870`, `890`-`903`, `922`-`934`). | DB-diff PK includes `DATA_SEQ`; business-section exists in both T24 borrower tables (`TB_T24_CO_BORROWER_INFO.md:32`, `40`, `47`; `TB_T24_MAIN_BORROWER_INFO.md:47`). No intentional delta found. | 照舊: owner confirmed `DATA_SEQ` mapping for co-borrower `CO_CHECK` on 2026-06-22, and confirmed business-section comparison as mandatory on 2026-06-22. | closed 2026-06-22 |
| M6 `EST_COM_DATE` / `OTHER_EST_COM_DATE` | Old query/save uses `dd/MM/yyyy` (`EPROIS_0921_mod.java:168`, `261`-`262`, `284`-`285`, `416`, `422`). Current backend save writes both fields as `null` (`DataInputServiceImpl.java:1025`, `1095`). | DB-diff keeps `TB_DISBUR_COLL.EST_COM_DATE` and `TB_DISBUR_OTHER_COLL.OTHER_EST_COM_DATE` as `DATE` (`TB_DISBUR_COLL.md:55`; `TB_DISBUR_OTHER_COLL.md:47`). Refactor-spec explicitly changes response wire format to `MM/YYYY`, and current DTO length is 7 for `estCom`/`otrEstCom`. | 偏新 `REF-D4`: owner confirmed on 2026-06-22 that API wire format is `MM/YYYY`; BE must persist and query round-trip month/year to the DATE columns without writing null for supplied values. | closed 2026-06-22 |

## PRD TBD Disposition
| PRD TBD | SRS disposition | Status |
|---|---|---|
| TBD-001 legacy naming noise (`EPROIS_0911` / Collateral Information) | R12 keeps to-be names as `EPROISU0921` / Data Input and treats legacy naming as provenance only. | closed in SRS |
| TBD-002 physical completion flag typo `EPORIS_0921` | R2/R12 map public `eprois0921` to physical `EPORIS_0921`; no DB rename in this SRS. | closed in SRS |
| TBD-003 physical account typo `DRAWDOWN_ACCOINT` | R12 and `schema.sql` preserve physical typo while API uses `drawdownAccount`. | closed in SRS |
| TBD-004 legacy `.get(0)` prerequisite-data assumption | R1/R2 require `MSG_DATA_NOT_FOUND`/404 for missing prerequisite data and prohibit unchecked-list failure. | closed in SRS |
| TBD-005 `CASE_PROGRESS=24` initialization updates `DISBURSING_DATE` | R1 explicitly documents the retained side effect and requires audit/transaction safety, while address `updDate` stays old `APPLICATION_DATE`-derived baseline per owner decision on 2026-06-22. | closed in SRS |
| TBD-006 Product Code to Sector/Industry mapping | Owner confirmed on 2026-06-22: use PRD mapping as authoritative for main-borrower check (`01`/`02` -> `1001`/`1001`; `03` -> `1002`/`1001`); any unlisted product code must not pass by default. | closed `TBD-0921-003` |
| TBD-007 Return cleanup scope | Owner confirmed on 2026-06-22: follow the old/refactor SQL1-SQL12 DB cleanup scope, retain/write audit history, and do not require physical file deletion unless separately specified. | closed `TBD-0921-004` |
| TBD-008 shared `collproSize` limit | Owner confirmed on 2026-06-22: use the same limit value 5 for CBC Member and Add Purchased Property, but count each list separately; BE must enforce the cap on Save/Finished. | closed `TBD-0921-005` |

## Requirements

### R1 Select/init options and address date **強制點: BE**
covers-prd: FR-INIT-001, FR-INIT-002, FR-INIT-005, AC-001, AC-002

`/epl-sele-isu-data-input` must return all Data Input options needed before rendering: common field options, visible law firms, `updDate`, province list, and static value lists for the Data Input, collateral, and purchased-property regions. Owner confirmed `REF-D3` on 2026-06-22: law firm options expose only `TB_LAW_FIRM` rows where `IS_SHOW='Y'`. Owner also confirmed on 2026-06-22 that `updDate` must be the same application-date-derived address-version used by the old system; common address endpoints must use this value for province, district, commune, and village lookups.

When `CASE_PROGRESS=24`, the legacy initialization updates `TB_LON_SUMMARY_INFO.DISBURSING_DATE` as a retained side effect, but legacy `getdisDate` still derives address `updDate` from `APPLICATION_DATE`. The endpoint remains a mutating POST and the mutation must be explicit, audited, and transactionally safe; the address-version returned as `updDate` must remain application-date-derived. Missing case summary or prerequisite loan-condition data returns `MSG_DATA_NOT_FOUND` with 404. Query or system failure returns `MSG_QUERY_FAIL` with 500. Neither case may fail through unchecked list access.

### R2 Query Data Input page state **強制點: BE**
covers-prd: FR-INIT-001, FR-INIT-002, FR-INIT-003, FR-INIT-004, FR-UI-004, AC-001, AC-002

`/epl-info-isu-data-input` must query `APPLICATION_NO` and return summary header, `TB_DISBUR_DATE`, collateral list, purchased-property list, co-borrower list, T24 borrower check state, account candidates, `mbCheck`, `coCheck`, and `eprois0921`. If no `TB_DISBUR_DATE` exists, the response must prefill disbursement currency/amount and borrower T24 number from approved loan-condition/source data without marking completion.

The response field `eprois0921` is the API-facing completion flag mapped to DB column `TB_DISBUR_DATE.EPORIS_0921`. EPROISU0920 Summary may proceed only when this value is `Y`; blank or `N` blocks Summary and returns the user to Data Input.

### R3 Role/page authorization and editability **強制點: BE**
covers-prd: FR-UI-001, FR-UI-002

The page must use the current page-column authorization model (`epl-auth-page-column` dependency) to decide visible buttons and editable fields. CAD Maker role `404` at `CASE_PROGRESS=24` can see Back, Return, Save, Finished, main borrower Check, and co-borrower Check. Query-only or non-editable states must not call mutating endpoints.

The backend must still enforce role/state for `/epl-save-isu-data-input`, `/epl-retu-isu-data-input`, `/epl-case-isu-data-input-check-mb`, and `/epl-case-isu-data-input-check-co`. `TB_API_AUTH` route rows are necessary but not sufficient; service-level guards must reject direct calls when the user cannot act on the case.

### R4 Main borrower T24/CIF/SSI check **強制點: BE**
covers-prd: FR-INIT-003, FR-UI-003, AC-003, AC-004

`/epl-case-isu-data-input-check-mb` must validate `applicationNo` and `borrowerT24No`, call the borrower/CIF/SSI source, compare name, date of birth, gender, Sector/Industry, and `BUSINESS_SEC_CODE`, then persist `TB_T24_MAIN_BORROWER_INFO` and `TB_MAIN_BORROWER_ACC`. The case product code source is `TB_LON_SUMMARY_INFO.PRODUCT_CODE`; owner confirmed on 2026-06-22 that Sector/Industry mapping is authoritative as follows: product `01` or `02` requires Sector `1001` and Industry `1001`; product `03` requires Sector `1002` and Industry `1001`; any unlisted product code or unlisted Sector/Industry combination must fail the main-borrower check rather than pass by default. `MB_CHECK=Y` requires successful comparison and today's `CHECK_DATE`; mismatch, missing account, or stale date returns HTTP 200 with `MB_CHECK=N` and result messages without partially trusting previous pass state. Upstream timeout, unavailable service, or system exception must return a non-2xx error envelope and must not masquerade as `MB_CHECK=N`.

When Borrower CIF No. in T24 changes after a successful check, FE must reset local `mbCheck` to `N`; BE must treat stored pass state as stale unless it matches the current request/case state.

### R5 Co-borrower T24/CIF check and A-4 baseline **強制點: BE**
covers-prd: FR-INIT-004, FR-UI-003, AC-005, AC-008

`/epl-case-isu-data-input-check-co` must validate every co-borrower CIF input by `DATA_SEQ`, call the T24/CIF source, compare name, date of birth, gender, and `BUSINESS_SEC_CODE`, and persist `TB_T24_CO_BORROWER_INFO` rows keyed by `APPLICATION_NO`, `RECID`, and `DATA_SEQ`. The returned `coCheck` is `Y` only when every existing co-borrower row passes.

`coCheck=N` is reserved for business mismatch, stale check date, missing row, missing required CIF input, or row-level validation failure. Upstream timeout, unavailable T24/CIF service, or system exception must return a non-2xx error envelope and must not masquerade as `coCheck=N`.

For initialization and Finished gating, the to-be follows old baseline: owner confirmed on 2026-06-22 that if the case has no co-borrowers, co-borrower check is considered pass and must not block Finished. Owner also confirmed that if co-borrowers exist, `CO_CHECK=Y` requires row count parity, no failed row, today's `CHECK_DATE`, and `DATA_SEQ` mapping. No intentional refactor delta was found.

### R6 Save draft and Finished transaction **強制點: BE**
covers-prd: Save / Finished, validation table, AC-006, AC-007, AC-008

`/epl-save-isu-data-input` must support draft (`isFinish=N`) and Finished (`isFinish=Y`) modes. Draft persists supplied Data Input, collateral, purchased-property, and co-borrower temporary rows without setting `EPORIS_0921=Y`. Finished must execute all required-field, address, money, law-firm, T24-check, and role/state validations before mutation, then atomically save `TB_DISBUR_DATE`, `TB_DISBUR_COLL`, `TB_DISBUR_OTHER_COLL`, and any T24 temp rebuild rows.

Finished success sets `TB_DISBUR_DATE.EPORIS_0921='Y'` and updates `TB_LON_SUMMARY_INFO.RECEIVED_DATE` according to the already-fixed M4 regression. Failed Finished must not leave partial completion state. Owner confirmed on 2026-06-22 that client-supplied `coCheck` is not authoritative; BE must recompute or verify against current stored T24 check state before completion.

Finished is not a retryable money mutation. Before any `isFinish=Y` mutation, BE must query the current `TB_DISBUR_DATE.EPORIS_0921`; if it is already `Y`, the request must be rejected with named validation code `EPROISU0921_ALREADY_FINISHED` and no-op all mutable effects, including `RECEIVED_DATE`, `FACILITY_FEE`, `REFINANCING_FEE`, collateral rows, purchased-property rows, and T24 temporary rows. Draft saves may still update editable draft data only while the case remains in an editable Maker state, but they must not reopen or overwrite a completed Finished event.

### R7 M6 completion dates **強制點: BE**
covers-prd: M6 completion dates, `collateralList`, `addpurchasedList`

`collList[].estCom` maps to `TB_DISBUR_COLL.EST_COM_DATE`; `purPropList[].otrEstCom` maps to `TB_DISBUR_OTHER_COLL.OTHER_EST_COM_DATE`. Under `REF-D4`, public API wire format is `MM/YYYY`, not legacy `dd/MM/yyyy` and not ISO `date`. Query must return stored month/year values in `MM/YYYY`; save must parse and persist supplied month/year values to the physical DATE columns. Null is allowed only when the field is not supplied or the business field is not applicable.

Current backend lines that set both fields to null are a regression against old baseline, db-diff physical columns, and the owner-confirmed `REF-D4` to-be behavior. BE must restore month/year round-trip behavior and must not write null when a valid M6 value is supplied.

### R8 Sequence identity and business-section consistency **強制點: BE**
covers-prd: co-borrower check, collateralList, addpurchasedList, AC-005

`COLL_DATA_SEQ`, `OTHER_COLL_DATA_SEQ`, and co-borrower `DATA_SEQ` are stable ordering/identity keys. Save must not renumber existing rows in a way that breaks T24 comparison or downstream collateral references. Owner confirmed on 2026-06-22 that `TB_T24_CO_BORROWER_INFO.DATA_SEQ` must map back to the corresponding co-borrower row, and any `BUSINESS_SEC_CODE` mismatch must fail the relevant borrower check.

### R9 Return Data Input case **強制點: BE**
covers-prd: TBD-007, AC-010

`/epl-retu-isu-data-input` must validate role/state and return the case to the prior workflow state using the old/refactor return cleanup set confirmed by owner on 2026-06-22. The atomic unit includes updating the case summary back to the prior state, inserting return audit/history rows in `TB_APP_HISTORY`, setting `TB_CONTR_DATA.CONTR_STATUS='R'`, and deleting the Data Input/T24/contract-generation temporary DB artifacts: `TB_T24_MAIN_BORROWER_INFO`, `TB_T24_CO_BORROWER_INFO`, `TB_MAIN_BORROWER_ACC`, `TB_DISBUR_COLL`, `TB_DISBUR_OTHER_COLL`, `TB_DISBUR_DATE`, `TB_CONTR_AUTO_FILE_PTH`, `TB_LOAN_CONDITION_FEE` where `CON_TYPE='FN'`, and `TB_LOAN_CONDITION_DETAIL` where `CON_TYPE='FN'`.

The cleanup boundary is DB metadata/data only. Deleting physical generated contract files is not part of this SRS unless a separate owner decision adds it. The transaction must be atomic: if history, workflow update, contract status update, or cleanup fails, the workflow state must not be partially returned.

### R10 Money, address, and law-firm validations **強制點: BE**
covers-prd: validation table, AC-007, AC-009, fee M7/M10 non-reopened constraint

Money and fee fields must follow DB precision `NUMBER(17,2)` where applicable. Disbursement amount cannot exceed approved loan amount; invalid amount restores or rejects according to the page rule. Designated repayment day must be 1-31. `LAW_FIRM_AMOUNT_90` and `LAW_FIRM_90_OTHER_REMARK` are paired: if either is supplied, both are required; remark max length is 16.

`FACILITY_FEE` and `REFINANCING_FEE` are BE-computed values on Finished, not client-authoritative request values. Facility fee source is the approved loan-condition amount `TB_LOAN_CONDITION_DETAIL.LOAN_AMOUNT` for the case's current `FIN_CON_TYPE` multiplied by `TB_LOAN_CONDITION_FEE.FEE_1 / 100`. Refinancing fee source is the submitted `TB_DISBUR_DATE.DISBURSEMENT_AMOUNT` multiplied by `TB_LOAN_CONDITION_FEE.FEE_5 / 100`. Missing fee source fields persist null rather than synthesizing a value; non-numeric, overflow, or unsupported-currency fee calculation fails before Finished mutation with named code `EPROISU0921_FEE_SOURCE_INVALID`. Rounding follows old-system parity unless a later owner decision explicitly approves a delta: USD must format to 2 decimals with the legacy `String.format("%.2f", value)` behavior and must not truncate with `RoundingMode.DOWN`; KHR keeps the accepted A-5/domain decision of scale 0 with `RoundingMode.DOWN`; any other disbursement currency remains by-design unreachable under the USD/KHR-only disbursement decision and must not silently produce a supported fee value.

Collateral and purchased-property address front/back text must not exceed 65 characters combined per row. FE may provide immediate validation, but BE is authoritative for Finished and mutating saves.

Owner confirmed PRD `TBD-008` on 2026-06-22: CBC Member Reference and Add Purchased Property use the same `collproSize` limit value of 5, but the counts are independent. CBC Member may have at most 5 entries, and Add Purchased Property may have at most 5 rows; the two counts must not be summed into one shared total. FE may block add actions early, but BE is authoritative for `/epl-save-isu-data-input` Save/Finished and must reject over-limit payloads instead of truncating silently.

### R11 Authorization, privacy, and audit guards **強制點: BE**
covers-prd: security and transaction expectations

All endpoints must require authenticated user context and service-level authorization for the application. Error responses must not expose credentials, hostnames, stack traces, production URLs, T24 raw payloads, or personal data beyond the minimum field-level result message already expected by the UI. Mutating endpoints must write existing audit/history records consistently with the workflow.

`funcIsuDataInputCheckBorInfo` is an internal comparison helper, not a public OpenAPI endpoint. If an implementation exposes it behind a controller for reuse, it must be protected as internal-only and must not return raw comparison source rows beyond the fields needed by the caller.

`TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` is carried as server-read routing and audit context for the individual disbursement flow. EPROISU0921 does not create a separate S/U branch inside Data Input: upstream tab/page eligibility and collateral-page availability are decided before this page by the ISU shell/EPROISU0920 routing. BE must not trust any client-supplied secure attribute and must not use it to bypass Data Input validation; a future S/U behavior split requires a new PRD/SRS delta.

### R12 Traceability and completion interoperability **強制點: both**
covers-prd: FR-UI-004, AC-001, AC-007, AC-008

The API contract intentionally exposes `eprois0921` while preserving physical DB column `EPORIS_0921`. The old legacy paths `/EPROIS_0921/query`, `/EPROIS_0921/save_dataInput`, `/EPROIS_0921/CheckMainBorr`, and `/EPROIS_0921/CheckCoBorr` are provenance only; the to-be public contract is the epl-* endpoint set in this bundle. EPROISU0920 Summary gating must use the to-be `eprois0921` value and must not infer completion from partial Data Input rows.

## 新舊 DB / refactor reconcile delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_DISBUR_DATE` is active and stores Data Input main data including money fields, law firm fields, and physical completion flag `EPORIS_0921`. | carried | R2/R6/R10/R12 map `eprois0921` to physical `EPORIS_0921`; no DB rename. | `docs/db-diff/02_tables/TB_DISBUR_DATE.md:45`-`61`, PRD `:132`, `:142` |
| DB-D2 `TB_DISBUR_COLL.EST_COM_DATE` and `TB_DISBUR_OTHER_COLL.OTHER_EST_COM_DATE` exist as `DATE`. | physical carried + owner-confirmed `REF-D4` wire delta | R7 requires save/query month-year round-trip; current null persistence is not to-be. | `docs/db-diff/02_tables/TB_DISBUR_COLL.md:55`; `docs/db-diff/02_tables/TB_DISBUR_OTHER_COLL.md:47`; current `DataInputServiceImpl.java:1025`, `1095` |
| DB-D3 T24 check tables retain `CHECK_DATE`, `CHECK_SUCCESS`, `DATA_SEQ`, and `BUSINESS_SEC_CODE`. | carried | R4/R5/R8 require current-day pass and business-section comparison. | `docs/db-diff/02_tables/TB_T24_MAIN_BORROWER_INFO.md:40`, `46`-`47`; `docs/db-diff/02_tables/TB_T24_CO_BORROWER_INFO.md:32`, `40`-`48` |
| DB-D4 Address tables are keyed by `UPD_DATE`. | confirmed old baseline | Owner confirmed on 2026-06-22: R1 requires one application-date-derived `updDate` for province/district/commune/village. | `docs/db-diff/02_tables/TB_PROVINCE.md:32`, `41`; `docs/db-diff/02_tables/TB_DISTRICT.md:32`, `42`; `docs/db-diff/02_tables/TB_COMMUNE.md:32`, `42`; `docs/db-diff/02_tables/TB_VILLAGE.md:32`, `42` |
| DB-D5 `TB_LAW_FIRM.IS_SHOW` remains physical filter field. | physical carried + confirmed `REF-D3` behavior delta | R1/R10 only expose active law firms and reject inactive direct save, superseding the old non-`02.21` all-law-firm branch per owner decision on 2026-06-22. | `docs/db-diff/02_tables/TB_LAW_FIRM.md:42`; legacy `EPROIS_0921_mod.java:300`-`311`; current `TBLawFirmRepository.java:16`-`18` |
| DB-D6 `TB_API_AUTH` is active/exact and supports epl endpoint seed rows. | carried with security guard | R3/R11 require route auth plus service-level role/state guard. | `docs/db-diff/02_tables/TB_API_AUTH.md:38`-`40`; playbook D-axis requirement |
| DB-D7 `TB_DISBUR_DATE.DISBURSEMENT_BY` physical length is 25. | DB-resolvable fact | OpenAPI uses `maxLength: 25`; the refactor save artifact's `String 5` signal does not override db-diff physical width because the column stores account/payment text. | `docs/db-diff/02_tables/TB_DISBUR_DATE.md:47`; `docs/refactor-spec/03_artifacts/be-individual/EPROISU0921/epl-save-isu-data-input.md:117`; `openapi.yaml` `disbursementBy` |
| DB-D8 `TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` is an active case-routing attribute. | carried + page-level disclaim | R11 carries it as server-read routing/audit context and explicitly disclaims any intra-0921 S/U split. | Bible `docs/specs/bible/bible-eproposal.md:230`, `326`; `schema.sql` `TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE` |
| DB-D9 `TB_DISBUR_DATE.DRAWDOWN_ACCOINT` keeps the physical typo but stores account text. | DB-resolvable correction | `schema.sql` uses `VARCHAR2(25)` and OpenAPI exposes `drawdownAccount` as string max 25; this corrects the SRS schema type while preserving the physical column name. | Current entity `TBDisburDateEntity.java:60`-`61`; refactor save artifact `epl-save-isu-data-input.md:116`; legacy UI `EPROIS0921_JS.jsp:173`, `181` |
| DB-D10 `TB_DISBUR_DATE.FACILITY_FEE` and `REFINANCING_FEE` are `NUMBER(17,2)` computed fields. | carried with BE-authoritative calculation | R10 defines the Finished-time formula, source tables, null/failure policy, and rounding; OpenAPI returns `facilityFee` and `refinancingFee` as server-calculated fields. USD rounding follows legacy `String.format("%.2f", value)` parity; KHR `RoundingMode.DOWN` is limited to the A-5/domain-approved KHR branch. | PRD AC-007 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:173`; legacy `EPROIS_0921_mod.java:451`-`459`, `470`-`477`; current backend `DataInputServiceImpl.java:882`-`905`, `1149`-`1155`; `docs/disbursement/disbursement-domain-escalations.md:13` |
| REF-D1 Refactor latest splits legacy actions into epl-* endpoints and adds page-column authorization. | intentional contract modernization | Endpoints table and openapi use epl-* routes; legacy paths remain provenance only. | `docs/refactor-spec/02_modules/EPROISU0921.md:22`-`29`; `eproisu0921-data-input.md:167`-`181` |
| REF-D2 Refactor carries `coCheck` in save request but does not make it backend-authoritative. | carried with confirmed BE authority constraint | R6 accepts `coCheck` for compatibility only; owner confirmed on 2026-06-22 that BE verifies current stored check state before Finished. | `eproisu0921-data-input.md:134`; legacy save request `EPROIS0921_JS.jsp:1058`-`1059`; legacy save read `EPROIS_0921_mod.java:386`-`387` |
| REF-D3 Refactor removes the old `SYSTEM_VER` law-firm branch and always filters visible law firms by `IS_SHOW='Y'`. | confirmed intentional contract modernization | Owner adopted `REF-D3` on 2026-06-22; R1/R10 use `IS_SHOW='Y'` as to-be select and save validation rule. | legacy `EPROIS_0921_mod.java:300`-`311`; refactor `epl-sele-isu-data-input.md:210`; current `TBLawFirmRepository.java:16`-`18` |
| REF-D4 Refactor changes M6 completion date wire format from legacy `dd/MM/yyyy` to `MM/YYYY`. | intentional contract modernization + owner-confirmed 2026-06-22 | R7 and openapi use `MM/YYYY` for `estCom`/`otrEstCom`; physical DB remains DATE and must round-trip month/year. | legacy `EPROIS_0921_mod.java:168`, `416`, `422`; refactor `epl-info-isu-data-input.md:127`-`128`; current DTO `SaveCollList.java:90`-`92`, `SavePurPropList.java:55`-`57` |
| REG-D1 Current backend returns blank `coCheck` when no co-borrower T24 rows exist. | regression against confirmed old baseline | Owner confirmed on 2026-06-22: no co-borrower = `CO_CHECK=Y`; Finished must not be blocked by missing co-borrowers. | legacy `EPROIS_0921_mod.java:232`-`242`; current `DataInputServiceImpl.java:479`-`485` |
| REG-D2 Current backend sets M6 date columns to null on save. | regression | R7 requires restoring old date round-trip. | legacy `EPROIS_0921_mod.java:416`, `422`; current `DataInputServiceImpl.java:1025`, `1095` |
| REG-D3 Current backend Sector/Industry condition can pass unlisted product or Sector/Industry combinations by default. | regression risk against confirmed product mapping | R4 requires closed mapping: `01`/`02` -> `1001`/`1001`; `03` -> `1002`/`1001`; anything else fails. | legacy `EPROIS_0921_mod.java:698`-`713`; current `DataInputServiceImpl.java:1426`-`1430` |
| REG-D4 Current backend does not visibly reject over-limit CBC Member or Add Purchased Property payloads before persistence. | regression risk against owner-confirmed limit rule | R10 requires BE rejection when `cbcMemberList` has more than 5 entries or `purPropList` has more than 5 rows; FE-only limits are insufficient for T1 Save/Finished. | legacy `EPROIS0921_JS.jsp:1118`-`1121`, `1143`-`1147`; refactor `EPROISU0921_Data_Input_前端系統規格書_v1.8_20251125--4c5f2248.md:372`, `582`; current `DataInputServiceImpl.java:968`-`984`, `1083`-`1088` |
| REG-D5 Duplicate `isFinish=Y` submissions can repeat money/completion side effects unless guarded. | Bible disaster-scenario blocker | R6 requires already-finished rejection/no-op with `EPROISU0921_ALREADY_FINISHED` before updating `RECEIVED_DATE`, fees, collateral, purchased-property, or T24 temp rows. | Bible duplicate-disbursement risk `docs/specs/bible/bible-eproposal.md:246`, `463`; PRD idempotency row `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md:185` |
| REG-D6 Current backend truncates USD facility/refinancing fee with `RoundingMode.DOWN`. | regression risk against old-system USD fee parity | R10 requires USD to follow legacy two-decimal `String.format("%.2f", value)` behavior. No owner evidence was found that approves the USD truncation delta; only KHR `DOWN` and USD/KHR currency narrowing are approved under A-5. | legacy `EPROIS_0921_mod.java:451`-`459`, `470`-`477`; current `DataInputServiceImpl.java:897`-`905`, `1149`-`1155`; `docs/build-tasks/done/khr-currency-handling-recon-findings.md:161`-`167`; `docs/disbursement/disbursement-domain-escalations.md:13` |

## @PENDING
| ID | Status | Decision needed | Owner | Source |
|---|---|---|---|---|
| TBD-0921-001 | closed | A-4 owner confirmed on 2026-06-22: no-co-borrower pass = `CO_CHECK=Y`; co-borrower `CO_CHECK=Y` requires count parity, every row success, today's `CHECK_DATE`, and `DATA_SEQ` mapping; Finished `mbCheck`/`coCheck` requires BE authority; law firm uses `REF-D3` `IS_SHOW='Y'`; address `UPD_DATE` is `APPLICATION_DATE`-derived with separate `DISBURSING_DATE` initialization side effect; business-section comparison is mandatory. | PM/SA/RD | This spec R1/R4/R5/R6/R8/R10; dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md:46`-`49`, `55`-`63` |
| TBD-0921-002 | closed | Owner confirmed on 2026-06-22: API wire format is `MM/YYYY` under `REF-D4`, and `EST_COM_DATE` / `OTHER_EST_COM_DATE` must be queried, accepted, and persisted when supplied; current save-to-null behavior is a regression to fix. | PM/SA/RD | This spec R7; dispatch `docs/build-tasks/disbursement-reopen-srs-dispatch.md:48`, `61`-`63` |
| TBD-0921-003 | closed | Owner confirmed on 2026-06-22: PRD mapping is complete and authoritative for this SRS (`01`/`02` -> `1001`/`1001`; `03` -> `1002`/`1001`); unlisted product code or Sector/Industry combination must fail the main-borrower check. | PM/SA | PRD `TBD-006`; this spec R4 |
| TBD-0921-004 | closed | Owner confirmed on 2026-06-22: Return follows the old/refactor SQL1-SQL12 database cleanup set, retains/writes `TB_APP_HISTORY`, sets `TB_CONTR_DATA.CONTR_STATUS='R'`, deletes T24 temp rows, Data Input collateral/date rows, `TB_CONTR_AUTO_FILE_PTH`, and FN loan-condition fee/detail rows; physical file deletion is not required unless separately decided. | PM/SA/QA | PRD `TBD-007`; this spec R9 |
| TBD-0921-005 | closed | Owner confirmed on 2026-06-22: CBC Member and Add Purchased Property share the same limit value 5, but each list is counted separately; BE must reject over-limit Save/Finished payloads and must not silently truncate. | PM/SA | PRD `TBD-008`; this spec R10 |

## Traceability Matrix
| PRD / source | SRS | QA |
|---|---|---|
| FR-INIT-001 / AC-001 | R1, R2 | QA-001, QA-002, QA-030, QA-031 |
| FR-INIT-002 / AC-002 | R2 | QA-002, QA-031 |
| FR-INIT-003 / AC-003 / AC-004 | R4 | QA-006, QA-007, QA-028 |
| FR-INIT-004 / AC-005 / AC-008 | R5, R8 | QA-008, QA-009, QA-010, QA-016, QA-017, QA-026, QA-029, QA-032 |
| FR-INIT-005 / PRD TBD-005 | R1 | QA-003, QA-030 |
| FR-UI-001 / FR-UI-002 | R3, R11 | QA-005, QA-022, QA-027 |
| FR-UI-003 | R4, R5 | QA-007, QA-010, QA-026, QA-028, QA-029 |
| FR-UI-004 | R2, R12 | QA-004, QA-023, QA-031 |
| PRD TBD-001 / TBD-002 / TBD-003 / TBD-004 / TBD-005 | R1, R2, R12 | QA-001, QA-002, QA-003, QA-023, QA-030, QA-031 |
| PRD TBD-006 / TBD-007 / TBD-008 | R4, R9, R10 | QA-006, QA-018, QA-019, QA-020, QA-025, QA-028, QA-032 |
| Save / Finished / AC-006 / AC-007 / AC-008 | R6, R10 | QA-011, QA-012, QA-013, QA-019, QA-020, QA-027, QA-032, QA-033, QA-034, QA-035 |
| M6 completion dates | R7 | QA-014, QA-015, QA-032 |
| Fee M7/M10 non-reopened constraint | R10 | QA-021, QA-033, QA-035 |
| `RECEIVED_DATE` M4 non-reopened constraint | R6 | QA-012, QA-034 |
| Return / AC-010 | R9 | QA-018 |
| Security/audit/authorization | R3, R11 | QA-005, QA-022, QA-024, QA-027, QA-036 |
| SECURE_ATTRIBUTE carry/disclaim | R11, R12 | QA-036 |

## NFR
- Transactionality: Finished and Return must be atomic across summary, disbursement, collateral, T24 temp, and history updates.
- Observability: failed T24/CIF checks return structured result messages without leaking sensitive service details.
- Compatibility: preserve physical DB names and legacy completion flag semantics while using epl-* API contract names.
- Testability: QA cases are written as seedable API-level cases; all T1 money/checkpoint/security rules require BE verification.

## Verification Status
| Gate | Result |
|---|---|
| Mechanical `check-srs-bundle` | PASS on 2026-06-22 for `python scripts/check-srs-bundle.py docs/specs/srs/EPROISU0921`; warnings are advisory only (`epl-auth-page-column`/`epl-contract` prose, missing Bible-PRD trace file). |
| N-axis A Comprehensive/spec-review | PASS after latest read-only spec-reviewer recheck; no SRS completeness blocker found, and status remains In Review/no self-Approved. |
| N-axis B as-is parity | PASS after latest regression recheck; SRS now preserves `DRAWDOWN_ACCOINT` as account text, records duplicate Finished as a blocker requirement, and treats current USD fee truncation as REG-D6 rather than target behavior. |
| N-axis C error-code carriage | PASS after latest contract recheck; `EPROISU0921_COLL_OVER_LIMIT`, `EPROISU0921_ALREADY_FINISHED`, and `EPROISU0921_FEE_SOURCE_INVALID` are carried in OpenAPI/QA/spec. |
| N-axis D security/auth | PASS by local implementation evidence on 2026-06-23; status remains In Review/no self-Approved. Backend now locks the case summary row before `isFinish=Y`, rejects already-finished `EPORIS_0921='Y'`, verifies current stored T24 main/co-borrower checks before money/completion mutation, and outbound request/response logging masks URI plus non-JSON bodies. |
| N-axis E DB/refactor reconcile | PASS after latest contract recheck; `DRAWDOWN_ACCOINT` keeps the physical typo with `VARCHAR2(25)`, and fee DB deltas are explicit. |
| N-axis F money/precision/truncation | PASS after latest regression recheck; USD fee rounding follows legacy `String.format("%.2f", value)`, KHR `DOWN` remains limited to the A-5/domain-approved branch, and current backend USD `DOWN` is recorded as REG-D6. |
| N-axis G testability/trace | PASS after latest spec-reviewer recheck; QA-033 through QA-036 cover the blocker fixes. |
