# GET Body Contract Sweep Findings

> Scope: grep / inventory only. No source changes. Date: 2026-06-15.
> Task source: `docs/build-tasks/get-body-contract-sweep.md`.

## Summary

- FE direct `apiGetRequestWithBody(...)` call sites: 0.
- FE equivalent GET-with-body call sites via `apiGetRequestForBlob(...)`: 2.
- BE `GET` handler with `@RequestBody`: 3.
- Cross-paired `body-missing` risks: 2.
- Additional method-contract mismatch risk: 1.
- Fixed sample: 00600 search options is already aligned as GET query; not counted as a remaining change location.

## FE GET-Body Inventory

| # | FE file:line | Endpoint | Body source | Pairing status |
|---|---|---|---|---|
| 1 | `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/service/api.service.ts:32-35` | `epl-case-mis-report-scorecard-export-excel` | `postData` from `exportExcel()` / `searchCondition` at `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/scorecard-report.component.ts:104-111` | Paired with BE GET + `@RequestBody`; body-missing risk. |
| 2 | `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/service/api.service.ts:41-44` | `epl-case-mis-report-scorecard-export-pdf` | `postData` from `exportPDF()` / `searchCondition` at `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/scorecard-report.component.ts:114-121` | Paired with BE GET + `@RequestBody`; body-missing risk. |

Supporting grep:

- `frontend/src/app/core/services/api/app-api.service.ts:19-22` defines `apiGetRequestWithBody` as a GET-with-body wrapper, but no business call site was found under `frontend/src/app`.
- `frontend/src/app/core/services/api/app-api.service.ts:29-35` defines `apiGetRequestForBlob`, which uses `HttpClient.request('GET', ..., { body })`.

## BE GET + RequestBody Inventory

| # | BE file:line | Endpoint | Request body DTO | FE pairing | Risk |
|---|---|---|---|---|---|
| 1 | `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java:38-39` | `epl-case-query-reviseditem` | `QueryReviseditemRequest`, `applicationNo` at `backend/src/main/java/khd/svc/epro/dto/request/common/revisedItem/QueryReviseditemRequest.java:15-18` | FE currently calls POST body at `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:18-24` | Method mismatch / likely 405; if invoked as GET without body, body-missing risk. |
| 2 | `backend/src/main/java/khd/svc/epro/controller/common/ScorecardReportController.java:55-56` | `epl-case-mis-report-scorecard-export-pdf` | `ReportScoredCardListRequest`, filters at `backend/src/main/java/khd/svc/epro/dto/request/common/scorecardReport/ReportScoredCardListRequest.java:12-36` | FE GET body at `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/service/api.service.ts:41-44` | Exact GET-body contract mismatch; intermediaries/clients may drop body. |
| 3 | `backend/src/main/java/khd/svc/epro/controller/common/ScorecardReportController.java:73-74` | `epl-case-mis-report-scorecard-export-excel` | `ReportScoredCardListRequest`, filters at `backend/src/main/java/khd/svc/epro/dto/request/common/scorecardReport/ReportScoredCardListRequest.java:12-36` | FE GET body at `frontend/src/app/pages/mis-report/sub-pages/scorecard-report/service/api.service.ts:32-35` | Exact GET-body contract mismatch; intermediaries/clients may drop body. |

## Cross-Pair Classification

| # | Endpoint | Current contract | Legacy / semantic evidence | Classification | Minimal next-step direction |
|---|---|---|---|---|---|
| 1 | `epl-case-mis-report-scorecard-export-excel` | FE GET with body; BE `@GetMapping` + `@RequestBody`. | Legacy export actions pass request parameters via `VOTool.requestToMap(req)` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0640.java:212-216` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0640.java:247-251`; module export reuses query filters at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0640_mod.java:243-283` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0640_mod.java:318-358`. DTO requires multiple filters (`scorecard`, `analysis`, date range, paging) at `backend/src/main/java/khd/svc/epro/dto/request/common/scorecardReport/ReportScoredCardListRequest.java:12-36`. | POST body | Convert export contract to POST body on both sides; keep query/list semantics aligned with current query-list POST. |
| 2 | `epl-case-mis-report-scorecard-export-pdf` | FE GET with body; BE `@GetMapping` + `@RequestBody`. | Legacy export actions pass request parameters via `VOTool.requestToMap(req)` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0640.java:134-141` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0640.java:173-180`; module export reuses query filters at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0640_mod.java:149-161` and `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0640_mod.java:200-212`. DTO requires multiple filters at `backend/src/main/java/khd/svc/epro/dto/request/common/scorecardReport/ReportScoredCardListRequest.java:12-36`. | POST body | Convert export contract to POST body on both sides; avoid GET body for generated-file requests. |
| 3 | `epl-case-query-reviseditem` | BE GET + `@RequestBody`; FE already POST body to same endpoint. | Legacy init query receives `APPLICATION_NO` from request parameter at `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0800.java:69-78`; module validates and queries by `APPLICATION_NO` at `legacy-epro/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java:110-119`. New FE sends body via POST at `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts:18-24`. | POST body | Minimal alignment is changing BE mapping to POST while keeping `@RequestBody`; alternatively GET query would match simple `applicationNo` semantics but would require FE change and is not the smallest contract fix. |

## Fixed Template Reference

| Endpoint | Current evidence | Why not counted |
|---|---|---|
| `epl-case-search-options` | BE is GET + `@ModelAttribute` at `backend/src/main/java/khd/svc/epro/controller/common/SearchController.java:38-39`; FE builds query string and calls GET at `frontend/src/app/pages/search/service/api.service.ts:24-34`. | Already follows the 00600 fix pattern: no body on GET. Historical fix documented at `docs/build-tasks/done/00600-search-options-fix.md:34-45`. |
