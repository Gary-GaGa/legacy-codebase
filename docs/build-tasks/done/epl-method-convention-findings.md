# epl-* Method Convention Findings

Status: 等人審

## Scope

- Task type: A 類 read-only recon.
- Repo state check: `git status --short --branch` returned `## master...origin/master`; no `git pull` was run.
- Source scope: 75 controller files under `backend/src/main/java/**/*Controller.java`; `backend/src/main/java/khd/svc/epro/task/controller/TaskController.java` has no `epl-*` mapping, so all counted `epl-*` endpoints come from `backend/src/main/java/khd/svc/epro/controller/**/*.java`.
- Counting rule: one mapped URL string counts as one endpoint. Multiple paths in one annotation count separately.
- Method resolution rule: method-level `@GetMapping/@PostMapping` wins; otherwise method-level `@RequestMapping(... method = RequestMethod.X)` wins; otherwise class-level `@RequestMapping(method = RequestMethod.X)` is inherited.
- Query-like bucket:
  - strict token set: `query|list|sele|info`, case-insensitive.
  - broad token set used for the headline count: strict set plus legacy abbreviation `quer`, because current endpoints include `epl-quer-*` names.

## Conclusion

全站沒有可證明的「RPC 一律 POST」政策：backend `epl-*` endpoints 目前是高度偏向 POST（280/282），但仍有 2 個 GET endpoint；也不是 `query=GET / mutation=POST`，因為 broad query-like endpoints 中 132/133 是 POST。

## Statistics

### All `epl-*` Endpoints

| HTTP method | Count |
|---|---:|
| POST | 280 |
| GET | 2 |
| Total | 282 |

### Query-Like Endpoints

Broad query-like token set: `query|quer|list|sele|info`.

| HTTP method | Count |
|---|---:|
| POST | 132 |
| GET | 1 |
| Total | 133 |

Strict query-like token set: `query|list|sele|info`.

| HTTP method | Count |
|---|---:|
| POST | 128 |
| GET | 1 |
| Total | 129 |

### Requested Token Cross-Check

Counts below are token occurrence buckets by endpoint name; one endpoint may match more than one token.

| Token | Total | POST | GET |
|---|---:|---:|---:|
| `query` | 12 | 11 | 1 |
| `list` | 36 | 36 | 0 |
| `sele` | 37 | 37 | 0 |
| `info` | 67 | 67 | 0 |

The broad count adds four `quer-only` endpoints that do not match the strict token set:

