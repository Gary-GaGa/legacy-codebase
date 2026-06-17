# Diff Vs Feature Inventory

Status: **SUPERSEDED by 2026-06-17 drift re-check**（見 `drift-recheck-2026-06-17.md`）——06-11 的 code-state 快照已過期（Phase G/06-16 後 13/16 DIFF 已解）。**勿照本檔 §4 的 `[ ]` 回填**（會把 Phase G 成果反砍成 regression）。原：S-final complete on 2026-06-11；BIBLE-GAP recon 2026-06-15.

Input note: required QC memo `docs/build-tasks/refactor-audit-qc.md` is not present in the workspace and is not tracked by `git ls-files`; searches for `F-1` through `F-5` under `docs/` returned no QC log. This report maps the one QC item named in the task prompt, `F-1 企金 FE 缺口`, to DIFF-001 and marks `F-2` through `F-5` as `QC-INPUT-UNFOUND` instead of guessing.

## 1. 總量表

Row-level counts are copied from `docs/build-tasks/refactor-audit/master.md:55` through `docs/build-tasks/refactor-audit/master.md:64` and each module small-total line. `碼在` means both FE and BE are code-backed for the audit row. M1 and M9 are action/group-level audits; the page-level conversion column is for inventory comparison only and does not change the row-level status totals.

| Module | Audit file | Audit row total | Page-level conversion | 碼在 | 🟡 | 🔴 | 🚫 | UNFOUND | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| M1 `zz` | `M1-zz.md` | 4 | 1 | 4 | 0 | 0 | 0 | 0 | Action-level: one login JSP plus three shared address AJAX actions (`M1-zz.md:9`, `M1-zz.md:10`, `M1-zz.md:11`, `M1-zz.md:12`). |
| M2 `is` | `M2-is.md` | 34 | 34 | 31 | 1 | 0 | 1 | 1 | A+B total from `M2-is.md:40` and `M2-is.md:61`. |
| M3 `iu` | `M3-iu.md` | 20 | 20 | 18 | 0 | 0 | 0 | 2 | `M3-iu.md:37`. |
| M4 `cs` | `M4-cs.md` | 20 | 20 | 7 | 0 | 0 | 1 | 12 | `M4-cs.md:59`; S4b four-anchor recheck kept all 12 FE rows UNFOUND. |
| M5 `cu` | `M5-cu.md` | 17 | 17 | 7 | 0 | 0 | 0 | 10 | `M5-cu.md:54`; S4b four-anchor recheck kept all 10 FE rows UNFOUND. |
| M6 `i0` | `M6-i0.md` | 22 | 22 | 22 | 0 | 0 | 0 | 0 | `M6-i0.md:52`; old `01xx` and `02xx` variants are separate rows. |
| M7a `c0` | `M7a-c0-00110-00115.md` | 10 | 10 | 6 | 2 | 0 | 0 | 2 | `M7a-c0-00110-00115.md:26`. |
| M7b `c0` | `M7b-c0-00116-00120-rest.md` | 10 | 10 | 8 | 2 | 0 | 0 | 0 | `M7b-c0-00116-00120-rest.md:28`. |
| M8 `z0` | `M8-z0.md` | 18 | 18 | 12 | 6 | 0 | 0 | 0 | `M8-z0.md:36`. |
| M9 common/demo | `M9-common.md` | 11 | 16 | 1 | 0 | 0 | 0 | 10 | Action/group-level: layout/error/demo/admin groups; page conversion counts distinct legacy JSP/surface files represented by the 11 rows (`M9-common.md:11` through `M9-common.md:21`). |
| **System total** |  | **166** | **168** | **116** | **11** | **0** | **2** | **37** | Page-level conversion adjusts only M1/M9; status totals stay row-level. |

## 2. 差異清單

Only differences are listed. Every item points back to audit module line(s); `feature-inventory.md` is the diff target, not evidence for implementation.

