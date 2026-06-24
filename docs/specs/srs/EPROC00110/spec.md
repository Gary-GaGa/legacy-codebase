# SRS - EPROC00110 Corporate Credit Investigation Frame

## Metadata
| Field | Value |
|---|---|
| Status | 規格定版: Approved (2026-06-24, owner — axis A–F 獨立確認 Blocker 全清); 實作完成: pending RD (QA 暫拔除) |
| N-axis review | 2026-06-24 source/domain patch + Should-fix closeout PASS. Cleared the 2026-06-23 3🔴 by standardizing checkpoint polarity (`Y` = pending / `N` = completed), adding `visibleTabs` as the visibility/order carrier while `pageMap` remains checkpoint state, and excluding `EPROCSU0160` from the EPROC00110 contract. Later Should-fix closeout grounded R9 four-to-two checkpoint consolidation in db-diff: active CS/CU rows are keyed by `APPLICATION_NO` without DB discriminator, while `sourceFrame`/`sourceTabMap` carry mutually exclusive 0110/0210 provenance; `schema.sql` also notes physical `EPROCSU0160` is intentionally excluded from this contract. Mechanical gate PASS. Pre-merge halves passed axis-A + cross-model review; after the 2026-06-24 branch-reconciliation merge, a post-merge cross-model axis-A re-review of the combined (7-fix spec + first-round QA) bundle found only Should-fix (QA-006 polarity wording aligned to the `Y`=pending/`N`=completed定版 plus a `visibleTabs`-as-visibility-carrier assertion), all closed, with no Blocker. Pending closeout axis-A found no Blocker; switchGeneration consistency Should-fix was closed in R7 and QA-008/QA-012. Owner-approved 2026-06-24 (規格定版) after axis A–F independent cross-model confirmation (3 prior Blockers closed: Pending Register reconcile, EPROC00114 CS-only/CU-omit, ERROR_MODULE carry); implementation/tests remain RD code-stage DoD. |
| funcId | EPROC00110 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00110/` |
| Source baseline | PRD v1.0 + Bible v1.1 + local db-diff + local refactor-spec + bounded source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |

## Scope
- This SRS covers the C0 corporate credit-investigation parent frame migrated from legacy `EPROC0_0110` and `EPROC0_0210` into funcId `EPROC00110`; PRD scope names the two legacy pages and the GI/FI/checkpoint/data-clearing responsibility at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:15-19`.
- In scope: load the frame, default `ASSESSMENT_TYPE=2` and `BUSINESS_TYPE=G`, expose GI/FI radio state, build child tab map, support checkbox/checkpoint state, switch GI/FI with data clearing, and preserve general-vs-renewal source behavior where evidenced; PRD scope and flow are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:92-123`.
- Out of scope: child-page business rules for `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120`; PRD non-scope excludes child-page internals at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:97-101`.
- The current refactor implementation exposes only `epl-info-c0-credit-investigation-tab` and `epl-save-c0-credit-investigation-tab`; this is evidenced by the controller at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:32-50` and refactor-spec at `docs/refactor-spec/02_modules/EPROC00110.md:19-21`.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD functional list | FR-001 through FR-010 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:158-171`. | Carried by R1-R12; PRD TBD rows are carried by R13-R18. |
| PRD TBD list | TBD-001 through TBD-006 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43-48`. | TBD-001 through TBD-006 are closed by R13-R18 decisions. |
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
| `epl-confirm-c0-credit-investigation-switch` | POST | Issue a short-lived single-use server token for one destructive GI/FI switch after the user accepts the warning text. | R7, R12, R18 |
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

The frame must display a business type control with values `G` and `F`. The legacy 0110 JSP sets default variables and renders GI/FI labels at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:39-43` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:325-328`; legacy 0210 does the same at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:322-324`. The current Angular config declares `businessType` radio options `G` and `F` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/fielditem-config.ts:17-35`.

Users without edit permission must not switch business type. PRD states query/edit/old behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:363-381`. Legacy 0110 disables the view in non-edit mode at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:264-265`; legacy 0210 disables it at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:261-262`. Current FE derives editable state from authorization at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:131-136`.

### R5 Build visibleTabs and pageMap by business type, CS/CU, and old-case flag - 強制點: both
covers-prd: FR-004, FR-008  
強制點: both

For both `sourceFrame=GENERAL_0110` and `sourceFrame=RENEWAL_0210`, `visibleTabs` uses normalized refactor funcIds. GI must include `EPROC00115`, `EPROC00112`, `EPROC00116`, and `EPROC00117`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. FI must include `EPROC00115`, `EPROC00112`, `EPROC00119`, and `EPROC00120`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. `EPROC00114` is CS-only: CU responses must not include it in `visibleTabs`, `sourceTabMap`, or `pageMap`, because `TB_CHECK_POINTS_CU` has no `EPROC00114` checkpoint column in this bundle's schema. The order must follow the legacy tab array order. PRD tab mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:257-287`, including the 0110/0210 source-page matrix at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:278-287`.

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

When a user changes `BUSINESS_TYPE`, the UI must require an explicit confirmation before calling `epl-save-c0-credit-investigation-tab`; if the user cancels, the UI must not call the backend and must restore the previous business type. The save request must carry the same `sourceFrame` used by the loaded frame so the backend resets the correct general or renewal/change checkpoint provenance. PRD exception flow states cancel behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:141-144`, and PRD FR-006 defines the trigger and precondition at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:308-318`. Legacy JSP confirmation is at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:238-258` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:235-255`; current Angular confirms before save at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:139-164`.

