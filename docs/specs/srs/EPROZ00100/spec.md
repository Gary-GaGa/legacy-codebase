# SRS - EPROZ00100 To Do List

## Metadata
| Field | Value |
|---|---|
| Status | Draft |
| Owner | PM/SA/RD/QA review |
| funcId | EPROZ00100 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md` |
| Bible | `docs/specs/bible/bible-eproposal.md` |
| Bundle | `docs/specs/srs/EPROZ00100/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec + legacy source evidence |

## Scope
- In scope: EPROZ0_0100 / EPROZ00100 dashboard initialization, role flags, TO DO LIST query, CAD/TLOD query, page routing, delete, close, reason selection, proposal download, and current-application session context.
- In scope: API contract draft for Spring Boot migration and DB side-effect verification against active new DB snapshot.
- Out of scope: final action-permission approval, final CASE_PROGRESS business names, final file-download token design, and final session retirement plan. These remain `@PENDING` evidence items, not SRS approval.
- This bundle is draft/in-review evidence only. It is not Approved.

## Sources
| Source | Evidence |
|---|---|
| PRD overview | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:9`, `61`-`66`, `72`-`81` |
| PRD requirements | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:109`-`117`, `119`-`128`, `130`-`138`, `140`-`153`, `155`-`173`, `175` |
| PRD API/error | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:213`-`226`, `232`-`249`, `256`-`262` |
| PRD DB/QA | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:191`-`200`, `281`-`294` |
| Bible | `docs/specs/bible/bible-eproposal.md:315`-`332`, `390`, `796`-`810` |
| Legacy trx | `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:67`-`86`, `150`-`157`, `185`-`193`, `224`-`227`, `326`-`338`, `371`-`380`, `408`-`431` |
| Legacy module | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:58`-`59`, `72`-`74`, `99`-`109`, `135`-`181`, `242`-`284`, `376`-`431`, `448`-`512`, `566`-`577` |
| db-diff | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`16`, `38`-`84`; `docs/db-diff/02_tables/TB_APP_HISTORY.md:11`-`16`, `32`-`44`; `docs/db-diff/02_tables/TB_DEL_REASON.md:11`-`16`, `32`-`41`; `docs/db-diff/02_tables/TB_CLO_REASON.md:11`-`16`, `32`-`41`; `docs/db-diff/02_tables/TB_RELATED_PARTY_INFO.md:11`-`16`, `32`-`43`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:11`-`16`, `32`-`47`; `docs/db-diff/02_tables/TB_EMP_PROXY.md:11`-`16`, `32`-`43`; `docs/db-diff/02_tables/TB_ROLE_DEFINE.md:11`-`16`, `32`-`40`; `docs/db-diff/02_tables/TB_PROCESS_CODE.md:11`-`16`, `32`-`42`; `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`, `32`-`40` |
| refactor-spec | `docs/refactor-spec/02_modules/EPROZ00100.md:3`-`21`; `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:6`-`14`, `88`-`107`, `135`-`137`, `149`-`156`, `164`-`217`; `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-delreason.md:6`-`14`, `106`-`114`, `122`-`124`, `150`-`177`, `187`-`188`; `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-cloreason.md:6`-`14`, `106`-`114`, `122`-`125`, `151`-`175`, `185`-`187`; `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:6`-`14`, `96`-`104`, `165`-`214` |
| auth runtime | `docs/build-tasks/c0-authz-sql-findings.md:17`-`21`, `30` |

## Role Display Baseline
| Role code | Display/group label | Evidence |
|---|---|---|
| `001` | AO Assistant | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `002` | AO | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `003` | Manager / Unit Manager | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `101` | Credit Risk Admin | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `102` | Credit Reviewer | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `103` | Credit Reviewer + Scorecard | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `201/202/203` | CO roles | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `301/302` | SCO roles | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `402` | CAD | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `404` | TLOD Maker | Bible `docs/specs/bible/bible-eproposal.md:796` |
| `405` | TLOD Checker | Bible `docs/specs/bible/bible-eproposal.md:796` |

