# c0 Authz SQL Findings

Status: **APPLIED to `OVSLXLON02` 2026-06-25 (ops reported)** — `TB_API_AUTH` seed (33 rows incl owner-ratified pxls←ppdf-c0 + confirm-switch←save-c0) + `TB_ROLE_TASK` inserted. **c0/csu Phase V 403 前置解除。** RD addendum updated 2026-06-25 for EPROC00116 pxls reviewed-equivalent auth seed. **Owner ratified 2026-06-25** both RD-proposed authz role-source substitutions (00116 pxls←ppdf-c0; 00110 confirm-switch←save-c0) after independent review — same-semantics sibling copy (export→export, mutate→mutate). **DBA post-apply 待驗**：pxls 列最終角色數 == ppdf-c0（應 14）。**注意：seed 層已套＝必要非充分**——雙層授權的 service-guard 層仍為 RD code-stage（見 line 109）。

## Output

- SQL: `docs/build-tasks/c0-authz-sql.sql`
- Statements: 5 Oracle insert blocks plus `COMMIT`
- Logical mappings: 33 `TB_API_AUTH` endpoint mappings + 8 `TB_ROLE_TASK` page mappings
- DB precheck scope: `epro-db/new.cmd`, SELECT only, `OVSLXLON02` current schema / owner in precheck queries, no INSERT executed
- Expected `TB_API_AUTH` inserts now: 18 from the original precheck baseline: 17 exact-source rows plus 1 EPROC00116 pxls reviewed-equivalent row copied from the existing c0 ppdf row. Current c0 rows: 15/33. Source i0 rows: 30/32 plus one EPROC00110 to-be confirm row copied from the existing c0 save row.
- Expected `TB_ROLE_TASK` inserts now: 0. Current c0 rows: 8/8. Source i0 rows: 8/8.
- UNSURE / gap rows: 0 after owner ratification 2026-06-25 (was RD-proposed). The prior `epl-pxls-c0-financial-statement-comments` gap is resolved by copying roles from the existing c0 `epl-ppdf-c0-financial-statement-comments` reviewed-equivalent row.

## Pattern Evidence

- `TB_API_AUTH` columns are `API_ID`, `ROLE`, `REF_FUNCTION_ID`, `UPDATE_USER`, `UPDATE_DATE`: `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/columns_new_OVSLXLON01.psv:1-5`.
- `TB_ROLE_TASK` columns are `PAGE_CODE`, `ROLE`, `FUNCTION`, `PAGE_NAME`: `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/columns_new_OVSLXLON01.psv:2777-2780`.
- R7 model defines `TB_API_AUTH` as endpoint access and `TB_ROLE_TASK` as page operation/edit access; `TB_API_AUTH` uses `API_ID` as the documented key and `TB_ROLE_TASK` uses `PAGE_CODE` + `FUNCTION` as the documented key: `docs/legacy/db-schema-catalog.md:75-76`.
- Migration rule says `TB_API_AUTH` links `API_ID` to role and `REF_FUNCTION_ID`, and page migration uses funcId to build API auth: `docs/legacy/migration-backlog.md:65`.
- Runtime API auth compares `ROLE LIKE %:role%` and exact `API_ID`: `backend/src/main/java/khd/svc/epro/repository/TBApiAuthRepository.java:14`.
- Runtime API id is slash-stripped by `request.getRequestURI().replace("/","")`: `backend/src/main/java/khd/svc/epro/config/security/APIAuthorizationFilter.java:40`.
- Existing seed/migration search: `git grep -n -i "insert.*TB_API_AUTH\|insert.*TB_ROLE_TASK" -- .` returned no matches, so no repo-local data row template was found.
- Existing SQL file search found only the 00800 SRS `schema.sql` (now archived at `docs/archive/EPROZ00800-v0.9-superseded/srs/schema.sql`); no product seed/migration SQL directory was found, so this DB-free artifact is placed under `docs/build-tasks/` with the task card.

## Template Basis

