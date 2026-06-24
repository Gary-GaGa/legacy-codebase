# SRS - EPROC00110 Corporate Credit Investigation Frame

## Metadata
| Field | Value |
|---|---|
| Status | In Review / draft-for-review; wait for controller gate and N-axis review |
| N-axis review | 2026-06-24 source/domain patch + N-axis axis A re-review PASS. Cleared the 2026-06-23 3🔴 by standardizing checkpoint polarity (`Y` = pending / `N` = completed), adding `visibleTabs` as the visibility/order carrier while `pageMap` remains checkpoint state, and excluding `EPROCSU0160` from the EPROC00110 contract. A first re-review raised R9 0210 parity fail-fast; second patch added `sourceFrame`/`sourceTabMap` and QA-009 now fails missing 021x parity instead of logging release gap. Mechanical gate PASS; axis A PASS with no Blocker/Should-fix. Not Approved: @PENDING items and owner approval remain open. |
| funcId | EPROC00110 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00110/` |
| Source baseline | PRD v1.0 + Bible v1.1 + local db-diff + local refactor-spec + bounded source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- This SRS covers the C0 corporate credit-investigation parent frame migrated from legacy `EPROC0_0110` and `EPROC0_0210` into funcId `EPROC00110`; PRD scope names the two legacy pages and the GI/FI/checkpoint/data-clearing responsibility at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:15-19`.
- In scope: load the frame, default `ASSESSMENT_TYPE=2` and `BUSINESS_TYPE=G`, expose GI/FI radio state, build child tab map, support checkbox/checkpoint state, switch GI/FI with data clearing, and preserve general-vs-renewal source behavior where evidenced; PRD scope and flow are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:92-123`.
- Out of scope: child-page business rules for `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120`; PRD non-scope excludes child-page internals at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:97-101`.
- The current refactor implementation exposes only `epl-info-c0-credit-investigation-tab` and `epl-save-c0-credit-investigation-tab`; this is evidenced by the controller at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:32-50` and refactor-spec at `docs/refactor-spec/02_modules/EPROC00110.md:19-21`.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD functional list | FR-001 through FR-010 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:158-171`. | Carried by R1-R12; PRD TBD rows are carried by R13-R18. |
| PRD TBD list | TBD-001 through TBD-006 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43-48`. | Open as `@PENDING`; not decided in this SRS. |
| Bible scope guard | Bible says C0 source family includes `EPROC0_0110`, `EPROC0_0120`, `EPROC0_0210`, and `EPROC0_0220`, and that source-confirmed legacy IDs must be preserved beside the refactor family at `docs/specs/bible/bible-eproposal.md:700` and `docs/specs/bible/bible-eproposal.md:741`. | SRS names both legacy source IDs and the refactor funcId. |
| Legacy 0110 transaction | `EPROC0_0110` prompt routes to JSP and outputs frame context at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:45-69`; getPage calls `changePage` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:84-88`. | Baseline for general case. |
| Legacy 0210 transaction | `EPROC0_0210` prompt routes to JSP and outputs RC context at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:45-71`; getPage calls `changePage` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:88-91`. | Baseline for renewal/change case. |
| Current backend | `CsuCreditInvestigationServiceImpl.getInfo` loads summary, determines CS/CU, defaults blank type, and builds pageMap at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:105-142`. | Current implementation covers 0110-style merged endpoint only; 0210-specific page codes remain gap evidence. |
| Current frontend | FE calls `epl-info-c0-credit-investigation-tab` and `epl-save-c0-credit-investigation-tab` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/services/api.service.ts:23-50`; radio confirm/save flow is at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:139-164`. | Current UI supports G/F business type switch with client confirm. |
| DB diff | `TB_LON_SUMMARY_INFO` columns include `ASSESSMENT_TYPE`, `BUSINESS_TYPE`, and `CR_SCORE_CARD_COMPLETED` at `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:58-67`; new checkpoint tables are active/exact at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:13-16` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:13-16`. | New DB table names are authoritative for SRS schema. |

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-info-c0-credit-investigation-tab` | POST | Load source frame, business type, visible tabs, source aliases, and pageMap for the corporate credit-investigation frame. | R1-R6, R9-R11 |
| `epl-save-c0-credit-investigation-tab` | POST | Persist a GI/FI business type switch for the submitted source frame, clear affected data, and reset checkpoints. | R7-R8, R9, R11-R12 |

## Rules

### R1 Load corporate credit-investigation frame - 強制點: both
covers-prd: FR-001, FR-009  
強制點: both

Given a valid `applicationNo` and source-frame discriminator, the system must load the corporate credit-investigation frame through `epl-info-c0-credit-investigation-tab`, returning the effective `sourceFrame`, `businessType`, ordered `visibleTabs`, `sourceTabMap`, and `pageMap`. Legacy 0110 prompt returned frame attributes and role/editor flags at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:51-69`; legacy 0210 returned the renewal frame and `isCR` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:51-71`. The current backend request DTO contains only `applicationNo` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCreditInvestigation/GetCsuCreditInvestigationTabRequest.java:11-17`, and the response DTO contains only `businessType` and `pageMap` at `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCreditInvestigation/GetCsuCreditInvestigationTabResponse.java:11-17`; adding `sourceFrame`, `visibleTabs`, and `sourceTabMap` is a contract gap the implementation must close.

