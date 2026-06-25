# SRS - EPROC00110 Corporate Credit Investigation Frame

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| Status | 規格定版: Approved (2026-06-24, owner — axis A–F 獨立確認 Blocker 全清); 實作完成: done (owner 2026-06-25; rd-done+獨立驗+ratify) (QA 暫拔除) |
| N-axis review | 2026-06-24 source/domain patch + Should-fix closeout PASS. Cleared the 2026-06-23 3🔴 by standardizing checkpoint polarity (`Y` = pending / `N` = completed), adding `visibleTabs` as the visibility/order carrier while `pageMap` remains checkpoint state, and excluding `EPROCSU0160` from the EPROC00110 contract. Later Should-fix closeout grounded R9 four-to-two checkpoint consolidation in db-diff: active CS/CU rows are keyed by `APPLICATION_NO` without DB discriminator, while `sourceFrame`/`sourceTabMap` carry mutually exclusive 0110/0210 provenance; `schema.sql` also notes physical `EPROCSU0160` is intentionally excluded from this contract. Mechanical gate PASS. Pre-merge halves passed axis-A + cross-model review; after the 2026-06-24 branch-reconciliation merge, a post-merge cross-model axis-A re-review of the combined (7-fix spec + first-round QA) bundle found only Should-fix (QA-006 polarity wording aligned to the `Y`=pending/`N`=completed定版 plus a `visibleTabs`-as-visibility-carrier assertion), all closed, with no Blocker. Pending closeout axis-A found no Blocker; switchGeneration consistency Should-fix was closed in R7 and QA-008/QA-012. Owner-approved 2026-06-24 (規格定版) after axis A–F independent cross-model confirmation (3 prior Blockers closed: Pending Register reconcile, EPROC00114 CS-only/CU-omit, ERROR_MODULE carry); implementation/tests remain RD code-stage DoD. **2026-06-25 兩半轉換**：改 canonical Contract/Appendix 結構、Traceability 段已移除（追溯靠 covers-prd；原 QA 欄為 dormant 已隨段移除）、各 Rn 加 `[ev→Rn]`、as-is/provenance 搬 Appendix `Rule Evidence`。covers-prd 既存且對得到 PRD FR-001..FR-010，逐條覆核保留、無 TBD。 |
| funcId | EPROC00110 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00110/` |
| Source baseline | PRD v1.0 + Bible v1.1 + local db-diff + local refactor-spec + bounded source read |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |

## Scope
- This SRS covers the C0 corporate credit-investigation parent frame migrated from legacy `EPROC0_0110` and `EPROC0_0210` into funcId `EPROC00110`; PRD scope names the two legacy pages and the GI/FI/checkpoint/data-clearing responsibility at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:15-19`.
- In scope: load the frame, default `ASSESSMENT_TYPE=2` and `BUSINESS_TYPE=G`, expose GI/FI radio state, build child tab map, support checkbox/checkpoint state, switch GI/FI with data clearing, and preserve general-vs-renewal source behavior where evidenced; PRD scope and flow are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:92-123`.
- Out of scope: child-page business rules for `EPROC00112`, `EPROC00114`, `EPROC00115`, `EPROC00116`, `EPROC00117`, `EPROC00118`, `EPROC00119`, and `EPROC00120`; PRD non-scope excludes child-page internals at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:97-101`.

