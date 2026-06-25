# SRS - EPROZ00800 Revised Item

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| funcId | EPROZ00800 |
| Status | 規格定版: Approved (2026-06-23) / 實作完成: not asserted (DoD 閘門牆另裁) |
| Owner | PM/SA/RD/QA review |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md` |
| Bible | `docs/specs/bible/bible-eproposal.md` |
| Bundle | `docs/specs/srs/EPROZ00800/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec + legacy/current source evidence |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `README.md`（人類 digest，見 `digest-template.md`）（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | 規格定版軸 `Approved` (2026-06-23) was owner-stamped after mechanical gate PASS + two-round N-axis spec-reviewer (0🔴/0🟡); 實作完成軸 remains adjudicated by the DoD 閘門牆, not self-declared by this bundle. **2026-06-25 兩半轉換**：改 canonical Contract/Appendix 結構、Traceability Matrix 段已移除（追溯靠 covers-prd）、各 Rn 加 `[ev→Rn]`、段名正規化；僅重排不改語意。 |

## Scope
- In scope: Revised Item page initialization, query, item display, validation, save, side-effect restore/delete behavior, checkpoint/page-menu reprocessing, error responses, authorization, and audit expectations for EPROZ00800.
- In scope: New DB/refactor reconciliation for the Revised Item contract, with open owner decisions retained as `@PENDING`.
- Terminology: `shared` / `common` means EPROZ00800 is a reusable common module in the case-edition page framework; it does not mean every case must show or complete the tab.
- Out of scope（Non-Goals）: code table maintenance for `REVISED_ITEM`, full migration of downstream pages, report rebuild, or approval of open C-class decisions.

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `/api/eproposal/eproz00800/prompt` | GET | Initialize page attributes and visibility for EPROZ00800 | R1, R16 |
| `epl-case-query-reviseditem` | GET | Query loan type, customer/security attributes, current Revised Item values, and display options | R2, R5, R6 |
| `epl-case-insert-reviseditem` | POST | Save Revised Item and execute side effects/checkpoints in one transaction | R8, R9, R10, R11, R12, R13, R14, R15, R16, R17 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 Page initialization and visibility - 強制點: both
covers-prd: REQ-001

