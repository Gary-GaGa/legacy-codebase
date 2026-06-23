# SRS - EPROC00112 CBC Banking Relationship

## Metadata
| Field | Value |
|---|---|
| Status | In Review / draft-for-review |
| N-axis review | spec-reviewer (axis A) 2026-06-23: mechanical gate PASS; 0🔴 + 6🟡 (Approvable direction). Top 🟡 = reverify-TSV provenance is repo-external (add "待母資料夾複核" disclaim); R7 cites un-finalized isFinish polarity as current fact; `pageCheckMap` required vs backend-authoritative tension. Remains In Review; re-review after 🟡 adoption. |
| funcId | EPROC00112 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00112/` |
| Source baseline | PRD v1.0 + Bible + db-diff + refactor-spec + bounded legacy/new source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- This SRS covers the C0 corporate CBC banking relationship page migrated from legacy `EPROC0_0112` and `EPROC0_0212` into funcId `EPROC00112`; PRD states the single new page must carry both legacy sources and preserve checkpoint/father-tab differences at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:64`.
- In scope: initial data load, BBL/BGL/GBGL source rows, CBC master/detail maintenance, USD/KHR totals, full replacement save, checkpoint update, and all-tab done status; PRD success scope is listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:41-43`.
- Out of scope: deciding PRD TBD rows, changing source-table business rules not evidenced in legacy/refactor/db-diff, or ledger/status updates outside this bundle. The parity SOP requires `UNFOUND` instead of inference when decisive evidence is absent at `docs/process/legacy-parity-sop.md:18-28`.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD functional list | REQ-001 through REQ-010 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:104-113`. | Carried by R1-R10; PRD TBD rows are carried by R11-R17. |
| PRD TBD list | `待確認-001` through `待確認-007` are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:49-55`. | Open as `@PENDING`; not decided in this SRS. |
| Bible scope guard | Bible places C0 credit/scoring pages in the I0/C0 credit/scoring family, not AO main flow, at `docs/specs/bible/bible-eproposal.md:739`. | SRS keeps C0 page scope and parent-frame dependency explicit. |
| Legacy 0112 transaction | Legacy 0112 routes `initQuery`, `calculation`, and `save` in `EPROC0_0112` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java:48-122`. | Baseline for general corporate flow. |
| Legacy 0212 transaction | Legacy 0212 routes the same actions and writes parent `EPROC0_0210` progress at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java:48-122`. | Baseline for renewal/change corporate flow. |
| Current backend endpoint | Current controller exposes `epl-save-c0-cbc-banking-relationship` and `epl-info-c0-cbc-banking-relationship` at `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:31-46`. | SRS uses the implemented RPC-style endpoint names, not PRD draft REST paths. |
| Current frontend endpoint use | FE calls both endpoints via POST at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/service/api.service.ts:18-42`. | SRS method is POST for both endpoints. |
| Refactor spec | Refactor-spec lists the info/save artifacts and page artifact for EPROC00112 at `docs/refactor-spec/02_modules/EPROC00112.md:19-22`. | SRS aligns to refactor endpoint surface. |
| DB diff | CBC tables and new checkpoint tables are active/exact in db-diff, for example `docs/db-diff/02_tables/TB_CBC_BBL.md:13-16`, `docs/db-diff/02_tables/TB_CBC_GBGL.md:13-16`, and `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:13-16`. | Schema is based on db-diff, with conflicts recorded in DB reconcile. |

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-info-c0-cbc-banking-relationship` | POST | Load BBL, BGL, GBGL, totals, and current checkpoint context for a case. | R1-R3, R5, R8 |
| `epl-save-c0-cbc-banking-relationship` | POST | Persist CBC banking relationship data by full replacement and update the tab checkpoint. | R4, R6-R9 |

The PRD draft proposed `GET /api/epro/eproc00112/info`, `POST /api/epro/eproc00112/calculate`, and `POST /api/epro/eproc00112/save` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:196-198`. Current refactor code and refactor-spec instead show two page endpoints plus shared/common calculation behavior at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00112/epl-info-c0-cbc-banking-relationship.md:139-141`, `docs/refactor-spec/03_artifacts/be-corporate/EPROC00112/epl-save-c0-cbc-banking-relationship.md:139-141`, and `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00112/eproc00112-cbc-banking-relationship.md:47-49`; this SRS uses the implemented endpoint surface.

## Rules

### R1 Load initial CBC banking relationship data - 強制點: BE
covers-prd: REQ-001
強制點: BE

`epl-info-c0-cbc-banking-relationship` must accept `applicationNo`, `legacyFunctionId`, and `isQuery`, then return the BBL, BGL, and GBGL sections for the requested case. PRD requires `legacyFunctionId` for 0112/0212 parent-tab selection at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:204-205`; current request DTO only carries `applicationNo` and `isQuery` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/InfoCsuCbcBankingCorpRelationshipInfoRequest.java:12-19`, so adding or equivalently deriving `legacyFunctionId` is an RD implementation gap.

Dropdown/code options are page dependencies, but current info response DTO only carries the CBC section data and totals at `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCbcBankingCorpRelationship/InfoCsuCbcBankingCorpRelationshipInfoResponse.java:11-18` and `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCbcBankingCorpRelationship/InfoCsuCbcBankingCorpRelationshipInfoResponse.java:51-61`. The Angular page satisfies the four dropdown families through `FieldOptionsService`, calling `CCY`, `CBC_LOAN_STATUS`, `CBC_PRODUCT_TYPE`, and `CBC_SECURITY_TYPE` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/banking-relationship.component.ts:124-147`; this split replaces the legacy initQuery maps while still satisfying PRD REQ-001.

