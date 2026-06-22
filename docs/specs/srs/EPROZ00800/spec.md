# SRS - EPROZ00800 Revised Item

## Metadata
| Field | Value |
|---|---|
| Status | 規格定版: in-review candidate / 實作完成: not asserted |
| Owner | PM/SA/RD/QA review |
| funcId | EPROZ00800 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md` |
| Bible | `docs/specs/bible/bible-eproposal.md` |
| Bundle | `docs/specs/srs/EPROZ00800/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec + legacy/current source evidence |

## Scope
- In scope: Revised Item page initialization, query, item display, validation, save, side-effect restore/delete behavior, checkpoint/page-menu reprocessing, error responses, authorization, and audit expectations for EPROZ00800.
- In scope: New DB/refactor reconciliation for the Revised Item contract, with open owner decisions retained as `@PENDING`.
- Terminology: `shared` / `common` means EPROZ00800 is a reusable common module in the case-edition page framework; it does not mean every case must show or complete the tab.
- Non-goal: code table maintenance for `REVISED_ITEM`, full migration of downstream pages, report rebuild, or approval of open C-class decisions.
- This bundle stops at `in-review candidate`; it does not self-declare `Approved`.

## Sources
| Source | Evidence |
|---|---|
| PRD control/TBD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:24`-`56` |
| PRD behavior | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:143`-`158`, `176`-`260`, `274`-`315` |
| PRD API/error/DB/QA | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:324`-`384`, `386`-`459` |
| Archived v0.9 input | `docs/archive/EPROZ00800-v0.9-superseded/README.md`; `docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md:97`-`116` |
| Pending register | `docs/pending-register.md:10`-`11`, `40`-`52`, `58`-`71` |
| db-diff Revised Item | `docs/db-diff/02_tables/TB_REVISED_ITEM.md:1`-`17`, `32`-`51`; `docs/db-diff/02_tables/TB_REVISED_ITEM_DETAIL.md:1`-`18`, `32`-`52` |
| db-diff summary/checkpoint | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:1`-`19`, `32`-`84`; `docs/db-diff/02_tables/TB_CHECK_POINTS_IS.md:1`-`18`, `38`-`55`; `docs/db-diff/02_tables/TB_CHECK_POINTS_IU.md:1`-`18`, `38`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:1`-`18`, `38`-`53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:1`-`18`, `38`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC.md:13`, `39`-`54`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_IU.md:13`, `39`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:13`, `39`-`52`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:13`, `39`-`51` |
| db-diff option names | `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:32`, `38`-`48`; `docs/db-diff/02_tables/TB_MULTI_LANG.md:32`, `38`-`40` |
| refactor-spec latest map | `docs/refactor-spec/02_modules/EPROZ00800.md:3`-`18` |
| refactor BE query | `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:6`-`14`, `65`-`87`, `111`-`160` |
| refactor BE save | `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:6`-`14`, `87`-`99`, `154`-`212` |
| refactor FE | `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:106`-`143`, `171`-`217` |
| PRD NFR | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:433`-`440` |
| implementation closeout | `docs/build-tasks/00800-implementation-closeout-findings.md`; SELECT-only auth proof `docs/build-tasks/00800-contract-closeout-authz.sql`; pending DB backfill `docs/build-tasks/00800-contract-closeout-authz-backfill.sql` |
| legacy Revised Item | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:177`-`263`, `607`-`609`, `675`-`694` |
| current backend | `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:38`-`54`; `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:18`-`81`; `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:163`, `182`-`208`, `220`-`225`, `381`-`423`, `428`-`520`, `545`-`595`, `679`-`782`, `845`-`907` |
| current frontend | `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:13`-`27` |

## Endpoints
| Endpoint | Method | Purpose | Covers | Baseline |
|---|---|---|---|---|
| `/api/eproposal/eproz00800/prompt` | GET | Initialize page attributes and visibility for EPROZ00800 | R1, R16 | PRD prompt/routing API; not an `epl-*` RPC endpoint |
| `epl-case-query-reviseditem` | GET | Query loan type, customer/security attributes, current Revised Item values, and display options | R2, R5, R6 | Target contract is OpenAPI GET query parameter. Implementation closeout updated current BE/FE to GET query semantics; latest refactor POST text remains historical delta captured in REF-D2. |
| `epl-case-insert-reviseditem` | POST | Save Revised Item and execute side effects/checkpoints in one transaction | R8, R9, R10, R11, R12, R13, R14, R15, R16, R17 | Target request is final per RP11; BP4 target response is the platform success envelope, and FE refreshes tab state by re-calling `epl-auth-tab-control`. Current BE `pageMenuCondition` output is tolerated legacy/refactor drift captured in REF-D5. |

## Requirements

### R1 Page initialization and visibility **強制點 both**
covers-prd: REQ-001

When a user enters EPROZ00800 through the prompt/routing entry, the system must obtain the case application number, `lonTypeCode`, editability, and CU/secured attributes before rendering the Revised Item form. The Bible case-type axis maps to backend-owned `TB_LON_SUMMARY_INFO.LON_TYPE_CODE`: `01=New`, `02=Additional`, `03=Renew` / 展期, `04=Change Condition` / 展變, and `05=Restructure` when present in `TB_LON_TYPE`; it is distinct from customer/page-family predicates such as `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, `caseCategory`, and `ISU` / `CSU`. EPROZ00800 is supported only when `LON_TYPE_CODE` is `03` or `04`. For any other `LON_TYPE_CODE`, tab-control/prompt must not expose EPROZ00800, and direct query/save calls must be rejected before returning Revised Item data or mutating DB, with HTTP 403 `ACCESS_DENIED` or the platform canonical forbidden-page envelope. Prompt initialization failure returns `MSG_INITIAL_FAIL`. BP1 is closed by the binary show/hide adjudication, BP2 is closed by the `LON_TYPE_CODE` mapping, and BP3 is closed as shared validation for `03` and `04`; the case-specific differences remain R5 and R13.3. BP5 is closed by terminology split: PRD/refactor `common/shared` classifies this as a reusable common module/tab config, while actual visibility remains conditional through backend-owned `LON_TYPE_CODE in ('03','04')` and `epl-auth-tab-control` `pageMap`; user-facing wording must not imply all cases must complete Revised Item. Evidence: Bible `docs/specs/bible/bible-eproposal.md:80`, `109`, `171`-`176`, `198`, `323`, `339`, `497`, `505`-`506`, `728`-`730`, `752`, `756`, `792`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:62`, `78`-`80`, `125`-`132`, `196`-`204`, `352`, `394`-`406`, `497`; db-diff `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:39`, `docs/db-diff/02_tables/TB_LON_TYPE.md:38`-`39`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:6`-`10`, `161`-`167`; legacy EPROZ00800 `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:37`-`51`, `101`-`103`, `117`-`120`, `135`-`153`; backend tab-control `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:50`, `277`, `302`-`303`; frontend visibility `frontend/src/app/pages/case-edition/config/case-edition-navlink.ts:7`, `36`-`40`, `frontend/src/app/core/models/pages/case-edition/case-edition-tab-control.ts:49`-`63`, `frontend/src/app/pages/case-edition/services/shared.service.ts:82`-`86`; current shared validation `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/config/validate-rule.ts`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:136`-`144`, `176`-`198`, `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:59`-`79`.

### R2 Query Revised Item state **強制點 both**
covers-prd: REQ-002

`epl-case-query-reviseditem` must accept `applicationNo` as a query parameter, reject blank input with HTTP 400 and top-level `code=COMMON_MSG_ERROR_LON`, read `TB_LON_SUMMARY_INFO` for `LON_TYPE_CODE`, `LON_ATTRIBUTE`, and `SECURE_ATTRIBUTE`, read `TB_REVISED_ITEM` for `ITEM1` through `ITEM14`, `REASON_MEMO`, and `UPD_DATE`, and return blank item values when no Revised Item row exists. The response must include backend-computed `isCorporateUnsecured`, true only when `LON_ATTRIBUTE='C'` and `SECURE_ATTRIBUTE='U'`, so the FE does not infer CU from `SECURE_ATTRIBUTE` alone. Field-validation detail may appear only under error `data`. Query failures return `MSG_QUERY_FAIL`; no matching case returns `MSG_DATA_NOT_FOUND`; over-limit query failures return `MSG_OVER_COUNT_LIMIT`.

Implementation closeout evidence: BE now binds the GET query through `@ModelAttribute`, FE calls `apiGetRequest` with an `applicationNo` query parameter, and controller tests cover query-param success/validation.

### R3 Revised Item display option names **強制點 both**
covers-prd: REQ-002, REQ-003

The UI must display the 14 Revised Item options by their approved `REVISED_ITEM` code-table names. RP6 closed the formal names from prior DB evidence, but the current PRD still marks TBD-001; this SRS carries the closed decision and requires QA to verify labels against code-table/reference data. Code-table maintenance remains out of scope.

| Item | Display baseline | Side-effect group |
|---|---|---|
| item1 | Renew Loan Tenor | Loan tenor / renewal gating |
| item2 | Guarantor | guarantor and borrower flag |
| item3 | Collateral | collateral and collateral provider flag |
| item4 | Approved Terms and Conditions - Loan Purpose | loan condition detail |
| item5 | Approved Terms and Conditions - Loan Amount | loan condition detail |
| item6 | Approved Terms and Conditions - Facility Type | loan condition detail |
| item7 | Approved Terms and Conditions - Repayment Mode | loan condition detail |
| item8 | Approved Terms and Conditions - Repayment Frequency | loan condition detail |
| item9 | Approved Terms and Conditions - Grace Period | loan condition detail |
| item10 | Approved Terms and Conditions - Tenor | loan condition detail |
| item11 | Approved Terms and Conditions - Interest Rate | loan condition detail |
| item12 | Approved Fees | loan condition fee |
| item13 | Disbursement Terms and Conditions | persist only unless new evidence is approved |
| item14 | Other Conditions from Approver | persist only unless new evidence is approved |

### R4 Client and backend validation **強制點 both**
covers-prd: REQ-003, REQ-004

At least one item must be selected before save. `item1` through `item14` may only be `Y` or `N` on execute; query response may carry blank values for a never-saved row. `reasonMemo` is required, trimmed, and capped at 3000 characters for execute. The physical DB column is wider (`TB_REVISED_ITEM.REASON_MEMO VARCHAR2(4000)`), but the input contract must not silently expand beyond PRD/current DTO validation. Blank or non-`Y/N` item flags in execute requests are rejected with HTTP 400 and top-level `code=COMMON_MSG_ERROR_LON`; field-validation detail may appear only under error `data`, and execute must never store blank item flags. BP3 adjudication: this R4 validation matrix is shared by `03=Renew` and `04=Change Condition`; do not create separate mandatory-item, reason, or item-flag validation sets unless a later source-backed PRD/owner decision supersedes this SRS.

### R5 ITEM1 loan type rule **強制點 FE**
covers-prd: REQ-003

When `LON_TYPE_CODE=03` (`Renew` / 展期), the UI must force `item1=Y` and make the control non-editable. When `LON_TYPE_CODE<>03`, including `04=Change Condition`, the UI must force `item1=N` and make the control non-editable. RP2 closed the business reason from archived evidence: item1 is renewal loan tenor, so renewal cases require it by definition. This is the closed `03` case-specific default/lock rule, not a separate validation matrix from R4.

### R6 ITEM3 CU rule **強制點 FE**
covers-prd: REQ-003

When the case is corporate unsecured, the UI must force `item3=N` and make the control non-editable. RP8 is closed by owner/RD adjudication: `secureAttribute='U'` alone is rejected because it also matches individual-unsecured cases and is not equivalent to legacy `attrMap.isCU`. The to-be predicate is backend-owned corporate unsecured, defined as `LON_ATTRIBUTE='C' AND SECURE_ATTRIBUTE='U'`; the query/prompt contract must expose `isCorporateUnsecured` or an equivalent backend-computed flag, and FE must not derive the lock from `SECURE_ATTRIBUTE` alone. Implementation closeout updated current BE to compute `isCorporateUnsecured` and current FE to consume it; latest refactor `secureAttribute='U'` text remains historical delta evidence.

### R7 Editability / field authorization **強制點 both**
covers-prd: REQ-003

When editability is false, all Revised Item controls and save/finish actions must be hidden or disabled in the UI, and backend mutation must still enforce authorization instead of relying on FE-only hiding. Legacy `isEdit` is a coarse page predicate derived from editor role and non-query action, and the JSP disables `.isView` controls and hides `#btnFinshed` when it is false. RP8 is closed by owner/RD adjudication: the refactor/current granular FE model using `epl-auth-tab-control` `isEdit` plus `epl-auth-page-column` `isShowList` / `canEditList` is accepted as the UI model, but it is not proof of equivalence to legacy `isEdit`. Backend execute must reject direct mutation using backend-owned page/edit authorization before any DB write; API-level `TB_API_AUTH` alone is insufficient. Implementation closeout added a service-level guard for `revised.item`, `reason.item`, and `button.butSave` / `button.butFinish`, plus tests for rejection before mutation. SELECT-only DB proof found `revised.item` and button rows but currently misses `reason.item`; `docs/build-tasks/00800-contract-closeout-authz-backfill.sql` must be DBA/RD-applied or otherwise resolved before approval.