The SRS contract does not require the new endpoint to expose every legacy JSP variable one-to-one. It requires the page state needed by the Angular frame and child-tab routing. PRD lists request/response context at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:431-458`.

### R2 Default summary assessment/business type - 強制點: BE
covers-prd: FR-002  
強制點: BE

If `TB_LON_SUMMARY_INFO.ASSESSMENT_TYPE` and `TB_LON_SUMMARY_INFO.BUSINESS_TYPE` are both blank, initial load must persist `ASSESSMENT_TYPE='2'` and `BUSINESS_TYPE='G'`. PRD defines this default at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:117-123` and `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:211-236`. Legacy 0110 initializes those values in `EPROC0_0110_mod.initQuery` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:46-91`; legacy 0210 does the same in `EPROC0_0210_mod.initQuery` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:50-96`.

The current backend implements the default in `initializeCreditInvestigationTab` by setting `assessmentType` to `2` and the supplied/default `businessType` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:190-228`. The schema source for `ASSESSMENT_TYPE` and `BUSINESS_TYPE` is `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:58-59`.

### R3 Select CS/CU checkpoint table from summary attributes - 強制點: BE
covers-prd: FR-002, FR-007  
強制點: BE

The backend must derive case type from `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE + TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE`; `CS` uses `TB_CHECK_POINTS_CS`, and other supported corporate cases use `TB_CHECK_POINTS_CU`. PRD states this decision at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:151-152`. The current backend derives type from `lonAttribute + secureAttribute` and branches to CS/CU repositories at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:115-142`.

New DB tables `TB_CHECK_POINTS_CS` and `TB_CHECK_POINTS_CU` are active/exact and transpose legacy checkpoint tables at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10-16` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10-16`. Legacy `TB_CHECK_POINT_CORP`, `TB_CHECK_POINT_CU`, `TB_CHECK_POINT_RC_CORP`, and `TB_CHECK_POINT_RC_CU` are marked removed/transferred at `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10-16`, and `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10-16`.

### R4 Display and guard GI/FI business type control - 強制點: both
covers-prd: FR-003, FR-008  
強制點: both

The frame must display a business type control with values `G` and `F`. The legacy 0110 JSP sets default variables and renders GI/FI labels at `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:39-43` and `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:325-328`; legacy 0210 does the same at `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42` and `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:322-324`. The current Angular config declares `businessType` radio options `G` and `F` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/fielditem-config.ts:17-35`.

Users without edit permission must not switch business type. PRD states query/edit/old behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:363-381`. Legacy 0110 disables the view in non-edit mode at `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:264-265`; legacy 0210 disables it at `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:261-262`. Current FE derives editable state from authorization at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:131-136`.

### R5 Build visibleTabs and pageMap by business type, CS/CU, and old-case flag - 強制點: both
covers-prd: FR-004, FR-008  
強制點: both