| ID | Type | Inventory row | Audit result | Module evidence | Suggested disposition |
|---|---|---|---|---|---|
| DIFF-001 / QC F-1 | inventory green but audit non-green / status conflict | `feature-inventory.md:27`, `feature-inventory.md:61` through `feature-inventory.md:72` mark CS/CU `EPROCSU0150/0160/0170/0171/0172/0173` FE as done or verification-only. | Audit finds corporate CS/CU BE code-backed but FE UNFOUND for the main collateral/loan-condition/credit-decision/LC/approved-condition/old-eval pages and popups. This is the headline corporate FE gap. | CS rows: `M4-cs.md:19`, `M4-cs.md:20`, `M4-cs.md:22`, `M4-cs.md:23`, `M4-cs.md:24`, `M4-cs.md:25`, `M4-cs.md:26`, `M4-cs.md:27`, `M4-cs.md:28`, `M4-cs.md:29`, `M4-cs.md:30`, `M4-cs.md:31`; CU rows: `M5-cu.md:19`, `M5-cu.md:20`, `M5-cu.md:21`, `M5-cu.md:22`, `M5-cu.md:23`, `M5-cu.md:24`, `M5-cu.md:25`, `M5-cu.md:26`, `M5-cu.md:27`, `M5-cu.md:28`. | Backfill inventory M4/M5 from green to "BE code-backed / FE UNFOUND for listed CSU pages"; open/keep FE gap card. |
| DIFF-002 | audit non-migration row vs inventory ambiguity | `feature-inventory.md:75` says `EPROIS_0140` Property Info is not developed; `feature-inventory.md:44` uses `EPROISU0140` for Collateral Provider. | Audit confirms old `EPROIS_0140` is 🚫 not migrated, but old `EPROIS_0240` remains UNFOUND and is not covered by the non-migration note. | `M2-is.md:19`, `M2-is.md:20`. | Keep `EPROIS_0140` as not migrated; add an explicit `EPROIS_0240` row or owner decision. |
| DIFF-003 | inventory missing old pages | M3 `iu` is shown as merged into `EPROISU*` and verification-only (`feature-inventory.md:26`, `feature-inventory.md:38` through `feature-inventory.md:58`). | Audit finds IU Property Info old pages with no new FE/BE correspondence. | `M3-iu.md:22`, `M3-iu.md:23`. | Add `EPROIU_0140` and `EPROIU_0240` as UNFOUND, or record an explicit non-migration decision. |
| DIFF-004 | status conflict | Inventory marks `EPROISU0920/0921/0922` BE as 🔴 under disbursement (`feature-inventory.md:56`, `feature-inventory.md:57`, `feature-inventory.md:58`, details at `feature-inventory.md:131` through `feature-inventory.md:139`). | Audit shows 0920 and 0921 are code-backed; 0922 is 🟡 because the authorize chain still hits exchange-rate/T24/report mismatches. | `M2-is.md:56`, `M2-is.md:57`, `M2-is.md:58`, `M2-is.md:59`. | Scope page status to `0920=碼在`, `0921=碼在`, `0922=🟡`; keep the cross-page disbursement domain/T24 risk separately. |
| DIFF-005 | inventory total/granularity mismatch | Inventory M6 says 42 (`feature-inventory.md:29`) while the page table lists 11 new `EPROI00*` pages (`feature-inventory.md:81` through `feature-inventory.md:91`). | Audit counts 22 old i0 rows: old `01xx` and `02xx` variants are separate and all are code-backed. | `M6-i0.md:16`, `M6-i0.md:27`, `M6-i0.md:39`, `M6-i0.md:48`, `M6-i0.md:52`. | Change M6 total to 22 under audit counting, with note "11 new pages cover 22 old variant rows." |
| DIFF-006 | inventory green but audit non-green | Inventory `EPROC00114` is ✅/✅ (`feature-inventory.md:100`). | Audit downgrades old `0114/0214` to 🟡 because the FE calculate handler is empty and no c0 calc route was found. | `M7a-c0-00110-00115.md:19`, `M7a-c0-00110-00115.md:20`. | Change `EPROC00114` FE to 🟡; keep BE code-backed. |
| DIFF-007 | inventory missing old pages | Inventory states c0 has no `00111/00113` (`feature-inventory.md:95`) and lists only the eight Phase F pages. | Audit finds old `EPROC0_0211` and `EPROC0_0213` JSP/action rows; both FE and BE are UNFOUND after four-anchor search. | `M7a-c0-00110-00115.md:23`, `M7a-c0-00110-00115.md:24`. | Add explicit old-row entries as UNFOUND or record non-migration decisions for `EPROC0_0211/0213`. |
| DIFF-008 | inventory green but audit non-green | Inventory `EPROC00119` is ✅/✅ (`feature-inventory.md:105`). | Audit downgrades old `0119/0219` to 🟡 because FE select-option lists are empty while required fields consume them. | `M7b-c0-00116-00120-rest.md:23`, `M7b-c0-00116-00120-rest.md:24`. | Change `EPROC00119` FE to 🟡; keep BE code-backed. |
| DIFF-009 | inventory total/granularity mismatch | Inventory M7 says 38 and all Phase F c0 FE is complete (`feature-inventory.md:30`, `feature-inventory.md:94` through `feature-inventory.md:109`). | Audit counts 20 old c0 rows: 14 code-backed, 4 🟡, 2 UNFOUND. | `M7a-c0-00110-00115.md:26`, `M7b-c0-00116-00120-rest.md:28`. | Change M7 total to 20 under audit counting; keep a separate note for 8 new-page Phase F coverage. |
| DIFF-010 | inventory green but audit non-green / inventory missing popups | Inventory lists `EPROZ00100` only as ✅/✅ (`feature-inventory.md:114`). | Audit splits ToDo into main page plus delete/close popups. Main ToDo is 🟡 due proposal-download/upload handling; `EPROZ00101` and `EPROZ00102` popups are 🟡 because reason lists are overwritten by hardcoded options. | `M8-z0.md:17`, `M8-z0.md:18`, `M8-z0.md:19`. | Change `EPROZ00100` FE to 🟡 and add `EPROZ00101/00102` popup rows as 🟡/碼在. |
| DIFF-011 | status conflict | Inventory keeps `EPROZ00300` 🟡/🟡 for a suspected return-action issue (`feature-inventory.md:116`, `feature-inventory.md:176`). | Audit S9 records the Document Checklist page as FE/BE code-backed. | `M8-z0.md:21`. | Either move the return-action concern to a separate recon note or change the inventory row to code-backed with a validation caveat. |
| DIFF-012 | inventory missing popup | Inventory lists `EPROZ00600` Search but not its process-history popup (`feature-inventory.md:120`). | Audit has a separate code-backed `EPROZ00601` process-history popup row. | `M8-z0.md:26`. | Add `EPROZ00601` as a migrated shared popup row. |
| DIFF-013 | inventory green but audit non-green | Inventory says `EPROZ00640` is ✅/✅ and method-aligned (`feature-inventory.md:124`). | Audit keeps FE code-backed but BE 🟡 because the PDF export path returns `ResponseEntity<String>` and PDF writer/document output is commented. | `M8-z0.md:30`. | Change `EPROZ00640` BE to 🟡 for PDF export completeness; Excel remains code-backed. |
| DIFF-014 | inventory green but audit non-green | Inventory says `EPROZ00660` is ✅/✅ (`feature-inventory.md:126`). | Audit marks FE 🟡 because FE calls `epl-case-TLOD-onhandstatus-query-list` while BE exposes `epl-case-CAD-onhandstatus-query-list`. | `M8-z0.md:32`. | Change `EPROZ00660` FE to 🟡 until endpoint naming is reconciled. |
| DIFF-015 | status conflict | Inventory uses 🟠/🟠 for `EPROZ00800` and points to pending SRS/RD work (`feature-inventory.md:128`). | Audit has FE 🟡 and BE code-backed; the concrete static gap is FE POST vs BE GET for `epl-case-query-reviseditem`. | `M8-z0.md:34`. | Replace 🟠 with `FE 🟡 / BE 碼在`; carry SRS pending items separately. |
| DIFF-016 | inventory green but audit non-green / total conflict | Inventory M9 common/demo is ✅ with `~50` (`feature-inventory.md:32`). | Audit has only 1 code-backed group and 10 UNFOUND action/groups; page-level conversion is 16 legacy JSP/surface files, not `~50`. | `M9-common.md:11`, `M9-common.md:12`, `M9-common.md:13`, `M9-common.md:14`, `M9-common.md:15`, `M9-common.md:16`, `M9-common.md:17`, `M9-common.md:18`, `M9-common.md:19`, `M9-common.md:20`, `M9-common.md:21`, `M9-common.md:23`. | Change M9 from ✅ to `1 碼在 / 10 UNFOUND` under audit counting; replace `~50` with "11 action/group rows, page-level conversion 16." |
| QC-INPUT-UNFOUND | required QC cross-check unavailable | Task requires QC log F-1 through F-5. | `docs/build-tasks/refactor-audit-qc.md` is not present/tracked; only F-1 can be mapped from the prompt text. | No module line; input file missing. | Add the missing QC memo before human review if F-2 through F-5 are mandatory gates. |