### R2 Populate BBL and BGL from borrower source rows - 強制點: BE
covers-prd: REQ-002, REQ-003
強制點: BE

BBL must include main borrower and co-borrower rows based on corporate borrower source tables, and BGL must use the same source family while persisting to its own tables. PRD states BBL and BGL source behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:105-106`; PRD source table mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:257`.

Current backend queries main borrower rows from `TB_MAIN_BORROWER_INFO_CORP` with `TB_CBC_BBL` and `TB_CBC_BGL` joins at `backend/src/main/java/khd/svc/epro/repository/TBMainBorrowerInfoCorpRepository.java:152-175`, and co-borrower rows from `TB_CO_BORROWER_INFO_CORP` with BBL/BGL joins at `backend/src/main/java/khd/svc/epro/repository/TBCoBorrowerInfoCorpRepository.java:100-131`. Current service assembles BBL and BGL response sections at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:143-189`.

### R3 Populate GBGL from individual and corporate guarantor source rows - 強制點: BE
covers-prd: REQ-004
強制點: BE

GBGL must distinguish personal and corporate guarantors by `IS_IND`, carrying both lists in one section. PRD defines personal/corporate guarantor behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:107`, and source table mapping at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:259-260`.

Current service reads personal guarantor rows through `TBGuarantorInfoRepository.getSql7` and corporate guarantor rows through `TBGuarantorInfoCorpRepository.getSql8` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:191-256`. The repository SQL joins `TB_CBC_GBGL` with `IS_IND='Y'` for personal guarantors at `backend/src/main/java/khd/svc/epro/repository/TBGuarantorInfoRepository.java:199-209` and `IS_IND='N'` for corporate guarantors at `backend/src/main/java/khd/svc/epro/repository/TBGuarantorInfoCorpRepository.java:163-173`. The exact `CR_DEL` filter policy is pending under R12.

### R4 Maintain CBC master/detail data and Save vs Finished behavior - 強制點: BE
covers-prd: REQ-005
強制點: BE

