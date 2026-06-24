# SRS - EPROC00116 Financial Statement GI

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00116 |
| Status | In Review / draft-for-controller-gate; awaiting human approval |
| N-axis review | 2026-06-24 source/domain patch + Should-fix closeout PASS. Cleared the 2026-06-23 2🔴 by adding R11 for BR-006 recalculation / hide Print-PDF behavior and adding QA-016/QA-017/QA-018 for recalc and Finished balance gates. Later Should-fix closeout downgraded R7 from unproven BE Finished balance-gate proof to FE-blocks + to-be BE hardening under `PENDING-EPROC00116-PARITY-CODE-VERIFY`, carried BR-016 KHR no-decimal formatting in R3/R11 + QA-019, and added QA-020 for required blank Finished blocking independent of imbalance. Mechanical gate PASS; axis-A reviewer PASS and cross-model reviewer PASS with no new Blocker/Should-fix. Not Approved: existing @PENDING items and owner approval remain open. |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md` |
| Legacy source | `EPROC0_0116`, `EPROC0_0216`, `EPROC00116.jsp`, `EPROC00216.jsp`, GI financial statement DAOs |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- In scope: C0 Financial Statement GI option lookup, current-case query, reference-application copy query, calculation, Save/Finished save, PDF/Excel export contracts, GI statement table writes, checkpoint update, and DB/schema reconcile for EPROC00116.
- Out of scope: FI Financial Statement, Financial Evaluation GI ratio/scoring details, report template redesign, ledger/status/register edits, implementation code edits, and owner decisions for open PRD TBDs.
- Current contract uses real RPC endpoints `epl-sele-c0-financial-statement-comments`, `epl-info-c0-financial-statement-comments`, `epl-quer-c0-financial-statement-comments`, `epl-calc-c0-financial-statement-comments`, `epl-save-c0-financial-statement-comments`, `epl-ppdf-c0-financial-statement-comments`, and `epl-pxls-c0-financial-statement-comments`; legacy `inti`, `search`, `calculation`, `save`, `print`, and `printPDF` are source evidence, not public API paths.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | Scope and legacy programs at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:9-23`; PRD TBDs at `:55-62`; FRs at `:175-185`; data/error rules at `:628-764`; acceptance cases at `:785-817`. | Non-pending FRs map to R1-R11; PRD TBDs remain `@PENDING` under R12. |
| Dispatch | Real endpoint style and four-file bundle rules at `docs/build-tasks/prd-to-srs-codex-dispatch.md`. | Use only `epl-*` RPC endpoints and produce exactly four files. |
| Legacy actions | `EPROC0_0116.java` exposes AJAX actions `inti`, `search`, `calculation`, `print`, `printPDF`, and `save` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0116.java:50`, `:96`, `:133`, `:171`, `:205`, `:233`; `EPROC0_0216.java` mirrors them at the same line ranges. | Legacy names establish behavior and error keys; current SRS uses new endpoints. |
| Legacy module | Option/query/reference/calc/save/export methods at `EPROC0_0116_mod.java:302`, `:327`, `:379`, `:426`, `:449`, `:567`, `:625`; reference eligibility at `:382-387`; transaction and delete/insert sequence at `:497-552`; formulas at `:61-68`, `:96-104`, `:161-162`, `:903-923`, `:945-970`, `:1005-1059`; highlight split at `:800-805`. | Formula and transaction behavior carried; reference status semantics and highlight migration stay pending. |
| Legacy JS | Five `BALANCE_DATE_0..4` validation fields at `EPROC00116_JS.jsp:213-217`; FI-looking validation key at `:270-272`; payload skips blank year rows at `:612-617`; old highlight pipes at `:711-721`; PDF/calc/save event flow at `:846-917` in `EPROC00216_JS.jsp`. | Validation and delimiter risks are pending; payload shape informs API arrays. |
| Current backend | Controller POST endpoints at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:34`, `:47`, `:60`, `:73`, `:86`, `:99`, `:112`; service option/query/save/export details at `CsuFinancialStatementServiceImpl.java:83-133`, `:156-182`, `:270-340`, `:352-466`. | Current backend is API grounding. |
| Current frontend | GI API service calls select/info/query/save/calc endpoints at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-gi/services/api.service.ts:37-100`; amount changes set `needCalculate=true` and hide print at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-gi/financial-statement-gi.component.ts:316-329`; Finished blocks while `needCalculate` is true at `:692-715`; build task confirms ppdf/pxls POST blob endpoints at `docs/build-tasks/done/phase-f-step2-00116-financial-statement-gi.md:13-27`. | FE uses backend calculation and export APIs; BR-006 is carried as R11; report template verification stays pending. |
| Refactor spec | Module index lists seven BE artifacts and FE artifact at `docs/refactor-spec/02_modules/EPROC00116.md:22-29`; FE artifact lists API calls at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00116/eproc00116-financial-statement-and-comments-gi.md:77-83`; calc/select artifacts define POST and body fields at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00116/epl-calc-c0-financial-statement-comments.md:145-159` and `epl-sele-c0-financial-statement-comments.md:184-188`. | Refactor contracts quantify current DTO direction; stale or undecided items remain pending. |
| DB diff and latest reverify | db-diff marks four GI tables active/exact at `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:13-16`, `TB_FIN_STATEMENT_BALANCE_GI.md:13-16`, `TB_FIN_STATEMENT_INCOME_GI.md:13-16`, `TB_FIN_STATEMENT_CASHFLOW_GI.md:13-16`; latest reverify confirms current main/detail columns and PKs at `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:1223-1273`, `:1287-1299`, `:1330-1393` and PKs at `..._pk.tsv:151-160`; checkpoint columns at `..._columns.tsv:128`, `:144`. | `schema.sql` follows latest reverify/current entity, with stale-source deltas called out. |
| Auth and inventory | c0 auth findings list seven endpoints at `docs/build-tasks/c0-authz-sql-findings.md:153-159`, with pxls gap at `:192` and calc note at `:196`; inventory marks EPROC00116 present and asks export-template confirmation at `docs/feature-inventory.md:103`; matrix leaves parity gated at `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:38`; parity task says calc/comments need source recheck at `docs/build-tasks/c0-legacy-parity-recheck.md:27`. | API seed and parity risks become `@PENDING`; this bundle does not close approval. |