For both `sourceFrame=GENERAL_0110` and `sourceFrame=RENEWAL_0210`, `visibleTabs` uses normalized refactor funcIds. GI must include `EPROC00115`, `EPROC00112`, `EPROC00116`, and `EPROC00117`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. FI must include `EPROC00115`, `EPROC00112`, `EPROC00119`, and `EPROC00120`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. The order must follow the legacy tab array order. PRD tab mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:257-287`, including the 0110/0210 source-page matrix at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:278-287`.

`pageMap` must not be the sole visibility carrier. It carries checkpoint state for known C0 child pages, while `visibleTabs` carries tab visibility and order, and `sourceTabMap` maps each normalized visible tab to its source-confirmed legacy page code. For `sourceFrame=GENERAL_0110`, `sourceTabMap` must map `EPROC00115/112/114/116/117/118/119/120` to `EPROC0_0115/0112/0114/0116/0117/0118/0119/0120`. For `sourceFrame=RENEWAL_0210`, the same normalized keys must map to `EPROC0_0215/0212/0214/0216/0217/0218/0219/0220`. Legacy JSP tab conditions support the same GI/FI, old-case, and CS branches at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:169-218` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:167-215`. The current backend builds G/F maps by adding/removing pageMap keys at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:260-295`, and the current FE filters `pageMap` into visible tabs at `frontend/src/app/core/models/pages/case-edition/corporate/credit-investigation/credit-investigation-tab-control.ts:49-66`; that current coupling is an implementation gap against this response contract.

### R6 Manage checkbox and checkpoint state - 強制點: both
covers-prd: FR-005, FR-009  
強制點: both

The frame must expose checkpoint completion state for child tabs and accept child-page callbacks equivalent to legacy `check(pageName, isCheck)`. PRD defines `updateCheckMap`, checkbox state, `check(pageName,isCheck)`, and `getPageObj` context at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:289-307`. Legacy 0110 provides `check` only when editable at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:57-60`; legacy 0210 additionally blocks old cases at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:55-60`.

Checkpoint polarity is fixed as follows: for a page listed in `visibleTabs`, `Y` means the tab is pending / still needs work, and `N` means completed. This follows PRD `setCheckboxStatus(pageName, updateCheckMap[pageName] == 'N')` and `check(pageName, isCheck)` semantics at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:303-305`, legacy JSP checkbox updates at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:58-59` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:215-218`, and legacy `getChangeCheck` initializing active GI/FI pages to `Y` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:157-167` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:163-177`.

The physical DB default `'N'` in `TB_CHECK_POINTS_CS` and `TB_CHECK_POINTS_CU` is not the EPROC00110 active-frame initialization rule. On first frame initialization or GI/FI switch, active visible pages must be explicitly set to `Y`; inactive or hidden pages may remain `N` without implying visibility. The current backend reads checkpoint state from CS/CU repositories and maps `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:230-257`. The new C0 child DB columns are listed at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:45-52` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:43-49`.

### R7 Confirm GI/FI switch before destructive save - 強制點: both
covers-prd: FR-006  
強制點: both

When a user changes `BUSINESS_TYPE`, the UI must require an explicit confirmation before calling `epl-save-c0-credit-investigation-tab`; if the user cancels, the UI must not call the backend and must restore the previous business type. The save request must carry the same `sourceFrame` used by the loaded frame so the backend resets the correct general or renewal/change checkpoint provenance. PRD exception flow states cancel behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:141-144`, and PRD FR-006 defines the trigger and precondition at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:308-318`. Legacy JSP confirmation is at `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:238-258` and `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:235-255`; current Angular confirms before save at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:139-164`.

The save contract requires `confirmationToken`; the backend must reject missing, invalid, stale, or mismatched tokens before any destructive delete/update. TBD-006 remains open only for final confirmation text, token issuance lifetime, and exact version-check policy. The backend must also reject non-edit users and invalid `businessType` at service level; frontend confirmation alone is not sufficient for authorization.

### R8 Clear affected data and reset checkpoints in one transaction - 強制點: BE
covers-prd: FR-006  
強制點: BE