The save endpoint must accept `applicationNo`, `legacyFunctionId`, `isFinish`, `pageCheckMap`, and BBL, BGL, and GBGL master/detail structures, then persist them as CBC rows. PRD requires `legacyFunctionId` and `pageCheckMap` for 0112/0212 parent-tab completion semantics at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:222-228`. Current save DTO only requires `applicationNo`, `isFinish`, `bBL`, `bGL`, and `gBGL` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/SaveCsuCbcBankingCorpRelationshipInfoRequest.java:16-38`, so adding these fields or an explicitly equivalent server-side derivation is an RD implementation gap; current nested borrower and info validation is defined at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/SaveCsuCbcBankingCorpRelationshipInfoRequest.java:57-166` and guarantor validation at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/SaveCsuCbcBankingCorpRelationshipInfoRequest.java:187-221`.

Legacy `Save` calls `save('Y')` and `Finished` calls `save('N')` in both 0112 and 0212 JS at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00112_JS.jsp:492-503` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00212_JS.jsp:494-505`. Current Angular maps Save and Finish to `SubmitStatus.SAVE` and `SubmitStatus.FINISH` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/banking-relationship.component.ts:233-238` and transforms the save payload with `isFinish` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/config/form-config.ts:305-313`.

### R5 Calculate and return USD/KHR totals - 強制點: BE
covers-prd: REQ-006
強制點: BE

The page must calculate total credit amount and total outstanding balance for USD and KHR for BBL, BGL, and GBGL. PRD requires USD/KHR totals and marks non-USD behavior as TBD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:109`. Current response DTO initializes USD/KHR total fields for borrower and guarantor sections at `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCbcBankingCorpRelationship/InfoCsuCbcBankingCorpRelationshipInfoResponse.java:51-61` and `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCbcBankingCorpRelationship/InfoCsuCbcBankingCorpRelationshipInfoResponse.java:144-154`.

Current backend delegates totals to `investigationCaleByCurrencyService` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:300-337`; the shared calculator only sums rows where currency is USD or KHR at `backend/src/main/java/khd/svc/epro/service/individual/impl/InvestigationCaleByCurrencyServiceImpl.java:133-142`. Non-USD treatment is pending under R13 and must not be silently normalized in this SRS.

### R6 Save by full replacement in one transaction - 強制點: BE
covers-prd: REQ-007
強制點: BE

`epl-save-c0-cbc-banking-relationship` must delete existing BBL, BGL, GBGL, and their detail rows for the case, insert the submitted rows, update checkpoint state, and roll back all changes on failure. PRD requires full replacement and rollback at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:110` and describes the legacy transaction at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:96`.

Legacy 0112 begins transaction, deletes six table families, inserts rows, updates checkpoint, commits, and rolls back on exception at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0112_mod.java:243-279`; legacy 0212 mirrors this at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0212_mod.java:246-282`. Current backend marks save as transactional and performs delete/process/checkpoint update at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:93-119`, with row construction logic at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:430-626`.

### R7 Update EPROC00112 checkpoint and parent done state - 強制點: BE
covers-prd: REQ-008, REQ-009
強制點: BE