When a user enters EPROZ00800 through the prompt/routing entry, the system must obtain the case application number, `lonTypeCode`, editability, and CU/secured attributes before rendering the Revised Item form. The Bible case-type axis maps to backend-owned `TB_LON_SUMMARY_INFO.LON_TYPE_CODE`: `01=New`, `02=Additional`, `03=Renew` / 展期, `04=Change Condition` / 展變, and `05=Restructure` when present in `TB_LON_TYPE`; it is distinct from customer/page-family predicates such as `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, `caseCategory`, and `ISU` / `CSU`. EPROZ00800 is supported only when `LON_TYPE_CODE` is `03` or `04`. For any other `LON_TYPE_CODE`, tab-control/prompt must not expose EPROZ00800, and direct query/save calls must be rejected before returning Revised Item data or mutating DB, with HTTP 403 `ACCESS_DENIED` or the platform canonical forbidden-page envelope. Prompt initialization failure returns `MSG_INITIAL_FAIL`. User-facing wording must not imply all cases must complete Revised Item; actual visibility remains conditional through backend-owned `LON_TYPE_CODE in ('03','04')` and `epl-auth-tab-control` `pageMap`. The case-specific differences for `03` vs `04` remain R5 and R13.3. [ev→R1]

### R2 Query Revised Item state - 強制點: both
covers-prd: REQ-002

`epl-case-query-reviseditem` must accept `applicationNo` as a query parameter, reject blank input with HTTP 400 and top-level `code=COMMON_MSG_ERROR_LON`, read `TB_LON_SUMMARY_INFO` for `LON_TYPE_CODE`, `LON_ATTRIBUTE`, and `SECURE_ATTRIBUTE`, read `TB_REVISED_ITEM` for `ITEM1` through `ITEM14`, `REASON_MEMO`, and `UPD_DATE`, and return blank item values when no Revised Item row exists. The response must include backend-computed `isCorporateUnsecured`, true only when `LON_ATTRIBUTE='C'` and `SECURE_ATTRIBUTE='U'`, so the FE does not infer CU from `SECURE_ATTRIBUTE` alone. Field-validation detail may appear only under error `data`. Query failures return `MSG_QUERY_FAIL`; no matching case returns `MSG_DATA_NOT_FOUND`; over-limit query failures return `MSG_OVER_COUNT_LIMIT`. [ev→R2]

### R3 Revised Item display option names - 強制點: both
covers-prd: REQ-002, REQ-003

The UI must display the 14 Revised Item options by their approved `REVISED_ITEM` code-table names, verified against code-table/reference data. Code-table maintenance remains out of scope.

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

[ev→R3]

### R4 Client and backend validation - 強制點: both
covers-prd: REQ-003, REQ-004

At least one item must be selected before save. `item1` through `item14` may only be `Y` or `N` on execute; query response may carry blank values for a never-saved row. `reasonMemo` is required, trimmed, and capped at 3000 characters for execute. The physical DB column is wider (`TB_REVISED_ITEM.REASON_MEMO VARCHAR2(4000)`), but the input contract must not silently expand beyond PRD/current DTO validation. Blank or non-`Y/N` item flags in execute requests are rejected with HTTP 400 and top-level `code=COMMON_MSG_ERROR_LON`; field-validation detail may appear only under error `data`, and execute must never store blank item flags. This R4 validation matrix is shared by `03=Renew` and `04=Change Condition`; do not create separate mandatory-item, reason, or item-flag validation sets unless a later source-backed PRD/owner decision supersedes this SRS. [ev→R4]

### R5 ITEM1 loan type rule - 強制點: FE
covers-prd: REQ-003

When `LON_TYPE_CODE=03` (`Renew` / 展期), the UI must force `item1=Y` and make the control non-editable. When `LON_TYPE_CODE<>03`, including `04=Change Condition`, the UI must force `item1=N` and make the control non-editable. This is the `03` case-specific default/lock rule, not a separate validation matrix from R4. [ev→R5]

### R6 ITEM3 CU rule - 強制點: FE
covers-prd: REQ-003

When the case is corporate unsecured, the UI must force `item3=N` and make the control non-editable. The to-be predicate is backend-owned corporate unsecured, defined as `LON_ATTRIBUTE='C' AND SECURE_ATTRIBUTE='U'`; the query/prompt contract must expose `isCorporateUnsecured` or an equivalent backend-computed flag, and FE must not derive the lock from `SECURE_ATTRIBUTE` alone. [ev→R6]

### R7 Editability / field authorization - 強制點: both
covers-prd: REQ-003

When editability is false, all Revised Item controls and save/finish actions must be hidden or disabled in the UI, and backend mutation must still enforce authorization instead of relying on FE-only hiding. The granular FE model using `epl-auth-tab-control` `isEdit` plus `epl-auth-page-column` `isShowList` / `canEditList` is accepted as the UI model. Backend execute must reject direct mutation using backend-owned page/edit authorization before any DB write; API-level `TB_API_AUTH` alone is insufficient. Backend page/edit guard must cover `revised.item`, `reason.item`, and `button.butSave` / `button.butFinish`. [ev→R7]

### R8 Change warning before destructive save - 強制點: FE
covers-prd: REQ-004, REQ-005

If existing item state differs from the requested state, the UI must warn the user that removing or changing Revised Item selections can clear related modifications. The prompt is skipped only for the first save when no prior `TB_REVISED_ITEM` row exists and all prior item values are blank/N. User confirmation is represented by `isNotSame`, but that flag is only evidence that the warning was shown; it is not the authoritative side-effect trigger. [ev→R8]

### R9 Transaction and DB-side comparison - 強制點: BE
covers-prd: REQ-004, REQ-005, REQ-006

`epl-case-insert-reviseditem` must run in a single transaction. The backend must read the current `TB_REVISED_ITEM` state, normalize missing values to `N`, compare it with the normalized request item state, and use that DB-side comparison as the authoritative trigger for all side effects. Failure during Revised Item save, side-effect restore/delete, or checkpoint update must roll back every write and return `COMMON_MSG_SAVE_FAIL`. [ev→R9]

### R10 Persist Revised Item row - 強制點: BE
covers-prd: REQ-004

Execute must delete the current `TB_REVISED_ITEM` row for `applicationNo` and insert one row with `APPLICATION_NO`, `ITEM1` through `ITEM14`, `REASON_MEMO`, and `UPD_DATE`. The saved item flags are exactly `Y` or `N`; `reasonMemo` is trimmed and no longer than 3000 input characters. [ev→R10]

### R11 Execute request shape - 強制點: both
covers-prd: REQ-004

The target execute request is final: `applicationNo`, required boolean `isFinish`, required boolean `isNotSame`, and `itemMap.item1` through `item14` plus `itemMap.reasonMemo`. `checkPointMap` is not a client-owned request field in the to-be contract. The to-be backend must derive checkpoint/page-menu updates from backend-owned case type, current DB state, side-effect decisions, and `isFinish`; client-supplied checkpoint keys must not drive persistence. `isNotSame` remains advisory evidence that FE showed the warning and is not the authoritative side-effect trigger. [ev→R11]

### R12 RI-MAT guarantor and collateral side effects - 強制點: BE
covers-prd: REQ-005

- **R12.1** When `item2` changes from `Y` to `N`, delete the current case guarantor personal/corporate rows, restore guarantors from `REF_APPLICATION_NO` when reference data exists, and update borrower `IS_ANY_GUARANTOR` from reference state.
- **R12.2** When `item2` changes from `N` to `Y` and the reference application has no guarantor, set the current borrower guarantor flag to `Y`.
- **R12.3** When `item3` changes from `Y` to `N`, delete current collateral/valuation/site/title/provider/owner rows, restore from reference data when available, and update `IS_ANY_COLLATERAL_PROVIDER`.

These behaviors keep legacy side effects, fix known implementation bugs, and leave an audit summary. [ev→R12]

### R13 RI-MAT loan condition and fee side effects - 強制點: BE
covers-prd: REQ-005

- **R13.1** For the loan-condition item set `item1`, `item4`, `item5`, `item6`, `item7`, `item8`, `item9`, `item10`, and `item11`, delete current loan condition detail and revised item detail rows when either (a) existing DB state has at least one `Y` and requested state is all `N`, or (b) existing DB state is all `N` and requested state has at least one `Y`; then mark affected downstream tabs for reprocessing.
- **R13.2** Otherwise, when any item in the same loan-condition item set changes from `Y` to `N`, restore the corresponding original loan-condition fields into `TB_LOAN_CONDITION_DETAIL` and `TB_REVISED_ITEM_DETAIL`.
- **R13.3** When `LON_TYPE_CODE=04` (`Change Condition` / 展變), old `item12=N`, and new `item12=Y`, delete current `TB_LOAN_CONDITION_FEE` rows. This is the closed `04` side-effect branch, not a separate validation matrix from R4.
- **R13.4** When item13 or item14 changes, persist the selection only; no downstream side effect is triggered unless new owner-approved evidence supersedes this SRS.

Loan amount, grace period, tenor, fixed/tier/base/FD rate fields must preserve DB precision and reject invalid precision or truncation at the service boundary. [ev→R13]

### R14 Checkpoint and page-menu update - 強制點: BE
covers-prd: REQ-006

Execute must update the active new checkpoint tables `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, or `TB_CHECK_POINTS_CU` according to backend-owned checkpoint family (`LON_ATTRIBUTE` + `SECURE_ATTRIBUTE` / `caseCategory`), not the `LON_TYPE_CODE` case-type axis and not the removed/unused old `TB_CHECK_POINT_RC` family tables. It must write the `EPROZ00800` self key and only approved downstream reprocess keys. Revised Item downstream tab refresh may update `EPROISU0150` only for IS because `TB_CHECK_POINTS_IS` has that physical key, and `EPROCSU0150` only for CS because `TB_CHECK_POINTS_CS` has that physical key; IU/CU have no `0150` checkpoint key and must not synthesize one. `EPROISU0173`/`EPROCSU0173` are summary/read-display dependencies, not EPROZ00800 checkpoint/page-menu targets; field-level 0173 display/source mapping belongs to the 0173 bundles. The target FE refresh pattern is to re-call `epl-auth-tab-control` after save; save response does not need to carry authoritative page-menu keys. PRD legacy `_0260` names are trace labels, not the to-be DB contract. [ev→R14]

