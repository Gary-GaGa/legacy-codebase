# Bible ↔ PRD 對照表 — CDC-EPRO-0001 / EPROC00118 Corporate Scorecard

> 上行追溯：PRD `CDC-EPRO-0001`（funcId `EPROC00118`，企業授信評分卡）的 FR ← Bible v1.1（`../bible/bible-eproposal.md`）。
> ⚠️ **PRD 用 `FR-NNN`（非 `REQ-NNN`）**：gateⒷ 機械追溯比對 `REQ-\d{3}` token，**對 FR-### 不機械驗**——本表為人讀 Bible→PRD 登記（漂移點），FR↔Rn 機械追溯由 SRS `Traceability Matrix` 承載。
> ⚠️ PRD 快照 `PRD-CDC-EPRO-0001-EPROC00118-v1.0.md` 須與本 trace 同放 `docs/specs/prd/`（pilot push 僅含 `srs/` bundle，快照待 owner 補 push）。

## 表 A：PRD FR ↔ Bible 錨點 ↔ SRS Rn
| FR | Bible 旅程/錨點 | SRS Rn | seam/PENDING |
|---|---|---|---|
| FR-001 初始化查詢 | 信用決策旅程「企金 c0 評分頁載入」；`TB_LON_SUMMARY_INFO`/`TB_CORP_SCRCARD` 錨點 | R1 | TBD-001（param seed）|
| FR-002 23 項 AO/CR 欄位 | c0 評分卡欄位（金錢/比率欄）；**BR-010/011** late-transaction 連動 | R2, R11 | TBD-005（AO copy 欄）｜TBD-008（default toggle）|
| FR-003 Rate 計算 | 計分引擎「不分叉、用 `FunctionService.funcGetRate`」（c0 唯一例外注入 i0，`decisions:34-35`）| R3 | —（已裁）|
| FR-004 Default 規則 | Loan Default 90+ → risk=Default/score=-1；AO 同步 CR | R4 | TBD-010（AO→CR 同步免再評，PM/風控）|
| FR-005 role/query mode | 角色字典 `TB_ROLE_DEFINE`/授權 `TB_API_AUTH`；AO 001/002・CR 102/103 | R5 | TBD-004（role 003 可否編輯）｜TBD-AUTH（授權 seed）|
| FR-006 Save/Finished | 案件狀態轉換「評分完成→`CR_SCORE_CARD_COMPLETED`」單一交易+checkpoint | R6, R10, R11 | TBD-002（兩碼語意/CreditEval 覆寫）｜TBD-003（後端強檢）|
| FR-007 父頁完成狀態 | `CR_SCORE_CARD_COMPLETED` 兩碼（00118 第2碼 / 00114 另一碼）| R7 | TBD-002 |
| FR-008 參數有效日期 | `TB_SCORE_CARD_PARAM_DETAIL` `ST_DATE` 版本 | R8 | TBD-009（是否納 END_DATE）|
| NFR | 安全/授權（BE 權威、不只前端 disabled）；audit/敏感遮罩 | R9, R10 | TBD-ERR-STATUS（錯誤碼→HTTP status）|

## 表 B：Bible→PRD seam（Bible 有、PRD/SRS 落空）
| seam | 待決 | 影響 | owner |
|---|---|---|---|
| CreditEval 整欄覆寫 | 既有 `CsuCreditEval*` 對 `CR_SCORE_CARD_COMPLETED` 整欄寫 `"NN"`（E1/E2 escalation）vs 本頁「只動第2碼」——跨頁互動 | 本頁 Save 後狀態可能被覆寫 | PM/SA/CreditEval（TBD-002，與 E1/E2 合流）|

> 註：本頁 10 個 PRD TBD（TBD-001~005/008/009/010/AUTH/ERR-STATUS）單一出處＝`../srs/EPROC00118/spec.md §@PENDING`；TBD-006/007 已 closed/non-goal。