After save, the backend must update the new checkpoint column `EPROC00112` on the CS or CU checkpoint table, preserve 0112/0212 parent-tab semantics through `legacyFunctionId` plus `pageCheckMap` or an explicitly equivalent server-side derivation, and return `isAllTabsCheck` so the parent C0 frame can refresh all-tab completion state. PRD requires 0112/0212 plus CS/CU checkpoint mapping and all-tab done status at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:111-112`.

Legacy 0112 saves parent progress through `getTabsCheckPage(... "EPROC0_0110")` and `getCheckedProgressCORP` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java:120-121`; legacy 0212 uses parent `EPROC0_0210` and `getCheckedProgressRC_CORP` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java:120-121`. New DB checkpoint columns are `TB_CHECK_POINTS_CS.EPROC00112` and `TB_CHECK_POINTS_CU.EPROC00112` at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:46` and `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:44`. Current backend derives case type from summary attributes and writes `EPROC00112` with `isFinish ? "N" : "Y"` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:629-644`. The `isFinish` polarity is pending under R14.

### R8 Standardize validation and error/message handling - 強制點: BE
covers-prd: REQ-001, REQ-005, REQ-007
強制點: BE

The API contract must carry the PRD error and message keys: `COMMON_MSG_ERROR_LON`, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMON_MSG_TOTAL_FAIL`, `COMMON_MSG_ONE_DATA`, `COMMON_MSG_LIMIT`, `COMMON_MSG_SAVE_SUCCESS`, and `COMMON_MSG_SAVE_FAIL`. The OpenAPI contract also carries current request-validation code `E130` for invalid save payloads. PRD error and success keys are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:276`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:292-297`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:329-330`, and `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:233`.

Legacy 0112 maps data-not-found, over-count, calculation failure, save success, and save failure at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java:60-69`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java:89-96`, and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java:116-136`; legacy 0212 mirrors the same keys at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java:60-69`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java:89-96`, and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java:116-136`. Request validation must reject blank `applicationNo` and invalid required structures before mutation, as current DTO annotations require at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/SaveCsuCbcBankingCorpRelationshipInfoRequest.java:16-38`.

### R9 Preserve page-level edit/query/old-case behavior - 強制點: both
covers-prd: REQ-005, REQ-009
強制點: both

The page must expose Save and Finished actions only where permitted by page state, and the backend must enforce the same edit/query/old-case restrictions for `epl-save-c0-cbc-banking-relationship` before deleting/reinserting CBC data. Legacy 0112 renders a Finished button unconditionally in the page body at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00112.jsp:18`; legacy 0212 renders Finished only when `${attrMap.isOld}` is false at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00212.jsp:18-19`. Current Angular declares Save and Finish buttons and calls save/finish handlers at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/banking-relationship.component.ts:62-79` and `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/banking-relationship.component.ts:233-238`; current save controller/service mutate at `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:31-46` and `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:93-119`, so service-level authorization is a required RD implementation gap and cannot be satisfied by FE visibility or `TB_API_AUTH` seed rows alone.

Refactor field-control marks query modes as hidden/non-edit and AO edit mode as visible/editable at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00112/eproc00112-cbc-banking-relationship-field-control.md:64-86`. The OpenAPI contract exposes 401/403 target outcomes for missing auth or disallowed mutation; current backend evidence for that save-path gate is missing and is tracked as `SEC-001` in the pending register. The exact 0212 old-case Finished behavior is pending under R17.

### R10 Preserve source-difference decisions explicitly - 強制點: both
covers-prd: REQ-010
強制點: both

Differences between legacy 0112, legacy 0212, current refactor code, and db-diff must be recorded as explicit decisions, not silently defaulted. PRD requires suspicious defects such as `CR_DEL` and non-USD behavior to have decision records at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:113`. The parity SOP classifies differences as regression, intended evolution/reduction, or DB structure difference, and requires `UNFOUND` when evidence is not decisive at `docs/process/legacy-parity-sop.md:18-28`.

This SRS therefore records unresolved source filters, currency conversion, `check`/`isFinish` polarity, nullable detail lists, CS/CU branch conditions, old-case UI behavior, and DB length/PK conflicts as `@PENDING` or DB reconcile rows.

### R11 @PENDING TBD-001 funcId, route, menu, and document naming - 強制點: both
covers-prd: REQ-001, REQ-010
強制點: both

PRD `待確認-001` says the target funcId/route/menu/doc naming still needs confirmation at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:49`. Refactor code and docs currently use EPROC00112 and endpoint names `epl-info-c0-cbc-banking-relationship` / `epl-save-c0-cbc-banking-relationship` at `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:31-46` and `docs/refactor-spec/02_modules/EPROC00112.md:19-22`. Final menu and document naming beyond these endpoints remains 待 RD 核對.