- No repo-local seed row template exists for `TB_API_AUTH` / `TB_ROLE_TASK`; the i0 template for each API mapping is therefore the current individual controller route listed in the `i0 route evidence` column.
- `TB_API_AUTH` copies `ROLE` only from source rows matching both source `API_ID` and source `REF_FUNCTION_ID`; there is no `REF_FUNCTION_ID IS NULL` fallback.
- DB constraint precheck confirmed `TB_API_AUTH_PK(API_ID)` and `TB_ROLE_TASK_PK(PAGE_CODE,FUNCTION)` in `OVSLXLON02`, so the SQL skips an existing target API by `API_ID` and an existing task by `PAGE_CODE` + `FUNCTION`.
- `TB_ROLE_TASK` copies source page operation rows by source `PAGE_CODE`; target idempotency follows the DB/documented logical key `PAGE_CODE` + `FUNCTION`, so the script does not overwrite an existing target operation row with a different `ROLE`.

## DB Apply-Precheck

Command scope: `epro-db/new.cmd`, `SELECT` only, `OVSLXLON02` current schema / owner in precheck queries. No INSERT was executed. The SQL file itself uses unqualified table names and must be applied with current schema `OVSLXLON02`.

### TB_API_AUTH Endpoint Verification

| Target funcId | Target endpoint | C0 exists? | C0 roles | i0 source endpoint | i0 source exists? | i0 source roles | Expected insert count | Note |
|---|---|---|---|---|---|---|---:|---|
| EPROC00110 | `epl-info-c0-credit-investigation-tab` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | `epl-info-i0-credit-investigation-tab` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00110 | `epl-save-c0-credit-investigation-tab` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | `epl-save-i0-credit-investigation-tab` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00110 | `epl-confirm-c0-credit-investigation-switch` | N |  | `epl-save-c0-credit-investigation-tab` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 1 | RD addendum: copy existing c0 save roles; no i0 confirm route exists |
| EPROC00112 | `epl-info-c0-cbc-banking-relationship` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;403;404;405` | `epl-info-i0-cbc-banking-relationship` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | 0 | skip existing |
| EPROC00112 | `epl-save-c0-cbc-banking-relationship` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | `epl-save-i0-cbc-banking-relationship` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00114 | `epl-info-c0-collateral-assessment` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;403;404;405` | `epl-info-i0-collateral-assessment` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;403;404;405` | 0 | skip existing |
| EPROC00114 | `epl-save-c0-collateral-assessment` | Y | `001;002;102;103` | `epl-save-i0-collateral-assessment` | Y | `001;002;102;103` | 0 | skip existing |
| EPROC00114 | `epl-sele-c0-collateral-assessment` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | `epl-sele-i0-collateral-assessment` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00115 | `epl-info-c0-borrower-group-exposure` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | `epl-info-i0-borrower-group-exposure` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00115 | `epl-save-c0-borrower-group-exposure` | Y | `001;002;403` | `epl-save-i0-borrower-group-exposure` | Y | `001;002;403` | 0 | skip existing |
| EPROC00115 | `epl-sele-c0-borrower-group-exposure` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | `epl-sele-i0-borrower-group-exposure` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405;403` | 0 | skip existing |
| EPROC00116 | `epl-calc-c0-financial-statement-comments` | Y | `001;002` | `epl-calc-i0-financial-statement-comments` | N |  | 0 | c0 already exists; i0 source missing has no insert impact |
| EPROC00116 | `epl-info-c0-financial-statement-comments` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | `epl-info-i0-financial-statement-comments` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 0 | skip existing |
| EPROC00116 | `epl-ppdf-c0-financial-statement-comments` | N |  | `epl-ppdf-i0-financial-statement-comments` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 1 | will insert |
| EPROC00116 | `epl-pxls-c0-financial-statement-comments` | N |  | `epl-ppdf-c0-financial-statement-comments` | Y | inherits ppdf-c0 final roles＝`001;002;003;101;102;103;201;202;203;301;302;401;404;405`(14, == ppdf) | 1 | owner-RATIFIED 2026-06-25 reviewed equivalent copies existing c0 ppdf roles; **DBA verify post-apply: pxls role count == ppdf-c0 (14)** |
| EPROC00116 | `epl-quer-c0-financial-statement-comments` | Y | `001;002` | `epl-quer-i0-financial-statement-comments` | Y | `001;002` | 0 | skip existing |
| EPROC00116 | `epl-save-c0-financial-statement-comments` | Y | `001;002` | `epl-save-i0-financial-statement-comments` | Y | `001;002` | 0 | skip existing |
| EPROC00116 | `epl-sele-c0-financial-statement-comments` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | `epl-sele-i0-financial-statement-comments` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 0 | skip existing |
| EPROC00117 | `epl-info-c0-financial-business` | N |  | `epl-info-i0-financial-business` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 1 | 00117 flip: will insert |
| EPROC00117 | `epl-save-c0-financial-business` | N |  | `epl-save-i0-financial-business` | Y | `001;002` | 1 | 00117 flip: will insert |
| EPROC00117 | `epl-sele-c0-financial-list` | N |  | `epl-sele-i0-financial-list` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;404;405` | 1 | 00117 flip: will insert |
| EPROC00118 | `epl-calc-c0-corporateScorecard` | N |  | `epl-calc-i0-corporateScorecard` | Y | `001;002;102;103` | 1 | will insert |
| EPROC00118 | `epl-info-c0-corporateScorecard` | N |  | `epl-info-i0-corporateScorecard` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | 1 | will insert |
| EPROC00118 | `epl-save-c0-corporateScorecard` | N |  | `epl-save-i0-corporateScorecard` | Y | `001;002;102;103` | 1 | will insert |
| EPROC00118 | `epl-sele-c0-corporateScorecard-list` | N |  | `epl-sele-i0-corporateScorecard-list` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 1 | will insert |
| EPROC00119 | `epl-calc-c0-financial-statement-cmts-fi` | N |  | `epl-calc-i0-financial-statement-cmts-fi` | Y | `001;002` | 1 | will insert |
| EPROC00119 | `epl-info-c0-financial-statement-cmts-fi` | N |  | `epl-info-i0-financial-statement-cmts-fi` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | 1 | will insert |
| EPROC00119 | `epl-ppdf-c0-financial-statement-cmts-fi` | N |  | `epl-ppdf-i0-financial-statement-cmts-fi` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | 1 | will insert |
| EPROC00119 | `epl-pxls-c0-financial-statement-cmts-fi` | N |  | `epl-pxls-i0-financial-statement-cmts-fi` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | 1 | will insert |
| EPROC00119 | `epl-quer-c0-financial-statement-cmts-fi` | N |  | `epl-quer-i0-financial-statement-cmts-fi` | Y | `001;002` | 1 | will insert |
| EPROC00119 | `epl-save-c0-financial-statement-cmts-fi` | N |  | `epl-save-i0-financial-statement-cmts-fi` | Y | `001;002` | 1 | will insert |
| EPROC00120 | `epl-info-c0-financial-evaluation-table-fi` | N |  | `epl-info-i0-financial-evaluation-table-fi` | Y | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | 1 | will insert |
| EPROC00120 | `epl-save-c0-financial-evaluation-table-fi` | N |  | `epl-save-i0-financial-evaluation-table-fi` | Y | `001;002` | 1 | will insert |

### TB_ROLE_TASK Page Verification

| Target page | Source page | C0 exists? | C0 task rows | i0 source exists? | i0 task rows | Expected insert count |
|---|---|---|---|---|---|---:|
| EPROC00110 | EPROI00110 | Y | `E:001,002,403:信用調查_Credit Investigation_主框架` | Y | `E:001,002,403:信用調查_Credit Investigation_主框架` | 0 |
| EPROC00112 | EPROI00112 | Y | `E:001,002,403:信用調查_Credit Investigation_CBC (Banking Relationship)(共用)` | Y | `E:001,002,403:信用調查_Credit Investigation_CBC (Banking Relationship)(共用)` | 0 |
| EPROC00114 | EPROI00114 | Y | `E:001,002,102,103,403:信用調查_Credit Investigation_Collateral Assessment(共用)` | Y | `E:001,002,102,103,403:信用調查_Credit Investigation_Collateral Assessment(共用)` | 0 |
| EPROC00115 | EPROI00115 | Y | `E:001,002,403:信用調查_集團控管表Credit Investigation_Borrower group exposure(共用)` | Y | `E:001,002,403:信用調查_集團控管表Credit Investigation_Borrower group exposure(共用)` | 0 |
| EPROC00116 | EPROI00116 | Y | `E:001,002,403:信用調查_財務報表Credit Investigation_Financial Statement and  comments Highlight_GI (business owner)` | Y | `E:001,002,403:信用調查_財務報表Credit Investigation_Financial Statement and  comments Highlight_GI (business owner)` | 0 |
| EPROC00118 | EPROI00118 | Y | `E:001,002,102,103,403:信用調查_Credit Investigation_Scorecard (business owner)` | Y | `E:001,002,102,103,403:信用調查_Credit Investigation_Scorecard (business owner)` | 0 |
| EPROC00119 | EPROI00119 | Y | `E:001,002,403:信用調查_財務報表Credit Investigation_Financial Statement and Comments Highlight_FI (business owner)` | Y | `E:001,002,403:信用調查_財務報表Credit Investigation_Financial Statement and Comments Highlight_FI (business owner)` | 0 |
| EPROC00120 | EPROI00120 | Y | `E:001,002,403:信用調查_Credit Investigation_Financial Evaluation Table_FI(business owner)` | Y | `E:001,002,403:信用調查_Credit Investigation_Financial Evaluation Table_FI(business owner)` | 0 |

### 00117 Flip Verification

Original card said existing 00117 (`CsuFinancialStaffController`) should not be changed. SELECT-only precheck proved `TB_ROLE_TASK.EPROC00117` exists but the three current c0 API auth rows are absent, so this SQL now appends the three `TB_API_AUTH` rows from exact i0 templates.

| Object | Key | Exists? | Count | Source key / roles | SQL action |
|---|---|---|---:|---|---|
| TB_API_AUTH | `epl-info-c0-financial-business` | N | 0 | `epl-info-i0-financial-business` / `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | will insert |
| TB_API_AUTH | `epl-save-c0-financial-business` | N | 0 | `epl-save-i0-financial-business` / `001;002` | will insert |
| TB_API_AUTH | `epl-sele-c0-financial-list` | N | 0 | `epl-sele-i0-financial-list` / `001;002;003;101;102;103;201;202;203;301;302;401;402;404;405` | will insert |
| TB_ROLE_TASK | `EPROC00117` | Y | 1 | `E:001,002,403:信用調查_Credit Investigation_Financial Evaluation Table_GI(business owner)` | no insert needed |