## Endpoints
| Endpoint | Method | Purpose | Evidence |
|---|---|---|---|
| `/epl-sele-c0-financial-statement-comments` | POST | Return currency, currency unit, and type-of-year options. | Controller `:34`; service `:83-100`; refactor select artifact. |
| `/epl-info-c0-financial-statement-comments` | POST | Query current case summary, main, Balance GI, Income GI, Cashflow GI, and `haveData`. | Controller `:60`; service `:156-205`. |
| `/epl-quer-c0-financial-statement-comments` | POST | Query a reference application and return copyable GI financial statement data. | Controller `:47`; service `:111-145`; legacy `search` at `EPROC0_0116_mod.java:379-408`. |
| `/epl-calc-c0-financial-statement-comments` | POST | Calculate derived Balance/Income/Cashflow values and validation messages. | Controller `:73`; service `:208-260`; legacy formulas `EPROC0_0116_mod.java:903-1059`. |
| `/epl-save-c0-financial-statement-comments` | POST | Save draft or Finished GI statement rows and update checkpoint in one transaction. | Controller `:86`; service `:270-340`; legacy transaction `EPROC0_0116_mod.java:497-552`. |
| `/epl-ppdf-c0-financial-statement-comments` | POST | Generate GI PDF report blob/path using current platform download response. | Controller `:99`; service `:352-390`; build task `:19`, `:24-27`. |
| `/epl-pxls-c0-financial-statement-comments` | POST | Generate GI Excel file blob. | Controller `:112`; service `:395-466`; build task `:20`, `:24-27`. |

## Rules

### R1 Load options and current-case data - 強制點: both - covers-prd: FR-001
The page must call select and info endpoints when loading EPROC00116. Select requires `applicationNo` and `langType` and returns option lists for `CCY`, `CCY_UNIT`, and `TYPE_OF_YEAR`. Info requires `applicationNo` and `isQuery`; it must query loan summary, `TB_FIN_STATEMENT_MAIN`, `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_INCOME_GI`, and `TB_FIN_STATEMENT_CASHFLOW_GI`, then return the current-case maps plus `haveData`.

Target parity expects `haveData=Y` only when the main record and all three GI detail groups needed for print/export exist. Current backend sets `haveData` from main, Balance, and Income only, and omits Cashflow from that flag; this implementation gap is tracked under `PENDING-EPROC00116-HAVEDATA-CASHFLOW-PARITY`. If the current case is not query mode and the loan summary/application date is missing, the API returns business error `E126` / `FAILED_E126`.

Evidence: PRD FR-001 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:203-219`; current service option/info code at `CsuFinancialStatementServiceImpl.java:83-100`, `:156-182`; latest DB shape at reverify columns `:1223-1393`.

### R2 Query reference application without mutating current case - 強制點: both - covers-prd: FR-002
The reference query endpoint must accept `reApplicationNo`, validate the reference case through the current repository rule, and return main, Balance GI, Income GI, and Cashflow GI maps only when all source data is present. Missing loan-date/status or missing any financial statement group returns `FAILED_E116` and must not write to current-case tables or checkpoint.

Legacy allowed reference copy only for specific status/contract conditions and used `COMMOM_MSG_NO_DATA`; the official business meaning of those status values is pending under `PENDING-EPROC00116-REFERENCE-STATUS-CODES`.

Evidence: PRD FR-002 and AC at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:176`, `:802-804`; legacy reference status check at `EPROC0_0116_mod.java:382-387`; current service reference query and not-found behavior at `CsuFinancialStatementServiceImpl.java:111-145`.