## Assumptions / Dependencies / Constraints
- The current refactor implementation exposes only `epl-info-c0-credit-investigation-tab` and `epl-save-c0-credit-investigation-tab`; the `epl-confirm-c0-credit-investigation-switch` token endpoint is a contract addition this SRS requires before release. Current-implementation grounding is in `## Rule Evidence`.
- The active checkpoint schema has one row per `APPLICATION_NO` in the selected CS/CU table and carries no general-vs-renewal discriminator column; `sourceFrame`/`sourceTabMap` therefore carry runtime provenance (see R9 and `## DB Reconcile / Delta`).
- Authorization seed `TB_API_AUTH` is a boundary only and is not sufficient proof of service-level authorization (see R12).

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-info-c0-credit-investigation-tab` | POST | Load source frame, business type, visible tabs, source aliases, and pageMap for the corporate credit-investigation frame. | R1-R6, R9-R11 |
| `epl-confirm-c0-credit-investigation-switch` | POST | Issue a short-lived single-use server token for one destructive GI/FI switch after the user accepts the warning text. | R7, R12, R18 |
| `epl-save-c0-credit-investigation-tab` | POST | Persist a GI/FI business type switch for the submitted source frame, clear affected data, and reset checkpoints. | R7-R8, R9, R11-R12 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 Load corporate credit-investigation frame - 強制點: both
covers-prd: FR-001, FR-009

Given a valid `applicationNo` and source-frame discriminator, the system must load the corporate credit-investigation frame through `epl-info-c0-credit-investigation-tab`, returning the effective `sourceFrame`, `businessType`, ordered `visibleTabs`, `sourceTabMap`, and `pageMap`.

The SRS contract does not require the new endpoint to expose every legacy JSP variable one-to-one. It requires the page state needed by the Angular frame and child-tab routing. [ev→R1]

### R2 Default summary assessment/business type - 強制點: BE
covers-prd: FR-002

If `TB_LON_SUMMARY_INFO.ASSESSMENT_TYPE` and `TB_LON_SUMMARY_INFO.BUSINESS_TYPE` are both blank, initial load must persist `ASSESSMENT_TYPE='2'` and `BUSINESS_TYPE='G'`. [ev→R2]

### R3 Select CS/CU checkpoint table from summary attributes - 強制點: BE
covers-prd: FR-002, FR-007

The backend must derive case type from `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE + TB_LON_SUMMARY_INFO.SECURE_ATTRIBUTE`; `CS` uses `TB_CHECK_POINTS_CS`, and other supported corporate cases use `TB_CHECK_POINTS_CU`. [ev→R3]

### R4 Display and guard GI/FI business type control - 強制點: both
covers-prd: FR-003, FR-008

The frame must display a business type control with values `G` and `F`. Users without edit permission must not switch business type. [ev→R4]

### R5 Build visibleTabs and pageMap by business type, CS/CU, and old-case flag - 強制點: both
covers-prd: FR-004, FR-008

For both `sourceFrame=GENERAL_0110` and `sourceFrame=RENEWAL_0210`, `visibleTabs` uses normalized refactor funcIds. GI must include `EPROC00115`, `EPROC00112`, `EPROC00116`, and `EPROC00117`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. FI must include `EPROC00115`, `EPROC00112`, `EPROC00119`, and `EPROC00120`; non-old cases also include `EPROC00118`, and non-old CS cases include `EPROC00114`. `EPROC00114` is CS-only: CU responses must not include it in `visibleTabs`, `sourceTabMap`, or `pageMap`, because `TB_CHECK_POINTS_CU` has no `EPROC00114` checkpoint column in this bundle's schema. The order must follow the legacy tab array order.

`pageMap` must not be the sole visibility carrier. It carries checkpoint state for known C0 child pages, while `visibleTabs` carries tab visibility and order, and `sourceTabMap` maps each normalized visible tab to its source-confirmed legacy page code. For `sourceFrame=GENERAL_0110`, `sourceTabMap` must map `EPROC00115/112/114/116/117/118/119/120` to `EPROC0_0115/0112/0114/0116/0117/0118/0119/0120`. For `sourceFrame=RENEWAL_0210`, the same normalized keys must map to `EPROC0_0215/0212/0214/0216/0217/0218/0219/0220`. [ev→R5]

### R6 Manage checkbox and checkpoint state - 強制點: both
covers-prd: FR-005, FR-009

The frame must expose checkpoint completion state for child tabs and accept child-page callbacks equivalent to legacy `check(pageName, isCheck)`.

Checkpoint polarity is fixed as follows: for a page listed in `visibleTabs`, `Y` means the tab is pending / still needs work, and `N` means completed. The physical DB default `'N'` in `TB_CHECK_POINTS_CS` and `TB_CHECK_POINTS_CU` is not the EPROC00110 active-frame initialization rule. On first frame initialization or GI/FI switch, active visible pages must be explicitly set to `Y`; inactive or hidden pages may remain `N` without implying visibility. [ev→R6]

### R7 Confirm GI/FI switch before destructive save - 強制點: both
covers-prd: FR-006

When a user changes `BUSINESS_TYPE`, the UI must require an explicit confirmation before calling `epl-save-c0-credit-investigation-tab`; if the user cancels, the UI must not call the backend and must restore the previous business type. The save request must carry the same `sourceFrame` used by the loaded frame so the backend resets the correct general or renewal/change checkpoint provenance.

The save contract requires both `confirmationToken` and `switchGeneration`; the backend must reject missing, invalid, stale, reused, or mismatched token/generation values before any destructive delete/update. The token and `switchGeneration` are issued only by `epl-confirm-c0-credit-investigation-switch` after the UI displays and the user accepts the warning text finalized in R18. The backend must also reject non-edit users and invalid `businessType` at service level; frontend confirmation alone is not sufficient for authorization. [ev→R7]

### R8 Clear affected data and reset checkpoints in one transaction - 強制點: BE
covers-prd: FR-006

After confirmed GI/FI switch, the backend must update `TB_LON_SUMMARY_INFO.BUSINESS_TYPE`, delete all affected financial evaluation, financial statement, and corporate scorecard data, and reset checkpoint fields for the submitted `sourceFrame` in one transaction.

Affected schema tables are `TB_FINANCIAL_EVALUATION_GI`, `TB_FINANCIAL_EVALUATION_FI`, `TB_FIN_STATEMENT_MAIN`, `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_BALANCE_FI`, `TB_FIN_STATEMENT_CASHFLOW_GI`, `TB_FIN_STATEMENT_CASHFLOW_FI`, `TB_FIN_STATEMENT_INCOME_GI`, `TB_FIN_STATEMENT_INCOME_FI`, and `TB_CORP_SCRCARD`. [ev→R8]

### R9 Preserve general vs renewal/change source behavior - 強制點: both
covers-prd: FR-007

The SRS must preserve the distinction that legacy `EPROC0_0110` used general checkpoint behavior and legacy `EPROC0_0210` used renewal/change checkpoint behavior. The caller must provide `sourceFrame=GENERAL_0110` or `sourceFrame=RENEWAL_0210`; if a local adapter derives that value from route metadata instead of JSON, the backend contract boundary must still receive the same discriminator before building tabs or checkpoint state.

For `sourceFrame=GENERAL_0110`, the backend must use the general source alias set and general checkpoint provenance (`TB_CHECK_POINT_CORP/CU` in legacy; normalized to `TB_CHECK_POINTS_CS/CU` in the refactor DB). For `sourceFrame=RENEWAL_0210`, it must use the 021x source alias set and renewal/change checkpoint provenance (`TB_CHECK_POINT_RC_CORP/CU` in legacy; normalized to `TB_CHECK_POINTS_CS/CU` in the refactor DB). Because the active CS/CU checkpoint tables have `APPLICATION_NO` as the only PK and no RC discriminator column, this SRS treats `sourceFrame` as mutually exclusive runtime provenance for a given `APPLICATION_NO`, carried by request/response `sourceFrame` and `sourceTabMap`, not by an additional checkpoint-table column. The `ASSESSMENT_TYPE=1` 0211/0213 branch remains separately blocked by R13 and must not be exposed as confirmed corporate GI/FI behavior. [ev→R9]

### R10 Update cross-module page menu completion state - 強制點: BE
covers-prd: FR-010

Child-page completion must contribute to the parent credit-investigation page menu state. [ev→R10]

### R11 Standardize error handling and message keys - 強制點: BE
covers-prd: FR-001, FR-006, FR-007

The SRS carries PRD error keys `MSG_INITIAL_FAIL`, `MSG_DATA_NOT_FOUND`, `MSG_QUERY_FAIL`, and `MSG_OVER_COUNT_LIMIT`.

The PRD module-error path is preserved instead of being silently collapsed into `MSG_QUERY_FAIL`: failures that correspond to `ReturnCode.ERROR_MODULE` must carry `ERROR_MODULE` plus the module message, and over-count failures must carry `ERROR_MODULE` plus `MSG_OVER_COUNT_LIMIT`. Generic query/switch failures without a module-returned message remain `ReturnCode.ERROR` plus `MSG_QUERY_FAIL`. The 0210 initial-load `ErrorInputException` branch must not silently preserve the legacy empty-return behavior; R15 closes it as a standard `MSG_INITIAL_FAIL` initial-load error. [ev→R11]

### R12 Enforce security, audit, and destructive-operation NFR - 強制點: both
covers-prd: FR-006, FR-008

The backend must enforce edit/query/old-case restrictions independently of the UI for any mutating call, and `epl-save-c0-credit-investigation-tab` must require and validate a server-issued destructive-switch confirmation/version token before deleting financial/scorecard data. `TB_API_AUTH` is named only as an authorization seed boundary, not as sufficient proof of service-level authorization; service-level reject behavior must be verified separately.

Every destructive switch attempt must produce an auditable outcome as a project-standard application audit event with event type `EPROC00110_GI_FI_SWITCH`, observable through the configured audit sink or test audit collector. For token issuance rejection, token issuance, rejected save, successful switch, and transaction rollback/failure, the backend must record actor, session or request correlation id, `applicationNo`, `sourceFrame`, old `businessType`, requested new `businessType`, token id or fingerprint, outcome, failure reason when applicable, and the affected table list. Audit records must not include financial statement, financial evaluation, or scorecard row contents. The physical sink implementation belongs to the code-stage DoD, but the named event and fields are part of this SRS contract and must be test-verifiable before release. [ev→R12]

### R13 TBD-001 renewal assessment-type switch is not exposed by EPROC00110 - 強制點: both
covers-prd: FR-007

`EPROC00110` must not expose `EPROC0_0211` / `EPROC0_0213`, normalized `EPROC00111` / `EPROC00113`, or a personal assessment-type switch. The EPROC00110 frame contract remains GI/FI `businessType` driven only; `assessmentType` is not a client-visible switch in this bundle. Future migration or ownership of the 0211/0213 actions requires a separate owner-approved bundle. (Decision NO_PERSONAL_ASSESSMENT_SWITCH_IN_00110; see `## @PENDING` TBD-001.) [ev→R13]