### Apply Impact Summary

- `TB_API_AUTH`: 17 rows expected to insert; 15 target endpoints already exist and will be skipped; 1 target endpoint remains missing because its i0 source auth row is absent.
- `TB_ROLE_TASK`: 0 rows expected to insert; all 8 target pages already have the source-equivalent task row.
- `00117`: `TB_ROLE_TASK` exists, but all 3 current `TB_API_AUTH` endpoint rows are absent; this addendum now expects 3 `TB_API_AUTH` inserts for `EPROC00117`.

### EPROC00118 Security Close Verification List

Use this list to re-check the EPROC00118 authorization close conditions before QA regression or testing deployment.

2026-06-19 SELECT-only verification against `OVSLXLON02` found `TARGET_COUNT=0` and `SOURCE_COUNT=4`, so the four target rows still need DB apply evidence. Owner decision on 2026-06-20 also requires service-level rejection for non-AO/non-CR save roles; DB seed evidence alone is not sufficient for full security signoff.

| Target API_ID | Expected ROLE | REF_FUNCTION_ID | Source API_ID |
|---|---|---|---|
| `epl-sele-c0-corporateScorecard-list` | `001;002;003;101;102;103;201;202;203;301;302;401;404;405` | `EPROC00118` | `epl-sele-i0-corporateScorecard-list` |
| `epl-info-c0-corporateScorecard` | `001;002;003;101;102;103;201;202;203;301;302;401;402;403;404;405` | `EPROC00118` | `epl-info-i0-corporateScorecard` |
| `epl-calc-c0-corporateScorecard` | `001;002;102;103` | `EPROC00118` | `epl-calc-i0-corporateScorecard` |
| `epl-save-c0-corporateScorecard` | `001;002;102;103` | `EPROC00118` | `epl-save-i0-corporateScorecard` |