### R12 @PENDING TBD-002 GBGL `CR_DEL` filtering - 強制點: BE
covers-prd: REQ-004, REQ-010
強制點: BE

PRD `待確認-002` says legacy 0112 GBGL SQL does not filter `CR_DEL != 'Y'`, while 0212 excludes `CR_DEL='Y'`; PM/SA must decide the new behavior at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:50`. Current new repository methods used by service do not show a `CR_DEL` predicate in personal `getSql7` or corporate `getSql8` at `backend/src/main/java/khd/svc/epro/repository/TBGuarantorInfoRepository.java:199-209` and `backend/src/main/java/khd/svc/epro/repository/TBGuarantorInfoCorpRepository.java:163-173`. This SRS does not decide whether to keep, remove, or branch the filter.

### R13 @PENDING TBD-003 non-USD currency calculation - 強制點: BE
covers-prd: REQ-006, REQ-010
強制點: BE

PRD `待確認-003` says legacy calculation appears to map non-USD to KHR, while UI formatting only supports USD/KHR at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:51`. Current calculator sums only USD and KHR currencies at `backend/src/main/java/khd/svc/epro/service/individual/impl/InvestigationCaleByCurrencyServiceImpl.java:133-142`. Non-USD behavior is 待 RD 核對.

### R14 @PENDING TBD-004 `check` vs `isFinish` polarity - 強制點: BE
covers-prd: REQ-005, REQ-008, REQ-009
強制點: BE

PRD `待確認-004` says legacy `check` uses `Y=Save` and `N=Finished`, which can invert intuitive boolean naming at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:52`. Legacy JS sends `save('Y')` for Save and `save('N')` for Finished at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00112_JS.jsp:492-503` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00212_JS.jsp:494-505`; current backend writes `isFinish ? "N" : "Y"` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:629-644`. This polarity needs explicit RD/QA confirmation before release.

### R15 @PENDING TBD-005 null or missing `infoList` - 強制點: BE
covers-prd: REQ-005, REQ-007
強制點: BE

PRD `待確認-005` says legacy `formateDB` iterates `infoList`; API behavior for missing or null list needs validation at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:53`. Legacy 0112 formats BBL/BGL/GBGL lists at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0112_mod.java:218-227`; legacy 0212 mirrors it at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0212_mod.java:221-230`. Current DTO validates nested lists/objects, but exact empty-list vs null behavior for each `infoList` remains 待 RD 核對.

### R16 @PENDING TBD-006 CS/CU checkpoint branch condition - 強制點: BE
covers-prd: REQ-008, REQ-009
強制點: BE

PRD `待確認-006` says `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` means secured and other values mean CU at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:54`. Current backend implements the same branch at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:629-644`, but the full allowed value set for non-CS corporate cases is UNFOUND in this bounded read.

### R17 @PENDING TBD-007 0212 old-case Finished visibility - 強制點: both
covers-prd: REQ-005, REQ-009, REQ-010
強制點: both

PRD `待確認-007` says `EPROC00212.jsp` does not show Finished when `${attrMap.isOld}` is true at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:55`. Legacy 0212 JSP gates the Finished button with `${!attrMap.isOld}` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00212.jsp:18-19`; current Angular exposes a Finish button in component config at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/banking-relationship/banking-relationship.component.ts:72-79`. Final parity decision is 待 RD 核對.