### R14 TBD-002 application number source is the required API request field - 強制點: both
covers-prd: FR-001, FR-009

The to-be contract uses `applicationNo` as the stable required request field for `epl-info-c0-credit-investigation-tab`, `epl-save-c0-credit-investigation-tab`, and child frame calls launched from EPROC00110. FE must source this value from the migrated case/frame context and send the same value across parent and child calls; BE must reject blank or missing `applicationNo` before any query or mutation and must not depend on legacy JSP request attributes. Implementation and tests belong to the code-stage DoD and remain pending RD. [ev→R14]

### R15 TBD-003 0210 ErrorInputException returns standard initial failure - 強制點: BE
covers-prd: FR-007

The 0210 initialization `ErrorInputException` branch must return the standard initial-load failure response: `ReturnCode.ERROR` with `MSG_INITIAL_FAIL`, or the equivalent new API error envelope carrying `MSG_INITIAL_FAIL`. The backend must not return success, an empty message, or raw exception text for this branch. Implementation and tests belong to the code-stage DoD and remain pending RD. [ev→R15]

### R16 TBD-004 title and i18n key ownership is C0-owned - 強制點: FE
covers-prd: FR-001

EPROC00110 title and legend i18n ownership is C0-owned. FE must use one C0-owned key for the frame function title and fieldset legend, such as `EPROC00110_FUNC_NAME` or the project-standard C0 namespace equivalent, and must not depend on I0-owned `EPROI0_0110_FUNC_NAME`. Implementation and tests belong to the code-stage DoD and remain pending RD. (Decision C0_OWNED_I18N_KEY; see `## @PENDING` TBD-004.) [ev→R16]

