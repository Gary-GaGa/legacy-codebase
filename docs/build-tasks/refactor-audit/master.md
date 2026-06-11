# Full Refactor Audit Master

Status: S0 initialized on 2026-06-11.

## Rules

- Scope is read-only for product code: do not edit `backend/`, `frontend/`, or `legacy-epro/`.
- This audit does not trust `docs/feature-inventory.md`; read it only in S-final.
- Do not read Bible or large docs during S1-S9 except the required module-local hints.
- Each row must be backed by code evidence. Missing evidence is `UNFOUND`, not inferred.
- If context gets high, stop, write the breakpoint here, and continue from files in a new session.

## Row Schema

| 舊 funcId/JSP | 功能（畫面/action） | Bible 錨點 | 新對應（FE 路由 / BE `epl-*`） | FE | BE | 證據 | 缺口/備註 |
|---|---|---|---|---|---|---|---|

Status vocabulary for FE/BE: `碼在`, `🟡 碼在疑未完`, `🔴 無對應`, `🚫 確認不遷`, `UNFOUND`.

## Initial Catalog Hints

These are only S0 hints from `docs/legacy/page-mapping.md`, not final audit totals.

| Area | S0 hint | Source |
|---|---:|---|
| M2/M3 IS+IU main flow catalog | 18 EPROISU rows | `docs/legacy/page-mapping.md:14-34` |
| M4/M5 CS+CU main flow catalog | 10 EPROCSU/CAD rows | `docs/legacy/page-mapping.md:36-48` |
| M6 i0 score catalog | 11 EPROI00 ids | `docs/legacy/page-mapping.md:50-51` |
| M7 c0 score catalog | 9 EPROC00 ids + 2 TBD legacy ids | `docs/legacy/page-mapping.md:53-55` |
| M8 z0 common catalog | Task card says 18 pages; page-mapping visible catalog needs S9 recount | `docs/legacy/page-mapping.md:57-66` |
| M1 zz / M9 common-demo | No S0 count in page-mapping catalog | `docs/legacy/page-mapping.md:57-66` |

## Session Progress

| S | Scope | Output | Status | Breakpoint funcId | Notes |
|---|---|---|---|---|---|
| S0 | Build `refactor-audit/` skeleton | `master.md` + module files + `diff-vs-inventory.md` | 完成 |  | Skeleton only; no product code read beyond allowed S0 hints. |
| S1 | M1 `zz` login/home + M9 common/demo | `M1-zz.md`, `M9-common.md` | 完成 |  | M1 total 4; M9 total 11. No breakpoint. |
| S2 | M2a `is` application flow `0110-0290` | `M2-is.md#a-s2-m2a-is-application-flow-0110-0290` | 完成 |  | Total 26; source old-source; no breakpoint. Output follows user instruction to write M2a into `M2-is.md`. |
| S3 | M2b `is` contract/disbursement `0910-0922` + M3 `iu` | `M2-is.md#b-s3-m2b-is-contract--disbursement-0910-0922`, `M3-iu.md` | 完成 |  | M2b total 8; M3 total 20. No breakpoint. Removed empty split placeholders. |
| S4 | M4 `cs` + M5 `cu` | `M4-cs.md`, `M5-cu.md` | 完成 |  | M4 total 20; M5 total 17. No breakpoint. CS/CU merged in new pages; list source differences separately. S4b 復核完成: 22 FE=UNFOUND rows rechecked by four anchors; totals unchanged. |
| S5 | M6a `i0` `00110-00115` | `M6-i0.md#a-s5-m6a-i0-00110-00115` | 完成 |  | Total 12; source old-source; no breakpoint. Old `0110-0115` and `0210-0215` variants both counted and mapped to merged new `EPROI00110-00115` pages. |
| S6 | M6b `i0` `00116-00120` + remaining i0 JSPs | `M6b-i0-00116-00120-rest.md` | 未開 |  | Exhaust all remaining i0 JSP/action entries. |
| S7 | M7a `c0` `00110-00115` segment | `M7a-c0-00110-00115.md` | 未開 |  | Use corporate scoring source and controllers. |
| S8 | M7b `c0` `00116-00120` + remaining c0 JSPs | `M7b-c0-00116-00120-rest.md` | 未開 |  | Exhaust all remaining c0 JSP/action entries. |
| S9 | M8 `z0` `00100-00800` all pages | `M8-z0.md` | 未開 |  | Task card says 18 pages; S9 must verify from old source. |
| S-final | Total + diff vs inventory + Bible spot-check | `diff-vs-inventory.md` | 未開 |  | Only this session reads `feature-inventory.md` and Bible. |

## Module Totals

All totals are empty until the owning session fills evidence-backed rows.

| File | Scope | 總列數 | 碼在 | 🟡 | 🔴 | 🚫 | UNFOUND |
|---|---|---:|---:|---:|---:|---:|---:|
| `M1-zz.md` | M1 `zz` login/home | 4 | 4 | 0 | 0 | 0 | 0 |
| `M2-is.md` | M2 `is` `0110-0290` + `0910-0922` | 34 | 31 | 1 | 0 | 1 | 1 |
| `M3-iu.md` | M3 `iu` all | 20 | 18 | 0 | 0 | 0 | 2 |
| `M4-cs.md` | M4 `cs` all | 20 | 7 | 0 | 0 | 1 | 12 |
| `M5-cu.md` | M5 `cu` all | 17 | 7 | 0 | 0 | 0 | 10 |
| `M6-i0.md` | M6a `i0` `00110-00115` | 12 | 12 | 0 | 0 | 0 | 0 |
| `M6b-i0-00116-00120-rest.md` | M6b `i0` rest | 0 | 0 | 0 | 0 | 0 | 0 |
| `M7a-c0-00110-00115.md` | M7a `c0` `00110-00115` | 0 | 0 | 0 | 0 | 0 | 0 |
| `M7b-c0-00116-00120-rest.md` | M7b `c0` rest | 0 | 0 | 0 | 0 | 0 | 0 |
| `M8-z0.md` | M8 `z0` all | 0 | 0 | 0 | 0 | 0 | 0 |
| `M9-common.md` | M9 common/demo/error/layout | 11 | 1 | 0 | 0 | 0 | 10 |

## Next Session

Recommended next session: S6. Read only the task card sections 0, 2, and S6; this `master.md`; existing `M6-i0.md`; and the relevant `page-mapping.md` hints. Then recount M6b `i0` from old source and dispatcher/web.xml before checking new FE/BE code.