## Endpoints
| Endpoint | Method | Purpose | Covers | Baseline |
|---|---|---|---|---|
| `epl-init-z0-todolist` | POST | Clear current session, return role flags, and optionally run CA/CR redistribution | R1 | PRD/legacy draft; refactor artifact missing |
| `epl-list-todolist` | POST | Query non-CAD task list and CAD/TLOD search list using explicit query mode | R2, R3, R4 | refactor latest BE artifact |
| `epl-case-insert-delreason` | POST | Delete case with delete reason and history update | R5 | refactor latest BE artifact |
| `epl-case-insert-cloreason` | POST | Close CAD/TLOD case with close reason and history update | R6 | refactor latest BE artifact |
| `epl-file-z0-proposal-download` | POST | Generate proposal download reference for CS/CU/IS/IU | R7 | PRD/legacy draft; file token design pending |
| `epl-session-z0-current-application` | POST/DELETE | Set or clear current application context while legacy pages still need session | R8 | PRD/legacy draft; migration sunset pending |
| `epl-sele-z0-delete-reason` | GET | Return delete reason code map | R5 | PRD/legacy draft |
| `epl-sele-z0-close-reason` | GET | Return close reason code map | R6 | PRD/legacy draft |

### R1 Dashboard initialization and redistribution **強制點 both**
covers-prd: REQ-001

The backend must clear prior `APPLICATION_NO` / action session context, return `isAO`, `role`, `isCA`, `isCRCOSCO`, `isCOSCO`, and `isCADMERCER`, and run CA/CR redistribution only when the role and source conditions match. Because redistribution updates `TB_LON_SUMMARY_INFO` and inserts `TB_APP_HISTORY`, this operation is modeled as POST, not GET.

