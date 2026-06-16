# Bible Gap Recon Findings

Date: 2026-06-15

Scope: read-only source recon for `EPROZ00670`, `EPROISU0180`, `EPROISU0182`, `EPROISU0183`, and `EPROISU0184`, including IS/IU/CS/CU variants and Jasper report assets. Product code was not modified.

## Conclusion

No new formal audit row is added.

- `EPROZ00670` is not present in old source as a JSP, trx action, dispatcher target, Java report module, or Jasper report id.
- `EPROISU0180` is not an independent page; it is a credit-proposal report generator invoked from existing z0 ToDo/Search actions and is already carried by existing M8 rows.
- `EPROISU0182`, `EPROISU0183`, and `EPROISU0184` are not independent pages; they are Summary-page report downloads under existing `EPROIS_0922/EPROIS0922.jsp` and are already carried by the existing M2 `EPROISU0922` row.

Therefore the audit row totals do not change.

## Search Boundary

Searched old-source page/action patterns under `legacy-epro/WebContent/html/cathaybk/system/epro`, `legacy-epro/JavaSource/com/cathaybk/epro`, and `legacy-epro/WebContent/reports/xml/EPRO`:

- `EPROZ00670`, `EPROZ0_0670`, `EPROZ0067`, `0670`
- `EPROIS_0180`, `EPROIS0180`, `EPROISU0180`, and matching IU/CS/CU page-style variants
- `EPROIS_0182`, `EPROIS0182`, `EPROISU0182`, and matching IU/CS/CU page-style variants
- `EPROIS_0183`, `EPROIS0183`, `EPROISU0183`, and matching IU/CS/CU page-style variants
- `EPROIS_0184`, `EPROIS0184`, `EPROISU0184`, and matching IU/CS/CU page-style variants
- Jasper/report ids `EPRO_IS0180`, `EPRO_IU0180`, `EPRO_CS0180`, `EPRO_CU0180`, `EPRO_IS0182`, `EPRO_IS0183`, `EPRO_IS0184`

The page-style JSP/trx searches for `0180/0182/0183/0184` returned no independent page hits. The `EPROZ00670/0670` search returned no hits in JSP, Java, XML/properties/text, SQL, JS, or JRXML files.

## Findings

### BIBLE-GAP-1: `EPROZ00670`

Conclusion: not found in old source. Bible anchor should converge to the existing `EPROISU0181` / TLOD report row, not create a new z0 row.

Evidence:

- Bible describes `EPROZ00670` only as common report query and says the known query target is TLOD: `docs/specs/bible/bible-eproposal.md:340`, `docs/specs/bible/bible-eproposal.md:356`.
- Existing page mapping has `EPROISU0181` as TLOD Report and no `EPROZ00670` z0 catalog entry: `docs/legacy/page-mapping.md:27`, `docs/legacy/page-mapping.md:58`, `docs/legacy/page-mapping.md:66`.
- Old z0 source enumeration has exactly 18 JSP rows and stops at `EPROZ00660` before `EPROZ00700`; no `EPROZ00670` row exists: `docs/build-tasks/refactor-audit/M8-z0.md:9`.
- Existing z0 exhaustion statement found no remaining z0 JSP partials or extra trx classes: `docs/build-tasks/refactor-audit/M8-z0.md:11`.
- Runtime dispatcher is generic and does not register an `EPROZ00670` target: `legacy-epro/WebContent/WEB-INF/web.xml:57`, `legacy-epro/WebContent/WEB-INF/web.xml:70`, `legacy-epro/WebContent/WEB-INF/web.xml:71`.
- The only old-source TLOD carrier is the existing `0181` row: `docs/build-tasks/refactor-audit/M2-is.md:38`.

Disposition: close `BIBLE-GAP-1` as absent old-source page/action/report id; converge Bible wording to `EPROISU0181` / TLOD.

### BIBLE-GAP-2: `EPROISU0180`

Conclusion: report assets and generator modules exist, but no independent JSP/trx page exists. The audit carrier remains the existing M8 ToDo/Search report-action evidence; no new row is added.

Evidence:

- Old ToDo imports all IS/IU/CS/CU credit-proposal report modules: `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:15`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:16`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:17`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:18`.
- Old ToDo `downloadFile` dispatches by `TYPE` to `EPRO_CS0180`, `EPRO_CU0180`, `EPRO_IS0180`, and `EPRO_IU0180`: `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:224`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:233`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:235`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:237`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java:239`.
- Old Search has the same report-module imports and `downloadFile` dispatch: `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:14`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:15`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:16`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:17`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:208`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:217`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:219`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:221`, `legacy-epro/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0600.java:223`.
- Old report generator classes exist for all variants: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0180.java:60`, `legacy-epro/JavaSource/com/cathaybk/epro/iu/module/EPRO_IU0180.java:56`, `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPRO_CS0180.java:57`, `legacy-epro/JavaSource/com/cathaybk/epro/cu/module/EPRO_CU0180.java:55`.
- Old Jasper assets exist as report ids, not JSP pages: `legacy-epro/WebContent/reports/xml/EPRO/EPRO_IS0180.jrxml:2`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_IU0180.jrxml:2`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_CS0180.jrxml:2`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_CU0180.jrxml:2`.
- Existing audit carrier rows already include credit proposal report API evidence: `docs/build-tasks/refactor-audit/M8-z0.md:17`, `docs/build-tasks/refactor-audit/M8-z0.md:25`.
- New FE/BE report endpoints exist: `frontend/src/app/core/services/report/report.service.ts:96`, `frontend/src/app/core/services/report/report.service.ts:101`, `backend/src/main/java/khd/svc/epro/controller/individual/CreditProposalController.java:24`, `backend/src/main/java/khd/svc/epro/controller/individual/CreditProposalController.java:31`.