After confirmed GI/FI switch, the backend must update `TB_LON_SUMMARY_INFO.BUSINESS_TYPE`, delete all affected financial evaluation, financial statement, and corporate scorecard data, and reset checkpoint fields for the submitted `sourceFrame` in one transaction. PRD lists the destructive outcome at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:314-318`, idempotency and transaction expectation at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:470-476`, and rollback rule at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:561-563`.

Legacy 0110 `changePage` updates summary, deletes related data, updates checkpoint, and commits/rolls back at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:103-142`; legacy 0210 does the same for RC checkpoints at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:108-148`. Current backend `doSave` is transactional and calls deletion/update logic at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:152-184`; the deletion list is implemented at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:320-342`, and checkpoint reset is at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:344-383`.

Affected schema tables are `TB_FINANCIAL_EVALUATION_GI`, `TB_FINANCIAL_EVALUATION_FI`, `TB_FIN_STATEMENT_MAIN`, `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_BALANCE_FI`, `TB_FIN_STATEMENT_CASHFLOW_GI`, `TB_FIN_STATEMENT_CASHFLOW_FI`, `TB_FIN_STATEMENT_INCOME_GI`, `TB_FIN_STATEMENT_INCOME_FI`, and `TB_CORP_SCRCARD`; DB diff marks the financial evaluation tables active at `docs/db-diff/01_groups/group-21.md:13-17`, financial statement tables active at `docs/db-diff/01_groups/group-23.md:13-19`, and corporate scorecard active/exact at `docs/db-diff/00_HOME.md:186` plus `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13-16`.

### R9 Preserve general vs renewal/change source behavior - 強制點: both
covers-prd: FR-007  
強制點: both

The SRS must preserve the distinction that legacy `EPROC0_0110` used general checkpoint behavior and legacy `EPROC0_0210` used renewal/change checkpoint behavior. The caller must provide `sourceFrame=GENERAL_0110` or `sourceFrame=RENEWAL_0210`; if a local adapter derives that value from route metadata instead of JSON, the backend contract boundary must still receive the same discriminator before building tabs or checkpoint state. PRD makes the 0110/0210 difference part of this release scope at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:99`, marks FR-007 Must at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:168`, and maps source differences at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:342-361`.

For `sourceFrame=GENERAL_0110`, the backend must use the general source alias set and general checkpoint provenance (`TB_CHECK_POINT_CORP/CU` in legacy; normalized to `TB_CHECK_POINTS_CS/CU` in the refactor DB). For `sourceFrame=RENEWAL_0210`, it must use the 021x source alias set and renewal/change checkpoint provenance (`TB_CHECK_POINT_RC_CORP/CU` in legacy; normalized to `TB_CHECK_POINTS_CS/CU` in the refactor DB). Legacy 0210 has page-code behavior for `EPROC0_0216`, `EPROC0_0217`, `EPROC0_0218`, `EPROC0_0219`, and `EPROC0_0220` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:38-39` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:163-179`; PRD TC-008/TC-009 and TC-016/TC-017 require 0210 tab/checkpoint behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:591-600`. Current backend constants only expose normalized `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:76-93`, so the implementation must add the `sourceFrame`/`sourceTabMap` behavior before release. Missing 0210 parity is a failing condition for R9/QA-009, not an accepted release gap. The `ASSESSMENT_TYPE=1` 0211/0213 branch remains separately blocked by R13 and must not be exposed as confirmed corporate GI/FI behavior.

### R10 Update cross-module page menu completion state - 強制點: BE
covers-prd: FR-010  
強制點: BE