## 新舊 DB 對照 / 更動 delta / Reconcile
| Legacy / source table | New SRS table | Disposition | Evidence |
|---|---|---|---|
| `TB_CBC_BBL` | `TB_CBC_BBL` | Keep active/exact; master BBL rows. | `docs/db-diff/02_tables/TB_CBC_BBL.md:13-16`; `docs/db-diff/02_tables/TB_CBC_BBL.md:32-47` |
| `TB_CBC_BBL_INFO` | `TB_CBC_BBL_INFO` | Keep active/exact; BBL detail rows. | `docs/db-diff/02_tables/TB_CBC_BBL_INFO.md:13-16`; `docs/db-diff/02_tables/TB_CBC_BBL_INFO.md:32-52` |
| `TB_CBC_BGL` | `TB_CBC_BGL` | Keep active/exact; master BGL rows. | `docs/db-diff/02_tables/TB_CBC_BGL.md:13-16`; `docs/db-diff/02_tables/TB_CBC_BGL.md:32-47` |
| `TB_CBC_BGL_INFO` | `TB_CBC_BGL_INFO` | Keep active/exact; latest schema reverify PK is `APPLICATION_NO, BORROWER_NAME, SEQ_NO, INFO_SEQ_NO`, resolving the stale db-diff markdown PK that used `OUTSTANDING_BALANCE_CURRENCY`. | `docs/db-diff/02_tables/TB_CBC_BGL_INFO.md:13-16`; `docs/db-diff/02_tables/TB_CBC_BGL_INFO.md:32-52`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_pk.tsv:22-25` |
| `TB_CBC_GBGL` | `TB_CBC_GBGL` | Keep active/exact; master guarantor rows include `IS_IND`. | `docs/db-diff/02_tables/TB_CBC_GBGL.md:13-16`; `docs/db-diff/02_tables/TB_CBC_GBGL.md:32-47` |
| `TB_CBC_GBGL_INFO` | `TB_CBC_GBGL_INFO` | Keep active/exact; detail guarantor rows include `IS_IND`. Latest schema reverify PK order is `APPLICATION_NO, BORROWER_NAME, SEQ_NO, IS_IND, INFO_SEQ_NO`, resolving the stale db-diff markdown order that placed `INFO_SEQ_NO` before `IS_IND`. | `docs/db-diff/02_tables/TB_CBC_GBGL_INFO.md:13-16`; `docs/db-diff/02_tables/TB_CBC_GBGL_INFO.md:32-53`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_pk.tsv:30-34` |
| CBC `BORROWER_NAME` / `GUARANTOR_NAME` | Same columns | Keep as `VARCHAR2(100)`. Current db-diff markdown lists length 50, while latest schema reverify lists length 100 for BBL/BGL/GBGL master/detail name columns; schema and OpenAPI follow latest reverify. | `docs/db-diff/02_tables/TB_CBC_BBL.md:39`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:45`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:66`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:70`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:91`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:95`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:116` |
| `TB_CHECK_POINTS_CS.EPROCSU0140` | `TB_CHECK_POINTS_CS.EPROCSU0140` | Keep as `VARCHAR2(2)` checkpoint flag. The db-diff markdown row has blank `data_type`; schema reverify TSV recovers `VARCHAR2` length `2`, so schema uses the recovered DB fact instead of inferring from sibling flags. | `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:43`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:135` |
| `TB_CHECK_POINTS_CS.EPROCSU0171` | `TB_CHECK_POINTS_CS.EPROCSU0171` | Keep as `VARCHAR2(2)` checkpoint flag. db-diff markdown stops before this latest column; schema follows the latest DB reverify and records the version delta. | `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38-53`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:136` |
| `TB_CHECK_POINTS_CU.EPROC00114` / `TB_CHECK_POINTS_CU.EPROCSU0140` | Same columns | Keep as `VARCHAR2(2)` checkpoint flags. db-diff markdown stops at 13 CU columns, while latest DB reverify lists 15 columns including `EPROC00114` and `EPROCSU0140`; schema follows the latest DB reverify and records the version delta. | `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38-50`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:149`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:151` |
| `TB_LON_SUMMARY_INFO.PROJECT_CODE` | `TB_LON_SUMMARY_INFO.PROJECT_CODE` | Keep as `VARCHAR2(5)` source attribute. db-diff markdown stops at 51 columns, while latest schema reverify lists `PROJECT_CODE` as column 52; schema follows the recovered DB fact and records the version delta here. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:38-88`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:1849` |
| `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_RC_CORP` | `TB_CHECK_POINTS_CS.EPROC00112` | Old checkpoint tables are removed/transferred; new secured corporate field is `EPROC00112`. | `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:13-16`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:13-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:44-46` |
| `TB_CHECK_POINT_CU` / `TB_CHECK_POINT_RC_CU` | `TB_CHECK_POINTS_CU.EPROC00112` | Old checkpoint tables are removed/transferred; new CU field is `EPROC00112`. | `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:13-16`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:13-16`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:42-44` |
| `LATE_PAYMENT_MONTH_YEAR` | Same column on CBC master tables | Keep as `VARCHAR2(7)`. Current db-diff markdown lists length 5, while latest schema reverify and legacy UI support `MM/YYYY` length 7; schema and OpenAPI follow latest reverify. | `docs/db-diff/02_tables/TB_CBC_BBL.md:44`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:18`; `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00112_JS.jsp:369-418` |
| `NOTE` | Same column on CBC master tables | Keep as `VARCHAR2(1000)`. Current db-diff markdown lists length 500, while latest schema reverify and current DTO support 1000; schema and OpenAPI follow latest reverify. | `docs/db-diff/02_tables/TB_CBC_BBL.md:46`; `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:20`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCbcBankingCorpRelationship/SaveCsuCbcBankingCorpRelationshipInfoRequest.java:73-107` |

## @PENDING Register
| ID | Rule | Owner | Impact | Evidence | Status |
|---|---|---|---|---|---|
| TBD-001 | R11 | PM/SA/RD | Final funcId, route, menu, and document naming. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:49` | Open |
| TBD-002 | R12 | PM/SA | GBGL `CR_DEL` filtering parity or intended change. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:50` | Open |
| TBD-003 | R13 | RD | Non-USD total treatment. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:51` | Open |
| TBD-004 | R14 | RD/QA | `check` vs `isFinish` polarity and checkpoint meaning. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:52` | Open |
| TBD-005 | R15 | RD | Null/missing `infoList` request validation. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:53` | Open |
| TBD-006 | R16 | SA/RD | CS/CU checkpoint branch value set. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:54` | Open |
| TBD-007 | R17 | PM/SA/RD | 0212 old-case Finished visibility. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:55` | Open |
| SEC-001 | R9 | RD/Security | Add or verify service-level save authorization for edit/query/old-case restrictions before CBC delete/insert; FE visibility and `TB_API_AUTH` seed rows are not sufficient. | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md:305`; `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:31-46`; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CbcBankingCorpRelationshipServiceImpl.java:93-119` | Open |