The save contract requires both `confirmationToken` and `switchGeneration`; the backend must reject missing, invalid, stale, reused, or mismatched token/generation values before any destructive delete/update. The token and `switchGeneration` are issued only by `epl-confirm-c0-credit-investigation-switch` after the UI displays and the user accepts the warning text finalized in R18. The backend must also reject non-edit users and invalid `businessType` at service level; frontend confirmation alone is not sufficient for authorization.

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

The active checkpoint schema has one checkpoint row per `APPLICATION_NO` in the selected CS/CU table and does not contain a general-vs-renewal discriminator. This is a DB-resolvable constraint: `TB_CHECK_POINTS_CS` and `TB_CHECK_POINTS_CU` are active/exact, each has primary key `APPLICATION_NO` only, and their column sets normalize 011x/021x child checkpoints into `EPROC001xx` fields at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:13-16`, `:32`, `:45-52` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:13-16`, `:32`, `:43-49`; the legacy general and RC checkpoint tables are removed/unused and transferred into those same active tables at `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10`, `:13`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10`, `:13`, and `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10`, `:13`. Therefore this SRS treats `sourceFrame` as mutually exclusive runtime provenance for a given `APPLICATION_NO`, carried by request/response `sourceFrame` and `sourceTabMap`, not by an additional checkpoint-table column.

### R10 Update cross-module page menu completion state - 強制點: BE
covers-prd: FR-010  
強制點: BE

Child-page completion must contribute to the parent credit-investigation page menu state. PRD identifies CS/CU page-menu updates and `CR_SCORE_CARD_COMPLETED` role logic at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:402-418`. Legacy CS modules call `changeCheckPoint` and put `EPROC0_0110` or `EPROC0_0210` into page-menu conditions at `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0110_mod.java:148-150` and `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0210_mod.java:167-169`.

Current backend authorization/menu logic sets `EPROC00110` from `crScore` at `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:467-507`. Full parity for every CS/CU borrower save path is not proven in this bounded read; unresolved paths are UNFOUND and require regression verification against R10 QA.

### R11 Standardize error handling and message keys - 強制點: BE
covers-prd: FR-001, FR-006, FR-007  
強制點: BE

