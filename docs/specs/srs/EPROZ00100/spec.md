# SRS - EPROZ00100 TO DO LIST / Work-list Dashboard

| 欄位 | 內容 |
|---|---|
| Status | In Review - PRD TBD-001~008 未裁；blocking: TBD-002 prompt redistribution/method, TBD-004 CAD docNo mapping, TBD-006 download file security. |
| Owner | SA / RD / QA |
| Slug | `EPROZ00100` |
| 版本 | v0.3-draft, 2026-06-18 |
| 上游 PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md` |
| as-is 來源 | `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java`, `docs/refactor/`, `docs/db-schema/` |

## Scope / Non-Goals
- Scope: dashboard prompt, role flags, CA/CR redistribution decision point, non-CAD and CAD work-list query, case routing, delete, close, reason options, proposal download, set/clear current application context.
- Non-goals: downstream application pages, report body generation, login/JWT issuance, code-table maintenance UI, schema migration execution.
- This SRS records legacy behavior and local refactor/schema deltas; db-schema/refactor deltas use the latest local new artifacts as the to-be baseline, while PRD/domain/security TBD remain open.

## Assumptions / Dependencies / Constraints
- Authentication context provides `roleId`, employee id, employee name, branch/dept.
- New APIs use RPC-style `epl-*` paths, not PRD idealized `/api/eproz0-0100/*`.
- Local DB schema docs are snapshots under `docs/db-schema/02_tables/`; refactor specs are joined by `module_code=EPROZ00100` and `program_code=epl-*`.
- Error response body uses `{ code, message, data }`. HTTP status separates validation/auth/system classes; bare legacy codes are carried in `Rn` and `openapi.yaml`.

## Endpoints
| action | endpoint | method | source / decision |
|---|---|---|---|
| prompt | `epl-comm-todolist-prompt` | candidate POST | legacy prompt has side effects: clears context and may run CA/CR redistribution at `EPROZ0_0100.java:67-91`; endpoint/method remains `@PENDING(TBD-002)` and is not approved until owner decides keep/remove redistribution. |
| initQuery/queryCAD | `epl-list-todolist` | POST | refactor latest says POST at `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:95`; CAD is role branch. |
| getReason/getCloReason | `epl-comm-field-options` | POST | screen spec uses common field option API for `DEL_REASON`/`CLO_REASON`; legacy actions call option maps at `EPROZ0_0100.java:258-298`. |
| execute delete | `epl-case-insert-delreason` | POST | refactor latest endpoint and body at delreason spec; legacy action at `EPROZ0_0100.java:326-335`. |
| executeclose | `epl-case-insert-cloreason` | POST | refactor latest endpoint and body at cloreason spec; legacy action at `EPROZ0_0100.java:371-380`. |
| downloadFile | `epl-file-todolist-download` | POST | legacy dispatch by `TYPE` at `EPROZ0_0100.java:224-240`; file-return shape is `@PENDING(TBD-006)`. |
| setSession | `epl-comm-todolist-setsession` | POST | legacy server session set at `EPROZ0_0100.java:408-414`; migration strategy is `@PENDING(TBD-008)`. |
| clearSession | `epl-comm-todolist-clearsession` | POST | legacy server session clear at `EPROZ0_0100.java:428-434`; migration strategy is `@PENDING(TBD-008)`. |

## Business Rules

### R1 - prompt initializes dashboard and role flags **強制點: FE+BE** `covers-prd: REQ-001`
When a user opens TO DO LIST, the system shall clear the previous current-application context and return role flags `isAO`, `role`, `isCA`, `isCRCOSCO`, `isCOSCO`, `isCADMERCER`. Evidence: legacy clears via `EPRO_Z0Z005.clearInfo(req)` and derives role flags at `EPROZ0_0100.java:74-91`. To-be role names/permission semantics remain `@PENDING(TBD-001)`.

### R2 - CA/CR redistribution on prompt **強制點: BE** `covers-prd: REQ-001` `@PENDING(TBD-002)`
When role is CA `101` or CR `102/103`, legacy prompt calls `updateLonSummaryInfo(user, "CA"/"CR")` (`EPROZ0_0100.java:79-87`). Legacy redistribution wraps summary/history writes in transactions (`EPROZ0_0100_mod.java:249-291`, `EPROZ0_0100_mod.java:305-342`). To-be shall either keep this as a POST side effect or explicitly remove it; this is a C-class decision and is not self-decided. If kept, failure returns `REDISTRIBUTION_FAILED` with HTTP 500 and rollback.

### R3 - non-CAD work-list query **強制點: FE+BE** `covers-prd: REQ-002`
For non-CAD roles, `epl-list-todolist` shall query current-user cases and exclude `CASE_PROGRESS` in `{03,D1,R0305,R0313,R0397}`. Evidence: legacy `initQuery` sets `CURRENT_USER_ID` and `NOT_IN_CASE_PROGRESS` at `EPROZ0_0100_mod.java:70-74`. Response shall include paged list and `totalCount`; refactor request fields are `page`, `size`, `applicationNo`, dates, `mainBorrowerName`, `docNo`, `langType` at `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:135-143`.

### R4 - language must not filter data **強制點: BE** `covers-prd: REQ-002`
`langType` is accepted for labels and display, but shall not change result counts. This carries the existing owner decision in `docs/decisions.md:39`; the old regression came from language in data WHERE and is treated as regression fix, not a new behavior.

### R5 - list row enrichment **強制點: FE+BE** `covers-prd: REQ-002`
Each row shall enrich borrower display, application date, related-party marker, loan type label, and USD/KHR amount. Amount sums shall preserve `TB_LOAN_CONDITION_DETAIL.LOAN_AMOUNT NUMBER(17,2)` scale in the API value and shall not be truncated; UI-only KHR zero-decimal display, if required, must not alter the API sum. Evidence: legacy switches corp borrower name, blanks `01/01/1900`, queries `TB_RELATED_PARTY_INFO`, and sums `TB_LOAN_CONDITION_DETAIL` at `EPROZ0_0100_mod.java:81-112`. Refactor latest added `SOFR` to SQL2 at `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:47`.

### R6 - CAD query scope and filters **強制點: FE+BE** `covers-prd: REQ-003`
For CAD roles `404/405`, query scope shall include the current CAD employee plus active proxy employees, restrict `LON_TYPE_CODE` to `{01,02,03,04}`, and support `applicationNo`, `docNo`, `mainBorrowerName`, and decision date range filters. CAD response rows shall carry decision date display, approval level display, `docNo1`, borrower name, sales channel, and target `page`. Evidence: legacy builds `IN_CURRENT_USER_ID` from `TB_EMP_PROXY` at `EPROZ0_0100_mod.java:135-150`, maps `NO`/`NAME` filters at `EPROZ0_0100_mod.java:157-167`, and applies decision dates at `EPROZ0_0100_mod.java:170-177`. `DOC_NO` vs legacy `NO` mapping is `@PENDING(TBD-004)`.

### R7 - CAD query validation **強制點: BE** `covers-prd: REQ-003`
CAD query shall reject empty all-condition searches and partial date ranges with `INVALID_CAD_QUERY_CONDITION` over HTTP 400. FE may show UI validation, but BE is authoritative. Six-month backend enforcement is `@PENDING(TBD-005)`.

### R8 - case routing **強制點: FE+BE** `covers-prd: REQ-004`
Routing shall map CA by attribute (`IS/IU/CS/CU`) to `0171`, CAD Maker `21/22` to `EPROIS_0910`, CAD Maker `24/25` to `EPROIS_0920`, CAD Checker `23` to `EPROIS_0910`, CAD Checker `25` to `EPROIS_0920`, otherwise `MANUALAPP`; other roles use first `EPRO_Z0Z006.getCheckPage`. Evidence: `EPROZ0_0100_mod.java:552-584`. CASE_PROGRESS code semantics remain `@PENDING(TBD-003)`.

### R9 - delete case **強制點: FE+BE** `covers-prd: REQ-005`
Delete shall require `applicationNo` and at least one reason, reject role `003` with `FORBIDDEN_ACTION` over HTTP 403, require `otherReason` when `D99` is selected, insert `TB_DEL_REASON`, insert `TB_APP_HISTORY`, and set `TB_LON_SUMMARY_INFO.CASE_PROGRESS='D1'` in one transaction. Evidence: legacy validation and writes at `EPROZ0_0100_mod.java:376-435`; refactor request fields and error codes include `applicationNo`, `reasonCode`, `otherReason`, `E102`, `E998`, `E999` in the delreason spec.

### R10 - close case **強制點: FE+BE** `covers-prd: REQ-006`
Close shall require `applicationNo` and at least one close reason, require `otherReason` when `C99` is selected, insert `TB_CLO_REASON`, insert `TB_APP_HISTORY`, set `CASE_PROGRESS='C1'`, clear `CURRENT_USER_ID`, and convert `IS_AUTODIS M->MC` or `Y->YC` in one transaction. Evidence: `EPROZ0_0100_mod.java:448-517`.

### R11 - proposal download **強制點: FE+BE** `covers-prd: REQ-007` `@PENDING(TBD-006)`
Download shall dispatch `TYPE` CS/CU/IS/IU to the corresponding proposal printer and not mutate business DB. Evidence: `EPROZ0_0100.java:224-240`. Legacy returns `encryptTempFileFullPath`; to-be file token/path/security behavior is `@PENDING(TBD-006)`. Failure returns `DOWNLOAD_FAILED` over HTTP 500; missing `applicationNo` or invalid `type` returns HTTP 400.

### R12 - current application context **強制點: FE+BE** `covers-prd: REQ-002` `@PENDING(TBD-008)`
When user selects an application, the system shall set current application context; when clearing, it shall remove the context. Legacy uses server session helpers at `EPROZ0_0100.java:408-434`. Route-param migration and session retention window are `@PENDING(TBD-008)`.

### R13 - reason options **強制點: FE+BE** `covers-prd: REQ-005`
Reason options shall be loaded from `epl-comm-field-options`/common option source, not hard-coded. Legacy maps `DEL_REASON` and `CLO_REASON` at `EPROZ0_0100_mod.java:355-365`. Exact code values and D99/C99 value semantics are `@PENDING(TBD-007)`.

### R14 - NFR: auth, error, audit, transaction, performance **強制點: BE** `covers-prd: REQ-005`
BE shall enforce authorization for all EPROZ00100 endpoints via `TB_API_AUTH` and role dictionary `TB_ROLE_DEFINE`, including `prompt` if redistribution is kept, `setSession`, and `clearSession`; FE visibility is not sufficient. Mutating actions shall be transactional and audit-able. Query endpoints shall page results and avoid unbounded CAD searches. Error mapping: `E102`, `MISSING_APPLICATION_NO`, `MISSING_REASON`, `MISSING_OTHER_REASON`, `INVALID_CAD_QUERY_CONDITION` use HTTP 400; `E998`/`FORBIDDEN_ACTION` use HTTP 403; `E999`, `MSG_QUERY_FAIL`, `MSG_OVER_COUNT_LIMIT`, `REDISTRIBUTION_FAILED`, `DOWNLOAD_FAILED`, `COMMON_MSG_SET_SESSION_FAIL` use 500 according to operation class, without mixing validation and system failures.

## 新舊 DB / 更動 delta
| delta id | source | observation | 三判 |
|---|---|---|---|
| DB-D1 | `docs/db-schema/02_tables/TB_DEL_REASON.md:39`, `docs/db-schema/02_tables/TB_DEL_REASON.md:40`, `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-case-insert-delreason_新增刪除原因_後端系統規格書_v1.1_20240923--566ed65482.md:118-120` | Snapshot `REASON_CODE` and `OTH_REASON` are `VARCHAR2(100)`. Use `reasonCode maxLength=100`; old draft `200` would exceed schema. | (c) DB 對齊 |
| DB-D2 | `docs/db-schema/02_tables/TB_CLO_REASON.md:39`, `docs/db-schema/02_tables/TB_CLO_REASON.md:40`, `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-case-insert-cloreason_新增結案原因_後端系統規格書_v1.1_20240923--071f8ed746.md:118-121` | Snapshot `REASON_CODE` and `OTH_REASON` are `VARCHAR2(100)`. Use `reasonCode maxLength=100`; no widening without migration. | (c) DB 對齊 |
| DB-D3 | `docs/db-schema/02_tables/TB_APP_HISTORY.md:38`, `docs/db-schema/02_tables/TB_APP_HISTORY.md:40`, `docs/db-schema/02_tables/TB_APP_HISTORY.md:41`, `docs/db-schema/02_tables/TB_APP_HISTORY.md:42`, `docs/db-schema/02_tables/TB_APP_HISTORY.md:43`, `docs/db-schema/02_tables/TB_APP_HISTORY.md:44`, legacy `EPROZ0_0100_mod.java:414-423`, `EPROZ0_0100_mod.java:495-504` | Snapshot has `PROCESS_EMP_CODE/NAME/BRANCH_*` and PK `(APPLICATION_NO, APP_PROCESS_CODE, PROCESS_DATE)`; legacy writes `PROCESS_AGENT_CODE/NAME` for proxy, but the latest new DB snapshot lacks those columns. Per owner direction, new schema wins: do not add legacy proxy-agent columns; audit identity shall use the snapshot columns. | (c) new DB schema wins |
| DB-D4 | `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:46`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:47`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:49`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:60`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:62`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:73`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:84`, legacy `EPROZ0_0100_mod.java:273-284`, `EPROZ0_0100_mod.java:474-483` | Snapshot supports touched columns `CASE_PROGRESS`, `CURRENT_USER_ID`, `CR_CODE`, `RE_DISTRIBUTION`, `RECEIVED_DATE`, `DISTRIBUTION_DATE`, `IS_AUTODIS`. Delete/close/redistribution can use existing columns. | (b) keep existing schema |
| DB-D5 | `docs/db-schema/02_tables/TB_RELATED_PARTY_INFO.md:41`, `docs/db-schema/02_tables/TB_RELATED_PARTY_INFO.md:42`, `docs/db-schema/02_tables/TB_RELATED_PARTY_INFO.md:44`, legacy `EPROZ0_0100_mod.java:98-102` | PRD says `IS_Y`; snapshot has `IS_CUB_RELATED`, `IS_CUBC_RELATED`, `IS_TCP`, not `IS_Y`. SRS maps `showRelated=Y` to any of those flags = `Y`; do not invent `IS_Y` column. | (c) DB mapping correction |
| DB-D6 | `docs/db-schema/02_tables/TB_LOAN_CONDITION_DETAIL.md:28-67`, `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:47`, `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:264-271` | Refactor v1.3 SQL2 adds `SOFR`, while the new DB schema snapshot for `TB_LOAN_CONDITION_DETAIL` has no physical `SOFR` column. Use latest artifacts by layer: list/query behavior carries refactor `SOFR`; `schema.sql` stays aligned to the db-schema snapshot until that snapshot exposes a physical column. | (c) new artifacts win by layer |
| DB-D7 | `docs/db-schema/02_tables/TB_EMP_PROXY.md:38`, `docs/db-schema/02_tables/TB_EMP_PROXY.md:39`, `docs/db-schema/02_tables/TB_EMP_PROXY.md:40`, `docs/db-schema/02_tables/TB_EMP_PROXY.md:41`, legacy `EPROZ0_0100_mod.java:135-150` | Active proxy scope is supported by `EMP_ID`, `PROXY_ID`, `STR_TIME`, `END_TIME`; CAD query must preserve it. | (b) keep legacy behavior |
| REF-D1 | `docs/refactor/02_specs/fe-spec/shared/EPROZ00100/epl-list-todolist_待辦清單_後端系統規格書_v1.3_20260427--cb679bf7bc.md:95` | Refactor latest uses POST `epl-list-todolist`, not PRD `/api/...` GET split. | (b) keep current RPC contract |
| REF-D2 | same file `:141-143` vs PRD §3.2 | Refactor has `mainBorrowerName maxLength=100`, `docNo maxLength=20`, while PRD says both 30. To-be follows latest refactor for API contract and records PRD delta. | (b) keep refactor latest |
| REF-D3 | `docs/decisions.md:39`, `docs/build-tasks/done/00100-todo-empty-recon-findings.md:45-46` | Language WHERE caused empty TODO regression; to-be removes language as data filter. | (a) regression fix |

## @PENDING
| id | owner | impact | blocking | status |
|---|---|---|---|---|
| TBD-001 | PM/SA | Role code names and authorization matrix for 001/002/003/101/102/103/201/202/203/301/302/404/405. | yes | open |
| TBD-002 | SA/RD | Keep/remove prompt CA/CR redistribution side effect and final method. | yes | open |
| TBD-003 | PM/SA | Formal meaning of `D1/C1/R0305/R0313/R0397` and CAD `21~25`. | partial | open |
| TBD-004 | RD | CAD `DOC_NO` request vs legacy `NO` mapping. | yes | open |
| TBD-005 | SA/RD | Whether BE enforces six-month decision-date window. | no | open |
| TBD-006 | RD/security | Download path vs token, expiry, authorization, storage. | yes | open |
| TBD-007 | PM/SA | `DEL_REASON`/`CLO_REASON` values and D99/C99 semantics. | partial | open |
| TBD-008 | RD | Server session retention vs route-param migration. | no | open |

## Traceability Matrix
| PRD REQ | SRS Rn | QA |
|---|---|---|
| REQ-001 | R1, R2 | QA-001, QA-002 |
| REQ-002 | R3, R4, R5, R12 | QA-003, QA-004, QA-005, QA-006, QA-013 |
| REQ-003 | R6, R7 | QA-007, QA-008, QA-009, QA-021 |
| REQ-004 | R8 | QA-010, QA-024, QA-027 |
| REQ-005 | R9, R13, R14 | QA-011, QA-012, QA-014, QA-016, QA-018, QA-019, QA-020, QA-025 |
| REQ-006 | R10, R14 | QA-015, QA-022, QA-026 |
| REQ-007 | R11, R14 | QA-017, QA-023 |

## RD Notes
- Implement with exact DB column names from `schema.sql`; do not use `PROCESSOR_CODE`/`CREATE_DATE` aliases for `TB_APP_HISTORY`.
- For db-schema/refactor deltas, use the latest local new artifacts as the to-be baseline; do not re-open legacy-only column drift as TBD.
- Carry `SOFR` in list/query behavior where the latest refactor SQL provides it; keep `schema.sql` aligned to the db-schema snapshot until that snapshot includes a physical `SOFR` column.
- All mutating endpoints must have BE-side authorization and transaction rollback tests.