SELECT-only recheck SQL:

```sql
select api_id, role, ref_function_id
from tb_api_auth
where api_id in (
  'epl-sele-c0-corporateScorecard-list',
  'epl-info-c0-corporateScorecard',
  'epl-calc-c0-corporateScorecard',
  'epl-save-c0-corporateScorecard'
)
order by api_id;
```

Expected close condition: all four target rows exist with the `ROLE` and `REF_FUNCTION_ID` above; `epl-save-c0-corporateScorecard` also has service-level non-AO/non-CR rejection evidence and a regression test proving no scorecard, summary, or checkpoint update occurs.

### Ops Apply Checklist

1. Execute/apply only against schema `OVSLXLON02`; confirm current schema before applying and do not run against `OVSLXLON01`.
2. Idempotency check: first apply should insert 17 `TB_API_AUTH` rows and 0 `TB_ROLE_TASK` rows from the original precheck state, plus the EPROC00116 pxls reviewed-equivalent row when ppdf c0 exists; a second apply should insert 0 rows because `TB_API_AUTH` is guarded by `API_ID` and `TB_ROLE_TASK` by `PAGE_CODE,FUNCTION`.
3. The prior missing-source list is closed by **owner ratification 2026-06-25** (was RD-proposed): `epl-pxls-c0-financial-statement-comments` copies roles from the existing c0 `epl-ppdf-c0-financial-statement-comments` reviewed-equivalent row; the 00117 API auth gap is addressed by the appended insert block.