Evidence: PRD requires clearing session, role flags, CA/CR redistribution, and non-GET semantics at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:113`-`117`. Legacy `doPrompt` calls `updateLonSummaryInfo(user, "CA")` / `"CR"` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:67`-`86`. Legacy redistribution writes `CASE_PROGRESS`, `CURRENT_USER_ID`, `CR_CODE`, `RE_DISTRIBUTION`, `RECEIVED_DATE`, `DISTRIBUTION_DATE`, and history rows at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:242`-`284`, `294`-`337`.

Error-code contract: `REDISTRIBUTION_FAILED` is returned as 500 when the redistribution transaction fails; general init query/setup failures return 500 with `MSG_QUERY_FAIL`; unauthorized API access returns platform authorization error, with `FORBIDDEN_ACTION` reserved for business-role rejection.

### R2 Main task list query **強制點 both**
covers-prd: REQ-002

`epl-list-todolist` with `queryMode=GENERAL` must query by current user, exclude `CASE_PROGRESS` values `03`, `D1`, `R0305`, `R0313`, `R0397`, return borrower display fields, convert sentinel application date `01/01/1900` to blank display, enrich `showRelated=Y` when `TB_RELATED_PARTY_INFO.IS_CUB_RELATED`, `IS_CUBC_RELATED`, or `IS_TCP` is `Y`, and enrich USD/KHR total amount from `TB_LOAN_CONDITION_DETAIL`. `D1` is carried as legacy as-is exclusion evidence; its formal business meaning remains controlled by `PENDING-Z002`.

Evidence: PRD lists these behaviors at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:123`-`128`. Legacy defines the excluded statuses at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:58`-`59`, queries by `CURRENT_USER_ID` at `72`-`74`, and enriches related party / loan condition data at `99`-`109`. Refactor `epl-list-todolist` carries request fields and response mappings at `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:88`-`107`, `164`-`217`.

Error-code contract: missing or invalid CAD query input returns `INVALID_CAD_QUERY_CONDITION`; general list/CAD repository failures return 500 with `MSG_QUERY_FAIL`.

### R3 CAD/TLOD task search **強制點 both**
covers-prd: REQ-003

`epl-list-todolist` with `queryMode=CAD` must query current CAD/TLOD user plus active proxy employees, restrict `LON_TYPE_CODE` to `01/02/03/04`, support `applicationNo`, `docNo`, `mainBorrowerName`, `startDecisionDate`, and `endDecisionDate`, and return `decisionDate`, approval level, `docNo1`, borrower name, sales channel, `caseProgress`, and `page`. Date inputs use `dd/MM/yyyy`; incomplete pairs, invalid date strings, and ranges over six months are rejected in the draft contract unless SA/RD later relax `PENDING-Z005`.

Evidence: PRD CAD search rules are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:134`-`138`. Legacy obtains active proxy employees from `TB_EMP_PROXY` and adds them to `IN_CURRENT_USER_ID` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:135`-`150`, maps request field `NO` for document/register number at `158`-`160`, applies borrower name and date range filters at `164`-`181`, uses corporate `REGISTER_NO` for `docNo1` at `207`-`208`, and normalizes borrower name at `213`-`215`.

Error-code contract: empty condition, incomplete date pair, or invalid date range returns `INVALID_CAD_QUERY_CONDITION` as 400.

### R4 Page routing **強制點 both**
covers-prd: REQ-004

Routing must preserve the legacy first-page decisions while returning refactor page-family routes as the to-be contract. CA + IS/IU routes to the `EPROISU0171` family, CA + CS/CU routes to the `EPROCSU0171` family, CAD/TLOD Maker status `21/22` routes `EPROISU0910`, Maker `24/25` routes `EPROISU0920`, CAD/TLOD Checker `23` routes `EPROISU0910`, Checker `25` routes `EPROISU0920`, other CAD/TLOD routes `MANUALAPP`, and other roles use first-page resolution in the `EPROISU` / `EPROCSU` page family. Legacy IDs such as `EPROIS_0910` remain trace labels only, not acceptance route IDs.

Evidence: PRD routing table is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:140`-`153`. Legacy CAD routing branches are at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:566`-`577`. Bible requires distinguishing legacy `IS/IU/CS/CU` from refactor `EPROISU/EPROCSU` page families at `docs/specs/bible/bible-eproposal.md:793`-`794`.

### R5 Delete case **強制點 BE**
covers-prd: REQ-005

Only AO roles `001/002` may delete from this page; AO role `003` must not delete. The request must include `applicationNo` and `reasonList` with at least one reason. If reason `D99` is selected, `otherReason` is required and max length is 100. The API accepts a reason array; semicolon-joining is a DB persistence detail for `TB_DEL_REASON.REASON_CODE`, not an API input contract. The transaction must insert `TB_DEL_REASON`, insert `TB_APP_HISTORY`, update `TB_LON_SUMMARY_INFO.CASE_PROGRESS = D1`, and roll back all three writes on failure. `D1` is legacy as-is evidence for delete; its formal to-be status meaning is not approved until `PENDING-Z002` is closed.

Evidence: PRD delete rules are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:159`-`163`. Legacy execute validates `APPLICATION_NO`, builds `TB_DEL_REASON`, sets `CASE_PROGRESS = D1`, writes history, and commits/rolls back at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:376`-`431`. Refactor `epl-case-insert-delreason` carries `applicationNo`, `reasonCode`, `otherReason`, process code `D1`, and table writes at `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-delreason.md:122`-`124`, `150`-`177`, `187`-`188`.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; no reason returns `MISSING_REASON`; `D99` without `otherReason` returns `MISSING_OTHER_REASON`; `otherReason` over 100 chars returns `E102` field validation under `REF-D3` until RD maps the final error envelope; unauthorized business roles return `FORBIDDEN_ACTION`; transaction/update failure returns `MSG_UPDATE_FAIL`.

### R6 Close CAD/TLOD case **強制點 BE**
covers-prd: REQ-006

Only CAD/TLOD Maker or Checker roles may close. The request must include `applicationNo` and `reasonList` with at least one close reason; `caseProgress` is read/derived from case state and is not required from the client. If reason `C99` is selected, `otherReason` is required and max length is 100. The API accepts a reason array; semicolon-joining is a DB persistence detail for `TB_CLO_REASON.REASON_CODE`, not an API input contract. The transaction must insert `TB_CLO_REASON`, insert `TB_APP_HISTORY`, set `TB_LON_SUMMARY_INFO.CASE_PROGRESS = C1`, clear `CURRENT_USER_ID`, and convert `IS_AUTODIS` from `M` to `MC` or `Y` to `YC`.

Evidence: PRD close rules are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:169`-`173`. Legacy close validates `APPLICATION_NO`, receives `reasonList` from the request, reads `TB_LON_SUMMARY_INFO`, sets `CASE_PROGRESS=C1`, clears `CURRENT_USER_ID`, converts `IS_AUTODIS`, writes close reason/history, and commits/rolls back at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:379`-`380` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:448`-`512`. Refactor `epl-case-insert-cloreason` exposes `caseProgress` / `reasonCode`, but this SRS keeps the PRD/legacy `reasonList` contract and treats semicolon joining as DB-internal evidence at `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-cloreason.md:122`-`125`, `151`-`175`, `185`-`187`.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; no close reason returns `MISSING_REASON`; `C99` without `otherReason` returns `MISSING_OTHER_REASON`; `otherReason` over 100 chars returns `E102` field validation under `REF-D3` until RD maps the final error envelope; unauthorized business roles return `FORBIDDEN_ACTION`; transaction/update failure returns `MSG_UPDATE_FAIL`.