### R8 Change warning before destructive save **強制點 FE**
covers-prd: REQ-004, REQ-005

If existing item state differs from the requested state, the UI must warn the user that removing or changing Revised Item selections can clear related modifications. The prompt is skipped only for the first save when no prior `TB_REVISED_ITEM` row exists and all prior item values are blank/N. User confirmation is represented by `isNotSame`, but that flag is only evidence that the warning was shown; it is not the authoritative side-effect trigger.

### R9 Transaction and DB-side comparison **強制點 BE**
covers-prd: REQ-004, REQ-005, REQ-006

`epl-case-insert-reviseditem` must run in a single transaction. The backend must read the current `TB_REVISED_ITEM` state, normalize missing values to `N`, compare it with the normalized request item state, and use that DB-side comparison as the authoritative trigger for all side effects. Failure during Revised Item save, side-effect restore/delete, or checkpoint update must roll back every write and return `COMMON_MSG_SAVE_FAIL`.

### R10 Persist Revised Item row **強制點 BE**
covers-prd: REQ-004

Execute must delete the current `TB_REVISED_ITEM` row for `applicationNo` and insert one row with `APPLICATION_NO`, `ITEM1` through `ITEM14`, `REASON_MEMO`, and `UPD_DATE`. The saved item flags are exactly `Y` or `N`; `reasonMemo` is trimmed and no longer than 3000 input characters.