## Endpoint Mapping

| Target funcId | Target endpoint | c0 route evidence | i0 source endpoint | i0 route evidence | Role source | UNSURE? |
|---|---|---|---|---|---|---|
| EPROC00110 | `epl-info-c0-credit-investigation-tab` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:35` | `epl-info-i0-credit-investigation-tab` | `backend/src/main/java/khd/svc/epro/controller/individual/CreditInvestigationController.java:33` | exact i0 `TB_API_AUTH` row | No |
| EPROC00110 | `epl-save-c0-credit-investigation-tab` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:56` | `epl-save-i0-credit-investigation-tab` | `backend/src/main/java/khd/svc/epro/controller/individual/CreditInvestigationController.java:46` | exact i0 `TB_API_AUTH` row | No |
| EPROC00110 | `epl-confirm-c0-credit-investigation-switch` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:42` | `epl-save-c0-credit-investigation-tab` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditInvestigationController.java:56` | existing c0 save `TB_API_AUTH` row; to-be confirm route has no i0 source | No |
| EPROC00112 | `epl-info-c0-cbc-banking-relationship` | `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:44` | `epl-info-i0-cbc-banking-relationship` | `backend/src/main/java/khd/svc/epro/controller/individual/CbcBankingRelationshipController.java:47` | exact i0 `TB_API_AUTH` row | No |
| EPROC00112 | `epl-save-c0-cbc-banking-relationship` | `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:31` | `epl-save-i0-cbc-banking-relationship` | `backend/src/main/java/khd/svc/epro/controller/individual/CbcBankingRelationshipController.java:60` | exact i0 `TB_API_AUTH` row | No |
| EPROC00114 | `epl-sele-c0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCollateralAssessmentController.java:37` | `epl-sele-i0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/individual/CollateralAssessmentController.java:63` | exact i0 `TB_API_AUTH` row | No |
| EPROC00114 | `epl-info-c0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCollateralAssessmentController.java:65` | `epl-info-i0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/individual/CollateralAssessmentController.java:50` | exact i0 `TB_API_AUTH` row | No |
| EPROC00114 | `epl-save-c0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCollateralAssessmentController.java:51` | `epl-save-i0-collateral-assessment` | `backend/src/main/java/khd/svc/epro/controller/individual/CollateralAssessmentController.java:77` | exact i0 `TB_API_AUTH` row | No |
| EPROC00115 | `epl-info-c0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuBorrowerGroupExposureController.java:30` | `epl-info-i0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/individual/BorrowerGroupExposureController.java:38` | exact i0 `TB_API_AUTH` row | No |
| EPROC00115 | `epl-save-c0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuBorrowerGroupExposureController.java:37` | `epl-save-i0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/individual/BorrowerGroupExposureController.java:51` | exact i0 `TB_API_AUTH` row | No |
| EPROC00115 | `epl-sele-c0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuBorrowerGroupExposureController.java:44` | `epl-sele-i0-borrower-group-exposure` | `backend/src/main/java/khd/svc/epro/controller/individual/BorrowerGroupExposureController.java:64` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-sele-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:34` | `epl-sele-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:34` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-quer-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:47` | `epl-quer-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:47` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-info-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:60` | `epl-info-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:60` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-calc-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:73` | `epl-calc-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:73` | current c0 `TB_API_AUTH` row; exact i0 source auth missing in DB | Yes (source missing; c0 exists) |
| EPROC00116 | `epl-save-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:86` | `epl-save-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:86` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-ppdf-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:99` | `epl-ppdf-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:99` | exact i0 `TB_API_AUTH` row | No |
| EPROC00116 | `epl-pxls-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:112` | `epl-ppdf-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:99` | owner-approved reviewed equivalent: existing c0 ppdf `TB_API_AUTH` row | No |
| EPROC00117 | `epl-info-c0-financial-business` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStaffController.java:43` | `epl-info-i0-financial-business` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStaffController.java:78` | exact i0 `TB_API_AUTH` row; 00117 flip: original card said existing/no-touch, precheck proved c0 API auth missing | No |
| EPROC00117 | `epl-save-c0-financial-business` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStaffController.java:36` | `epl-save-i0-financial-business` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStaffController.java:65` | exact i0 `TB_API_AUTH` row; 00117 flip: original card said existing/no-touch, precheck proved c0 API auth missing | No |
| EPROC00117 | `epl-sele-c0-financial-list` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStaffController.java:29` | `epl-sele-i0-financial-list` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStaffController.java:52` | exact i0 `TB_API_AUTH` row; 00117 flip: original card said existing/no-touch, precheck proved c0 API auth missing | No |
| EPROC00118 | `epl-sele-c0-corporateScorecard-list` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31` | `epl-sele-i0-corporateScorecard-list` | `backend/src/main/java/khd/svc/epro/controller/individual/CorporateScorecardController.java:38` | exact i0 `TB_API_AUTH` row | No |
| EPROC00118 | `epl-info-c0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:38` | `epl-info-i0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/individual/CorporateScorecardController.java:51` | exact i0 `TB_API_AUTH` row | No |
| EPROC00118 | `epl-calc-c0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:45` | `epl-calc-i0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/individual/CorporateScorecardController.java:64` | exact i0 `TB_API_AUTH` row | No |
| EPROC00118 | `epl-save-c0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:52` | `epl-save-i0-corporateScorecard` | `backend/src/main/java/khd/svc/epro/controller/individual/CorporateScorecardController.java:77` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-quer-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:40` | `epl-quer-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:40` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-info-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:53` | `epl-info-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:53` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-calc-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:66` | `epl-calc-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:66` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-pxls-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:79` | `epl-pxls-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:79` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-ppdf-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:92` | `epl-ppdf-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:92` | exact i0 `TB_API_AUTH` row | No |
| EPROC00119 | `epl-save-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:105` | `epl-save-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:105` | exact i0 `TB_API_AUTH` row | No |
| EPROC00120 | `epl-info-c0-financial-evaluation-table-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialEvaluationTableFiController.java:26` | `epl-info-i0-financial-evaluation-table-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialEvaluationTableController.java:25` | exact i0 `TB_API_AUTH` row | No |
| EPROC00120 | `epl-save-c0-financial-evaluation-table-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialEvaluationTableFiController.java:33` | `epl-save-i0-financial-evaluation-table-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialEvaluationTableController.java:31` | exact i0 `TB_API_AUTH` row | No |

## Page Role Task Mapping

| Target page | Source page | SQL behavior |
|---|---|---|
| EPROC00110 | EPROI00110 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00112 | EPROI00112 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00114 | EPROI00114 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00115 | EPROI00115 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00116 | EPROI00116 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00118 | EPROI00118 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00119 | EPROI00119 | copy all source `TB_ROLE_TASK` rows for the page |
| EPROC00120 | EPROI00120 | copy all source `TB_ROLE_TASK` rows for the page |

## UNSURE

- No role is hard-coded or guessed; the EPROC00116 pxls addendum copies the reviewed-equivalent c0 ppdf role.
- `epl-pxls-c0-financial-statement-comments`: current c0 auth row was absent and exact i0 source auth row `epl-pxls-i0-financial-statement-comments` / `EPROI00116` was also absent in the precheck. **Owner ratified 2026-06-25** (was RD-proposed) using the existing c0 `epl-ppdf-c0-financial-statement-comments` row as the reviewed equivalent (pxls final roles == ppdf-c0).
- `epl-confirm-c0-credit-investigation-switch` (EPROC00110, to-be): no i0 source route. **Owner ratified 2026-06-25** (was RD-proposed) copying ROLE from existing c0 `epl-save-c0-credit-investigation-tab` — same mutating GI/FI switch contract / edit-audience.

## Resolved Precheck Notes

- `epl-calc-c0-financial-statement-comments`: exact i0 source auth row is absent, but current c0 auth row already exists, so the SQL safely skips it and there is no apply-time insert gap.
- `00117` current c0 API auth rows were absent in DB; source i0 rows exist, so this addendum now generates those 3 rows.

## Side Checks

- `00110`: DB verified two current c0 API auth rows exist, and `TB_ROLE_TASK.EPROC00110` exists. RD addendum adds the to-be `epl-confirm-c0-credit-investigation-switch` row by copying the existing c0 save role.
- `00112`: DB verified two current c0 API auth rows exist, and `TB_ROLE_TASK.EPROC00112` exists; SQL skips all 00112 rows.
- `00114`: DB verified three current c0 API auth rows exist, and `TB_ROLE_TASK.EPROC00114` exists; no c0 calc endpoint exists, so no calc auth row was generated.
- `00117`: current c0 routes exist at `CsuFinancialStaffController.java:29`, `:36`, `:43`; DB verified `TB_ROLE_TASK.EPROC00117` exists and the three current c0 API auth rows are absent. This addendum now generates those 3 rows from exact i0 `EPROI00117` source rows.

## Code vs Document Differences

- Current code has no corporate `epl-save-c0-financial-evaluation-staff-fi` route: `git grep -n "financial-evaluation-staff-fi" -- backend/src/main/java/khd/svc/epro/controller/corporate` returned no matches.
- Older docs still mention the removed staff-fi endpoint, for example `docs/legacy/page-mapping.md:92` and `docs/verification/verification-handoff.md:99`. SQL follows current controller code, not those stale references.