### R15 Error response contract - 強制點: both
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

Field validation codes such as `E102`, and PRD naked carriers such as `ErrorInputException message`, may appear as 400 field-validation detail inside the platform error envelope. They must not replace the PRD codes above without RD/SA mapping; when the platform cannot emit both, the SRS requires an explicit code-mapping decision before approval. [ev→R15]

### R16 Authorization and security - 強制點: BE
covers-prd: REQ-001, REQ-004, REQ-005, REQ-006

Backend must authorize the prompt/routing entry, `epl-case-query-reviseditem`, and especially mutating `epl-case-insert-reviseditem` through platform route/API authorization and case/page authorization, not only FE button or field hiding. Direct mutation attempts by a role/user that cannot edit this page must be rejected before any Revised Item or side-effect table is changed. `SECURE_ATTRIBUTE`, `LON_ATTRIBUTE`, and `LON_TYPE_CODE` predicates must be read from backend-controlled sources and not trusted solely from the client. [ev→R16]

### R17 Audit, logging, and rollback evidence - 強制點: BE
covers-prd: REQ-004, REQ-005, REQ-006, REQ-007

Execute must log an audit summary of side-effect categories, row counts, result, elapsed time, and operator context without logging full `reasonMemo`, borrower names, or sensitive payload contents. On exception, the audit entry records failure and the database transaction rolls back. [ev→R17]

### R18 Operational NFR - 強制點: both
covers-prd: REQ-007