Child-page completion must contribute to the parent credit-investigation page menu state. PRD identifies CS/CU page-menu updates and `CR_SCORE_CARD_COMPLETED` role logic at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:402-418`. Legacy CS modules call `changeCheckPoint` and put `EPROC0_0110` or `EPROC0_0210` into page-menu conditions at `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0110_mod.java:148-150` and `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0210_mod.java:167-169`.

Current backend authorization/menu logic sets `EPROC00110` from `crScore` at `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:467-507`. Full parity for every CS/CU borrower save path is not proven in this bounded read; unresolved paths are UNFOUND and require regression verification against R10 QA.

### R11 Standardize error handling and message keys - 強制點: BE
covers-prd: FR-001, FR-006, FR-007  
強制點: BE

The SRS carries PRD error keys `MSG_INITIAL_FAIL`, `MSG_DATA_NOT_FOUND`, `MSG_QUERY_FAIL`, and `MSG_OVER_COUNT_LIMIT`. PRD common error mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:460-468`, and detailed error principles are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:546-564`. Legacy 0110 maps initial and getPage errors at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:69-108`; legacy 0210 maps getPage errors at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:96-112`.

Legacy 0210 catches `ErrorInputException` without setting a return message at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`; because PRD marks this as TBD-003 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45`, the new contract must not silently preserve the empty-return behavior. The exact user-facing message for that branch remains `@PENDING` under R15.

### R12 Enforce security, audit, and destructive-operation NFR - 強制點: both
covers-prd: FR-006, FR-008  
強制點: both

The backend must enforce edit/query/old-case restrictions independently of the UI for any mutating call, and `epl-save-c0-credit-investigation-tab` must require and validate a server-issued destructive-switch confirmation/version token before deleting financial/scorecard data. PRD security and audit notes are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:519-525`, and NFR security/transaction/audit requirements are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:566-576`. Current save request validates only `applicationNo` and `businessType` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`, and current `doSave` starts mutation without a visible service-level edit/old-case guard at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:154-184`; these are implementation gaps, not optional behavior.

The SRS names `TB_API_AUTH` only as an authorization seed boundary, not as sufficient proof of service-level authorization. DB authorization seed verification and service-level reject behavior must be verified separately for R12.

### R13 @PENDING TBD-001 renewal assessment-type switch - 強制點: both
covers-prd: FR-007  
強制點: both

PRD TBD-001 says legacy `EPROC0_0210_mod.getChangeCheck` enables `EPROC0_0211` and `EPROC0_0213` when `ASSESSMENT_TYPE=1`, while the JSP main UI only shows GI/FI business type tabs; SA/RD must confirm whether 0211/0213 are used from another entry before exposing a personal assessment-type switch. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43`; legacy 0210 source branch is at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:163-179`; current FE/BE support is UNFOUND from current constants/nav evidence at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:76-93` and `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation-navlink-config.ts:11-84`.

### R14 @PENDING TBD-002 application number source - 強制點: both
covers-prd: FR-001, FR-009  
強制點: both

PRD TBD-002 says JSP AJAX payload uses `${APPLICATION_NO}` while display uses `${attrMap.APPLICATION_NO}`, and transaction does not directly add `APPLICATION_NO` output. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:44`. Legacy JSP evidence is `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:49` and `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:47`; current Angular request uses `applicationNo` directly at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation-tab-control.ts:76-79`.

### R15 @PENDING TBD-003 0210 ErrorInputException message - 強制點: BE
covers-prd: FR-007  
強制點: BE

PRD TBD-003 marks the legacy 0210 empty catch as a suspected legacy defect and requires new standard error handling. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45`; legacy empty catch evidence is `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`. The exact response key beyond the standard error set in R11 is待 RD 核對.

### R16 @PENDING TBD-004 title and i18n key ownership - 強制點: FE
covers-prd: FR-001  
強制點: FE

PRD TBD-004 says 0210 JSP `_funcName` uses `EPROC0_0110_FUNC_NAME`, fieldset legend uses `EPROI0_0110_FUNC_NAME`, and 0110 also mixes the I0 key; SA/RD must confirm whether C0 and I0 share title keys. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:46`; JSP 0210 title variable evidence is `legacy-epro/WebContent/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42`.

### R17 @PENDING TBD-005 GI/FI display names - 強制點: FE
covers-prd: FR-003  
強制點: FE

PRD TBD-005 says formal Chinese display names for business type `G` and `F` depend on i18n keys that were not found in this pass. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:47`. Current FE labels are `E_GENERAL_INDUSTRY` and `E_FINANCIAL_INDUSTRY` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/fielditem-config.ts:17-35`; final displayed Chinese text is待 RD 核對.

### R18 @PENDING TBD-006 destructive switch confirmation token - 強制點: both
covers-prd: FR-006  
強制點: both