### R11 Execute request shape **強制點 both**
covers-prd: REQ-004

The target execute request is final: `applicationNo`, required boolean `isFinish`, required boolean `isNotSame`, and `itemMap.item1` through `item14` plus `itemMap.reasonMemo`. `checkPointMap` is not a client-owned request field in the to-be contract. Legacy FE sent `checkPointMap` with `EPROZ0_0800=N`, but the to-be backend must derive checkpoint/page-menu updates from backend-owned case type, current DB state, side-effect decisions, and `isFinish`; client-supplied checkpoint keys must not drive persistence. `isNotSame` remains advisory evidence that FE showed the warning and is not the authoritative side-effect trigger.

### R12 RI-MAT guarantor and collateral side effects **強制點 BE**
covers-prd: REQ-005

- **R12.1** When `item2` changes from `Y` to `N`, delete the current case guarantor personal/corporate rows, restore guarantors from `REF_APPLICATION_NO` when reference data exists, and update borrower `IS_ANY_GUARANTOR` from reference state.
- **R12.2** When `item2` changes from `N` to `Y` and the reference application has no guarantor, set the current borrower guarantor flag to `Y`.
- **R12.3** When `item3` changes from `Y` to `N`, delete current collateral/valuation/site/title/provider/owner rows, restore from reference data when available, and update `IS_ANY_COLLATERAL_PROVIDER`.