### R3 Maintain main record and five financial-highlight text areas - 強制點: both - covers-prd: FR-003
Main data must carry `applicationNo`, `currency`, `currencyUnit`, company/audit fields, three criteria flags, audited-FS answers, and five highlight text areas: `loanRepaymentHT`, `financialSituationHT`, `businessRiskHT`, `borrowerRiskHT`, and `summaryHT`. Current API fields allow each highlight section up to 6000 characters; persistence splits each section into `_1` and `_2` columns of 3000 characters each.

On Finished, `currency`, `currencyUnit`, company name, audited-FS answers, and the five highlight text areas are required by current service validation. Legacy pipe-delimited `HIGHLIGHT` and latest `HIGHLIGHT_CLOB` handling remain pending under `PENDING-EPROC00116-HIGHLIGHT-MIGRATION`.

Currency formatting carries PRD BR-016: when `mainMap.currency = KHR`, FE amount inputs/display for Balance, Income, and Cashflow must use zero fraction digits; USD keeps decimal formatting. This is presentation/input formatting only and does not change DB numeric precision.

Evidence: PRD FR-003/data mapping at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:177`, `:628-635`; PRD BR-016/TC-008 at `:739`, `:807`; DTO lengths at `SaveCsuFinancialStatementCommentsRequest.java:19-92`; split/reassemble behavior at `CsuFinancialStatementServiceImpl.java:2106-2151`, `:2345-2349`; current FE currency formatting state at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-gi/financial-statement-gi.component.ts:143`, `:153`, `:246`, `:459-461`, and shared numeric fraction digits at `frontend/src/app/core/components/search-item/sub-components/input-number/input-number.component.html:13-14`.

### R4 Calculate and persist Balance Sheet GI rows - 強制點: BE - covers-prd: FR-004, FR-007
Balance rows are ordered by `DATA_SEQ`, use `BALANCE_DATE`, `PERIODS`, and `TYPE_OF_YEAR`, and persist the active GI columns in `TB_FIN_STATEMENT_BALANCE_GI`. Calculation must derive at least:

- `TOTAL_CUR_ASSETS` from current-asset fields.
- `NET_FIXED_ASSETS = LAND + BUILDING + EQUIPMENT + OTH_FIXED_ASSETS - DEPRECIATION_AMORTIZATION`.
- `NON_CUR_ASSETS` from fixed/non-current asset groups.
- `CUR_LIABILITIES`, `NON_CUR_LIABILITIES`, and `TOTAL_EQUITY` from their component fields.
- `TOTAL_ASSETS = TOTAL_CUR_ASSETS + NON_CUR_ASSETS`.
- `TOTAL_LIAB_EQUITY = CUR_LIABILITIES + NON_CUR_LIABILITIES + TOTAL_EQUITY`.
- `DIFFERENCE = TOTAL_ASSETS - TOTAL_LIAB_EQUITY`.

Finished state must reject rows where required Balance fields are blank. Calculation/result messages must include the unbalanced-sheet condition when first-year totals are zero or `DIFFERENCE != 0`.

Evidence: PRD formulas at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:853-861`; legacy formulas at `EPROC0_0116_mod.java:61-68`, `:903-923`; current calculation and result messages at `CsuFinancialStatementServiceImpl.java:716-918`; latest reverify Balance columns at `legacy_schema_reverify_new02_columns.tsv:1223-1273`.

### R5 Calculate and persist Income Statement GI rows - 強制點: BE - covers-prd: FR-005, FR-007
Income rows are ordered by `DATA_SEQ`, use the physical date column `IMCOME_DATE`, and persist the active GI columns in `TB_FIN_STATEMENT_INCOME_GI`. Calculation must derive:

- `GROSS_PROFIT = REVENUES - COST_OF_GOOD_SOLD`.
- `OPERATING_EXPENSES` from salary, commission, marketing, transportation, and utilities.
- `OPERATING_PROFIT = GROSS_PROFIT - OPERATING_EXPENSES`.
- `NON_OPERATING_INCOME` and `NON_OPERATING_EXPENSES` from their component fields.
- `PROFIT_BEFORE_TAX = OPERATING_PROFIT + NON_OPERATING_INCOME - NON_OPERATING_EXPENSES`.
- `ATTRIBUTED_TO_PARENT_COMP = CUR_PERIOD_PROFIT - MINORITY_INTERESTS`.

The SRS keeps physical typo columns such as `IMCOME_DATE` and `IMPAIMENT_LOSS` in schema until owner-approved mapping changes.

Evidence: PRD FR-005/formulas at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:179`, `:853-861`; legacy income formulas at `EPROC0_0116_mod.java:96-104`, `:945-970`; latest reverify Income columns at `legacy_schema_reverify_new02_columns.tsv:1330-1371`.