## 3. Bible 完備性抽查

Bible page mentions were taken from the golden journey, BR table, and SC table in `docs/specs/bible/bible-eproposal.md:100` through `docs/specs/bible/bible-eproposal.md:440`. This section only checks whether audit has a carrier row; it does not decide implementation scope.

| Bible item | Bible line(s) | Audit carrier | Result |
|---|---|---|---|
| `EPROZ00800` revised item | `bible-eproposal.md:104`, `:172`, `:188`, `:409` through `:412`, `:425` through `:428` | `M8-z0.md:34` | Covered, audit status FE 🟡 / BE 碼在. |
| `EPROISU0110` / `EPROCSU0110` borrower entry | `bible-eproposal.md:106`, `:173`, `:413` through `:416`, `:429` through `:432` | `M2-is.md:13`, `M2-is.md:14`, `M3-iu.md:16`, `M3-iu.md:17`, `M4-cs.md:13`, `M4-cs.md:14`, `M5-cu.md:13`, `M5-cu.md:14` | Covered. |
| `EPROZ00500` related-party comparison | `bible-eproposal.md:110`, `:128`, `:236`, `:244`, `:407`, `:436` | `M8-z0.md:24` | Covered. |
| `EPROISU0170` decision page | `bible-eproposal.md:110`, `:129`, `:130`, `:254`, `:437` | `M2-is.md:30`, `M2-is.md:31`, `M3-iu.md:27`, `M3-iu.md:28` | Covered. |
| `EPROISU0173` summary | `bible-eproposal.md:114`, `:139`, `:286`, `:290`, `:408`, `:433` | `M2-is.md:37`, `M3-iu.md:34` | Covered. |
| `EPROISU0910-0922` disbursement/contract path | `bible-eproposal.md:324`, `:365`, `:440` | `M2-is.md:52` through `M2-is.md:59` | Covered, with `EPROISU0922` audit status 🟡. |
| `EPROZ00300` AO flow checklist | `bible-eproposal.md:387` | `M8-z0.md:21` | Covered. |
| `EPROISU0181` / TLOD Report | `bible-eproposal.md:342`, `:356` | `M2-is.md:38`, `M3-iu.md:35`, `M4-cs.md:32`, `M5-cu.md:29` | Covered as shared TLOD/CAD report rows. |
| `EPROZ00670` common report query | `bible-eproposal.md:340`, `:356` | No old-source JSP/trx/report id found; existing TLOD carrier is `M2-is.md:38`. | Recon-closed: `EPROZ00670` should converge to the `EPROISU0181` / TLOD row. Evidence: `docs/build-tasks/done/bible-gap-recon-findings.md`. |
| `EPROISU0180` Credit Proposal report | `bible-eproposal.md:341`, `:364` | Existing M8 report-action carriers: `M8-z0.md:17`, `M8-z0.md:25`. | Recon-closed: no independent page; old report generator/actions are carried by ToDo/Search rows, so no new row total. Evidence: `docs/build-tasks/done/bible-gap-recon-findings.md`. |
| `EPROISU0182` Summary Report | `bible-eproposal.md:343`, `:364` | Existing carrier: `M2-is.md:59`. | Recon-closed: report id should converge to the `EPROISU0922` Summary row. Evidence: `docs/build-tasks/done/bible-gap-recon-findings.md`. |
| `EPROISU0183` Transaction Result report | `bible-eproposal.md:344`, `:365` | Existing carrier: `M2-is.md:59`. | Recon-closed: report id should converge to the `EPROISU0922` Summary row. Evidence: `docs/build-tasks/done/bible-gap-recon-findings.md`. |
| `EPROISU0184` Message Code Record report | `bible-eproposal.md:345`, `:365` | Existing carrier: `M2-is.md:59`. | Recon-closed: report id should converge to the `EPROISU0922` Summary row. Evidence: `docs/build-tasks/done/bible-gap-recon-findings.md`. |