These behaviors preserve the RP1 decision: keep legacy side effects, fix known implementation bugs, and leave an audit summary.

### R13 RI-MAT loan condition and fee side effects **強制點 BE**
covers-prd: REQ-005

- **R13.1** For the loan-condition item set `item1`, `item4`, `item5`, `item6`, `item7`, `item8`, `item9`, `item10`, and `item11`, delete current loan condition detail and revised item detail rows when either (a) existing DB state has at least one `Y` and requested state is all `N`, or (b) existing DB state is all `N` and requested state has at least one `Y`; then mark affected downstream tabs for reprocessing.
- **R13.2** Otherwise, when any item in the same loan-condition item set changes from `Y` to `N`, restore the corresponding original loan-condition fields into `TB_LOAN_CONDITION_DETAIL` and `TB_REVISED_ITEM_DETAIL`.
- **R13.3** When `LON_TYPE_CODE=04` (`Change Condition` / 展變), old `item12=N`, and new `item12=Y`, delete current `TB_LOAN_CONDITION_FEE` rows. This is the closed `04` side-effect branch, not a separate validation matrix from R4.
- **R13.4** When item13 or item14 changes, persist the selection only; no downstream side effect is triggered unless new owner-approved evidence supersedes RP5.

Loan amount, grace period, tenor, fixed/tier/base/FD rate fields must preserve DB precision and reject invalid precision or truncation at the service boundary.

RI-MAT as-is/current classification:

| Branch | Trigger | Legacy evidence | Current/refactor evidence | Three-way judgment |
|---|---|---|---|---|
| RI-MAT-001 | `item2` Y to N | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:206`-`263` deletes guarantors, restores from reference, and updates borrower flag | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:381`-`414`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:204`-`209` | carried, with bug-fix intent for reference parameters and audit evidence |
| RI-MAT-002 | `item2` N to Y and reference has no guarantor | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:185`-`187`, `255`-`263` set borrower guarantor flag when prior/reference state has no guarantor | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:415`-`423`, `825`-`834`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:210` | carried, with current implementation explicitly checking missing reference guarantor |
| RI-MAT-003 | `item3` Y to N | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:263`-`456` deletes/restores collateral-related data and updates collateral-provider flag | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:428`-`499`, `524`-`542`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:211`-`212` | carried, with bug-fix intent for collateral-provider flag and audit evidence |
| RI-MAT-004 | loan-condition item set all-off/delete transition | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:460`-`503` and archived decision `docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md:83` | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:679`-`701` currently differs by treating existing any-N plus request all-Y as delete | legacy carried as target; current condition is an implementation delta that must be fixed or owner-accepted before closeout; active checkpoint key delta handled by R14 |
| RI-MAT-005 | loan-condition item set Y to N restore | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:504`-`597` and archived decision `docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md:84` | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:712`-`782` | carried, with service-boundary precision validation required before update |
| RI-MAT-006 | `LON_TYPE_CODE=04`, old `item12=N`, new `item12=Y` | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:607`-`609`; archived decision `docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md:85` | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:512`-`520` | carried |
| RI-MAT-007 | `item13` or `item14` changes | No direct legacy downstream data-table side-effect branch was found; archived RP5 records persist-only as owner-closed, while legacy still performs generic page-menu/checkpoint completion writes | `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:667`-`676` persists flags and `845`-`907` performs generic page-menu/checkpoint writes | carried by closed RP5 for data-table side effects; generic checkpoint/page-menu behavior remains governed by R14 |

### R14 Checkpoint and page-menu update **強制點 BE**
covers-prd: REQ-006

Execute must update the active new checkpoint tables `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, or `TB_CHECK_POINTS_CU` according to backend-owned checkpoint family (`LON_ATTRIBUTE` + `SECURE_ATTRIBUTE` / `caseCategory`), not the `LON_TYPE_CODE` case-type axis and not the removed/unused old `TB_CHECK_POINT_RC` family tables. It must write the `EPROZ00800` self key and only approved downstream reprocess keys. BP4 adjudication: Revised Item downstream tab refresh may update `EPROISU0150` only for IS because `TB_CHECK_POINTS_IS` has that physical key, and `EPROCSU0150` only for CS because `TB_CHECK_POINTS_CS` has that physical key; IU/CU have no `0150` checkpoint key and must not synthesize one. `EPROISU0173`/`EPROCSU0173` are summary/read-display dependencies, not EPROZ00800 checkpoint/page-menu targets; field-level 0173 display/source mapping belongs to the 0173 bundles. The target FE refresh pattern is to re-call `epl-auth-tab-control` after save; save response does not need to carry authoritative page-menu keys. PRD legacy `_0260` names are trace labels, not the to-be DB contract. Evidence: Bible `docs/specs/bible/bible-eproposal.md:731`, `754`-`755`, `801`; db-diff `docs/db-diff/02_tables/TB_CHECK_POINTS_IS.md:44`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:44`, `docs/db-diff/02_tables/TB_CHECK_POINTS_IU.md:39`-`50`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:39`-`50`; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:845`-`907`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:27`-`32`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:200`-`202`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:216`.