### R6 Calculate and persist Cashflow Statement GI rows - 強制點: BE - covers-prd: FR-006, FR-007
Cashflow rows are ordered by `DATA_SEQ`, use `CASHFLOW_DATE`, `PERIOD`, and `TYPE_OF_YEAR`, and persist the active GI columns in `TB_FIN_STATEMENT_CASHFLOW_GI`. Calculation must derive:

- For year N > 1, `OPENING_BALANCE(N)` from previous year `END_BALANCE`.
- `END_BALANCE = NET_I_D_IN_CASH + OPENING_BALANCE`.
- `OPERATING_NET_CASHFLOW = NET_I_D_IN_CASH - FINANCING_NET_CASHFLOW - INVESTING_NET_CASHFLOW` where applicable.

Finished state must reject rows where required Cashflow fields are blank. Calculation/result messages must include the cash-equivalent mismatch condition when `END_BALANCE` differs from Balance `CASH_EQUIVALENT`.

Evidence: PRD FR-006/formulas at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:180`, `:853-861`; legacy cashflow formulas at `EPROC0_0116_mod.java:161-162`, `:1005-1059`; current check at `CsuFinancialStatementServiceImpl.java:920-953`; latest reverify Cashflow columns at `legacy_schema_reverify_new02_columns.tsv:1287-1299`.

### R7 Save draft/Finished as full replacement in one transaction - 強制點: FE; BE hardening pending - covers-prd: FR-008
Save and Finished use the same save endpoint. The backend must validate `applicationNo` and `isFinish`, load loan summary, validate fields according to draft vs Finished mode, save the main record, delete existing Balance/Income/Cashflow rows for the `applicationNo`, insert the submitted rows in request order, and update the checkpoint in one transaction.

Current checkpoint polarity is `isFinish=false -> EPROC00116 = "Y"` and `isFinish=true -> EPROC00116 = "N"` in the new `TB_CHECK_POINTS_CS` or `TB_CHECK_POINTS_CU` table. Any failure after delete must roll back the main/detail/checkpoint writes. Save is not safe for automatic client retry.

Finished may only proceed after successful Calculation and a balanced result: Balance `DIFFERENCE` must be zero and Cashflow `END_BALANCE` must equal Balance `CASH_EQUIVALENT`. Current FE blocks Finished while recalculation is required and displays the calculation-required warning, but current backend save evidence does not prove save-time recomputation or revalidation of `DIFFERENCE` / `END_BALANCE` vs `CASH_EQUIVALENT`. The to-be backend must harden save-time Finished validation before approval; until `PENDING-EPROC00116-PARITY-CODE-VERIFY` is closed, QA-018 is an FE oracle plus no-mutation assertion, not proof of current BE rejection for a direct imbalanced Finished payload.

Evidence: PRD transaction/idempotency at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:621-624`; PRD AC-006/AC-007 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:790-791`; legacy transaction at `EPROC0_0116_mod.java:497-552`; current calc result check at `CsuFinancialStatementServiceImpl.java:223-233`, `:920-953`; current save path calls `validateFields` and then writes rows/checkpoint at `CsuFinancialStatementServiceImpl.java:271-340`, with required-field validation at `:1358-1397` and no save-time `checkResult`; current FE Finished block at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-gi/financial-statement-gi.component.ts:692-715`; latest checkpoint columns at reverify `:128`, `:144`.

### R8 Export Excel and PDF only from complete persisted data - 強制點: both - covers-prd: FR-009, FR-010
PDF and Excel export endpoints must require `applicationNo`, load loan summary, main record, and all three GI detail groups from persisted data, and fail with `FAILED_E116` or platform-equivalent download error when any required group is missing. Export must be POST and must not rely on unsaved UI state. Successful Excel uses a binary download response; successful PDF uses the platform PDF/download response.

Report template naming and ownership are not closed because current code uses i0 template paths for c0 GI; this remains `PENDING-EPROC00116-REPORT-TEMPLATE-OWNERSHIP`.

