# SRS - EPROZ00100 To Do List

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| Status | 規格定版: Approved / 實作完成: Approved (RD/DBA closeout 2026-06-20) |
| Owner | PM/SA/RD/QA review |
| funcId | EPROZ00100 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md` |
| Bible | `docs/specs/bible/bible-eproposal.md` |
| Bundle | `docs/specs/srs/EPROZ00100/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec + legacy source evidence |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `README.md`（人類 digest）（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | Approved baseline; **2026-06-25 兩半轉換**：改 canonical Contract/Appendix 結構、Traceability 段已移除（追溯靠 covers-prd）、各 Rn 加 [ev→Rn]；只重排、不改語意。 |

## Scope
- In scope: EPROZ0_0100 / EPROZ00100 dashboard initialization, role flags, TO DO LIST query, CAD/TLOD query, page routing, delete, close, reason selection, proposal download, and current-application session context.
- In scope: Approved API contract for Spring Boot migration and DB side-effect verification against active new DB snapshot.
- Out of scope: I0/個金 page-family ownership and full table design ownership beyond the verification subset carried in `schema.sql`.

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-init-z0-todolist` | POST | Clear current session, return role flags, and run CA/CR redistribution when source conditions match | R1 |
| `epl-list-todolist` | POST | Query non-CAD task list and CAD/TLOD search list using explicit query mode | R2, R3, R4 |
| `epl-case-insert-delreason` | POST | Delete case with delete reason and history update | R5 |
| `epl-case-insert-cloreason` | POST | Close CAD/TLOD case with close reason and history update | R6 |
| `epl-file-z0-proposal-download` | POST/GET | Generate and consume a one-time proposal download reference for CS/CU/IS/IU | R7 |
| `epl-session-z0-current-application` | POST/DELETE | Set or clear current application context while legacy pages still need session | R8 |
| `epl-sele-z0-delete-reason` | GET | Return delete reason code map | R5 |
| `epl-sele-z0-close-reason` | GET | Return close reason code map | R6 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 Dashboard initialization and redistribution - 強制點: both
covers-prd: REQ-001

The backend must clear prior `APPLICATION_NO` / action session context, return `isAO`, `role`, `isCA`, `isCRCOSCO`, `isCOSCO`, and `isCADMERCER`, and run CA/CR redistribution only when the role and source conditions match. Because redistribution updates `TB_LON_SUMMARY_INFO` and inserts `TB_APP_HISTORY`, this operation is modeled as POST, not GET, and must be implemented with endpoint auth, one transaction, history insert, and rollback on failure.

Error-code contract: `REDISTRIBUTION_FAILED` is returned as 500 when the redistribution transaction fails; general init query/setup failures return 500 with `MSG_QUERY_FAIL`; unauthorized API access returns platform authorization error, with `FORBIDDEN_ACTION` reserved for business-role rejection. [ev→R1]

### R2 Main task list query - 強制點: both
covers-prd: REQ-002

`epl-list-todolist` with `queryMode=GENERAL` must query by current user, exclude `CASE_PROGRESS` values `03`, `D1`, `R0305`, `R0313`, `R0397`, return borrower display fields, convert sentinel application date `01/01/1900` to blank display, enrich `showRelated=Y` when `TB_RELATED_PARTY_INFO.IS_CUB_RELATED`, `IS_CUBC_RELATED`, or `IS_TCP` is `Y`, and enrich USD/KHR total amount from `TB_LOAN_CONDITION_DETAIL`. The to-be status baseline is the active `TB_PROCESS_CODE` rows: `D1=Delete`, `C1=Closed`, `R0305/R0313/R0397=CA Redistributing`, and CAD/TLOD `21`-`25` follow the DB contract/disbursement status names.

Error-code contract: missing or invalid CAD query input returns `INVALID_CAD_QUERY_CONDITION`; general list/CAD repository failures return 500 with `MSG_QUERY_FAIL`. [ev→R2]

### R3 CAD/TLOD task search - 強制點: both
covers-prd: REQ-003

`epl-list-todolist` with `queryMode=CAD` must query current CAD/TLOD user plus active proxy employees, restrict `LON_TYPE_CODE` to `01/02/03/04`, support `applicationNo`, `docNo`, `mainBorrowerName`, `startDecisionDate`, and `endDecisionDate`, and return `decisionDate`, approval level, `docNo1`, borrower name, sales channel, `caseProgress`, and `page`. Request `docNo` is the document/register search over identity document fields plus `REGISTER_NO`; response `docNo1` is sourced from `V_MAIN_BORROWER_INFO.DOC_NO_REGISTER_NO`, and corporate cases must surface `REGISTER_NO` through that view/source contract. Date inputs use `dd/MM/yyyy`; incomplete pairs, invalid date strings, end dates before start dates, and ranges where `endDecisionDate` is later than `startDecisionDate` plus six calendar months must be rejected by backend validation.

Error-code contract: empty condition, incomplete date pair, or invalid date range returns `INVALID_CAD_QUERY_CONDITION` as 400. [ev→R3]

### R4 Page routing - 強制點: both
covers-prd: REQ-004

Routing must preserve the legacy first-page decisions while returning refactor page-family routes as the to-be contract. CA + IS/IU routes to the `EPROISU0171` family, CA + CS/CU routes to the `EPROCSU0171` family, CAD/TLOD Maker status `21/22` routes `EPROISU0910`, Maker `24/25` routes `EPROISU0920`, CAD/TLOD Checker `23` routes `EPROISU0910`, Checker `25` routes `EPROISU0920`, other CAD/TLOD routes `MANUALAPP`, and other roles use first-page resolution in the `EPROISU` / `EPROCSU` page family. Legacy IDs such as `EPROIS_0910` remain trace labels only, not acceptance route IDs. [ev→R4]

### R5 Delete case - 強制點: BE
covers-prd: REQ-005

Only AO roles `001/002` may delete from this page; AO role `003` must not delete. The request must include `applicationNo` and `reasonList` with at least one reason. The delete reason baseline from DB is `D01`-`D12` and `D99`. If reason `D99` is selected, `otherReason` is required and max length is 100; otherwise `otherReason` may be blank. The API accepts a reason array; semicolon-joining is a DB persistence detail for `TB_DEL_REASON.REASON_CODE`, not an API input contract. The transaction must insert `TB_DEL_REASON`, insert `TB_APP_HISTORY`, update `TB_LON_SUMMARY_INFO.CASE_PROGRESS = D1`, and roll back all three writes on failure. For normal and proxy delete, `TB_APP_HISTORY.PROCESS_EMP_CODE` / `PROCESS_EMP_NAME` record the actual acting employee; `PROCESS_AGENT_CODE` / `PROCESS_AGENT_NAME` are legacy evidence only and are not to-be columns. `D1` is the approved `TB_PROCESS_CODE` to-be status for Delete.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; no reason returns `MISSING_REASON`; `D99` without `otherReason` returns `MISSING_OTHER_REASON`; `otherReason` over 100 chars returns `E102` field validation under `REF-D3` until RD maps the final error envelope; unauthorized business roles return `FORBIDDEN_ACTION`; transaction/update failure returns `MSG_UPDATE_FAIL`. [ev→R5]

### R6 Close CAD/TLOD case - 強制點: BE
covers-prd: REQ-006

Only CAD/TLOD Maker or Checker roles may close. The request must include `applicationNo` and `reasonList` with at least one close reason; `caseProgress` is read/derived from case state and is not required from the client. The close reason baseline from DB is `C01`-`C11` and `C99`. If reason `C99` is selected, `otherReason` is required and max length is 100; otherwise `otherReason` may be blank. The API accepts a reason array; semicolon-joining is a DB persistence detail for `TB_CLO_REASON.REASON_CODE`, not an API input contract. The transaction must insert `TB_CLO_REASON`, insert `TB_APP_HISTORY`, set `TB_LON_SUMMARY_INFO.CASE_PROGRESS = C1`, clear `CURRENT_USER_ID`, and convert `IS_AUTODIS` from `M` to `MC` or `Y` to `YC`. For normal and proxy close, `TB_APP_HISTORY.PROCESS_EMP_CODE` / `PROCESS_EMP_NAME` record the actual acting employee; `PROCESS_AGENT_CODE` / `PROCESS_AGENT_NAME` are legacy evidence only and are not to-be columns.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; no close reason returns `MISSING_REASON`; `C99` without `otherReason` returns `MISSING_OTHER_REASON`; `otherReason` over 100 chars returns `E102` field validation under `REF-D3` until RD maps the final error envelope; unauthorized business roles return `FORBIDDEN_ACTION`; transaction/update failure returns `MSG_UPDATE_FAIL`. [ev→R6]

### R7 Proposal download - 強制點: both
covers-prd: REQ-007

`type=CS/CU/IS/IU` dispatches to the corresponding proposal module only after the backend validates the requested type against the case attributes in `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE` and `SECURE_ATTRIBUTE`; the client-provided type is not trusted by itself. POST returns a one-time, short-lived `downloadToken` with `expiresAt` metadata and must not expose a reusable local filesystem path. GET on the same API ID consumes the token and streams the PDF; reuse, expiry, or an unknown token must be rejected. Token TTL uses the platform download-token policy when one exists; otherwise the default TTL is 10 minutes and must be configurable.

Error-code contract: missing `applicationNo` returns `MISSING_APPLICATION_NO`; unauthorized role returns `FORBIDDEN_ACTION`; proposal generation or encryption failure returns `DOWNLOAD_FAILED`. [ev→R7]

### R8 Current application session context - 強制點: both
covers-prd: REQ-001, REQ-004

`epl-session-z0-current-application` is a migration-only bridge. While legacy pages still depend on server session, POST must set `APPLICATION_NO` and optional action context before routing, and DELETE must clear it. If platform authorization rejects set/clear with `ACCESS_DENIED` or equivalent, the backend must leave the existing session unchanged and must not create or clear application context. The long-term target is route/API state, not server session; the bridge retires when the related `EPROISU` / `EPROCSU` routes no longer read server-session application context.

Error-code contract: missing `applicationNo` on set returns `MISSING_APPLICATION_NO`. [ev→R8]

### R9 Authorization, validation, audit, and logging - 強制點: BE
covers-prd: REQ-001, REQ-005, REQ-006, REQ-007

Backend must enforce role authorization for delete, close, download, and mutation endpoints; UI button hiding is not sufficient. Mutating actions must write audit/history records as specified and must not log sensitive full payloads. The eight SRS `epl-*` API IDs are the final `TB_API_AUTH` seed baseline: `epl-init-z0-todolist`, `epl-list-todolist`, `epl-case-insert-delreason`, `epl-case-insert-cloreason`, `epl-file-z0-proposal-download`, `epl-session-z0-current-application`, `epl-sele-z0-delete-reason`, and `epl-sele-z0-close-reason`. API authorization must be backed by the single `TB_API_AUTH.API_ID` row, its semicolon-delimited `ROLE` allow-list, and `REF_FUNCTION_ID=EPROZ00100`; a role absent from the `ROLE` allow-list is an authorization failure even when the `API_ID` row exists. Role allow-lists are least-privilege and exclude role `403` from every user-facing `EPROZ00100` API.

| API ID | Approved `ROLE` allow-list |
|---|---|
| `epl-init-z0-todolist` | `001;002;003;101;102;103;201;202;203;301;302;402;404;405` |
| `epl-list-todolist` | `001;002;003;101;102;103;201;202;203;301;302;402;404;405` |
| `epl-case-insert-delreason` | `001;002` |
| `epl-case-insert-cloreason` | `404;405` |
| `epl-file-z0-proposal-download` | `101;102;103;201;202;203;301;302` |
| `epl-session-z0-current-application` | `001;002;003;101;102;103;201;202;203;301;302;402;404;405` |
| `epl-sele-z0-delete-reason` | `001;002` |
| `epl-sele-z0-close-reason` | `404;405` |

Error-code contract: business authorization failure returns `FORBIDDEN_ACTION`; platform/API-auth failure returns `ACCESS_DENIED` or the platform standard auth response and must not be treated as successful mutation. [ev→R9]

## NFR
- Security: backend authorization must reject direct API calls for roles without action permission; `TB_API_AUTH` seed was verified for the eight final `epl-*` API IDs against `OVSLXLON02` on 2026-06-20. Any future seed drift is a regression, not an open SRS owner-decision pending item.
- Audit: actions that mutate `TB_LON_SUMMARY_INFO` must insert `TB_APP_HISTORY` or explicitly document the exception.
- Transaction: delete, close, and redistribution are all-or-nothing; partial reason/history/summary writes are regressions.
- Privacy: logs must not include full reason text, full borrower name, or reusable local download paths.
- Performance: list and CAD query must require bounded conditions and must not support unrestricted full-table query.

## Hard Boundaries
- Routing returns refactor `EPROISU`/`EPROCSU` page-family routes as the to-be contract; legacy IDs (e.g. `EPROIS_0910`) are trace labels only, never acceptance route IDs.
- Reason arrays are the API contract for delete/close; semicolon-joining stays inside persistence and must not surface as an API input shape.
- The session bridge (`epl-session-z0-current-application`) is migration-only and retires when `EPROISU`/`EPROCSU` routes no longer read server-session application context.
- `PROCESS_AGENT_CODE`/`PROCESS_AGENT_NAME` are legacy evidence only; do not add them to to-be DB/schema.

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## Source Evidence
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

## Trade-offs
- Implementation/test readiness closed on 2026-06-20: endpoint implementation and `TB_API_AUTH` seed rows were applied and rechecked against `OVSLXLON02`; no owner-decision pending items remain open inside this SRS bundle.
- Modeling redistribution as POST (not GET) trades REST-read purity for correct side-effect semantics, because init mutates `TB_LON_SUMMARY_INFO` and inserts `TB_APP_HISTORY`.
- Keeping the PRD/legacy `reasonList[]` request shape (with semicolon-join inside persistence) over the refactor artifact's `reasonCode`/`caseProgress` shape keeps the API aligned to business intent and avoids leaking persistence detail to clients.
- Tokenized download (one-time `downloadToken`) over the legacy `encryptTempFileFullPath` return trades implementation convenience for not exposing a reusable local filesystem path.

## DB Reconcile / Delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_LON_SUMMARY_INFO` remains the active/exact case master. Relevant columns include `APPLICATION_NO`, `LON_TYPE_CODE`, `APPLICATION_DATE`, `RECEIVED_DATE`, `DISTRIBUTION_DATE`, `DECISION_DATE`, `CASE_PROGRESS`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, `CR_CODE`, `CURRENT_USER_ID`, `CA_CODE`, `RE_DISTRIBUTION`, and `IS_AUTODIS`. | carried | `schema.sql` includes the touched columns and uses this table for list, CAD query, redistribution, delete, and close verification. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`16`, `32`, `38`-`84`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:191`-`194` |
| DB-D2 `TB_APP_HISTORY` remains active/exact with PK `APPLICATION_NO`, `APP_PROCESS_CODE`, `PROCESS_DATE`; db-diff lists seven physical columns. | carried | Delete, close, and redistribution must insert history rows in the same transaction as summary updates. The seven-column DB contract is kept: normal/proxy delete and close write the actual acting employee to `PROCESS_EMP_CODE` / `PROCESS_EMP_NAME`; legacy `PROCESS_AGENT_CODE` / `PROCESS_AGENT_NAME` are source evidence only and are not added to to-be DB/schema.sql. | `docs/db-diff/02_tables/TB_APP_HISTORY.md:11`-`16`, `32`-`44`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:163`, `195`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:421`-`422`, `502`-`503`; DB verification `docs/build-tasks/done/pilot-srs-pending-verification.md:69` |
| DB-D3 `TB_DEL_REASON` and `TB_CLO_REASON` remain active/exact and store semicolon-joined reason codes plus `OTH_REASON`. | carried | DB reason code baseline: delete `D01`-`D12` + `D99`, close `C01`-`C11` + `C99`. OpenAPI accepts `reasonList[]` plus `otherReason`; `D99/C99` require `otherReason`; semicolon joining remains inside persistence logic. | `docs/db-diff/02_tables/TB_DEL_REASON.md:11`-`16`, `38`-`41`; `docs/db-diff/02_tables/TB_CLO_REASON.md:11`-`16`, `38`-`41`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:235`-`236`; legacy request `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:334`, `379`; legacy join `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:390`-`396`, `462`-`469`; DB verification `docs/build-tasks/done/pilot-srs-pending-verification.md:66` |
| DB-D4 `TB_RELATED_PARTY_INFO`, `TB_LOAN_CONDITION_DETAIL`, and `TB_EMP_PROXY` remain active/exact lookup/enrichment tables. | carried | `showRelated` uses the active columns `IS_CUB_RELATED`, `IS_CUBC_RELATED`, and `IS_TCP`; PRD/legacy `IS_Y` is treated as a legacy DAO alias, not a physical column. `schema.sql` comments/DDL carry the subset needed for QA verification, not ownership of full table design. | `docs/db-diff/02_tables/TB_RELATED_PARTY_INFO.md:11`-`16`, `32`-`43`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:178`-`179`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:11`-`16`, `32`-`47`; `docs/db-diff/02_tables/TB_EMP_PROXY.md:11`-`16`, `32`-`43` |
| DB-D5 `TB_ROLE_DEFINE`, `TB_PROCESS_CODE`, and `TB_API_AUTH` are active/exact but rewritten seed/config tables. | changed | Role display names/groups are carried in the Role Display Baseline. Active `TB_PROCESS_CODE` rows are the EPROZ00100 to-be status baseline. The eight SRS `epl-*` API IDs are the final `TB_API_AUTH` seed baseline with single-row `API_ID`, semicolon `ROLE`, `REF_FUNCTION_ID=EPROZ00100`, and the least-privilege role allow-list in R9; role `403` is excluded from every user-facing EPROZ00100 API. | `docs/db-diff/02_tables/TB_ROLE_DEFINE.md:11`-`16`, `38`-`40`; `docs/db-diff/02_tables/TB_PROCESS_CODE.md:11`-`16`, `38`-`42`; `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`, `38`-`40`; `docs/build-tasks/c0-authz-sql-findings.md:21`, `30`; Bible `docs/specs/bible/bible-eproposal.md:390`, `796`-`797`; DB verification `docs/build-tasks/done/pilot-srs-pending-verification.md:27`-`37`, `60`-`69` |
| REF-D1 refactor latest map has 6 artifacts: 3 BE and 3 FE. BE latest includes `epl-list-todolist`, `epl-case-insert-delreason`, and `epl-case-insert-cloreason`. | changed | The SRS uses the three latest BE artifact IDs as implemented contract anchors and maps PRD-only actions to migration endpoints and implementation gaps. | `docs/refactor-spec/02_modules/EPROZ00100.md:3`-`21` |
| REF-D2 PRD lists legacy-style `/api/eproz0-0100/initQuery` GET and `/queryCAD` POST, while refactor latest has one POST `epl-list-todolist` artifact with search fields. | changed | Use POST `epl-list-todolist` with `queryMode=GENERAL/CAD` in OpenAPI; keep legacy action names as trace labels only. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:217`-`219`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:135`-`137`, `149`-`156` |
| REF-D3 delete/close refactor artifacts have placeholder API paths (`待補/...`), field-validation code `E102`, and `reasonCode` / `caseProgress` fields, while PRD/legacy require `reasonList[]` and do not require close `caseProgress` from the client. | changed | OpenAPI carries PRD business codes and the PRD/legacy request shape; `E102` remains platform validation evidence for field-level failures until RD maps final error envelope. | `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-delreason.md:114`, `187`-`188`; `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-cloreason.md:114`, `185`-`187`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:235`-`236`, `256`-`258`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:334`, `379` |
| REF-D4 FE latest says CAD was updated to TLOD in v1.5, while PRD still uses CAD language for role `404/405`. | changed | SRS names CAD/TLOD together and carries the DB/Bible role display baseline; the role allow-list is in R9. | `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00100/eproz00100-to-do-list.md:96`, `213`-`214`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:34`, `93`; Bible `docs/specs/bible/bible-eproposal.md:408`-`409` |
| REF-D5 refactor latest does not expose separate BE artifacts for prompt redistribution, set/clear session, proposal download, or reason-list query. | changed | Prompt redistribution stays `epl-init-z0-todolist`, tokenized proposal download is `epl-file-z0-proposal-download`, and the migration-only session bridge is `epl-session-z0-current-application`; RD closeout implemented these migration endpoints and DBA closeout verified their auth rows on 2026-06-20. | `docs/refactor-spec/02_modules/EPROZ00100.md:15`-`21`; PRD endpoints `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:217`-`226` |

## @PENDING
> 本 bundle 於 2026-06-20 RD/DBA closeout 後定版，無 open 待決；下列為已關決策的 provenance（owner decision 2026-06-19 + closeout 2026-06-20）。

| Id | Decision | Owner | Blocking? | Status |
|---|---|---|---|---|
| P-Z00100-redistribution | Keep legacy CA/CR redistribution as automatic init side effect; model init as POST with auth/transaction/history/rollback. | Owner 2026-06-19 | No | Closed |
| P-Z00100-process-status | Active `TB_PROCESS_CODE` rows are the to-be status baseline (`D1=Delete`, `C1=Closed`, `R0305/R0313/R0397=CA Redistributing`, CAD/TLOD `21`-`25`). | Owner 2026-06-19 | No | Closed |
| P-Z00100-cad-docno | Adopt current backend/view mapping for `docNo`/`docNo1` (identity doc + `REGISTER_NO`, `V_MAIN_BORROWER_INFO.DOC_NO_REGISTER_NO`). | Owner 2026-06-19 | No | Closed |
| P-Z00100-del-reason | Delete reason baseline `D01`-`D12` + `D99`; `D99` requires `otherReason` (max 100). | Owner 2026-06-19 | No | Closed |
| P-Z00100-clo-reason | Close reason baseline `C01`-`C11` + `C99`; `C99` requires `otherReason` (max 100). | Owner 2026-06-19 | No | Closed |
| P-Z00100-download-token | Tokenized one-time `downloadToken` contract; default TTL 10 min, configurable; backend validates `type` against case attributes. | Owner 2026-06-19 | No | Closed |
| P-Z00100-session-bridge | `epl-session-z0-current-application` approved as migration-only bridge; retires when routes no longer read server session. | Owner 2026-06-19 | No | Closed |
| P-Z00100-api-auth-seed | Eight `epl-*` API IDs are the final `TB_API_AUTH` seed baseline with least-privilege role allow-lists; role `403` excluded; verified against `OVSLXLON02` on 2026-06-20. | Owner 2026-06-19 + closeout 2026-06-20 | No | Closed |
| P-Z00100-history-columns | Seven-column `TB_APP_HISTORY` DB contract kept; `PROCESS_AGENT_*` not added to to-be DB. | Owner 2026-06-19 | No | Closed |
| P-Z00100-session-route-target | PRD marks session-to-route migration as the long-term target (PRD TBD); session bridge is the interim. | Owner 2026-06-19 | No | Closed |

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy）、REF-Dn delta、provenance（`file:line`/`@SHA`）、決策 ID；鍵到 Rn，與上半 `[ev→Rn]` 1:1。

| Rn | as-is（現況/legacy） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | Legacy `doPrompt` calls `updateLonSummaryInfo(user, "CA")` / `"CR"` and redistribution writes `CASE_PROGRESS`, `CURRENT_USER_ID`, `CR_CODE`, `RE_DISTRIBUTION`, `RECEIVED_DATE`, `DISTRIBUTION_DATE`, and history rows. | Owner decision 2026-06-19 keeps redistribution as automatic init side effect; model as POST with endpoint auth, one transaction, history insert, rollback on failure. P-Z00100-redistribution. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:113`-`117`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:67`-`86`; legacy redistribution `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:242`-`284`, `294`-`337`. |
| R2 | Legacy defines excluded statuses, queries by `CURRENT_USER_ID`, and enriches related party / loan condition data. | Owner decision 2026-06-19 approves active `TB_PROCESS_CODE` rows as to-be status baseline. P-Z00100-process-status; refactor carries request fields/response mappings. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:123`-`128`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:58`-`59`, `72`-`74`, `99`-`109`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-list-todolist.md:88`-`107`, `164`-`217`. |
| R3 | Legacy obtains active proxy employees from `TB_EMP_PROXY` and adds to `IN_CURRENT_USER_ID`, maps request `NO` for document/register number, applies borrower name and date filters, uses corporate `REGISTER_NO` for `docNo1`, normalizes borrower name. | Owner decision 2026-06-19 adopts current backend/view mapping. P-Z00100-cad-docno. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:134`-`138`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:135`-`150`, `158`-`160`, `164`-`181`, `207`-`208`, `213`-`215`. |
| R4 | Legacy CAD routing branches set first-page decisions per role/status. | Refactor `EPROISU`/`EPROCSU` page-family routes are the to-be contract; legacy IDs are trace labels only. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:140`-`153`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:566`-`577`; Bible `docs/specs/bible/bible-eproposal.md:793`-`794`. |
| R5 | Legacy execute validates `APPLICATION_NO`, builds `TB_DEL_REASON`, sets `CASE_PROGRESS = D1`, writes history, commits/rolls back. Refactor artifact uses `reasonCode`/`E102`/placeholder path. | Owner decision 2026-06-19 approves delete reason baseline `D01`-`D12` + `D99`; keep PRD/legacy `reasonList[]`; semicolon-join is persistence detail. P-Z00100-del-reason; REF-D3. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:159`-`163`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:376`-`431`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-delreason.md:122`-`124`, `150`-`177`, `187`-`188`. |
| R6 | Legacy close validates `APPLICATION_NO`, receives `reasonList`, reads `TB_LON_SUMMARY_INFO`, sets `CASE_PROGRESS=C1`, clears `CURRENT_USER_ID`, converts `IS_AUTODIS`, writes close reason/history, commits/rolls back. Refactor artifact exposes `caseProgress`/`reasonCode`. | Owner decision 2026-06-19 approves close reason baseline `C01`-`C11` + `C99`; keep PRD/legacy `reasonList[]`; `caseProgress` derived server-side. P-Z00100-clo-reason; REF-D3. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:169`-`173`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:379`-`380`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java:448`-`512`; refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00100/epl-case-insert-cloreason.md:122`-`125`, `151`-`175`, `185`-`187`. |
| R7 | Legacy `downloadFile` is an audited print action dispatching CS/CU/IS/IU; legacy `encryptTempFileFullPath` return is source evidence only. | Owner decision 2026-06-19 approves tokenized one-time download contract; backend validates `type` against case attributes; default TTL 10 min configurable. P-Z00100-download-token. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:177`-`183`, `249`, `275`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:224`-`241`; Bible `docs/specs/bible/bible-eproposal.md:809`-`810`. |
| R8 | Legacy set/clear session actions manage `APPLICATION_NO` / action context server-side. PRD marks session-to-route migration as TBD. | Owner decision 2026-06-19 approves migration-only bridge; on auth reject leave session unchanged; bridge retires when routes no longer read server session. P-Z00100-session-bridge; P-Z00100-session-route-target. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:113`, `225`-`226`, `287`, TBD at `:41`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:408`-`431`. |
| R9 | DB verification originally found missing `TB_API_AUTH` rows for init, proposal download, session bridge, and reason-list endpoints; runtime evidence records `ROLE LIKE %:role%` and exact `API_ID` matching with PK `TB_API_AUTH_PK(API_ID)`. | Owner decision 2026-06-19 approves the eight `epl-*` API IDs as final seed baseline with single-row `API_ID`, semicolon `ROLE` allow-list, `REF_FUNCTION_ID=EPROZ00100`, least-privilege allow-lists, role `403` excluded; RD/DBA closeout applied and SELECT-only rechecked against `OVSLXLON02` on 2026-06-20. P-Z00100-api-auth-seed. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md:270`-`275`; Bible `docs/specs/bible/bible-eproposal.md:332`, `439`, `448`; db-diff `docs/db-diff/02_tables/TB_API_AUTH.md:11`-`16`, `38`-`40`; runtime `docs/build-tasks/c0-authz-sql-findings.md:21`, `30`; DB verification `docs/build-tasks/done/pilot-srs-pending-verification.md:68`. |
