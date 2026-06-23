# EPROC00120 SRS N-axis findings

Date: 2026-06-23
Bundle: `docs/specs/srs/EPROC00120/`
PRD: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md`

## Gate
- PASS: `python scripts/check-srs-bundle.py docs/specs/srs/EPROC00120`
- Advisory only: no Bible-PRD trace file (`docs/specs/prd/trace-*EPROC00120*.md`).

## Axis Results
- A 綜合/完整性: PASS. R20/P-013, QA-032, and Trace Matrix FR-002 are aligned.
- B as-is parity: PASS. OpenAPI main schema uses current/parity-confirmed fields; P-010/P-012 remain deltas.
- C 錯誤碼: PASS. `ErrorInputException`, 200 business envelope, and 401 auth are carried.
- D 安全授權: PASS. Security/Auth Coverage separates `TB_API_AUTH`, page/menu roles, and service-level guard; P-011 remains open.
- E DB reconcile: PASS. `schema.sql` matches db-diff/entity names and precision; P-010 stays pending.
- F 金錢精度截斷: PASS. R20/P-013 tracks HALF_DOWN vs HALF_UP; QA-032 covers rounding boundary; maxlength anchors are fixed.
- G 可測試性: PASS. QA `When` steps use concrete `POST /epl-*` routes; pending rows remain explicitly blocked.

## Open PENDING For Human Review
- P-001 through P-008: PRD TBD items remain open.
- P-009: missing independent c0 `EPROC00120` refactor baseline and direct parity verification.
- P-010: `cetOneCapitalRatio` / `totalCapitalRatio` current-runtime fields need RD/DBA decision.
- P-011: `TB_API_AUTH` seed and service-level edit-role guard closeout.
- P-012: PRD/legacy parent-progress contract gap (`pageCheckMap`, `isAllTabsCheck`, parent context, cross-page reset ownership).
- P-013: rounding mode/intermediate scale for automatic ratio fields.
