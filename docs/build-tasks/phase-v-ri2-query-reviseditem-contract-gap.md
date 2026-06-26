# RD Contract Gap — EPROZ00800 RI-2 query revised item required options

> Status: RD_READY_CONTRACT_GAP  
> Created: 2026-06-26  
> Source: Phase V API selfverify harness v1.1, read-only runtime run  
> Scope: report only in this card; product code change must go through RD flow

## Problem assessment
- `docs/specs/srs/EPROZ00800/openapi.yaml` defines `QueryRevisedItemResponse.data.revisedType` and `data.revisedTypeSize` as required fields.
- Phase V RI-2 uses an application that exists in `TB_LON_SUMMARY_INFO` and has no row in `TB_REVISED_ITEM`.
- Runtime response is a success data envelope with blank item fields, but it does not include `revisedType` or `revisedTypeSize`.
- This is no longer an auth or infra failure. The harness used role `403`, serviceability smoke passed, and the endpoint returned HTTP 200 + `code=0000`.

## Evidence
- Harness report: `docs/verification/phase-v-api-selfverify-report.md`
- Response dump: `docs/verification/phase-v-api-selfverify-responses/RI-2-response.json`
- Fixture:
  - RI-2 applicationNo: `<fixture-B 空revised-item>`（真案號留本機證據、不進 repo）
  - `TB_REVISED_ITEM` row count: `0`
  - revised item option SQL count: `9`
- Actual response excerpt:
  - `code`: `0000`
  - `message`: `Success`
  - `data.lonTypeCode`: `01`
  - `data.secureAttribute`: `S`
  - `data.item1`-`data.item14`: blank strings
  - `data.reasonMemo`: blank string
  - missing: `data.revisedType`
  - missing: `data.revisedTypeSize`

## Expected behavior
- For an existing case with no `TB_REVISED_ITEM` row, `/epl-case-query-reviseditem` should still return a success data envelope.
- The response should include the required revised item option dictionary and size:
  - `data.revisedType`
  - `data.revisedTypeSize`
- `revisedTypeSize` should match the read-only option SQL count for `MSG_CODE='REVISED_ITEM'` and the selected langType.

## Recommended approach
- Enter RD flow for `EPROZ00800`.
- Keep endpoint method and request shape aligned with the current SRS/openapi (`GET` query by `applicationNo`).
- Fix product behavior only after RD review confirms the current SRS required fields remain authoritative.

## Trade-offs
- Treating this as a harness path bug is now ruled out: the harness reads `data.revisedType`, and the dumped `data` object lacks that field.
- Treating this as an invalid fixture is also ruled out: the endpoint returned a success data envelope for an existing case, and DB row count for `TB_REVISED_ITEM` is zero.
- Product fix may need to decide the authoritative langType for option labels; current harness uses `PHASE_V_RI_OPTION_LANG_TYPE|en_US`.

## Minimal viable next step
- Assign RD owner to reconcile `QueryRevisedItemResponse` implementation with `docs/specs/srs/EPROZ00800/openapi.yaml`.
- Re-run `tools/phase-v-run.ps1` after the RD fix; RI-2 should pass with `row=0 options=9`.