The SRS carries PRD error keys `MSG_INITIAL_FAIL`, `MSG_DATA_NOT_FOUND`, `MSG_QUERY_FAIL`, and `MSG_OVER_COUNT_LIMIT`. PRD common error mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:460-468`, and detailed error principles are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:546-564`. Legacy 0110 maps initial and getPage errors at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:69-108`; legacy 0210 maps getPage errors at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:96-112`.

The PRD module-error path is preserved instead of being silently collapsed into `MSG_QUERY_FAIL`: failures that correspond to `ReturnCode.ERROR_MODULE` must carry `ERROR_MODULE` plus the module message, and over-count failures must carry `ERROR_MODULE` plus `MSG_OVER_COUNT_LIMIT`. Generic query/switch failures without a module-returned message remain `ReturnCode.ERROR` plus `MSG_QUERY_FAIL`.

Legacy 0210 catches `ErrorInputException` without setting a return message at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`; because PRD marks this as TBD-003 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45`, the new contract must not silently preserve the empty-return behavior. R15 closes that branch as a standard `MSG_INITIAL_FAIL` initial-load error.

### R12 Enforce security, audit, and destructive-operation NFR - 強制點: both
covers-prd: FR-006, FR-008  
強制點: both

The backend must enforce edit/query/old-case restrictions independently of the UI for any mutating call, and `epl-save-c0-credit-investigation-tab` must require and validate a server-issued destructive-switch confirmation/version token before deleting financial/scorecard data. PRD security and audit notes are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:519-525`, and NFR security/transaction/audit requirements are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:566-576`. Current save request validates only `applicationNo` and `businessType` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`, and current `doSave` starts mutation without a visible service-level edit/old-case guard at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:154-184`; these are implementation gaps, not optional behavior.

The SRS names `TB_API_AUTH` only as an authorization seed boundary, not as sufficient proof of service-level authorization. DB authorization seed verification and service-level reject behavior must be verified separately for R12.

Every destructive switch attempt must produce an auditable outcome as a project-standard application audit event with event type `EPROC00110_GI_FI_SWITCH`, observable through the configured audit sink or test audit collector. For token issuance rejection, token issuance, rejected save, successful switch, and transaction rollback/failure, the backend must record actor, session or request correlation id, `applicationNo`, `sourceFrame`, old `businessType`, requested new `businessType`, token id or fingerprint, outcome, failure reason when applicable, and the affected table list. Audit records must not include financial statement, financial evaluation, or scorecard row contents. The physical sink implementation belongs to the code-stage DoD, but the named event and fields are part of this SRS contract and must be test-verifiable before release.

### R13 TBD-001 renewal assessment-type switch is not exposed by EPROC00110 - 強制點: both
covers-prd: FR-007  
強制點: both

Owner decision on 2026-06-24, option A: `EPROC00110` must not expose `EPROC0_0211` / `EPROC0_0213`, normalized `EPROC00111` / `EPROC00113`, or a personal assessment-type switch. The EPROC00110 frame contract remains GI/FI `businessType` driven only; `assessmentType` is not a client-visible switch in this bundle. Future migration or ownership of the 0211/0213 actions requires a separate owner-approved bundle.

Provenance: PRD TBD-001 explicitly says the new system must not expose the personal assessment-type switch before confirmation at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43`, and the PRD marks I0 personal assessment-type switching out of this C0 bundle at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:96-101`. Legacy 0210 contains backend/checkpoint evidence for `ASSESSMENT_TYPE=1` enabling `EPROC0_0211` and `EPROC0_0213` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:37-39` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:163-179`, but the main JSP GI/FI tab body omits 0211/0213 at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:321-355`. Refactor-spec carries only `businessType` and pageMap tabs `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120` at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:83-91` and `docs/refactor-spec/03_artifacts/be-corporate/EPROC00110/epl-info-c0-credit-investigation-tab.md:76-85`; audit evidence records EPROC0_0211/0213 FE/BE as UNFOUND at `docs/build-tasks/refactor-audit/M7a-c0-00110-00115.md:23-24`.