Prompt/query/execute observability and performance must carry the PRD non-functional criteria. Query-like init must target response time <= 3 seconds in normal cases. Execute must target response time <= 5 seconds in normal cases and complete within a configured transaction timeout <= 30 seconds, including maximum reasonable guarantor/collateral copy data. Every prompt, query, and execute attempt must log `requestId`, `applicationNo`, `userId`, `action`, result, elapsed time, and error code when present. Error responses and logs must not expose SQL text, stack traces, full personal data, full account/ID values, sensitive collateral document contents, full request payloads, or full `reasonMemo`. Failures must be traceable by `requestId` plus `applicationNo` to backend log and DB/audit state. [ev→R18]

## NFR
- Authorization: mutating save must be rejected by backend authorization when page/edit permission is absent.
- Transaction: save, Revised Item row replacement, side-effect writes, checkpoint update, and audit outcome are all-or-nothing except the failure audit record.
- Performance: init-query target <= 3 seconds; execute target <= 5 seconds; execute transaction timeout target <= 30 seconds unless RD provides approved optimization/batching evidence.
- Precision/truncation: item flags are 1-byte enum values; `reasonMemo` input max is 3000 even though the DB column is 4000; loan amount, grace period, tenor, fixed/tier/base/FD rate restore fields must preserve numeric DB precision.
- Privacy: logs and audit summaries must not include full `reasonMemo`, borrower names, full account/ID values, sensitive collateral document contents, SQL text, stack traces, or full request payloads.
- Operability: prompt/query/execute logs must include `requestId`, `applicationNo`, `userId`, `action`, result, elapsed time, and error code when present.
- Testability: every non-pending rule has at least one happy/error/edge acceptance hook; pending rules have explicit owner and retest hooks.

## Hard Boundaries
- 可先修（與 @PENDING 無關）：R1–R18 全為已關決策（RP1–RP11、BP1–BP5 皆 ✅），RD 可依契約全面實作。
- 待 TBD：無。本包所有 @PENDING 已關閉。
- 摘要：RD 可依 Contract 半全面開發；side-effect 三判 / RI-MAT delta / provenance 後讀 Appendix 即可。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## Source Evidence
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
| implementation closeout | `docs/build-tasks/done/00800-implementation-closeout-findings.md`; SELECT-only auth proof `docs/build-tasks/done/00800-contract-closeout-authz.sql`; applied DB backfill (2026-06-23) `docs/build-tasks/done/00800-contract-closeout-authz-backfill.sql` |
| legacy Revised Item | `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:177`-`263`, `607`-`609`, `675`-`694` |
| current backend | `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:38`-`54`; `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:18`-`81`; `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:163`, `182`-`208`, `220`-`225`, `381`-`423`, `428`-`520`, `545`-`595`, `679`-`782`, `845`-`907` |
| current frontend | `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:13`-`27` |

## Trade-offs
- `reasonMemo` 物理欄寬 4000、契約輸入封頂 3000：對齊 PRD/current DTO，避免靜默擴張；query 回應可暴露既有資料的 ≤4000（DB-D1）。
- Execute response 與 tab refresh 拆分：FE 存後 re-call `epl-auth-tab-control`，BE 不再建權威 downstream response；current BE 回 `pageMenuCondition` 為容忍的額外資料、非契約要求（REF-D5）。
- `checkPointMap` 不作 client-authoritative input：checkpoint/page-menu 由 backend 推導，避免 client 操控持久化（RP11 / REF-D3）。