Evidence: PRD FR-009/010 and export AC at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:183-184`, `:813-814`; current PDF/Excel logic at `CsuFinancialStatementServiceImpl.java:352-390`, `:395-466`; build task export constraints at `docs/build-tasks/done/phase-f-step2-00116-financial-statement-gi.md:23-27`.

### R9 Preserve GI downstream contract and checkpoint routing - 強制點: both - covers-prd: FR-011
EPROC00116 must preserve persisted GI data for downstream Financial Evaluation GI. The active schema route is unified to `TB_CHECK_POINTS_CS.EPROC00116` for `LON_ATTRIBUTE + SECURE_ATTRIBUTE = "CS"` and `TB_CHECK_POINTS_CU.EPROC00116` otherwise. The legacy `EPROC0_0117`/`EPROC0_0217` next-page checkpoint behavior is source evidence; the new system must not alter Balance/Income/Cashflow row order, `DATA_SEQ`, or physical column names without an owner decision and migration plan.

Because the broader c0 parity task still marks EPROC00116 as parity-gated, final keep/fix disposition is pending under `PENDING-EPROC00116-PARITY-CODE-VERIFY`.

Evidence: PRD downstream and checkpoint rules at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:155-160`, `:185`, `:724-738`; current checkpoint route at `CsuFinancialStatementServiceImpl.java:331-340`; matrix/parity evidence at `per-page-reinventory-matrix.md:38`, `c0-legacy-parity-recheck.md:27`.

### R10 Enforce validation, authorization, safe errors, and safe logging - 強制點: both - covers-prd: FR-001, FR-002, FR-007, FR-008, FR-009, FR-010
All seven endpoints require platform authorization using their exact `TB_API_AUTH.API_ID` rows. Mutating endpoints must also rely on backend-side case/edit authorization, not only hidden UI controls, but the current service-level guard proof is missing and tracked under `PENDING-EPROC00116-SERVICE-AUTHZ`. Request validation must produce controlled EPRO/API errors for blank `applicationNo`, blank `isFinish`, missing calculation lists, invalid numeric/date fields, missing Finished fields, no-data, save failure, calculation failure, and download/export failure.

The contract must recognize legacy/current message keys and current service errors: `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `MSG_ERROR_APPLICATION_NO`, `COMMON_MSG_TOTAL_FAIL`, `COMMON_MSG_ERROR_LON`, `COMMON_MSG_PRINT_FAIL`, `COMMON_MSG_DOWNLOAD_SUCCESS`, `COMMON_MSG_DOWNLOAD_FAIL`, `COMMON_MSG_SAVE_SUCCESS`, `COMMON_MSG_SAVE_FAIL`, `MSG_EXPORT_SUCCESS`, `COMMOM_MSG_NO_DATA`, `EPROI0_0160_MSG_ERRO_CURRENCY`, `EPROI00119_MSG_VALIDATE_004`, `E116` / `FAILED_E116`, and `E126` / `FAILED_E126`. Current `ReturnEnum` business errors use the EPRO `code/message/data` envelope with HTTP 200; HTTP 401 is reserved for authorization errors such as `E405`/`E498`. Logs must not include full financial statement payloads or sensitive personal data.

Evidence: PRD error and security requirements at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:754-774`; legacy error keys at `EPROC0_0116.java:70-84`, `:106-120`, `:156-159`, `:190-221`, `:247-260`; current DTO validation at `SaveCsuFinancialStatementCommentsRequest.java:19-47` and `CalcCsuFinancialStatementCommentsRequest.java:13-27`; auth findings at `docs/build-tasks/c0-authz-sql-findings.md:153-159`.

### R11 Recalculate after amount edits and hide export actions - 強制點: FE - covers-prd: FR-007, FR-009, FR-010
After a successful Calculation, any user edit to Balance, Income, or Cashflow amount fields must mark the page as needing Calculation again, show/enable the Calculation action for editable users, hide Print/Excel and PDF actions, and block Finished until Calculation is rerun successfully. Reference-application copy also counts as data replacement and must follow the same "needs Calculation / hide Print/PDF" behavior before Save/Finished.

Print/Excel and PDF may only be visible again when the page has complete persisted data per R8 and the current unsaved UI state is not marked as needing recalculation. This carries PRD BR-006 and AC-005 instead of leaving them as pending.

The same FE state must preserve BR-016 currency formatting: changing currency calls `setNumberIsDecimal`, KHR amount fields show/input zero decimals, and USD fields show/input decimal formatting.

Evidence: PRD BR-006 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:729`; PRD AC-005 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:789`; PRD BR-016/TC-008 at `:739`, `:807`; reference-copy hide/recalculate behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md:248`; current GI FE `valueChanges` handler sets `needCalculate=true` and `canShowPrintBtn=false` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-gi/financial-statement-gi.component.ts:316-329`; Calculation clears `needCalculate` at `:584-608`; Finished blocks with `E_CHECK_CALCULATE` while `needCalculate` is true at `:692-715`; current FE currency formatting state at `:143`, `:153`, `:246`, `:459-461`, and shared numeric fraction digits at `frontend/src/app/core/components/search-item/sub-components/input-number/input-number.component.html:13-14`.