### R17 TBD-005 GI/FI display names are source-confirmed English domain labels - 強制點: FE
covers-prd: FR-003

The EPROC00110 business type display text is `General Industry (GI)` for `BUSINESS_TYPE=G` and `Financial Industry (FI)` for `BUSINESS_TYPE=F`. FE must use C0-owned i18n keys, for example `EPROC00110_UI_GI` and `EPROC00110_UI_FI`, or the project-standard C0 namespace equivalent. FE must not depend on I0-owned legacy keys such as `EPROI00110_UI_GI` or `EPROI00110_UI_FI`. Implementation and tests belong to the code-stage DoD and remain pending RD. (Decision GI_FI_ENGLISH_LABELS; see `## @PENDING` TBD-005.) [ev→R17]

### R18 TBD-006 destructive switch confirmation token policy is finalized - 強制點: both
covers-prd: FR-006

EPROC00110 must use a destructive-switch confirmation flow with explicit delete-scope wording, a short-lived single-use server token, and a stale-version guard. The warning text must tell the user that switching Business Type between `General Industry (GI)` and `Financial Industry (FI)` will delete/reset financial statement data, financial evaluation data, Corporate Scorecard data, and related checkpoint completion state before the frame reloads. The UI may use project-standard wording, but it must preserve that delete-scope content.