## Traceability
| PRD | Rule | QA |
|---|---|---|
| REQ-001 | R1, R8, R11 | QA-001, QA-008, QA-011 |
| REQ-002 | R2 | QA-002 |
| REQ-003 | R2 | QA-002 |
| REQ-004 | R3, R12 | QA-003, QA-012 |
| REQ-005 | R4, R8, R9, R14, R15, R17 | QA-004, QA-008, QA-009, QA-014, QA-015, QA-017 |
| REQ-006 | R5, R13 | QA-005, QA-013 |
| REQ-007 | R6, R8, R15 | QA-006, QA-008, QA-015 |
| REQ-008 | R7, R14, R16 | QA-007, QA-014, QA-016 |
| REQ-009 | R7, R9, R14, R16, R17 | QA-007, QA-009, QA-014, QA-016, QA-017 |
| REQ-010 | R10, R11, R12, R13, R17 | QA-010, QA-011, QA-012, QA-013, QA-017 |

## Hard Boundaries
- This bundle does not modify `docs/pending-register.md`, ledgers, status files, source code, or generated API code.
- This bundle does not decide PRD TBD items. Each unresolved item is carried as `@PENDING`.
- Endpoint names follow current refactor/source evidence. If PM/SA later decides a different public route/menu name, update R11 and `openapi.yaml` together.