### R12 @PENDING PENDING-EPROC00116-OPEN-DECISIONS - 強制點: both - covers-prd: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011
The following items are C-class or owner-owned decisions. This bundle records them but does not decide them.

| ID | Owner | Impact | Evidence | Status |
|---|---|---|---|---|
| PENDING-EPROC00116-REFERENCE-STATUS-CODES @PENDING | PM / SA | Reference application copy can accept or reject the wrong cases. | PRD TBD-001 at `:55`; legacy status/contract check at `EPROC0_0116_mod.java:382-387`; current `getApplicationDateByCaseProgess` path at `CsuFinancialStatementServiceImpl.java:111-133`. | Open |
| PENDING-EPROC00116-LEGACY-ACTION-AND-MESSAGE-COMPAT @PENDING | SA / RD | Compatibility tests may require legacy typo names/keys or new canonical mapping. | PRD TBD-002/003/004 at `:56-58`; legacy `inti` at `EPROC0_0116.java:50`; legacy `COMMOM_MSG_NO_DATA` at `EPROC0_0116_mod.java:386-387`; JS key `EPROI00119_MSG_VALIDATE_004` at `EPROC00116_JS.jsp:270-272`. | Open |
| PENDING-EPROC00116-FIVE-YEAR-REQUIREDNESS @PENDING | PM / SA / QA | Finished validation can diverge between full five-year requirement and at-least-one-year behavior. | PRD TBD-005 at `:59`; JS validates `BALANCE_DATE_0..4` at `EPROC00116_JS.jsp:213-217`; payload skips blank dates at `:612-617`; current save DTO initializes missing arrays at `SaveCsuFinancialStatementCommentsRequest.java:612-623`. | Open |
| PENDING-EPROC00116-FIELD-TYPO-MAPPING @PENDING | DBA / SA / RD | Public API names, entity names, and physical DB names can drift during migration. | PRD TBD-006 at `:60`; db-diff typo columns `IMCOME_DATE`, `IMPAIMENT_LOSS`, `SHARDHOLDERS_LOAN`, `AP_RELATED_PARITIES` at `TB_FIN_STATEMENT_INCOME_GI.md:40`, `:70`, `TB_FIN_STATEMENT_BALANCE_GI.md:69`, `:80`. | Open |
| PENDING-EPROC00116-HIGHLIGHT-MIGRATION @PENDING | DBA / SA / RD | Old pipe-delimited `HIGHLIGHT`, latest split fields, and `HIGHLIGHT_CLOB` can lose or mis-split text. | PRD TBD-007 at `:61`; legacy pipe split at `EPROC00116_JS.jsp:711-721`; latest main columns at reverify `:1372-1393`; current split and null `HIGHLIGHT_CLOB` at `CsuFinancialStatementServiceImpl.java:2106-2151`. | Open |
| PENDING-EPROC00116-REPORT-TEMPLATE-OWNERSHIP @PENDING | SA / RD / QA | PDF/Excel output may use i0-owned template names for c0 GI. | PRD TBD-008 at `:62`; PDF/Excel paths at `CsuFinancialStatementServiceImpl.java:381-385`, `:441-461`; FE build task note at `phase-f-step2-00116-financial-statement-gi.md:27`. | Open |
| PENDING-EPROC00116-CALC-CHECKPOINT-SIDE-EFFECT @PENDING | SA / RD | Calculation currently mutates checkpoint, while PRD frames checkpoint update under Save/Finished. | PRD flow at `:136-137`; current calc checkpoint write at `CsuFinancialStatementServiceImpl.java:247-257`. | Open |
| PENDING-EPROC00116-PXLS-AUTHZ-SEED @PENDING | RD / Security / Ops | Excel endpoint can return 403 or remain unseeded even though route exists. | Auth finding says no c0 row and no exact i0 source row at `docs/build-tasks/c0-authz-sql-findings.md:159`, `:192`; inventory notes endpoint auth rollout at `docs/feature-inventory.md:196`. | Open |
| PENDING-EPROC00116-SAVE-LIST-BE-VALIDATION @PENDING | RD | Save with missing or empty main/detail lists may produce unclear validation semantics. | DTO fields are `@Valid` only at `SaveCsuFinancialStatementCommentsRequest.java:30-47`; current service loops after `request.init()` at `CsuFinancialStatementServiceImpl.java:1358-1397`; PRD TBD-005 remains open. | Open |
| PENDING-EPROC00116-PARITY-CODE-VERIFY @PENDING | RD / QA / Controller | Final keep/fix/rebuild disposition and save-time Finished balance-gate hardening cannot be closed from this worker bundle. | Matrix row marks EPROC00116 parity `?` at `per-page-reinventory-matrix.md:38`; parity task lists this page for calc/comments recheck at `c0-legacy-parity-recheck.md:27`; current save path `CsuFinancialStatementServiceImpl.java:271-340` does not show save-time `checkResult` / balance-cashflow revalidation. | Open |
| PENDING-EPROC00116-HAVEDATA-CASHFLOW-PARITY @PENDING | SA / RD / QA | Current info can return `haveData=Y` even when Cashflow rows are missing, while export requires Cashflow. | Current service sets `haveData` without `sql5Entities` at `CsuFinancialStatementServiceImpl.java:185-186`, but PDF/Excel require SQL5 at `:371-372`, `:421-425`. | Open |
| PENDING-EPROC00116-SERVICE-AUTHZ @PENDING | RD / Security | Save/calc/export may rely on platform API auth without proven backend case/edit or case ownership guard. | Controller/service evidence shows endpoint auth path, but no page-level edit guard before save/checkpoint writes at `CsuFinancialStatementServiceImpl.java:270-340`. | Open |

