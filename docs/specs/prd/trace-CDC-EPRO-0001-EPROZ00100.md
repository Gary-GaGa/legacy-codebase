# Bible ↔ PRD 對照表 — CDC-EPRO-0001 / EPROZ00100 TO DO LIST

> 上行追溯：PRD `CDC-EPRO-0001` REQ ← Bible v1.1（`../bible/bible-eproposal.md`）旅程/錨點。
> **Bible 對 EPROZ00100 為旅程級錨點**（「待辦與案件入口 `EPROZ0_0100`」、黃金旅程「案件建立/待辦入口」、狀態字典 `TB_PROCESS_CODE`、角色字典 `TB_ROLE_DEFINE`/`TB_API_AUTH`）；**無 BR-### 直接點名 EPROZ00100**（故本表不列 BR 列，gateⒷ「BR 點名未入 trace」不適用）。漂移登記點＝下表「seam/PENDING」欄。
> trace 行格式：`cell[0]＝REQ-id`（供 gateⒷ 上行追溯比對）。

## 表 A：PRD REQ ↔ Bible 錨點

| REQ | Bible 旅程/錨點 | PRD 章節 | SRS Rn | seam/PENDING |
|---|---|---|---|---|
| REQ-001 | 黃金旅程「案件建立/待辦入口 `EPROZ0_0100`」；角色字典 `TB_ROLE_DEFINE`/`TB_API_AUTH`（角色與 API 權限） | §4.1 | R1, R2 | TBD-001（角色權限）、TBD-002（redistribution+method）|
| REQ-002 | 「待辦與案件入口：使用者可看到哪些案件、權限與案件狀態範圍」；狀態字典 `TB_PROCESS_CODE`（CASE_PROGRESS 排除集合） | §4.2 | R3, R4, R5 | TBD-003（CASE_PROGRESS 語意）|
| REQ-003 | CAD 維度待辦（`TB_LON_SUMMARY_INFO` + proxy `TB_EMP_PROXY`）；`TB_LON_TYPE`（LON_TYPE_CODE 01–04） | §4.3 | R6, R7 | TBD-004（DOC_NO/NO mapping）、TBD-005（六個月限制）|
| REQ-004 | 案件導頁＝黃金旅程「待辦→主流程頁」轉場；`CASE_PROGRESS`→頁對應 | §4.4 | R8 | TBD-003（CAD 21–25 語意）|
| REQ-005 | 案件生命週期「撤件/刪除」狀態轉換（`CASE_PROGRESS=D1`、`TB_APP_HISTORY`） | §4.5 | R9 | TBD-007（reason code table）|
| REQ-006 | 案件生命週期「結案」狀態轉換（`CASE_PROGRESS=C1`、`IS_AUTODIS`→MC/YC） | §4.6 | R10 | TBD-007（reason code table）|
| REQ-007 | CA proposal download（依 attribute dispatch printProposal） | §4.7 | R11 | TBD-006（download 安全/檔案處理）|
| REQ-002 | session context（GOAL-002「點選 applicationNo→建立 current application」）；下游頁 routing | §2.1/§6 | R12 | TBD-008（session→route 遷移）|

## 表 B：Bible→PRD seam（Bible 有、PRD 未承載的旅程級邊界）

| seam | 待決（Bible 有、PRD/SRS 落空）| 影響 | owner |
|---|---|---|---|
| （無）| EPROZ00100 為待辦入口頁，Bible 旅程錨點均已由上表 REQ 承載；**無未承載之 Bible 安全/災難條件 seam**（與 00800 BR-014 不同）。 | — | — |

> 註：本頁 8 個 PRD TBD 皆屬 PRD 層待確認（非 Bible→PRD seam），單一出處＝`../srs/EPROZ00100/spec.md` §@PENDING。