### R7 Proposal download @PENDING **強制點 both**
covers-prd: REQ-007

The SRS carries the as-is dispatch evidence but does not approve the final file-delivery design. `type=CS/CU/IS/IU` dispatches to the corresponding proposal module only after the backend validates the requested type against the case attributes in `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE` and `SECURE_ATTRIBUTE`; the client-provided type is not trusted by itself. The response must return a one-time, short-lived `downloadToken` with expiry metadata and must not expose a reusable local filesystem path. The legacy `encryptTempFileFullPath` return is source evidence only and remains in `PENDING-Z006` for RD/Security closure.

Evidence: PRD names CS/CU/IS/IU dispatch and encrypted temp file output at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:177`-`183`, response draft at `249`, and security concerns at `275`. Legacy `downloadFile` is an audited print action and dispatches CS/CU/IS/IU at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:224`-`241`. Bible requires report/proposal sources to align with process source of truth at `docs/specs/bible/bible-eproposal.md:809`-`810`.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; unauthorized role returns `FORBIDDEN_ACTION`; proposal generation or encryption failure returns `DOWNLOAD_FAILED`.

### R8 Current application session context @PENDING **強制點 both**
covers-prd: REQ-001, REQ-004

While legacy pages still depend on server session, `epl-session-z0-current-application` must set `APPLICATION_NO` and optional action context before routing, and DELETE must clear it. If platform authorization rejects set/clear with `ACCESS_DENIED` or equivalent, the backend must leave the existing session unchanged and must not create or clear application context. The session dependency is migration-only and must not become the final long-term contract without RD approval.

Evidence: PRD session requirements are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:113`, `225`-`226`, `287`. Legacy set/clear actions are at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:408`-`431`. PRD marks session-to-route migration as TBD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:41`.

Error-code contract: missing `applicationNo` on set returns `MISSING_APPLICATION_NO`.

### R9 Authorization, validation, audit, and logging **強制點 BE**
covers-prd: REQ-001, REQ-005, REQ-006, REQ-007

Backend must enforce role authorization for delete, close, download, and mutation endpoints; UI button hiding is not sufficient. Mutating actions must write audit/history records as specified and must not log sensitive full payloads. API authorization must be backed by the `TB_API_AUTH.API_ID` row, its semicolon-delimited `ROLE` allow-list, and `REF_FUNCTION_ID`; a role absent from the `ROLE` allow-list is an authorization failure even when the `API_ID` row exists.

Evidence: PRD NFR requires backend authorization, audit, and safe logging at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:270`-`275`. Bible requires API authorization by `TB_API_AUTH` and negative tests for hidden-button bypass at `docs/specs/bible/bible-eproposal.md:332`, `439`, `448`. db-diff defines `TB_API_AUTH` as active/exact and rewritten at `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`, with single-column PK `API_ID` and columns `API_ID`, `ROLE`, and `REF_FUNCTION_ID` at `38`-`40`. Runtime evidence records `ROLE LIKE %:role%` and exact `API_ID` matching at `docs/build-tasks/c0-authz-sql-findings.md:21`, with DB precheck confirming `TB_API_AUTH_PK(API_ID)` at `30`.