## New-vs-Old DB Delta / Reconcile
| Source fact | Disposition | Rule impact | Evidence |
|---|---|---|---|
| `TB_FIN_STATEMENT_MAIN` in db-diff/legacy has 12 columns, old PK `APPLICATION_NO`, and `HIGHLIGHT LONG`; latest reverify/current entity has 22 columns, PK `APPLICATION_NO, CURRENCY`, split 3000-char highlight fields, and `HIGHLIGHT_CLOB`. | carried with pending migration | R3, R7, R12 | db-diff `TB_FIN_STATEMENT_MAIN.md:23-41`; latest reverify `legacy_schema_reverify_new02_columns.tsv:1372-1393`, PK `..._pk.tsv:159-160`; current entity/service split at `CsuFinancialStatementServiceImpl.java:2106-2151`. |
| `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_INCOME_GI`, and `TB_FIN_STATEMENT_CASHFLOW_GI` remain active/exact detail tables with PK `APPLICATION_NO, DATA_SEQ`; latest reverify confirms columns and PKs. | carried | R4, R5, R6, R7, R9 | db-diff active/exact evidence; latest reverify columns `:1223-1273`, `:1287-1299`, `:1330-1371`; PKs `..._pk.tsv:151-158`. |
| Physical typo columns are present in active schema and must remain in DDL until migration mapping is approved. | carried / pending | R5, R12 | PRD TBD-006; db-diff typo lines; latest reverify lines `:1247`, `:1254`, `:1265`, `:1332`, `:1362`. |
| New checkpoint tables expose `TB_CHECK_POINTS_CS.EPROC00116` and `TB_CHECK_POINTS_CU.EPROC00116`; legacy PRD still references CORP/CU and RC_CORP/RC_CU names. Latest reverify has the full active CS/CU column set and is wider than older db-diff. | carried with stale-source note | R7, R9 | PRD checkpoint table `:155-158`; db-diff CS/CU `EPROC00116` at `TB_CHECK_POINTS_CS.md:47`, `TB_CHECK_POINTS_CU.md:43`; latest reverify checkpoint columns `legacy_schema_reverify_new02_columns.tsv:120-151`, PKs `:35-36`; current service route `CsuFinancialStatementServiceImpl.java:331-340`. |
| `TB_API_AUTH` exists with PK `API_ID`; six of seven endpoint rows have usable seed evidence while pxls remains explicitly missing/source-missing. | carried / pending | R10, R12 | reverify `TB_API_AUTH` columns `:1-5`, PK `:1`; auth findings `docs/build-tasks/c0-authz-sql-findings.md:153-159`, `:192`, `:196`. |