### R15 Error response contract **強制點 both**
covers-prd: REQ-001, REQ-002, REQ-004, REQ-007

The SRS must carry every PRD error code in both rule text and OpenAPI:

| Code | HTTP | Applies to | Contract |
|---|---:|---|---|
| `MSG_INITIAL_FAIL` | 500 | init | Initialization/routing attribute failure |
| `COMMON_MSG_ERROR_LON` | 400 | query/execute | Blank or invalid application number |
| `MSG_DATA_NOT_FOUND` | 404 | query/execute | Case or required source data not found |
| `MSG_OVER_COUNT_LIMIT` | 400 | query | Query result limit exceeded |
| `MSG_QUERY_FAIL` | 500 | query | Query/repository failure |
| `COMMON_MSG_SAVE_FAIL` | 500 | execute | Save transaction failure / rollback |
| `COMMON_MSG_SAVE_SUCCESS` | 200 | execute | Successful save |

Field validation codes from current refactor evidence, such as `E102`, and PRD naked carriers such as `ErrorInputException message`, may appear as 400 field-validation detail inside the platform error envelope. They must not replace the PRD codes above without RD/SA mapping; when the platform cannot emit both, the SRS requires an explicit code-mapping decision before approval.

### R16 Authorization and security **強制點 BE**
covers-prd: REQ-001, REQ-004, REQ-005, REQ-006

Backend must authorize the prompt/routing entry, `epl-case-query-reviseditem`, and especially mutating `epl-case-insert-reviseditem` through platform route/API authorization and case/page authorization, not only FE button or field hiding. Direct mutation attempts by a role/user that cannot edit this page must be rejected before any Revised Item or side-effect table is changed. `SECURE_ATTRIBUTE`, `LON_ATTRIBUTE`, and `LON_TYPE_CODE` predicates must be read from backend-controlled sources and not trusted solely from the client.

Implementation closeout evidence: final `TB_API_AUTH` rows for `epl-case-query-reviseditem` and `epl-case-insert-reviseditem` were SELECT-verified with `REF_FUNCTION_ID=EPROZ00800`, and service-level edit guard evidence is present in code/tests. Remaining approval blocker: page-column auth data currently lacks `reason.item`, so DBA/RD must apply or otherwise resolve the backfill and re-run the SELECT-only closeout script before this security closeout can be treated as fully green.

### R17 Audit, logging, and rollback evidence **強制點 BE**
covers-prd: REQ-004, REQ-005, REQ-006, REQ-007

Execute must log an audit summary of side-effect categories, row counts, result, elapsed time, and operator context without logging full `reasonMemo`, borrower names, or sensitive payload contents. On exception, the audit entry records failure and the database transaction rolls back.

### R18 Operational NFR **強制點 both**
covers-prd: REQ-007

Prompt/query/execute observability and performance must carry the PRD non-functional criteria. Query-like init must target response time <= 3 seconds in normal cases. Execute must target response time <= 5 seconds in normal cases and complete within a configured transaction timeout <= 30 seconds, including maximum reasonable guarantor/collateral copy data. Every prompt, query, and execute attempt must log `requestId`, `applicationNo`, `userId`, `action`, result, elapsed time, and error code when present. Error responses and logs must not expose SQL text, stack traces, full personal data, full account/ID values, sensitive collateral document contents, full request payloads, or full `reasonMemo`. Failures must be traceable by `requestId` plus `applicationNo` to backend log and DB/audit state.