## 4. 建議回填項

These are proposed edits for human review. Do not apply them to `docs/feature-inventory.md` automatically.

| Check | Inventory target | Proposed backfill | Basis |
|---|---|---|---|
| [ ] | `feature-inventory.md:27` M4 module row | Change status from `✅ 前端／🟡 驗證` to `BE 碼在 / FE UNFOUND for EPROCSU0150/0160/0170/0171/0172/0173 and related popups`. | DIFF-001; `M4-cs.md:59`. |
| [ ] | `feature-inventory.md:28` M5 module row | Change status from `✅ 前端／🟡 驗證` to `BE 碼在 / FE UNFOUND for EPROCSU0160/0170/0171/0172/0173 and related popups`. | DIFF-001; `M5-cu.md:54`. |
| [ ] | `feature-inventory.md:67` | Change `EPROCSU0150` FE from ✅ to UNFOUND for CS collateral; BE remains code-backed. | `M4-cs.md:19`, `M4-cs.md:20`. |
| [ ] | `feature-inventory.md:68` | Change `EPROCSU0160` FE from ✅ to UNFOUND; add approved-case popup coverage gap. | `M4-cs.md:22`, `M4-cs.md:23`, `M4-cs.md:24`, `M5-cu.md:19`, `M5-cu.md:20`, `M5-cu.md:21`. |
| [ ] | `feature-inventory.md:69` | Change `EPROCSU0170` FE from ✅ to UNFOUND; add return/cancel popup gaps. | `M4-cs.md:25`, `M4-cs.md:26`, `M4-cs.md:27`, `M4-cs.md:28`, `M5-cu.md:22`, `M5-cu.md:23`, `M5-cu.md:24`, `M5-cu.md:25`. |
| [ ] | `feature-inventory.md:70` through `feature-inventory.md:72` | Change `EPROCSU0171/0172/0173` FE from ✅ to UNFOUND; BE remains code-backed. | `M4-cs.md:29`, `M4-cs.md:30`, `M4-cs.md:31`, `M5-cu.md:26`, `M5-cu.md:27`, `M5-cu.md:28`. |
| [ ] | `feature-inventory.md:75` | Keep `EPROIS_0140` not-developed decision, but add a separate line for `EPROIS_0240` as UNFOUND or request owner decision. | `M2-is.md:19`, `M2-is.md:20`. |
| [ ] | M3 `iu` section near `feature-inventory.md:38` through `feature-inventory.md:58` | Add `EPROIU_0140` and `EPROIU_0240` as UNFOUND or explicit non-migration decisions. | `M3-iu.md:22`, `M3-iu.md:23`. |
| [ ] | `feature-inventory.md:56` through `feature-inventory.md:58` | Set `EPROISU0920=碼在`, `EPROISU0921=碼在`, `EPROISU0922=BE 🟡`; keep disbursement domain/T24 as cross-page risk in §2F. | `M2-is.md:56`, `M2-is.md:57`, `M2-is.md:58`, `M2-is.md:59`. |
| [ ] | `feature-inventory.md:29` and `feature-inventory.md:81` through `feature-inventory.md:91` | Change M6 total to 22 audit rows; note 11 new pages cover 22 old `01xx/02xx` rows. | `M6-i0.md:52`. |
| [ ] | `feature-inventory.md:30` and `feature-inventory.md:94` through `feature-inventory.md:109` | Change M7 audit total to 20 rows; keep separate new-page Phase F status. | `M7a-c0-00110-00115.md:26`, `M7b-c0-00116-00120-rest.md:28`. |
| [ ] | `feature-inventory.md:100` | Change `EPROC00114` FE from ✅ to 🟡. | `M7a-c0-00110-00115.md:19`, `M7a-c0-00110-00115.md:20`. |
| [ ] | Near `feature-inventory.md:95` | Add `EPROC0_0211` and `EPROC0_0213` old rows as UNFOUND or add explicit non-migration decisions. | `M7a-c0-00110-00115.md:23`, `M7a-c0-00110-00115.md:24`. |
| [ ] | `feature-inventory.md:105` | Change `EPROC00119` FE from ✅ to 🟡. | `M7b-c0-00116-00120-rest.md:23`, `M7b-c0-00116-00120-rest.md:24`. |
| [ ] | `feature-inventory.md:114` | Change `EPROZ00100` FE to 🟡 and add `EPROZ00101/00102` popup rows as 🟡/碼在. | `M8-z0.md:17`, `M8-z0.md:18`, `M8-z0.md:19`. |
| [ ] | `feature-inventory.md:116` | Either change `EPROZ00300` to code-backed or keep the return-action concern as a separate recon note rather than audit status. | `M8-z0.md:21`. |
| [ ] | `feature-inventory.md:120` | Add `EPROZ00601` process-history popup as code-backed. | `M8-z0.md:26`. |
| [ ] | `feature-inventory.md:124` | Change `EPROZ00640` BE to 🟡 for PDF export completeness. | `M8-z0.md:30`. |
| [ ] | `feature-inventory.md:126` | Change `EPROZ00660` FE to 🟡 for TLOD/CAD endpoint mismatch. | `M8-z0.md:32`. |
| [ ] | `feature-inventory.md:128` | Replace 🟠/🟠 with `FE 🟡 / BE 碼在`; keep SRS pending list separately. | `M8-z0.md:34`. |
| [ ] | `feature-inventory.md:32` | Replace M9 `~50`/✅ with `11 action/group rows; page-level conversion 16; 1 碼在 / 10 UNFOUND`. | `M9-common.md:23`. |
| [x] | Bible follow-up | `BIBLE-GAP-1` through `BIBLE-GAP-5` recon closed; all five are absent as independent old pages, existing report-action carriers, or report ids converged to `EPROISU0181` / `EPROISU0922`. | `docs/build-tasks/done/bible-gap-recon-findings.md`; no audit row total changed. |
| [ ] | QC follow-up | Add or restore `docs/build-tasks/refactor-audit-qc.md`; map F-2 through F-5 before final human sign-off. | `QC-INPUT-UNFOUND`. |