Error-code contract: business authorization failure returns `FORBIDDEN_ACTION`; platform/API-auth failure returns `ACCESS_DENIED` or the platform standard auth response and must not be treated as successful mutation.

## 新舊 DB 對照 / 更動 delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_LON_SUMMARY_INFO` remains the active/exact case master. Relevant columns include `APPLICATION_NO`, `LON_TYPE_CODE`, `APPLICATION_DATE`, `RECEIVED_DATE`, `DISTRIBUTION_DATE`, `DECISION_DATE`, `CASE_PROGRESS`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, `CR_CODE`, `CURRENT_USER_ID`, `CA_CODE`, `RE_DISTRIBUTION`, and `IS_AUTODIS`. | carried | `schema.sql` includes the touched columns and uses this table for list, CAD query, redistribution, delete, and close verification. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`16`, `32`, `38`-`84`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:191`-`194` |
| DB-D2 `TB_APP_HISTORY` remains active/exact with PK `APPLICATION_NO`, `APP_PROCESS_CODE`, `PROCESS_DATE`; db-diff lists seven physical columns, while PRD/legacy delete and close write `PROCESS_AGENT_CODE` / `PROCESS_AGENT_NAME` when acting as proxy. | carried + @PENDING | Delete, close, and redistribution must insert history rows in the same transaction as summary updates. `schema.sql` preserves the db-diff snapshot and comments the legacy agent-field mismatch for `PENDING-Z010` rather than inventing unverified physical columns. | `docs/db-diff/02_tables/TB_APP_HISTORY.md:11`-`16`, `32`-`44`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:163`, `195`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:421`-`422`, `502`-`503` |
| DB-D3 `TB_DEL_REASON` and `TB_CLO_REASON` remain active/exact and store semicolon-joined reason codes plus `OTH_REASON`. | carried | `schema.sql` includes both reason tables; OpenAPI accepts `reasonList[]` plus `otherReason` and leaves semicolon joining inside persistence logic. | `docs/db-diff/02_tables/TB_DEL_REASON.md:11`-`16`, `38`-`41`; `docs/db-diff/02_tables/TB_CLO_REASON.md:11`-`16`, `38`-`41`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:235`-`236`; legacy request `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:334`, `379`; legacy join `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:390`-`396`, `462`-`469` |
| DB-D4 `TB_RELATED_PARTY_INFO`, `TB_LOAN_CONDITION_DETAIL`, and `TB_EMP_PROXY` remain active/exact lookup/enrichment tables. | carried | `showRelated` uses the active columns `IS_CUB_RELATED`, `IS_CUBC_RELATED`, and `IS_TCP` (the PRD references these explicit columns directly); the bare `IS_Y` form is treated as a legacy DAO alias, not a physical column. `schema.sql` comments/DDL carry the subset needed for QA verification, not ownership of full table design. | `docs/db-diff/02_tables/TB_RELATED_PARTY_INFO.md:11`-`16`, `32`-`43`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:178`-`179`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:11`-`16`, `32`-`47`; `docs/db-diff/02_tables/TB_EMP_PROXY.md:11`-`16`, `32`-`43` |
| DB-D5 `TB_ROLE_DEFINE`, `TB_PROCESS_CODE`, and `TB_API_AUTH` are active/exact but rewritten seed/config tables. | changed | Role display names/groups are carried in the Role Display Baseline. Status names and API auth seed remain configuration baselines requiring seed verification. `TB_API_AUTH` uses single-row `API_ID` with `ROLE` as an allow-list, not a composite `(API_ID, ROLE)` row model. | `docs/db-diff/02_tables/TB_ROLE_DEFINE.md:11`-`16`, `38`-`40`; `docs/db-diff/02_tables/TB_PROCESS_CODE.md:11`-`16`, `38`-`42`; `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`, `38`-`40`; `docs/build-tasks/c0-authz-sql-findings.md:21`, `30`; Bible `docs/specs/bible/bible-eproposal.md:390`, `796`-`797` |
| REF-D1 refactor latest map has 6 artifacts: 3 BE and 3 FE. BE latest includes `epl-list-todolist`, `epl-case-insert-delreason`, and `epl-case-insert-cloreason`. | changed | The SRS uses the three latest BE artifact IDs as implemented contract anchors and maps PRD-only actions to draft endpoints/pending items. | `docs/refactor-spec/02_modules/EPROZ00100.md:3`-`21` |
| REF-D2 PRD lists legacy-style `/api/eproz0-0100/initQuery` GET and `/queryCAD` POST, while refactor latest has one POST `epl-list-todolist` artifact with search fields. | changed | Use POST `epl-list-todolist` with `queryMode=GENERAL/CAD` in OpenAPI; keep legacy action names as trace labels only. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:217`-`219`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:135`-`137`, `149`-`156` |
| REF-D3 delete/close refactor artifacts have placeholder API paths (`待補/...`), field-validation code `E102`, and `reasonCode` / `caseProgress` fields, while PRD/legacy require `reasonList[]` and do not require close `caseProgress` from the client. | changed | OpenAPI carries PRD business codes and the PRD/legacy request shape; `E102` remains platform validation evidence for field-level failures until RD maps final error envelope. | `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-delreason.md:114`, `187`-`188`; `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-cloreason.md:114`, `185`-`187`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:235`-`236`, `256`-`258`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:334`, `379` |
| REF-D4 FE latest says CAD was updated to TLOD in v1.5, while PRD still uses CAD language for role `404/405`. | changed + @PENDING | SRS names CAD/TLOD together and keeps `PENDING-Z001` for PM/SA approval of user-facing role terminology. | `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:96`, `213`-`214`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:34`, `93`; Bible `docs/specs/bible/bible-eproposal.md:408`-`409` |
| REF-D5 refactor latest does not expose separate BE artifacts for prompt redistribution, set/clear session, proposal download, or reason-list query. | @PENDING | SRS includes draft paths for required PRD surface but marks final endpoint ownership and implementation artifact gaps in `PENDING-Z003`, `PENDING-Z006`, and `PENDING-Z008`. | `docs/refactor-spec/02_modules/EPROZ00100.md:15`-`21`; PRD endpoints `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:217`-`226` |