PRD TBD-006 says GI/FI switch deletes multiple financial and scorecard tables, legacy only has frontend confirm, and the new system should strengthen prompt text plus server-side confirmation token. Source: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:48`. The SRS contract already requires token validation in R7/R12; this pending item covers final confirmation wording, token issuance lifetime, and exact stale-version policy. Current FE confirm exists at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:139-164`; current save DTO has `applicationNo` and `businessType` but no token at `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`, so implementation must close that gap before approval.

## 新舊 DB 對照 / Delta / Reconcile
| Legacy / source table | New SRS table | Disposition | Evidence |
|---|---|---|---|
| `TB_LON_SUMMARY_INFO` | `TB_LON_SUMMARY_INFO` | Keep; stores `ASSESSMENT_TYPE`, `BUSINESS_TYPE`, source attributes, and scorecard completion. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:38-67` |
| `TB_CHECK_POINT_CORP` | `TB_CHECK_POINTS_CS` | Transposed/migrated; old table removed_or_unused. | `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10-16` |
| `TB_CHECK_POINT_CU` | `TB_CHECK_POINTS_CU` | Transposed/migrated; old table removed_or_unused. | `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10-16` |
| `TB_CHECK_POINT_RC_CORP` | `TB_CHECK_POINTS_CS` | Transposed/migrated; SRS keeps renewal source behavior but new DB does not retain separate RC table. | `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10-16` |
| `TB_CHECK_POINT_RC_CU` | `TB_CHECK_POINTS_CU` | Transposed/migrated; SRS keeps renewal source behavior but new DB does not retain separate RC table. | `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10-16` |
| `TB_CHECK_POINTS_CS/CU.EPROCSU0160` | Out of EPROC00110 contract schema | Physical checkpoint column exists for Loan Condition, but it is not a C0 credit-investigation child page and must not be emitted in `visibleTabs` or `pageMap` for EPROC00110. | DB column comments identify Loan Condition at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:53` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:50`; current EPROC00110 service omits it from `findCheckPointMap` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:230-257`. |
| Financial evaluation tables | Same active tables | Cleared on switch. | `docs/db-diff/01_groups/group-21.md:13-17` |
| Financial statement tables | Same active tables | Cleared on switch. | `docs/db-diff/01_groups/group-23.md:13-19` |
| `TB_CORP_SCRCARD` | `TB_CORP_SCRCARD` | Cleared on switch. | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13-16` |
| `TB_API_AUTH` | `TB_API_AUTH` | Active restructured API authorization seed; not sufficient by itself for service-level edit/old-case checks. | `docs/db-diff/00_HOME.md:92`; `docs/db-diff/02_tables/TB_API_AUTH.md:1-42` |

## @PENDING Register
| ID | Rule | Owner | Impact | Evidence | Status |
|---|---|---|---|---|---|
| TBD-001 | R13 | SA/RD | Renewal assessment-type switch and 0211/0213 exposure. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43` | Open |
| TBD-002 | R14 | RD | Stable `applicationNo` source for legacy-compatible frame calls. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:44` | Open |
| TBD-003 | R15 | RD | 0210 initial error response mapping. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45` | Open |
| TBD-004 | R16 | SA/RD | C0/I0 title and i18n ownership. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:46` | Open |
| TBD-005 | R17 | SA | GI/FI formal Chinese display names. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:47` | Open |
| TBD-006 | R18 | PM/SA/RD | Destructive switch prompt and server-side confirmation token. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:48` | Open |

## Traceability
| PRD | Rule | QA |
|---|---|---|
| FR-001 | R1, R11, R14, R16 | QA-001, QA-011, QA-014, QA-016 |
| FR-002 | R2, R3 | QA-002, QA-003 |
| FR-003 | R4, R17 | QA-004, QA-017 |
| FR-004 | R5 | QA-005, QA-019 |
| FR-005 | R6 | QA-006, QA-019 |
| FR-006 | R7, R8, R11, R12, R18 | QA-007, QA-008, QA-011, QA-012, QA-018 |
| FR-007 | R3, R9, R11, R13, R15 | QA-003, QA-009, QA-011, QA-013, QA-015 |
| FR-008 | R4, R5, R12 | QA-004, QA-005, QA-012 |
| FR-009 | R1, R6, R14 | QA-001, QA-006, QA-014 |
| FR-010 | R10 | QA-010 |