| HTTP method | Endpoint | Evidence |
|---|---|---|
| POST | `/epl-quer-c0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:40` |
| POST | `/epl-quer-c0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementController.java:47` |
| POST | `/epl-quer-i0-financial-statement-cmts-fi` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementCmtsFiController.java:40` |
| POST | `/epl-quer-i0-financial-statement-comments` | `backend/src/main/java/khd/svc/epro/controller/individual/FinancialStatementController.java:47` |

### `init-query` Same-Type Endpoints

Only one `init-query` endpoint was found in backend controllers, and it is POST.

| HTTP method | Endpoint | Evidence |
|---|---|---|
| POST | `/epl-case-comparison-table-of-loans-to-related-party-in-CUBC-init-query` | `backend/src/main/java/khd/svc/epro/controller/common/ComparisonTableOfLoansToRelatedPartyInController.java:34` |

## Evidence

### POST-Dominant Convention Evidence

Many controllers declare POST at class level and then use method-level `@RequestMapping(value = "...")` without repeating `method`; those endpoints resolve to POST under Spring mapping rules.

| Evidence | Meaning |
|---|---|
| `backend/src/main/java/khd/svc/epro/controller/common/ApplicationCancelReportController.java:19` | class-level `@RequestMapping(method = RequestMethod.POST)` |
| `backend/src/main/java/khd/svc/epro/controller/common/ApplicationCancelReportController.java:33` | `/epl-sele-dept-loantype-canreason` inherits POST |
| `backend/src/main/java/khd/svc/epro/controller/common/ApplicationCancelReportController.java:47` | `/epl-list-cancelreport` inherits POST |
| `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:17` | class-level `@RequestMapping(method = RequestMethod.POST)` |
| `backend/src/main/java/khd/svc/epro/controller/corporate/CbcBankingCorpRelationshipController.java:44` | `/epl-info-c0-cbc-banking-relationship` inherits POST |
| `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:31` | class-level `@RequestMapping(method = RequestMethod.POST)` |
| `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:45` | `/epl-sele-isu-data-input` inherits POST |
| `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:58` | `/epl-info-isu-data-input` inherits POST |

Direct POST mappings also appear throughout the controllers.

| Endpoint | Evidence |
|---|---|
| `/epl-auth-mis-authorization` | `backend/src/main/java/khd/svc/epro/controller/common/AuthorizationController.java:70` |
| `/epl-case-application-delete-report-query-list` | `backend/src/main/java/khd/svc/epro/controller/common/ApplicationDeleteReportController.java:48` |
| `/epl-info-isu-cr-dec` | `backend/src/main/java/khd/svc/epro/controller/individual/CreditEvalAndCreditDecisionController.java:188` |
| `/epl-info-i0-individual-scorecard` | `backend/src/main/java/khd/svc/epro/controller/individual/IndividualScoreCardController.java:54` |

### Non-POST Exceptions

Only two `epl-*` endpoints resolve to GET.

| HTTP method | Endpoint | Evidence |
|---|---|---|
| GET | `/epl-case-query-reviseditem` | `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:38` |
| GET | `/epl-case-search-options` | `backend/src/main/java/khd/svc/epro/controller/common/SearchController.java:38` |

The first GET exception is query-like; the second does not match the requested query-like tokens.

### Query-Like POST Evidence

The query-like bucket is not GET-led. Representative query/list/sele/info endpoints use POST or inherit POST:

| Token | Endpoint | HTTP method | Evidence |
|---|---|---|---|
| `query` | `/epl-case-CAD-onhandstatus-query-list` | POST | `backend/src/main/java/khd/svc/epro/controller/common/CADOnHandStatusController.java:31` |
| `query` | `/epl-case-document-checklist-table-query` | POST | `backend/src/main/java/khd/svc/epro/controller/common/DocumentChecklistController.java:44` |
| `list` | `/epl-list-casedistribution` | POST | `backend/src/main/java/khd/svc/epro/controller/common/CaseDistributionController.java:38` |
| `list` | `/epl-list-search` | POST | `backend/src/main/java/khd/svc/epro/controller/common/SearchController.java:52` |
| `sele` | `/epl-sele-tlod-report` | POST | `backend/src/main/java/khd/svc/epro/controller/common/TlodReportController.java:34` |
| `sele` | `/epl-sele-isu-data-input` | POST | `backend/src/main/java/khd/svc/epro/controller/individual/DataInputController.java:45` |
| `info` | `/epl-info-related-party` | POST | `backend/src/main/java/khd/svc/epro/controller/common/RelatedPartyInfoController.java:36` |
| `info` | `/epl-info-isu-loan-condition` | POST | `backend/src/main/java/khd/svc/epro/controller/individual/LoanConditionController.java:107` |

## Policy Assessment

| Candidate policy | Evidence-backed assessment |
|---|---|
| `RPC 一律 POST` | Not supported as a whole-site policy because 2 `epl-*` endpoints are GET. |
| `query=GET / mutation=POST` | Not supported because broad query-like endpoints are 132 POST vs 1 GET. |
| Mostly POST with local exceptions | Supported by current evidence: 280/282 endpoints are POST, including almost all query-like endpoints. |

## Self-Verification

- Re-read `docs/process/orchestration-playbook.md` §4 and §6 before recon; this artifact stays in A 類 read-only findings scope and does not make RP9 architecture/domain judgment.
- Parsed all `backend/src/main/java/**/*Controller.java` controller source; skipped commented-out mappings.
- Cross-checked method resolution with class-level POST examples, direct `@PostMapping`, direct `@GetMapping`, and explicit `RequestMethod.GET/POST`.
- Cross-checked all non-POST results: only `RevisedItemController.java:38` and `SearchController.java:38` were reported.
- No build/test was run because this task is read-only source reconnaissance plus findings documentation.