The token contract is mandatory for both FE and BE. FE must request a confirmation token only after the user accepts the warning; BE must issue a single-use token valid for 10 minutes and bind it to actor/session, `applicationNo`, `sourceFrame`, old `businessType`, new `businessType`, and a server-side monotonic `switchGeneration` for that `applicationNo` + `sourceFrame`. `epl-save-c0-credit-investigation-tab` must send both the token and the issued `switchGeneration`; the backend must validate both immediately before any delete/update and reject the save if either value is missing, invalid, expired, reused, bound to different context, or no longer equals the current server-side generation. Any successful destructive switch must advance the server-side `switchGeneration` and invalidate outstanding tokens for the same `applicationNo` + `sourceFrame`, so ABA changes cannot reuse an older token after the business type cycles back. A token is consumed on the first save validation attempt; if the later delete/update transaction fails or rolls back, FE must show the warning again and obtain a new token. Stale or mismatched token failures must leave summary, affected child data, and checkpoints unchanged. Implementation and tests belong to the code-stage DoD and remain pending RD. [ev→R18]

## NFR
- Transaction: GI/FI switch must update summary, delete affected financial/statement/scorecard data, and reset checkpoints atomically (one transaction), per R8; stale/mismatched token failures must leave data unchanged, per R18.
- Security: any mutating call must enforce edit/query/old-case restrictions at service level independently of the UI; a server-issued single-use confirmation token (10-minute validity) plus `switchGeneration` is required before destructive delete/update; `TB_API_AUTH` seed presence alone is insufficient (R12, R18).
- Audit: every destructive switch attempt must emit a `EPROC00110_GI_FI_SWITCH` audit event with the R12 field set, excluding financial/scorecard row contents; test-verifiable before release.
- Error handling: module-returned failures carry `ERROR_MODULE` + module message; over-count carries `ERROR_MODULE` + `MSG_OVER_COUNT_LIMIT`; generic failures carry `ReturnCode.ERROR` + `MSG_QUERY_FAIL`; 0210 initial-load `ErrorInputException` carries `MSG_INITIAL_FAIL` (R11, R15).

## Hard Boundaries
- 可先修（與 @PENDING 無關、契約已定）：R1-R12 載框/預設/CS-CU 分支/visibleTabs/checkpoint 極性/確認 token/清資料交易/source 區分/cross-module menu/錯誤碼/安全稽核。
- 待 TBD（已 owner 裁定關閉、實作仍 RD DoD）：R13-R18（TBD-001..006，見 `## @PENDING`）。
- 摘要：所有 TBD 已 spec-frozen，RD 可全面動工；0211/0213 個人評等切換明確不在本包（R13）。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

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

## Trade-offs
- Keeping renewal (0210) source behavior through mutually exclusive `sourceFrame`/`sourceTabMap` runtime provenance, rather than adding an RC discriminator column, aligns the contract with the active DB snapshot (CS/CU keyed by `APPLICATION_NO` only) while preserving general-vs-renewal distinction (R9; see `## DB Reconcile / Delta`).
- Promoting destructive GI/FI switch to a server-issued single-use token + `switchGeneration` (R7/R18) trades a heavier confirm flow for protection against accidental/ABA data loss; the legacy flow used only a frontend `confirm`.

## DB Reconcile / Delta
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

## @PENDING
| ID | Rule | Owner | Impact | Evidence | Status |
|---|---|---|---|---|---|
| TBD-001 | R13 | PM/SA/RD | Renewal assessment-type switch ownership. | PRD TBD-001 and R13 owner decision 2026-06-24. | Closed/spec-frozen: NO_PERSONAL_ASSESSMENT_SWITCH_IN_00110 |
| TBD-002 | R14 | RD | Required application number source and request validation. | PRD TBD-002 and R14 contract decision 2026-06-24. | Closed/spec-frozen: APPLICATION_NO_REQUIRED_FROM_CASE_CONTEXT; implementation/tests remain RD DoD |
| TBD-003 | R15 | RD | 0210 `ErrorInputException` message behavior. | PRD TBD-003 and R15 contract decision 2026-06-24. | Closed/spec-frozen: STANDARD_INITIAL_FAIL_FOR_ERROR_INPUT; implementation/tests remain RD DoD |
| TBD-004 | R16 | FE/RD | C0-owned title/i18n key. | PRD TBD-004 and R16 owner decision 2026-06-24. | Closed/spec-frozen: C0_OWNED_I18N_KEY |
| TBD-005 | R17 | FE/RD | GI/FI display labels. | PRD TBD-005 and R17 owner decision 2026-06-24. | Closed/spec-frozen: GI_FI_ENGLISH_LABELS |
| TBD-006 | R18 | FE/RD/Security | Destructive switch warning and confirmation token policy. | PRD TBD-006 and R18 owner decision 2026-06-24. | Closed/spec-frozen: SWITCH_TOKEN_AND_GENERATION_REQUIRED; implementation/tests remain RD DoD |

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy；含疑似 bug）、to-be delta/決策 ID、provenance（`file:line`/`@SHA`）；鍵到 Rn，與上半 `[ev→Rn]` 1:1。