## DB Reconcile / Delta
| Delta | 三判 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_REVISED_ITEM` remains active/exact with PK `APPLICATION_NO`, 14 item flags, `REASON_MEMO VARCHAR2(4000)`, and `UPD_DATE`. | carried + constrained | `schema.sql` lists the physical 4000-byte column, while OpenAPI/execute caps `itemMap.reasonMemo` at 3000 per PRD/current DTO. Query response may expose up to 4000 from existing data. | `docs/db-diff/02_tables/TB_REVISED_ITEM.md:11`-`17`, `32`-`51`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:341`; DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:18` |
| DB-D2 `TB_REVISED_ITEM_DETAIL` remains active/exact and stores original application / original condition tuple plus item flags for loan-condition restore. | carried | `schema.sql` includes verification columns; R13.2 requires restore/update behavior rather than treating this as a free-form RD stub. | `docs/db-diff/02_tables/TB_REVISED_ITEM_DETAIL.md:11`-`18`, `32`-`52`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:284`-`286` |
| DB-D3 `TB_LON_SUMMARY_INFO` remains active/exact and is the backend source for `LON_TYPE_CODE`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, and `REF_APPLICATION_NO`. | carried | Query and execute must read these backend-owned values; client-supplied loan/case type values are not authoritative. BP2 closes the case-type mapping as `LON_TYPE_CODE`: `01=New`, `02=Additional`, `03=Renew`, `04=Change Condition`, `05=Restructure` when present; EPROZ00800 accepts only the `03`/`04` subset. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`19`, `38`-`51`; `docs/db-diff/02_tables/TB_LON_TYPE.md:38`-`39`; Bible `docs/specs/bible/bible-eproposal.md:323`, `752`, `792`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:393`-`395` |
| DB-D4 Old `TB_CHECK_POINT_RC` family tables are marked removed/unused and transferred to active `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, and `TB_CHECK_POINTS_CU`. | changed | R14 and `schema.sql` use active new checkpoint tables and new funcId-style keys. BP4 closes downstream mapping: IS/CS may update the physical 0150 keys; IU/CU have no 0150 key; 0173 is summary/read-display trace only, not an EPROZ00800 checkpoint/page-menu key. Legacy `_0260` names stay trace labels only. | Old removed/unused: `docs/db-diff/02_tables/TB_CHECK_POINT_RC.md:13`, `39`-`54`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_IU.md:13`, `39`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:13`, `39`-`52`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:13`, `39`-`51`. Active new and BP4 physical-key split: `docs/db-diff/02_tables/TB_CHECK_POINTS_IS.md:38`-`55`; `docs/db-diff/02_tables/TB_CHECK_POINTS_IU.md:38`-`50`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:845`-`907`; current FE refresh `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:200`-`202`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`; archived RP10 |
| DB-D5 `TB_COMMON_FIELD_OPTIONS` / `TB_MULTI_LANG` remain the option-name source, but code-table maintenance is outside this page. | carried | R3 requires display verification against the option source and does not create new option rows. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:208`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:65`-`87`; db-diff `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:32`, `38`-`48`; `docs/db-diff/02_tables/TB_MULTI_LANG.md:32`, `38`-`44` |
| DB-D6 Side-effect tables for guarantor, collateral, loan condition, fee, and borrower flags remain active operational dependencies. | carried | R12/R13 enumerate behavior and `schema.sql` lists relevant verification columns/comments; full ownership of downstream table design remains in their own page bundles. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:282`-`288`, `404`-`414`; db-diff borrower `docs/db-diff/02_tables/TB_MAIN_BORROWER_PERSONAL_INFO.md:32`, `38`-`39`, `80`, `84`; `docs/db-diff/02_tables/TB_MAIN_BORROWER_INFO_CORP.md:32`, `38`-`39`, `55`, `68`, `74`; db-diff side effects `docs/db-diff/02_tables/TB_GUARANTOR_INFO.md:32`, `38`-`40`, `80`, `84`; `docs/db-diff/02_tables/TB_GUARANTOR_INFO_CORP.md:32`, `38`-`40`, `56`, `68`; `docs/db-diff/02_tables/TB_COLL_INFO.md:32`, `38`-`41`, `72`; `docs/db-diff/02_tables/TB_COLL_VALUE_INFO.md:32`, `38`-`39`; `docs/db-diff/02_tables/TB_COLL_LTV.md:32`, `38`; `docs/db-diff/02_tables/TB_COLL_PROVIDER_INFO.md:32`, `38`-`42`, `58`; `docs/db-diff/02_tables/TB_COLL_TITLE_REGIS_OWNER.md:32`, `38`-`42`; `docs/db-diff/02_tables/TB_COLL_SITE_VISIT.md:32`, `38`-`39`; `docs/db-diff/02_tables/TB_COLL_TITLE_DETAIL.md:32`, `38`-`40`; `docs/db-diff/02_tables/TB_COLL_VALUE_DETAIL.md:32`, `38`-`41`; `docs/db-diff/02_tables/TB_CROSS_CHARGE_DETAIL.md:32`, `38`-`41`; `docs/db-diff/02_tables/TB_INSPE_AO.md:32`, `38`-`42`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:32`, `38`-`72`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_FEE.md:32`, `38`-`59`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:187`-`212` |
| DB-D7 `TB_API_AUTH` or equivalent platform route/API authorization must contain the final EPROZ00800 query/save API IDs before implementation closeout. | verified | SELECT-only closeout found both final API IDs present with `REF_FUNCTION_ID=EPROZ00800` and no duplicates. This closes the route/API seed portion; the separate page-column `reason.item` row in R7/R16 was backfilled (DBA/RD-applied 2026-06-23) and the closeout re-run returned `PAGE_COLUMN_RESULT=PASS`, `MATCHED_ROWS=4`, so that portion is now closed too. | db-diff table shape `docs/db-diff/02_tables/TB_API_AUTH.md:1`, `32`, `38`-`42`; proof script `docs/build-tasks/done/00800-contract-closeout-authz.sql`; findings `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
| REF-D1 Latest refactor map has four EPROZ00800 artifacts: BE query, BE insert, FE screen, FE reference. | carried | SRS anchors endpoint names and UI workflow to those selected latest artifacts, while marking mismatches as deltas. | `docs/refactor-spec/02_modules/EPROZ00800.md:3`-`18` |
| REF-D2 PRD/RP9 says query is GET; latest refactor query source still says POST; pre-closeout BE declared GET with request body and FE called POST. | changed + implemented | OpenAPI defines GET query parameter. Implementation closeout removed the GET body binding and updated FE call semantics; latest refactor POST text remains a historical delta. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:328`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:120`; controller `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:39`-`40`; FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:20`-`23`; findings `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
| REF-D3 PRD/legacy mention or send `checkPointMap`; latest refactor/current DTO uses `itemMap`, `isNotSame`, `isFinish`, and backend-built page-menu response handling. | changed | RP11 adjudication closes the target request as `applicationNo` + required `isFinish` + required `isNotSame` + `itemMap`. `checkPointMap` is a legacy/PRD delta and must not be accepted as client-authoritative checkpoint input. Current DTO must be tightened if it still allows missing `isFinish`/`isNotSame`. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:240`-`260`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:155`-`160`; legacy module `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:149`-`150`, `687`-`704`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:123`, `127`, `129`, `192`-`203`; current DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:43`-`56`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:176`-`198` |
| REF-D4 Archived v0.9 closed RP1-RP7/RP9/RP10; RP8, RP11, BP1, BP2, BP3, BP4, and BP5 are closed in this regenerated bundle. | mixed | Closed items are carried where source evidence is stable; RP8 closes R6 as corporate-unsecured predicate parity and R7 as granular FE UI auth plus mandatory backend mutation guard; BP1 is closed as the binary `LON_TYPE_CODE in ('03','04')` page gate; BP2 is closed as the case-type mapping to `LON_TYPE_CODE`; BP3 is closed because `03` and `04` share R4 validation while R5/R13.3 hold the case-specific branches; BP4 is closed by splitting 0150 checkpoint/page-menu refresh from 0173 summary/read-display trace ownership; BP5 is closed by treating `shared/common` as module classification rather than all-case visibility. Implementation closeout verifies DB-D7 API auth, adds service guard evidence, and the DB page-column `reason.item` mapping was backfilled (DBA/RD-applied 2026-06-23, closeout re-run `PAGE_COLUMN_RESULT=PASS`, `MATCHED_ROWS=4`); no approval blocker remains. | refactor latest map `docs/refactor-spec/02_modules/EPROZ00800.md:3`-`18`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:65`-`87`, `120`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`, `167`-`173`, `187`-`212`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:6`-`10`, `161`-`167`, `173`, `176`, `190`, `194`, `196`, `197`-`201`, `216`; legacy CU/edit evidence `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z006.java:266`-`272`, `317`-`321`, `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:122`-`128`; current FE closeout `frontend/src/app/core/models/pages/case-edition/common/revised-item.ts:40`, `79`-`80`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:250`-`266`; current BE closeout `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:39`-`40`, `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:189`, `209`, `249`-`280`; db-diff checkpoint and option sources in DB-D4/DB-D5; Bible `docs/specs/bible/bible-eproposal.md:80`, `109`, `171`-`176`, `198`, `323`, `497`, `505`-`506`, `728`-`731`, `752`, `754`-`756`, `792`, `801`; backend tab-control `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:50`, `277`, `302`-`303`; findings `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
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

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy）、to-be delta / 決策 ID、provenance；鍵到 Rn，與上半 `[ev→Rn]` 1:1。