### R14 TBD-002 application number source is the required API request field - 強制點: both
covers-prd: FR-001, FR-009  
強制點: both

The to-be contract uses `applicationNo` as the stable required request field for `epl-info-c0-credit-investigation-tab`, `epl-save-c0-credit-investigation-tab`, and child frame calls launched from EPROC00110. FE must source this value from the migrated case/frame context and send the same value across parent and child calls; BE must reject blank or missing `applicationNo` before any query or mutation and must not depend on legacy JSP request attributes. Implementation and tests belong to the code-stage DoD and remain pending RD.

Provenance: PRD TBD-002 records the legacy ambiguity and recommends moving to `attrMap.APPLICATION_NO` if the framework does not guarantee `${APPLICATION_NO}` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:44`. Legacy prompt transactions populate `attrMap` and call modules with `MapUtils.getString(attrMap, "APPLICATION_NO")` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:49-67` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:49-68`; legacy JSPs also show the mismatch between AJAX `${APPLICATION_NO}` and display `${attrMap.APPLICATION_NO}` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:49`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:314-315`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:47`, and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:311-312`. Refactor-spec makes `applicationNo` a required request field at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:172-177` and carries backend blank validation at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00110/epl-info-c0-credit-investigation-tab.md:123-129`.

### R15 TBD-003 0210 ErrorInputException returns standard initial failure - 強制點: BE
covers-prd: FR-007  
強制點: BE

The 0210 initialization `ErrorInputException` branch must return the standard initial-load failure response: `ReturnCode.ERROR` with `MSG_INITIAL_FAIL`, or the equivalent new API error envelope carrying `MSG_INITIAL_FAIL`. The backend must not return success, an empty message, or raw exception text for this branch. Implementation and tests belong to the code-stage DoD and remain pending RD.

Provenance: PRD TBD-003 identifies the legacy empty catch as a defect suspect and says the new system must add standard error handling at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45` and `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:557-564`. PRD standard mapping assigns prompt initial failure to `MSG_INITIAL_FAIL` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:460-468` and `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:548-556`. Legacy 0210 has the empty `ErrorInputException` catch at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`, while legacy 0110 prompt and 0210 generic prompt exception both use `MSG_INITIAL_FAIL` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:71-75` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:75-79`.

### R16 TBD-004 title and i18n key ownership is C0-owned - 強制點: FE
covers-prd: FR-001  
強制點: FE

Owner decision on 2026-06-24, option A: EPROC00110 title and legend i18n ownership is C0-owned. FE must use one C0-owned key for the frame function title and fieldset legend, such as `EPROC00110_FUNC_NAME` or the project-standard C0 namespace equivalent, and must not depend on I0-owned `EPROI0_0110_FUNC_NAME`. Implementation and tests belong to the code-stage DoD and remain pending RD.

Provenance: PRD TBD-004 identifies the legacy mixed title keys and asks SA/RD to confirm ownership at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:46`. PRD metadata names this page `Credit Investigation Corporate Frame` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:15-19`; refactor-spec names the FE artifact `EPROC00110-Credit-Investigation(頁框)` and passes `functionName="EPROC00110"` at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:1-6` and `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:172-177`. Legacy JSPs show the drift: function description uses `EPROC0_0110_FUNC_NAME` while the fieldset legend uses `EPROI0_0110_FUNC_NAME` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:39-43`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:310-313`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42`, and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:307-310`.

### R17 TBD-005 GI/FI display names are source-confirmed English domain labels - 強制點: FE
covers-prd: FR-003  
強制點: FE

Owner decision on 2026-06-24, option A: the EPROC00110 business type display text is `General Industry (GI)` for `BUSINESS_TYPE=G` and `Financial Industry (FI)` for `BUSINESS_TYPE=F`. FE must use C0-owned i18n keys, for example `EPROC00110_UI_GI` and `EPROC00110_UI_FI`, or the project-standard C0 namespace equivalent. FE must not depend on I0-owned legacy keys such as `EPROI00110_UI_GI` or `EPROI00110_UI_FI`. Implementation and tests belong to the code-stage DoD and remain pending RD.

Provenance: PRD TBD-005 says the formal display text depended on i18n keys that were not found and that this pass marked the labels by JSP GI/FI comments at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:47`. The PRD functional body says the radio lets editable users choose `General Industry` or `Financial Industry` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:244`. Legacy C0 JSPs use keys `EPROI00110_UI_GI` and `EPROI00110_UI_FI`, with comments `General Industry (GI)` and `Financial Industry (FI)`, at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:325-330` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:322-325`. Refactor-spec labels the options as `General Industry(G)` and `Financial Industry(F)` at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:163-166`.