## 新舊 DB 對照 / 更動 delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_REVISED_ITEM` remains active/exact with PK `APPLICATION_NO`, 14 item flags, `REASON_MEMO VARCHAR2(4000)`, and `UPD_DATE`. | carried + constrained | `schema.sql` lists the physical 4000-byte column, while OpenAPI/execute caps `itemMap.reasonMemo` at 3000 per PRD/current DTO. Query response may expose up to 4000 from existing data. | `docs/db-diff/02_tables/TB_REVISED_ITEM.md:11`-`17`, `32`-`51`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:341`; DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:18` |
| DB-D2 `TB_REVISED_ITEM_DETAIL` remains active/exact and stores original application / original condition tuple plus item flags for loan-condition restore. | carried | `schema.sql` includes verification columns; R13.2 requires restore/update behavior rather than treating this as a free-form RD stub. | `docs/db-diff/02_tables/TB_REVISED_ITEM_DETAIL.md:11`-`18`, `32`-`52`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:284`-`286` |
| DB-D3 `TB_LON_SUMMARY_INFO` remains active/exact and is the backend source for `LON_TYPE_CODE`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, and `REF_APPLICATION_NO`. | carried | Query and execute must read these backend-owned values; client-supplied loan/case type values are not authoritative. BP2 closes the case-type mapping as `LON_TYPE_CODE`: `01=New`, `02=Additional`, `03=Renew`, `04=Change Condition`, `05=Restructure` when present; EPROZ00800 accepts only the `03`/`04` subset. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`19`, `38`-`51`; `docs/db-diff/02_tables/TB_LON_TYPE.md:38`-`39`; Bible `docs/specs/bible/bible-eproposal.md:323`, `752`, `792`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:393`-`395` |
| DB-D4 Old `TB_CHECK_POINT_RC` family tables are marked removed/unused and transferred to active `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, and `TB_CHECK_POINTS_CU`. | changed | R14 and `schema.sql` use active new checkpoint tables and new funcId-style keys. BP4 closes downstream mapping: IS/CS may update the physical 0150 keys; IU/CU have no 0150 key; 0173 is summary/read-display trace only, not an EPROZ00800 checkpoint/page-menu key. Legacy `_0260` names stay trace labels only. | Old removed/unused: `docs/db-diff/02_tables/TB_CHECK_POINT_RC.md:13`, `39`-`54`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_IU.md:13`, `39`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:13`, `39`-`52`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:13`, `39`-`51`. Active new and BP4 physical-key split: `docs/db-diff/02_tables/TB_CHECK_POINTS_IS.md:38`-`55`; `docs/db-diff/02_tables/TB_CHECK_POINTS_IU.md:38`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:845`-`907`; current FE refresh `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:200`-`202`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`; archived RP10 |
| DB-D5 `TB_COMMON_FIELD_OPTIONS` / `TB_MULTI_LANG` remain the option-name source, but code-table maintenance is outside this page. | carried | R3 requires display verification against the option source and does not create new option rows. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:208`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:65`-`87`; db-diff `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:32`, `38`-`48`; `docs/db-diff/02_tables/TB_MULTI_LANG.md:32`, `38`-`44` |
| DB-D6 Side-effect tables for guarantor, collateral, loan condition, fee, and borrower flags remain active operational dependencies. | carried | R12/R13 enumerate behavior and `schema.sql` lists relevant verification columns/comments; full ownership of downstream table design remains in their own page bundles. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:282`-`288`, `404`-`414`; db-diff borrower `docs/db-diff/02_tables/TB_MAIN_BORROWER_PERSONAL_INFO.md:32`, `38`-`39`, `80`, `84`; `docs/db-diff/02_tables/TB_MAIN_BORROWER_INFO_CORP.md:32`, `38`-`39`, `55`, `68`, `74`; db-diff side effects `docs/db-diff/02_tables/TB_GUARANTOR_INFO.md:32`, `38`-`40`, `80`, `84`; `docs/db-diff/02_tables/TB_GUARANTOR_INFO_CORP.md:32`, `38`-`40`, `56`, `68`; `docs/db-diff/02_tables/TB_COLL_INFO.md:32`, `38`-`41`, `72`; `docs/db-diff/02_tables/TB_COLL_VALUE_INFO.md:32`, `38`-`39`; `docs/db-diff/02_tables/TB_COLL_LTV.md:32`, `38`; `docs/db-diff/02_tables/TB_COLL_PROVIDER_INFO.md:32`, `38`-`42`, `58`; `docs/db-diff/02_tables/TB_COLL_TITLE_REGIS_OWNER.md:32`, `38`-`42`; `docs/db-diff/02_tables/TB_COLL_SITE_VISIT.md:32`, `38`-`39`; `docs/db-diff/02_tables/TB_COLL_TITLE_DETAIL.md:32`, `38`-`40`; `docs/db-diff/02_tables/TB_COLL_VALUE_DETAIL.md:32`, `38`-`41`; `docs/db-diff/02_tables/TB_CROSS_CHARGE_DETAIL.md:32`, `38`-`41`; `docs/db-diff/02_tables/TB_INSPE_AO.md:32`, `38`-`42`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:32`, `38`-`72`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_FEE.md:32`, `38`-`59`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:187`-`212` |
| DB-D7 `TB_API_AUTH` or equivalent platform route/API authorization must contain the final EPROZ00800 query/save API IDs before implementation closeout. | verified | SELECT-only closeout found both final API IDs present with `REF_FUNCTION_ID=EPROZ00800` and no duplicates. This closes the route/API seed portion, but does not close the separate page-column blocker for `reason.item` in R7/R16. | db-diff table shape `docs/db-diff/02_tables/TB_API_AUTH.md:1`, `32`, `38`-`42`; proof script `docs/build-tasks/00800-contract-closeout-authz.sql`; findings `docs/build-tasks/00800-implementation-closeout-findings.md` |
| REF-D1 Latest refactor map has four EPROZ00800 artifacts: BE query, BE insert, FE screen, FE reference. | carried | SRS anchors endpoint names and UI workflow to those selected latest artifacts, while marking mismatches as deltas. | `docs/refactor-spec/02_modules/EPROZ00800.md:3`-`18` |
| REF-D2 PRD/RP9 says query is GET; latest refactor query source still says POST; pre-closeout BE declared GET with request body and FE called POST. | changed + implemented | OpenAPI defines GET query parameter. Implementation closeout removed the GET body binding and updated FE call semantics; latest refactor POST text remains a historical delta. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:328`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:120`; controller `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:39`-`40`; FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:20`-`23`; findings `docs/build-tasks/00800-implementation-closeout-findings.md` |
| REF-D3 PRD/legacy mention or send `checkPointMap`; latest refactor/current DTO uses `itemMap`, `isNotSame`, `isFinish`, and backend-built page-menu response handling. | changed | RP11 adjudication closes the target request as `applicationNo` + required `isFinish` + required `isNotSame` + `itemMap`. `checkPointMap` is a legacy/PRD delta and must not be accepted as client-authoritative checkpoint input. Current DTO must be tightened if it still allows missing `isFinish`/`isNotSame`. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:240`-`260`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:155`-`160`; legacy module `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:149`-`150`, `687`-`704`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:123`, `127`, `129`, `192`-`203`; current DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:43`-`56`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:176`-`198` |
| REF-D4 Archived v0.9 closed RP1-RP7/RP9/RP10; RP8, RP11, BP1, BP2, BP3, BP4, and BP5 are closed in this regenerated bundle. | mixed | Closed items are carried where source evidence is stable; RP8 closes R6 as corporate-unsecured predicate parity and R7 as granular FE UI auth plus mandatory backend mutation guard; BP1 is closed as the binary `LON_TYPE_CODE in ('03','04')` page gate; BP2 is closed as the case-type mapping to `LON_TYPE_CODE`; BP3 is closed because `03` and `04` share R4 validation while R5/R13.3 hold the case-specific branches; BP4 is closed by splitting 0150 checkpoint/page-menu refresh from 0173 summary/read-display trace ownership; BP5 is closed by treating `shared/common` as module classification rather than all-case visibility. Implementation closeout now verifies DB-D7 API auth and adds service guard evidence; remaining approval blocker is the missing DB page-column `reason.item` mapping. | refactor latest map `docs/refactor-spec/02_modules/EPROZ00800.md:3`-`18`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:65`-`87`, `120`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`, `167`-`173`, `187`-`212`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:6`-`10`, `161`-`167`, `173`, `176`, `190`, `194`, `196`, `197`-`201`, `216`; legacy CU/edit evidence `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z006.java:266`-`272`, `317`-`321`, `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:122`-`128`; current FE closeout `frontend/src/app/core/models/pages/case-edition/common/revised-item.ts:40`, `79`-`80`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:250`-`266`; current BE closeout `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:39`-`40`, `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:189`, `209`, `249`-`280`; db-diff checkpoint and option sources in DB-D4/DB-D5; Bible `docs/specs/bible/bible-eproposal.md:80`, `109`, `171`-`176`, `198`, `323`, `497`, `505`-`506`, `728`-`731`, `752`, `754`-`756`, `792`, `801`; backend tab-control `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:50`, `277`, `302`-`303`; findings `docs/build-tasks/00800-implementation-closeout-findings.md` |
| REF-D5 Execute response and tab refresh split. | changed | Legacy/current BE can return borrower flags and `pageMenuCondition`, but latest refactor-spec removes authoritative downstream response building because FE re-calls tab-control after save. Target OpenAPI success `data` is nullable/simple; checkpoint/page-menu truth is refreshed through `epl-auth-tab-control`. Current BE returning `pageMenuCondition` is tolerated extra data, not a contract requirement. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:371`-`372`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:699`-`704`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:94`-`99`, `129`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:214`-`216`; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:207`-`208`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:27`-`32`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:200`-`202` |

## @PENDING
| id | status | pending item | blocks | owner |
|---|---|---|---|---|
| RP1 | ✅ closed | Keep side effects + fix bugs + audit | R8, R12, R13, R17 | PM/SA/RD |
| RP2 | ✅ closed | Keep `LON_TYPE_CODE=03` item1 forced rule | R5 | SA |
| RP3 | ✅ closed | Keep item12 fee-delete behavior | R13.3 | SA/RD |
| RP4 | ✅ closed | item1 and item10 are distinct tenor meanings, not a defect | R13.1, R13.2 | RD/SA |
| RP5 | ✅ closed | item13/item14 persist only, no side effect | R13.4 | SA/RD |
| RP6 | ✅ closed | item1 through item14 formal names | R3 | SA |
| RP7 | ✅ closed | UI text should be `Finished`, not `Finshed` | UI acceptance | PM/UX/RD |
| RP8 | ✅ closed | R6 uses backend-owned corporate-unsecured predicate (`LON_ATTRIBUTE='C' AND SECURE_ATTRIBUTE='U'` / `isCorporateUnsecured`), not `secureAttribute='U'` alone. R7 accepts granular FE page-column/button auth as the UI model, but requires mapping evidence and backend service-level page/edit authorization before mutation; `TB_API_AUTH` alone is insufficient. | R6, R7, R16, QA-006, QA-007, QA-042 | RD |
| RP9 | ✅ closed | query method follows PRD GET | R2, OpenAPI | RD/architecture |
| RP10 | ✅ closed | checkpoint uses active `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, and `TB_CHECK_POINTS_CU` tables with new funcId keys | R14 | RD/PM |
| RP11 | ✅ closed | execute request uses `applicationNo`, required `isFinish`, required `isNotSame`, and `itemMap`; legacy/PRD `checkPointMap` is not client-authoritative to-be input | R11, openapi execute request | RD/architecture |
| BP1 | ✅ closed | EPROZ00800 visibility gate is backend-owned `LON_TYPE_CODE in ('03','04')`; unsupported cases are hidden by tab-control/prompt and direct query/save is rejected before data read or mutation | R1, R16, QA-002, QA-043 | PM/SA |
| BP2 | ✅ closed | Bible case-type axis maps to backend-owned `TB_LON_SUMMARY_INFO.LON_TYPE_CODE`: `01=New`, `02=Additional`, `03=Renew`, `04=Change Condition`, `05=Restructure` when present; `LON_ATTRIBUTE`/`SECURE_ATTRIBUTE`/`caseCategory` remain separate customer/security/checkpoint-family predicates | R1, R5, R13.3, R14, QA-044 | SA |
| BP3 | ✅ closed | `03=Renew` and `04=Change Condition` share the R4 validation matrix; R5 `item1` default/lock and R13.3 `item12` fee-delete remain the only case-specific branches unless a later source-backed PRD/owner decision supersedes this SRS | R4, R5, R13.3, QA-045 | SA |
| BP4 | ✅ closed | Downstream split: `EPROISU0150`/`EPROCSU0150` are EPROZ00800 checkpoint/page-menu impacts only where physical keys exist (IS/CS); IU/CU have no 0150 key. `EPROISU0173`/`EPROCSU0173` are summary/read-display trace obligations owned by 0173 bundles, not 00800 checkpoint/page-menu targets. FE refreshes via `epl-auth-tab-control` after save. | R14, QA-046, REF-D5 | SA/RD |
| BP5 | ✅ closed | `shared` / `common` is module and tab-config classification, not an all-case visibility promise. EPROZ00800 remains conditionally visible/required only for backend-owned `LON_TYPE_CODE in ('03','04')`; non-03/04 cases must not show or require the tab. | Scope, R1, QA-047 | PM |