| Rn | as-is（現況/legacy） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | Legacy 0110 prompt returned frame attributes and role/editor flags; legacy 0210 returned the renewal frame and `isCR`. Current backend request DTO contains only `applicationNo`; response DTO contains only `businessType` and `pageMap`. | Add `sourceFrame`, `visibleTabs`, and `sourceTabMap` to the response contract (implementation gap to close). | legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:51-69`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:51-71`; current req DTO `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCreditInvestigation/GetCsuCreditInvestigationTabRequest.java:11-17`; current resp DTO `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuCreditInvestigation/GetCsuCreditInvestigationTabResponse.java:11-17`; PRD context `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:431-458`. |
| R2 | Legacy 0110/0210 initialize default values in `initQuery`. Current backend sets `assessmentType=2` and supplied/default `businessType` in `initializeCreditInvestigationTab`. | Persist `ASSESSMENT_TYPE='2'`/`BUSINESS_TYPE='G'` on blank initial load. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:117-123`, `:211-236`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:46-91`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:50-96`; current `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:190-228`; schema `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:58-59`. |
| R3 | Current backend derives type from `lonAttribute + secureAttribute` and branches to CS/CU repositories. Legacy `TB_CHECK_POINT_CORP/CU/RC_CORP/RC_CU` are removed/transferred. | Derive CS uses `TB_CHECK_POINTS_CS`, other corporate cases use `TB_CHECK_POINTS_CU`. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:151-152`; current `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:115-142`; new tables `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10-16`; legacy removed `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10-16`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10-16`. |
| R4 | Legacy 0110/0210 JSP render GI/FI labels and disable view in non-edit mode. Current Angular config declares `businessType` radio options `G`/`F`; FE derives editable state from authorization. | Display `G`/`F` control; users without edit permission must not switch. | legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:39-43`, `:264-265`, `:325-328`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42`, `:261-262`, `:322-324`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:363-381`; current FE `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/fielditem-config.ts:17-35`, `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:131-136`. |
| R5 | Legacy JSP tab conditions support GI/FI, old-case, and CS branches. Current backend builds G/F maps by adding/removing pageMap keys; current FE filters `pageMap` into visible tabs — this coupling is an implementation gap against the response contract. | `visibleTabs` carries visibility/order, `sourceTabMap` maps normalized→source legacy codes; `EPROC00114` CS-only; order follows legacy tab array. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:257-287`, `:278-287`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:169-218`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:167-215`; current BE `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:260-295`; current FE `frontend/src/app/core/models/pages/case-edition/corporate/credit-investigation/credit-investigation-tab-control.ts:49-66`. |
| R6 | Legacy 0110 provides `check` only when editable; 0210 additionally blocks old cases. Legacy `getChangeCheck` initializes active GI/FI pages to `Y`. Current backend reads checkpoint state and maps the EPROC001xx child pages. | Polarity fixed `Y`=pending/`N`=completed; active visible pages explicitly set `Y` on init/switch; physical DB default `'N'` is not the active-frame init rule. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:289-307`, `:303-305`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:57-60`, `:58-59`, `:215-218`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:55-60`; legacy mod `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:157-167`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:163-177`; current `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:230-257`; new columns `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:45-52`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:43-49`. |
| R7 | Legacy JSP confirms before `getPage`; current Angular confirms before save. Current save validates only `applicationNo`/`businessType` and starts mutation without service-level guard. | Require explicit confirm + restore on cancel; save carries `sourceFrame`, `confirmationToken`, `switchGeneration`; BE rejects bad token/gen and non-edit users before mutation. | legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:238-258`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:235-255`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:141-144`, `:308-318`; current FE `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/credit-investigation.component.ts:139-164`. |
| R8 | Legacy 0110/0210 `changePage` update summary, delete related data, update checkpoint, and commit/rollback. Current backend `doSave` is transactional with deletion/checkpoint-reset logic. | One-transaction summary update + delete affected financial/statement/scorecard + checkpoint reset for submitted `sourceFrame`. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:314-318`, `:470-476`, `:561-563`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0110_mod.java:103-142`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:108-148`; current `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:152-184`, `:320-342`, `:344-383`; affected schema `docs/db-diff/01_groups/group-21.md:13-17`, `docs/db-diff/01_groups/group-23.md:13-19`, `docs/db-diff/00_HOME.md:186`, `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13-16`. |
| R9 | Legacy 0210 has page-code behavior for `EPROC0_0216..0220`. Current backend constants only expose normalized EPROC001xx, so 0210 parity is missing — a failing condition for R9, not an accepted gap. Active CS/CU checkpoint tables are keyed by `APPLICATION_NO` only with no RC discriminator. | Treat `sourceFrame` as mutually exclusive runtime provenance; general vs RC alias/checkpoint provenance carried by `sourceFrame`/`sourceTabMap`, not an extra column; 0211/0213 stays blocked by R13. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:99`, `:168`, `:342-361`, `:591-600`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:38-39`, `:163-179`; current `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:76-93`; DB `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:13-16`, `:32`, `:45-52`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:13-16`, `:32`, `:43-49`; legacy removed `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:10`, `:13`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:10`, `:13`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10`, `:13`. |
| R10 | Legacy CS modules call `changeCheckPoint` and put `EPROC0_0110`/`EPROC0_0210` into page-menu conditions. Current backend authorization/menu logic sets `EPROC00110` from `crScore`; full CS/CU parity not proven in bounded read (UNFOUND, needs regression verification). | Child-page completion contributes to parent page menu state. | legacy `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0110_mod.java:148-150`, `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0210_mod.java:167-169`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:402-418`; current `backend/src/main/java/khd/svc/epro/service/common/impl/EPROAuthorizationServiceImpl.java:467-507`. |
| R11 | Legacy 0110 maps initial/getPage errors; legacy 0210 maps getPage errors and catches `ErrorInputException` without setting a return message (PRD TBD-003 defect suspect). | Preserve module-error path (`ERROR_MODULE` + module msg; over-count + `MSG_OVER_COUNT_LIMIT`); generic = `ERROR` + `MSG_QUERY_FAIL`; 0210 empty-catch closed by R15. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:460-468`, `:546-564`, `:45`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:69-108`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`, `:96-112`. |
| R12 | Current save request validates only `applicationNo`/`businessType`; current `doSave` mutates without a visible service-level edit/old-case guard — implementation gaps. | Service-level edit/query/old-case enforcement; server-issued token required before destructive delete; `EPROC00110_GI_FI_SWITCH` audit event with named fields; `TB_API_AUTH` seed not sufficient. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:519-525`, `:566-576`; current `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`, `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditInvestigationServiceImpl.java:154-184`; seed boundary `docs/db-diff/02_tables/TB_API_AUTH.md:1-42`. |
| R13 | Legacy 0210 has backend/checkpoint evidence for `ASSESSMENT_TYPE=1` enabling `EPROC0_0211`/`0213`, but the main JSP GI/FI tab body omits 0211/0213; refactor-spec carries only `businessType`/pageMap tabs; audit records EPROC0_0211/0213 FE/BE as UNFOUND. | Owner decision 2026-06-24 option A: NO_PERSONAL_ASSESSMENT_SWITCH_IN_00110; future 0211/0213 needs separate bundle. | PRD TBD-001 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:43`, `:96-101`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0210_mod.java:37-39`, `:163-179`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:321-355`; refactor-spec `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:83-91`, `docs/refactor-spec/03_artifacts/be-corporate/EPROC00110/epl-info-c0-credit-investigation-tab.md:76-85`; audit `docs/build-tasks/refactor-audit/M7a-c0-00110-00115.md:23-24`. |
| R14 | Legacy prompt transactions populate `attrMap` and call modules with `MapUtils.getString(attrMap, "APPLICATION_NO")`; legacy JSPs show AJAX `${APPLICATION_NO}` vs display `${attrMap.APPLICATION_NO}` mismatch (PRD TBD-002 ambiguity). | Owner/contract decision 2026-06-24: APPLICATION_NO_REQUIRED_FROM_CASE_CONTEXT; BE rejects blank/missing before any query/mutation; implementation RD DoD. | PRD TBD-002 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:44`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:49-67`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:49-68`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:49`, `:314-315`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:47`, `:311-312`; refactor-spec `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:172-177`, `docs/refactor-spec/03_artifacts/be-corporate/EPROC00110/epl-info-c0-credit-investigation-tab.md:123-129`. |
| R15 | Legacy 0210 has an empty `ErrorInputException` catch (PRD TBD-003 defect suspect); legacy 0110 prompt and 0210 generic prompt exception use `MSG_INITIAL_FAIL`. | Decision 2026-06-24: STANDARD_INITIAL_FAIL_FOR_ERROR_INPUT — return `ReturnCode.ERROR` + `MSG_INITIAL_FAIL`; no success/empty/raw text; implementation RD DoD. | PRD TBD-003 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:45`, `:557-564`, `:460-468`, `:548-556`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:73-78`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0110.java:71-75`, `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0210.java:75-79`. |
| R16 | Legacy JSPs drift: function description uses `EPROC0_0110_FUNC_NAME` while fieldset legend uses `EPROI0_0110_FUNC_NAME`. Refactor-spec names FE artifact `EPROC00110-Credit-Investigation(頁框)` and passes `functionName="EPROC00110"`. | Owner decision 2026-06-24 option A: C0_OWNED_I18N_KEY (`EPROC00110_FUNC_NAME` or C0 namespace); not I0-owned; implementation RD DoD. | PRD TBD-004 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:46`, `:15-19`; refactor-spec `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:1-6`, `:172-177`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:39-43`, `:310-313`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:37-42`, `:307-310`. |
| R17 | Legacy C0 JSPs use keys `EPROI00110_UI_GI`/`EPROI00110_UI_FI` with comments `General Industry (GI)`/`Financial Industry (FI)` (PRD TBD-005: formal text depended on not-found i18n keys). Refactor-spec labels options `General Industry(G)`/`Financial Industry(F)`. | Owner decision 2026-06-24 option A: GI_FI_ENGLISH_LABELS; C0-owned keys (`EPROC00110_UI_GI/FI`); not I0-owned; implementation RD DoD. | PRD TBD-005 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:47`, `:244`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:325-330`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:322-325`; refactor-spec `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:163-166`. |
| R18 | Legacy C0 JSPs only call frontend `confirm` before `getPage`; refactor-spec carries a generic reminder text weaker than finalized delete-scope wording. Current save DTO has `applicationNo`/`businessType` but no token (PRD TBD-006 data-loss risk). | Owner decision 2026-06-24 option A: SWITCH_TOKEN_AND_GENERATION_REQUIRED — single-use 10-min server token bound to context + monotonic `switchGeneration`, ABA-safe; implementation RD DoD. | PRD TBD-006 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:48`, `:313-324`, `:504-510`, `:561-563`, `:573-576`; legacy JSP `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:254-260`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:251-257`; refactor-spec `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00110/eproc00110-credit-investigation.md:124-165`; current DTO `backend/src/main/java/khd/svc/epro/dto/request/corporate/SaveCsuCreditInvestigationTabRequest.java:11-21`. |

<!-- covers-prd 覆核（2026-06-25 兩半轉換）：本包 18 條 Rn 全部已帶 covers-prd，逐條對到 PRD §3 需求清單 FR-001..FR-010（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md:162-171`）。映射：R1→FR-001/009、R2→FR-002、R3→FR-002/007、R4→FR-003/008、R5→FR-004/008、R6→FR-005/009、R7→FR-006、R8→FR-006、R9→FR-007、R10→FR-010、R11→FR-001/006/007、R12→FR-006/008、R13→FR-007、R14→FR-001/009、R15→FR-007、R16→FR-001、R17→FR-003、R18→FR-006。全數對得到、無 TBD、無臆造。原 `## Traceability` 段（含 dormant QA 欄）已於本次移除，追溯改以 covers-prd 為 SoT。 -->
