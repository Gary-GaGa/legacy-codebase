# T24 B-group legacy parity fix findings

## Scope

- Date: 2026-06-17
- Decision: owner ruled on 2026-06-16 that T24 outbound fields follow legacy spec.
- Boundary: keep the A-5 USD/KHR-only currency decision. This pass does not change E21, G4, G10, H8, KHR rounding, or fee currency branches.
- New backend target: `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java` (new T24 build method `funcIsuT24Authorize`, `:887`; legacy `createTransferA–H` has no 1:1 method in new code)
- Legacy evidence target: `legacy-epro/JavaSource/com/cathaybk/epro/is/module/EPRO_IS0922.java`
- Commit: `3d6f446` "fix(disbursement): align t24 b-group fields with legacy", 2026-06-17 10:41 +0800; pushed to `origin/master` (HEAD `9a5a9fe`); working tree clean. Git blame confirms each fixed field below sits in this commit.

## Field Findings

| Field | Legacy behavior evidence | New status before fix | Fix | Commit |
|---|---|---|---|---|
| `A16` | `EPRO_IS0922.java:92-96` maps product to `NORMAL.LAON`; `EPRO_IS0922.java:249-254` selects that map; `EPRO_IS0922.java:496` writes A16. | New code wrote `NORMAL.LOAN` for `MTG_PRODUCT_CODE=02` and `PRODUCT_CODE=03`. | Use legacy literal `NORMAL.LAON`. | `3d6f446` |
| `C12` | `EPRO_IS0922.java:660-662` reads `TB_COLL_VALUE_INFO.SUG_VAL`; `EPRO_IS0922.java:729` writes C12. | New code read `SUG_VAL` from the C-row collateral map, which comes from `TB_COLL_INFO` in this T24 path. | Read `TB_COLL_VALUE_INFO` through `TBCollValueInfoRepository.findByApplicationNoAndCollDataSeq(...)`. | `3d6f446` |
| `C13` | `EPRO_IS0922.java:642` formats `TB_LON_SUMMARY_INFO.DECISION_DATE`; `EPRO_IS0922.java:650` assigns it; `EPRO_IS0922.java:729` writes C13. | New code used `TB_T24_MAIN_BORROWER_INFO.CHECK_DATE`. | Use `lonSummaryInfo.DECISION_DATE`. | `3d6f446` |
| `A15` | `EPRO_IS0922.java:307` reads `HOUSING_PROJECT_CODE` with default `""`; `EPRO_IS0922.java:493-494` writes A15. | New code converted blank to `N/A`. | Preserve blank as `""`. | `3d6f446` |
| `G11`/`G12` | `EPRO_IS0922.java:1031-1049` maps remarks: `00 Registration Fee`, `01 De-register fee`, `02 Due diligent fee`, `03 Ownership change`, `90 LAW_FIRM_90_OTHER_REMARK`; `EPRO_IS0922.java:1096` writes G11/G12. | New code used `Legal fee`, `Other fee`, and `Special fee` for `02/03/90`. | Match legacy remarks and keep note numbers. | `3d6f446` |
| `A31` | `EPRO_IS0922.java:301-302` takes the last 16 chars of `AGREEMENT_NO`; `EPRO_IS0922.java:505` writes A31. | New code wrote the full agreement number. | Write `StringUtils.right(agreementNo, 16)`. | `3d6f446` |
| `G7` | `EPRO_IS0922.java:1072-1073` takes the last 16 chars of `AGREEMENT_NO`; `EPRO_IS0922.java:1093-1094` writes G7. | New code wrote the full agreement number. | Write `StringUtils.right(agreementNo, 16)`. | `3d6f446` |
| row ending | `EPRO_IS0922.java:70` defines `CHANGE_LINE = "\r\n"`; `EPRO_IS0922.java:176`, `555`, `1052`, `1170` join T24 records with CRLF. | New code appended records with `\n`, and E row added `\n` as an extra joined field. | Add a shared CRLF record appender; remove embedded newline fields and trailing per-record `\n`. | `3d6f446` |
| `C26` | `EPRO_IS0922.java:529-550` builds B/C per `COLL_DATA_SEQ`; `EPRO_IS0922.java:617-620` passes that seq into C; `EPRO_IS0922.java:702-716` joins title deeds only for that collateral; `EPRO_IS0922.java:738` writes C26. | New code pre-merged all title deeds and put them into every C row. | Filter title deeds by current row `COLL_DATA_SEQ` before writing C26. | `3d6f446` |
| `E21` | `EPRO_IS0922.java:934-940` converts all non-USD with central rate. | New code remains USD/KHR only, other currency -> `0`. | No change per A-5 owner keep: non-USD-non-KHR path is by-design unreachable. | keep |
| `G4`/`G10`/`H8` | `EPRO_IS0922.java:1076-1085`, `1090-1094`, `1133-1138`, `1154-1156` show legacy currency/exchange-rate fields. | New code still has the USD/KHR-era source/branch behavior. | No change in this pass per A-5 boundary and RD data-constraint follow-up. | keep |

## Verification Notes

- KHR branch and fee rounding code were intentionally left unchanged.
- `SummaryServiceImpl` now centralizes T24 line joining through CRLF and avoids adding newline as a data field.
- Full verification requires `mvn package` from `backend/`.