## Traceability Matrix
| PRD | SRS | QA |
|---|---|---|
| REQ-001 | R1, R15, R16 | QA-001, QA-002, QA-003, QA-028, QA-043, QA-044, QA-045, QA-047 |
| REQ-002 | R2, R3, R15 | QA-004, QA-005, QA-018, QA-024 |
| REQ-003 | R3, R4, R5, R6, R7 | QA-006, QA-007, QA-008, QA-009, QA-010, QA-011, QA-012, QA-013, QA-031, QA-032, QA-044, QA-045 |
| REQ-004 | R8, R9, R10, R11, R15, R16, R17 | QA-014, QA-015, QA-016, QA-017, QA-020, QA-025, QA-026, QA-027, QA-028, QA-033, QA-034, QA-035, QA-041, QA-042, QA-051, QA-055, QA-056 |
| REQ-005 | R8, R9, R12, R13 | QA-014, QA-019, QA-020, QA-021, QA-022, QA-023, QA-029, QA-033, QA-034, QA-035, QA-036, QA-037, QA-038, QA-039, QA-040, QA-045, QA-052, QA-053, QA-054 |
| REQ-006 | R9, R14 | QA-023, QA-030, QA-046, QA-056 |
| REQ-007 | R15, R17, R18 | QA-024, QA-025, QA-026, QA-027, QA-041, QA-048, QA-049, QA-050, QA-051, QA-055, QA-056 |

## NFR
- Authorization: mutating save must be rejected by backend authorization when page/edit permission is absent.
- Transaction: save, Revised Item row replacement, side-effect writes, checkpoint update, and audit outcome are all-or-nothing except the failure audit record.
- Performance: init-query target <= 3 seconds; execute target <= 5 seconds; execute transaction timeout target <= 30 seconds unless RD provides approved optimization/batching evidence.
- Precision/truncation: item flags are 1-byte enum values; `reasonMemo` input max is 3000 even though the DB column is 4000; loan amount, grace period, tenor, fixed/tier/base/FD rate restore fields must preserve numeric DB precision.
- Privacy: logs and audit summaries must not include full `reasonMemo`, borrower names, full account/ID values, sensitive collateral document contents, SQL text, stack traces, or full request payloads.
- Operability: prompt/query/execute logs must include `requestId`, `applicationNo`, `userId`, `action`, result, elapsed time, and error code when present.
- Testability: every non-pending rule has at least one happy/error/edge QA case; pending rules have explicit owner and retest hooks.