## @PENDING Register
| ID | Owner | Impact | Evidence | Status |
|---|---|---|---|---|
| PENDING-EPROC00116-REFERENCE-STATUS-CODES @PENDING | PM / SA | Reference application copy can accept or reject the wrong cases. | PRD TBD-001; legacy status/contract check; current reference query path. | Open |
| PENDING-EPROC00116-LEGACY-ACTION-AND-MESSAGE-COMPAT @PENDING | SA / RD | Legacy action and message typo compatibility can break conversion/regression tests. | PRD TBD-002/003/004; `inti`; `COMMOM_MSG_NO_DATA`; `EPROI00119_MSG_VALIDATE_004`. | Open |
| PENDING-EPROC00116-FIVE-YEAR-REQUIREDNESS @PENDING | PM / SA / QA | Finished validation can require all five years or allow partial-year payloads. | PRD TBD-005; JS date validation vs payload skip. | Open |
| PENDING-EPROC00116-FIELD-TYPO-MAPPING @PENDING | DBA / SA / RD | API/entity/schema naming can diverge for typo physical columns. | PRD TBD-006; db-diff/reverify typo columns. | Open |
| PENDING-EPROC00116-HIGHLIGHT-MIGRATION @PENDING | DBA / SA / RD | Highlight data can lose delimiter structure or ignore `HIGHLIGHT_CLOB`. | PRD TBD-007; legacy pipe highlight; latest split/CLOB columns; current `setHighlightClob(null)`. | Open |
| PENDING-EPROC00116-REPORT-TEMPLATE-OWNERSHIP @PENDING | SA / RD / QA | Export/PDF output can use wrong i0/c0 template ownership. | PRD TBD-008; current template paths; FE task note. | Open |
| PENDING-EPROC00116-CALC-CHECKPOINT-SIDE-EFFECT @PENDING | SA / RD | Calculation mutates checkpoint before Save/Finished decision. | Current calc writes checkpoint; PRD places checkpoint in save flow. | Open |
| PENDING-EPROC00116-PXLS-AUTHZ-SEED @PENDING | RD / Security / Ops | Excel route may be unauthorized in target DB. | c0 auth findings for pxls missing/source missing. | Open |
| PENDING-EPROC00116-SAVE-LIST-BE-VALIDATION @PENDING | RD | Missing save maps/lists may produce unclear validation semantics. | DTO `@Valid` only plus `init()` empty-list behavior. | Open |
| PENDING-EPROC00116-PARITY-CODE-VERIFY @PENDING | RD / QA / Controller | Final parity disposition and save-time Finished balance-gate hardening remain unclosed. | Matrix and c0 legacy parity recheck keep EPROC00116 gated; current save path has required-field validation but no save-time balance/cashflow recheck. | Open |
| PENDING-EPROC00116-HAVEDATA-CASHFLOW-PARITY @PENDING | SA / RD / QA | `haveData` can disagree with export completeness when only Cashflow is missing. | Current info omits Cashflow from `haveData`; export requires Cashflow. | Open |
| PENDING-EPROC00116-SERVICE-AUTHZ @PENDING | RD / Security | Mutating/export endpoints need proven case/edit authorization beyond API seed rows. | Service-level guard proof UNFOUND before save/checkpoint writes. | Open |

## Traceability
| PRD requirement | SRS rules | QA |
|---|---|---|
| FR-001 | R1, R10, R12 | QA-001, QA-002, QA-015, QA-P01, QA-P10, QA-P11 |
| FR-002 | R2, R10, R12 | QA-003, QA-004, QA-015, QA-P01 |
| FR-003 | R3, R7, R12 | QA-005, QA-010, QA-019, QA-020, QA-P02 @PENDING, QA-P04, QA-P05 |
| FR-004 | R4, R7, R12 | QA-006, QA-010, QA-017, QA-018, QA-020, QA-P03, QA-P04 |
| FR-005 | R5, R7, R12 | QA-007, QA-010, QA-P04 |
| FR-006 | R6, R7, R12 | QA-008, QA-010, QA-017, QA-018, QA-020, QA-P03 |
| FR-007 | R4, R5, R6, R10, R11, R12 | QA-006, QA-007, QA-008, QA-015, QA-016, QA-017, QA-018, QA-019, QA-020, QA-P07 |
| FR-008 | R7, R9, R10, R12 | QA-009, QA-010, QA-013, QA-014, QA-015, QA-017, QA-018, QA-020, QA-P08, QA-P09, QA-P12 |
| FR-009 | R8, R10, R11, R12 | QA-011, QA-012 @PENDING, QA-016, QA-P06, QA-P08, QA-P12 |
| FR-010 | R8, R10, R11, R12 | QA-011, QA-012 @PENDING, QA-016, QA-P06, QA-P08 |
| FR-011 | R9, R12 | QA-013, QA-P10 |

## Source Gaps
- No finalized parity findings file for EPROC00116 was found in this worker scope; matrix and parity task still require c0 code-vs-legacy verification, and current backend save evidence does not prove save-time balance/cashflow revalidation for direct imbalanced Finished payloads. The bundle therefore keeps save-time Finished hardening under `PENDING-EPROC00116-PARITY-CODE-VERIFY`.
- Latest DB evidence conflicts with older db-diff/legacy `TB_FIN_STATEMENT_MAIN.HIGHLIGHT` shape. `schema.sql` follows latest reverify/current entity, but migration semantics remain `@PENDING`.