## @PENDING
| ID | Status | Owner | Blocking? | Evidence | Required decision |
|---|---|---|---|---|---|
| PENDING-Z001 | @PENDING | PM/SA | Yes for final action approval | PRD TBD-001 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:34`; Bible role dictionary `docs/specs/bible/bible-eproposal.md:796`; FE TLOD rename `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:96` | Approve per-action permissions for delete, close, download, redistribution, and session set/clear by role. Role display labels are carried in the SRS baseline and are not pending. |
| PENDING-Z002 | @PENDING | PM/SA | Yes for status-code signoff | PRD TBD-003 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:36`; Bible status dictionary `docs/specs/bible/bible-eproposal.md:797` | Confirm formal semantics for `D1`, `C1`, `R0305`, `R0313`, `R0397`, and CAD/TLOD `21`-`25`. |
| PENDING-Z003 | @PENDING | SA/RD | Yes if redistribution remains on init | PRD TBD-002 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:35`; legacy side effect `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:80`-`86` | Decide whether dashboard init keeps CA/CR redistribution side effect and approve POST endpoint/artifact ownership. |
| PENDING-Z004 | @PENDING | RD | Yes for CAD query compatibility | PRD TBD-004 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:37`; legacy reads `NO` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:158`-`160`; PRD request calls it `docNo` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:237` | Confirm `docNo` to legacy `NO` mapping and response `docNo1` source rules. |
| PENDING-Z005 | @PENDING | SA/RD/QA | No for draft, Yes for performance signoff | PRD TBD-005 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:38`; FE six-month validation evidence `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:169`-`171` | Draft SRS rejects CAD decision-date ranges over six months; decide whether SA/RD approves, relaxes, or replaces this backend rule before signoff. |
| PENDING-Z006 | @PENDING | RD/Security | Yes for download implementation | PRD TBD-006 and NFR `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:39`, `275` | Approve token/path strategy for proposal download and retention/expiry policy. |
| PENDING-Z007 | @PENDING | PM/SA | Yes for reason-code seed approval | PRD TBD-007 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:40`; FE D99/C99 behavior `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:103`-`104` | Approve delete/close reason code table and `D99`/`C99` other-reason business rules. |
| PENDING-Z008 | @PENDING | RD | Yes for route/session retirement | PRD TBD-008 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:41`; legacy set/clear actions `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:408`-`431` | Decide how long server session context remains and when route parameters/API state replace it. |
| PENDING-Z009 | @PENDING | RD | No for draft, Yes before auth seed signoff | db-diff `TB_API_AUTH` rewritten `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`; SRS endpoints include draft IDs not present in refactor latest map `docs/refactor-spec/02_modules/EPROZ00100.md:15`-`21` | Insert/verify one `TB_API_AUTH` row per final `epl-*` API ID with the approved semicolon-delimited role allow-list and `REF_FUNCTION_ID`. |
| PENDING-Z010 | @PENDING | DBA/RD | Yes before implementation signoff | db-diff `TB_APP_HISTORY` has seven columns at `docs/db-diff/02_tables/TB_APP_HISTORY.md:38`-`44`; PRD/legacy require proxy agent fields at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:163` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:421`-`422`, `502`-`503` | Confirm where `PROCESS_AGENT_CODE` / `PROCESS_AGENT_NAME` are stored or update schema/DAO mapping for proxy delete/close history. |

## Traceability Matrix
| PRD | SRS | QA |
|---|---|---|
| REQ-001 | R1, R8, R9 | QA-001, QA-002, QA-003, QA-004, QA-004A, QA-005, QA-030, QA-037, QA-038, QA-039, QA-039A, QA-042 |
| REQ-002 | R2 | QA-006, QA-007, QA-008, QA-009, QA-010 |
| REQ-003 | R3 | QA-011, QA-012, QA-013, QA-014, QA-014A, QA-015 |
| REQ-004 | R4, R8 | QA-016, QA-017, QA-018, QA-019, QA-019A, QA-020, QA-030, QA-037, QA-038, QA-039, QA-039A |
| REQ-005 | R5, R9 | QA-021, QA-022, QA-022A, QA-023, QA-024, QA-025, QA-026, QA-040, QA-041, QA-042 |
| REQ-006 | R6, R9 | QA-027, QA-028, QA-029, QA-031, QA-032, QA-032A, QA-033, QA-040, QA-041, QA-042 |
| REQ-007 | R7, R9 | QA-034, QA-034A, QA-035, QA-036, QA-036A, QA-042 |

## NFR
- Security: backend authorization must reject direct API calls for roles without action permission; `TB_API_AUTH` seed must be verified for final API IDs.
- Audit: actions that mutate `TB_LON_SUMMARY_INFO` must insert `TB_APP_HISTORY` or explicitly document the exception.
- Transaction: delete, close, and redistribution are all-or-nothing; partial reason/history/summary writes are regressions.
- Privacy: logs must not include full reason text, full borrower name, or reusable local download paths.
- Performance: list and CAD query must require bounded conditions and must not support unrestricted full-table query.