Disposition: close `BIBLE-GAP-2` as existing report action covered by M8, not an independent Bible page.

### BIBLE-GAP-3: `EPROISU0182`

Conclusion: report id exists, but it is a Summary-page download under `EPROIS_0922`; Bible anchor should converge to the existing `EPROISU0922` row.

Evidence:

- Old Summary JSP calls `EPROIS_0922/downloadFile` for Summary PDF: `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:363`, `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:366`.
- Old `EPROIS_0922` imports and invokes `EPRO_IS0182`: `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:16`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:102`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:111`.
- Old report generator/JRXML exists as a report asset: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0182.java:60`, `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0182.java:66`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_IS0182.jrxml:2`.
- Existing audit carrier row already includes the old Summary download action and new FE/BE report endpoints: `docs/build-tasks/refactor-audit/M2-is.md:59`.
- New FE/BE report endpoints are under Summary/disbursement: `frontend/src/app/pages/case-edition/sub-pages/individual/disbursement-process/components/summary/summary.component.ts:135`, `frontend/src/app/core/services/report/report.service.ts:114`, `frontend/src/app/core/services/report/report.service.ts:117`, `backend/src/main/java/khd/svc/epro/controller/individual/ReportController.java:36`.

Disposition: close `BIBLE-GAP-3` as report id carried by `EPROISU0922`; no new audit row.

### BIBLE-GAP-4: `EPROISU0183`

Conclusion: report id exists, but it is a Summary-page download under `EPROIS_0922`; Bible anchor should converge to the existing `EPROISU0922` row.

Evidence:

- Old Summary JSP calls `EPROIS_0922/downloadTransResult` for Transaction Result: `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:399`, `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:402`.
- Old `EPROIS_0922` imports and invokes `EPRO_IS0183`: `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:17`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:261`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:270`.
- Old report generator/JRXML exists as a report asset: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0183.java:53`, `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0183.java:59`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_IS0183.jrxml:2`.
- Existing audit carrier row already includes the old Transaction Result action and new FE/BE report endpoints: `docs/build-tasks/refactor-audit/M2-is.md:59`.
- New FE/BE report endpoints are under Summary/disbursement: `frontend/src/app/pages/case-edition/sub-pages/individual/disbursement-process/components/summary/summary.component.ts:155`, `frontend/src/app/core/services/report/report.service.ts:122`, `frontend/src/app/core/services/report/report.service.ts:127`, `backend/src/main/java/khd/svc/epro/controller/individual/ReportController.java:24`.

Disposition: close `BIBLE-GAP-4` as report id carried by `EPROISU0922`; no new audit row.

### BIBLE-GAP-5: `EPROISU0184`

Conclusion: report id exists, but it is a Summary-page download under `EPROIS_0922`; Bible anchor should converge to the existing `EPROISU0922` row.

Evidence:

- Old Summary JSP calls `EPROIS_0922/downloadMsgCodeRecord` for Message Code Record: `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:406`, `legacy-epro/WebContent/html/cathaybk/system/epro/is/EPROIS_0900/EPROIS0922_JS.jsp:409`.
- Old `EPROIS_0922` imports and invokes `EPRO_IS0184`: `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:18`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:302`, `legacy-epro/JavaSource/com/cathaybk/epro/is/trx/EPROIS_0922.java:311`.
- Old report generator/JRXML exists as a report asset: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0184.java:37`, `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0184.java:43`, `legacy-epro/WebContent/reports/xml/EPRO/EPRO_IS0184.jrxml:2`.
- Existing audit carrier row already includes the old Message Code Record action and new FE/BE report endpoints: `docs/build-tasks/refactor-audit/M2-is.md:59`.
- New FE/BE report endpoints are under Summary/disbursement: `frontend/src/app/pages/case-edition/sub-pages/individual/disbursement-process/components/summary/summary.component.ts:162`, `frontend/src/app/core/services/report/report.service.ts:132`, `frontend/src/app/core/services/report/report.service.ts:137`, `backend/src/main/java/khd/svc/epro/controller/individual/ReportController.java:30`.

Disposition: close `BIBLE-GAP-5` as report id carried by `EPROISU0922`; no new audit row.

## Audit File Impact

- `M2-is.md`: no row added; existing `EPROIS_0922/EPROIS0922.jsp` row remains the carrier for `0182/0183/0184`.
- `M8-z0.md`: no row added; existing `EPROZ0_0100/EPROZ00100.jsp` and `EPROZ0_0600/EPROZ00600.jsp` rows remain the carrier for `0180`.
- `master.md`: no total change.
- `diff-vs-inventory.md`: Bible completeness rows updated from open `BIBLE-GAP` items to recon-closed dispositions.