| Rn | as-is（現況/legacy；含疑似 bug） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | Legacy/current expose EPROZ00800 visibility via JSP/tab-control + shared validation; BP1–BP3/BP5 previously open on visibility gate, case-type mapping, shared validation, and `shared/common` semantics. | BP1 closed by binary show/hide adjudication; BP2 closed by the `LON_TYPE_CODE` mapping; BP3 closed as shared validation for `03`/`04`; BP5 closed by terminology split (module classification, not all-case visibility). | Bible `docs/specs/bible/bible-eproposal.md:80`, `109`, `171`-`176`, `198`, `323`, `339`, `497`, `505`-`506`, `728`-`730`, `752`, `756`, `792`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:62`, `78`-`80`, `125`-`132`, `196`-`204`, `352`, `394`-`406`, `497`; db-diff `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:39`, `docs/db-diff/02_tables/TB_LON_TYPE.md:38`-`39`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:6`-`10`, `161`-`167`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:37`-`51`, `101`-`103`, `117`-`120`, `135`-`153`; backend tab-control `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:50`, `277`, `302`-`303`; frontend visibility `frontend/src/app/pages/case-edition/config/case-edition-navlink.ts:7`, `36`-`40`, `frontend/src/app/core/models/pages/case-edition/case-edition-tab-control.ts:49`-`63`, `frontend/src/app/pages/case-edition/services/shared.service.ts:82`-`86`; current shared validation `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/config/validate-rule.ts`, `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts:136`-`144`, `176`-`198`, `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:59`-`79` |
| R2 | Pre-closeout BE declared GET with request body and FE called POST; query mapping incomplete. | Implementation closeout: BE binds the GET query through `@ModelAttribute`, FE calls `apiGetRequest` with an `applicationNo` query parameter, and controller tests cover query-param success/validation. RP9 closed (GET). | REF-D2; current BE `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:39`-`40`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:20`-`23` |
| R3 | Current PRD still marks TBD-001 for the 14 formal option names; RP6 had closed names from prior DB evidence. | This SRS carries the RP6-closed decision and requires verification against code-table/reference data. Code-table maintenance out of scope. | RP6; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:208`; refactor query `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-query-reviseditem.md:65`-`87`; db-diff `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:32`, `38`-`48` |
| R4 | Current DTO validation present; BP3 previously open on whether `03`/`04` share one matrix. | BP3 adjudication: `03` and `04` share the R4 validation matrix; no separate mandatory-item/reason/item-flag sets unless a later source-backed PRD/owner decision supersedes. | BP3; DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:18`-`81` |
| R5 | Legacy forces item1 for renewal cases (renewal loan tenor by definition). | RP2 closed: `LON_TYPE_CODE=03` forces `item1=Y` locked, else `item1=N` locked; `03` case-specific default/lock, not a separate matrix from R4. | RP2; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:177`-`263` |
| R6 | Refactor text used `secureAttribute='U'` alone, which also matches individual-unsecured and is not equivalent to legacy `attrMap.isCU`. | RP8 closed: to-be predicate is backend-owned corporate unsecured `LON_ATTRIBUTE='C' AND SECURE_ATTRIBUTE='U'`; expose `isCorporateUnsecured`; FE must not derive lock from `SECURE_ATTRIBUTE` alone. Implementation closeout updated BE to compute it and FE to consume it; latest refactor `secureAttribute='U'` text remains historical delta. | RP8; REF-D4; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPRO_Z0Z006.java:266`-`272`, `317`-`321`; current FE `frontend/src/app/core/models/pages/case-edition/common/revised-item.ts:40`, `79`-`80` |
| R7 | Legacy `isEdit` is a coarse page predicate; JSP disables `.isView` controls and hides `#btnFinshed`. Refactor/current granular FE uses `epl-auth-tab-control` `isEdit` + `epl-auth-page-column` `isShowList`/`canEditList`. | RP8 closed: granular FE model accepted as UI model but not proof of legacy `isEdit` equivalence; backend execute must reject direct mutation with page/edit auth before any write; `TB_API_AUTH` alone insufficient. Implementation closeout added service-level guard for `revised.item`, `reason.item`, `button.butSave`/`button.butFinish` + rejection-before-mutation tests; `reason.item` page-column row backfilled (DBA/RD-applied 2026-06-23), SELECT-only re-run `PAGE_COLUMN_RESULT=PASS`, `MATCHED_ROWS=4` — R7 backend page/edit authorization closeout green. | RP8; REF-D4; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:122`-`128`; backfill `docs/build-tasks/done/00800-contract-closeout-authz-backfill.sql`; findings `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
| R8 | Legacy uses `isNotSame`/warning flow before destructive save. | RP1 carried: warning shown when state differs, skipped only on first save (no prior row, all blank/N); `isNotSame` is evidence of warning, not the authoritative side-effect trigger (R9 DB-side comparison is). | RP1; legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:149`-`150`, `687`-`704` |
| R9 | Legacy/current run the save in a transaction. | RP1 carried: single transaction; backend reads current state, normalizes missing to `N`, DB-side comparison is authoritative side-effect trigger; failure rolls back all + `COMMON_MSG_SAVE_FAIL`. | RP1; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:182`-`208` |
| R10 | Legacy/current delete + insert the row. | Carried: delete current row, insert one row with all 14 flags + `REASON_MEMO` + `UPD_DATE`; flags exactly `Y`/`N`; `reasonMemo` trimmed ≤3000 input. | current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:679`-`782` |
| R11 | Legacy FE sent `checkPointMap` with `EPROZ0_0800=N`; current DTO uses `itemMap`/`isNotSame`/`isFinish` and may allow missing `isFinish`/`isNotSame`. | RP11 closed: target request `applicationNo` + required `isFinish` + required `isNotSame` + `itemMap`; `checkPointMap` not client-owned; backend derives checkpoint/page-menu; current DTO must be tightened if it still allows missing required booleans. | RP11; REF-D3; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp:155`-`160`; current DTO `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/InsertReviseditemRequest.java:43`-`56` |
| R12 | RI-MAT-001/002/003: legacy deletes/restores guarantor and collateral data and updates borrower/collateral-provider flags; current implementation carries with some bug-fix intent. | RP1 carried: keep legacy side effects, fix known bugs (reference parameters, collateral-provider flag), leave audit evidence. | RP1; RI-MAT-001 legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:206`-`263`, current `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:381`-`414`, refactor `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:204`-`209`; RI-MAT-002 legacy `:185`-`187`, `255`-`263`, current `:415`-`423`, `825`-`834`, refactor `:210`; RI-MAT-003 legacy `:263`-`456`, current `:428`-`499`, `524`-`542`, refactor `:211`-`212` |
| R13 | RI-MAT-004: legacy all-off/delete transition is the target; current differs by treating existing any-N + request all-Y as delete (implementation delta). RI-MAT-005: legacy Y→N restore. RI-MAT-006: `LON_TYPE_CODE=04`, old item12=N, new item12=Y delete fee. RI-MAT-007: item13/item14 — no direct legacy data-table side-effect branch; legacy still does generic page-menu/checkpoint writes. | RP3/RP4/RP5 closed: legacy loan-condition delete/restore carried as target; current RI-MAT-004 condition is an implementation delta to fix or owner-accept before closeout; RP3 item12 fee-delete for `04`; RP5 item13/14 persist-only (data-table side effects), generic checkpoint behavior governed by R14; service-boundary precision validation required. BP3 holds R13.3 as the only `04` case-specific side-effect branch. | RP3, RP4, RP5, BP3; RI-MAT-004 legacy `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:460`-`503`, archived `docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md:83`, current `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:679`-`701`; RI-MAT-005 legacy `:504`-`597`, archived `:84`, current `:712`-`782`; RI-MAT-006 legacy `:607`-`609`, archived `:85`, current `:512`-`520`; RI-MAT-007 archived RP5, current `:667`-`676`, `845`-`907` |
| R14 | Legacy/current write generic page-menu/checkpoint; old `TB_CHECK_POINT_RC` family removed/unused. | RP10 + BP4 closed: use active `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_CS`, `TB_CHECK_POINTS_CU` by checkpoint family (not `LON_TYPE_CODE`, not old RC family); write `EPROZ00800` self key + approved downstream; IS/CS may update physical 0150 keys, IU/CU have none; 0173 is summary/read-display trace owned by 0173 bundles; FE re-calls `epl-auth-tab-control` after save; `_0260` names are trace labels only. | RP10, BP4; DB-D4; Bible `docs/specs/bible/bible-eproposal.md:731`, `754`-`755`, `801`; db-diff `docs/db-diff/02_tables/TB_CHECK_POINTS_IS.md:44`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:44`, `docs/db-diff/02_tables/TB_CHECK_POINTS_IU.md:39`-`50`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:39`-`50`; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:845`-`907`; current FE `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:27`-`32`, `.../revised-item.component.ts:200`-`202`; refactor save `docs/refactor-spec/03_artifacts/be-shared/EPROZ00800/epl-case-insert-reviseditem.md:129`; refactor FE `docs/refactor-spec/03_artifacts/fe-shared/EPROZ00800/eproz00800-revised-item-docx.md:216` |
| R15 | PRD carries error/success codes; refactor evidence has field-validation codes (`E102`) and naked `ErrorInputException`. | Carried: all 7 PRD codes in rule text + OpenAPI; field-validation codes may appear as 400 detail inside the platform envelope but must not replace PRD codes without RD/SA mapping; explicit code-mapping decision required if platform cannot emit both. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:324`-`384` |
| R16 | API-level `TB_API_AUTH` alone insufficient; client-supplied predicates not trustworthy. | RP8/BP1 carried: backend authorizes prompt/query/mutate via route/API + case/page auth; reject direct mutation before any table change; read `SECURE_ATTRIBUTE`/`LON_ATTRIBUTE`/`LON_TYPE_CODE` from backend sources. Closeout: final `TB_API_AUTH` rows SELECT-verified with `REF_FUNCTION_ID=EPROZ00800`; page-column `reason.item` backfilled (2026-06-23), re-run `PAGE_COLUMN_RESULT=PASS`, `MATCHED_ROWS=4`; security/authorization closeout fully green (full 實作完成 adjudicated by DoD 閘門牆). | RP8, BP1; DB-D7; proof `docs/build-tasks/done/00800-contract-closeout-authz.sql`; backfill `docs/build-tasks/done/00800-contract-closeout-authz-backfill.sql`; findings `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
| R17 | Legacy/current perform side effects within transaction. | RP1 carried: log audit summary (categories, row counts, result, elapsed, operator) without full `reasonMemo`/borrower names/sensitive payload; on exception record failure + roll back. | RP1; current BE `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java:845`-`907` |
| R18 | PRD NFR criteria for prompt/query/execute. | Carried: init-query ≤3s, execute ≤5s, transaction timeout ≤30s; log `requestId`/`applicationNo`/`userId`/`action`/result/elapsed/error code; no SQL/stack/full PII/full payload/full `reasonMemo` in errors/logs; failures traceable by `requestId`+`applicationNo`. | PRD NFR `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md:433`-`440` |