### R18 TBD-006 destructive switch confirmation token policy is finalized - 強制點: both
covers-prd: FR-006  
強制點: both

Owner decision on 2026-06-24, option A: EPROC00110 must use a destructive-switch confirmation flow with explicit delete-scope wording, a short-lived single-use server token, and a stale-version guard. The warning text must tell the user that switching Business Type between `General Industry (GI)` and `Financial Industry (FI)` will delete/reset financial statement data, financial evaluation data, Corporate Scorecard data, and related checkpoint completion state before the frame reloads. The UI may use project-standard wording, but it must preserve that delete-scope content.

The token contract is mandatory for both FE and BE. FE must request a confirmation token only after the user accepts the warning; BE must issue a single-use token valid for 10 minutes and bind it to actor/session, `applicationNo`, `sourceFrame`, old `businessType`, new `businessType`, and a server-side monotonic `switchGeneration` for that `applicationNo` + `sourceFrame`. `epl-save-c0-credit-investigation-tab` must send both the token and the issued `switchGeneration`; the backend must validate both immediately before any delete/update and reject the save if either value is missing, invalid, expired, reused, bound to different context, or no longer equals the current server-side generation. Any successful destructive switch must advance the server-side `switchGeneration` and invalidate outstanding tokens for the same `applicationNo` + `sourceFrame`, so ABA changes cannot reuse an older token after the business type cycles back. A token is consumed on the first save validation attempt; if the later delete/update transaction fails or rolls back, FE must show the warning again and obtain a new token. Stale or mismatched token failures must leave summary, affected child data, and checkpoints unchanged. Implementation and tests belong to the code-stage DoD and remain pending RD.

Provenance: PRD TBD-006 identifies the data-loss risk and requires stronger wording plus a server-side token at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:48`. PRD FR-006 defines the destructive switch flow and backend delete/update behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:313-324`; PRD lists affected tables at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:504-510`. PRD security and UX notes require clear user confirmation, server-side token or version check, audit trail, and explicit delete-scope wording at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:561-563` and `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:573-576`. Legacy C0 JSPs only call frontend `confirm` before `getPage` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:254-260` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:251-257`; refactor-spec currently carries a generic reminder text at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:124-165`, which is weaker than the finalized delete-scope wording. Current save DTO has `applicationNo` and `businessType` but no token at `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`, so implementation must close that gap before release.

## 新舊 DB 對照 / Delta / Reconcile
| Legacy / source table | New SRS table | Disposition | Evidence |
|---|---|---|---|
| `TB_LON_SUMMARY_INFO` | `TB_LON_SUMMARY_INFO` | Keep; stores `ASSESSMENT_TYPE`, `BUSINESS_TYPE`, source attributes, and scorecard completion. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:38-67` |
| `TB_CHECK_POINT_CORP` | `TB_CHECK_POINTS_CS` | Transposed/migrated; old table removed_or_unused. | `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10-16` |
| `TB_CHECK_POINT_CU` | `TB_CHECK_POINTS_CU` | Transposed/migrated; old table removed_or_unused. | `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10-16` |
| `TB_CHECK_POINT_RC_CORP` | `TB_CHECK_POINTS_CS` | Transposed/migrated; SRS keeps renewal source behavior through mutually exclusive `sourceFrame`/`sourceTabMap` provenance because the active target has `APPLICATION_NO` as the only PK and no RC discriminator column. | `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:13-16`, `:32`, `:45-52` |
| `TB_CHECK_POINT_RC_CU` | `TB_CHECK_POINTS_CU` | Transposed/migrated; SRS keeps renewal source behavior through mutually exclusive `sourceFrame`/`sourceTabMap` provenance because the active target has `APPLICATION_NO` as the only PK and no RC discriminator column. | `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:13-16`, `:32`, `:43-49` |
| `TB_CHECK_POINTS_CS/CU.EPROCSU0160` | Out of EPROC00110 contract schema | Physical checkpoint column exists for Loan Condition, but it is not a C0 credit-investigation child page and must not be emitted in `visibleTabs` or `pageMap` for EPROC00110. | DB column comments identify Loan Condition at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:53` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:50`; current EPROC00110 service omits it from `findCheckPointMap` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:230-257`. |
| Financial evaluation tables | Same active tables | Cleared on switch. | `docs/db-diff/01_groups/group-21.md:13-17` |
| Financial statement tables | Same active tables | Cleared on switch. | `docs/db-diff/01_groups/group-23.md:13-19` |
| `TB_CORP_SCRCARD` | `TB_CORP_SCRCARD` | Cleared on switch. | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13-16` |
| `TB_API_AUTH` | `TB_API_AUTH` | Active restructured API authorization seed; not sufficient by itself for service-level edit/old-case checks. | `docs/db-diff/00_HOME.md:92`; `docs/db-diff/02_tables/TB_API_AUTH.md:1-42` |

## Pending Register
| ID | Rule | Owner | Impact | Evidence | Status |
|---|---|---|---|---|---|
| TBD-001 | R13 | PM/SA/RD | Renewal assessment-type switch ownership. | PRD TBD-001 and R13 owner decision 2026-06-24. | Closed/spec-frozen: NO_PERSONAL_ASSESSMENT_SWITCH_IN_00110 |
| TBD-002 | R14 | RD | Required application number source and request validation. | PRD TBD-002 and R14 contract decision 2026-06-24. | Closed/spec-frozen: APPLICATION_NO_REQUIRED_FROM_CASE_CONTEXT; implementation/tests remain RD DoD |
| TBD-003 | R15 | RD | 0210 `ErrorInputException` message behavior. | PRD TBD-003 and R15 contract decision 2026-06-24. | Closed/spec-frozen: STANDARD_INITIAL_FAIL_FOR_ERROR_INPUT; implementation/tests remain RD DoD |
| TBD-004 | R16 | FE/RD | C0-owned title/i18n key. | PRD TBD-004 and R16 owner decision 2026-06-24. | Closed/spec-frozen: C0_OWNED_I18N_KEY |
| TBD-005 | R17 | FE/RD | GI/FI display labels. | PRD TBD-005 and R17 owner decision 2026-06-24. | Closed/spec-frozen: GI_FI_ENGLISH_LABELS |
| TBD-006 | R18 | FE/RD/Security | Destructive switch warning and confirmation token policy. | PRD TBD-006 and R18 owner decision 2026-06-24. | Closed/spec-frozen: SWITCH_TOKEN_AND_GENERATION_REQUIRED; implementation/tests remain RD DoD |

## Traceability
> ⚠️ **QA 2026-06-24 暫拔除**：`qa-cases.md` 已刪。本 bundle 所有 QA-0XX 引用（下表 QA 欄、metadata closeout/驗證佐證、R 條 QA 掛鉤）均為 **dormant、不得視為已驗證**；closeout 以規格決策（owner/RD-contract）為據。REQ↔Rn 追溯仍有效；恢復 QA 後重建。
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
