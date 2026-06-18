# SRS — EPROZ00100 TO DO LIST / Work-list Dashboard（SA 規格層）

| 欄位 | 內容 |
|---|---|
| Status | **規格定版**: In Review——TBD-001~008 未裁（blocking: **TBD-002** prompt method/redistribution、**TBD-004** CAD docNo mapping、**TBD-006** download 安全/檔案處理）；TBD 全關 → 升 `Approved`。**／實作完成**: 主清單查詢 `epl-list-todolist` as-is（含 langType regression 已修 `bbbaa19`/`7e1f0d2`）、popup reason 改回 API 來源已修（`2599752`）；其餘 action（CAD proxy scope／delete／close／download／session）as-is **待 RD 核對**。正式 SA 簽核待 owner。詳 §@PENDING（單一出處）＋文末 as-is→to-be 摘要 |
| Owner | SA（待指派）|
| Slug | `EPROZ00100`（＝funcId）|
| 版本 | v0.2-draft（2026-06-18：v0.1 `prd-to-srs` 產出 → 依 spec-reviewer 修 B1/B2/B3＋S1–S6/N1–N3）|
| 最後更新 | 2026-06-18 |
| 上游 PRD | `CDC-EPRO-0001 v1.1`（快照 `../../prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.1.md`）|
| as-is 來源 | `../../../build-tasks/done/00100-todo-empty-recon-findings.md`、`../../../build-tasks/done/00100-todo-fix.md`、`feature-inventory §2E:116` |

> **每條規則一個 `Rn`，標 `covers-prd:` 上游追溯**；QA 用 `covers: Rn`（見 `qa-cases.md`）。funcId 串 Bible→PRD→SRS→QA→code。
> ⚠️ **TBD 一律寫 `@PENDING` + owner、不自行裁定**；**不把 legacy 行為當已核准需求**。`file:line` 為新系統現碼（產品 repo `backend/`），引自 00100 findings；RD 實作時再核對。
> ℹ️ **TBD-001/003 參考資源（不代裁）**：Bible v1.1 已坐實角色字典 `TB_ROLE_DEFINE`/`TB_API_AUTH`、狀態字典 `TB_PROCESS_CODE`（`bible-eproposal.md` §DB 錨點）→ PM/SA 裁 role/CASE_PROGRESS 正式語意時可取為證據基。

## Scope / Non-Goals
- **本期**：dashboard 初始化（清 session＋role flags）、待辦清單查詢（一般 role＋CAD role 分支）、案件導頁、刪除、CAD 結案、proposal download、session context 設定/清除。
- **非本期**：下游業務頁籤內容、授信審查計算、proposal 報表內容本身、登入/角色管理維護（PRD 界外範圍）；reason/role/CASE_PROGRESS **code table 維護**（值層由 PM/SA 補，見 @PENDING）；R2 報表服務與檔案上傳 API（⏸ 待拍板 track，F-9 殘留掛此）。
- **未承載（上游缺口）**：（無）——Bible 對 00100 為旅程級錨點、均已由 REQ 承載；**無未承載之 Bible 安全/災難 seam**（見 trace 表 B；與 00800 BR-014 不同）。

## Assumptions / Dependencies / Constraints
- **Assumptions**：登入者身分（`roleId`/`empId`/branch/dept）來自 JWT（`JwtUtil.getCurrentEmployee()`）；`V_MAIN_BORROWER_INFO` view 提供清單欄位（含個金/企金 borrower name、langType 欄）；reason/role/CASE_PROGRESS code table 已建（值待 PM/SA 定）。
- **Dependencies**：`TB_LON_SUMMARY_INFO`（案件主檔）、`TB_APP_HISTORY`、`TB_DEL_REASON`/`TB_CLO_REASON`、`TB_RELATED_PARTY_INFO`、`TB_LOAN_CONDITION_DETAIL`、`TB_EMP_PROXY`、`TB_PROCESS_CODE`；下游主流程頁 routing（`EPROIS_0171`/`0910`/`0920`…）。
- **Constraints**：Oracle；RPC `epl-{verb}-{scope}-{feature}` 慣例（page-mapping §API）；既有新系統碼（brownfield：`ToDoListController`/`ToDoListServiceImpl`/`VMainBorrowerInfoRepository`，見 as-is）。**語系裁定（owner 2026-06-15，`decisions.md` i18n 列）**：語系切換**只影響元件翻譯（呈現層 i18n）、不影響查詢資料筆數**（→ R4）。

## Endpoints（真實 `epl-*`；PRD §6 的 `/api/...` REST 為理想化）
| 動作 | endpoint（to-be） | method（to-be） | as-is | DTO |
|---|---|---|---|---|
| prompt（初始化）| `epl-comm-todolist-prompt` | **POST**（`@PENDING TBD-002`：可能觸發 redistribution 異動，REQ-001-05 非純 GET）| ⚠️ 待核對（role flags 可由 JWT `roleId` 推；prompt 端點/redistribution 落點待核）| `PromptResponse`（role flags）|
| initQuery（非 CAD 清單）| `epl-list-todolist` | **POST** | ✅ as-is（`ToDoListController:63-68` POST、`VMainBorrowerInfoRepository.findToDoList`）| `ToDoListRequest`/`ToDoListResponse` |
| queryCAD（CAD 清單）| `epl-list-todolist`（role `404/405` 分支）| **POST** | ⚠️ 合併進同端點（role 分支：`404/405`→`LON_TYPE_CODE IN`、`DECISION_DATE` 排序）；**proxy scope 疑缺**（as-is 只 `CURRENT_USER_ID=:userId`，未含 active proxy；舊 `queryCAD` 組 `IN_CURRENT_USER_ID`）→ RD 核 | `ToDoListRequest`/`ToDoListResponse` |
| getReason（刪除原因）| `epl-sele-todolist-delreason` | **GET** | ✅（F-10 `2599752`：popup 改回 API 來源、移除硬編碼 D01–D99）| `ReasonMapResponse` |
| getCloReason（結案原因）| `epl-sele-todolist-cloreason` | **GET** | ✅（同上模式）| `ReasonMapResponse` |
| execute（刪除）| `epl-save-todolist-delete` | **POST** | ⚠️ 待 RD 核對 | `DeleteRequest` |
| executeclose（結案）| `epl-save-todolist-close` | **POST** | ⚠️ 待 RD 核對 | `CloseRequest` |
| downloadFile（呈報書下載）| `epl-file-todolist-download` | **POST**（`@PENDING TBD-006`）| ⚠️ as-is 走 `goPath()` stub、非報表服務（F-9 → 掛 R2 報表服務/檔案 API track）| `DownloadRequest`/`DownloadResponse` |
| setSession | `epl-comm-todolist-setsession` | **POST**（`@PENDING TBD-008`）| ⚠️ as-is server session、待核對 | `SessionRequest` |
| clearSession | `epl-comm-todolist-clearsession` | **POST**（`@PENDING TBD-008`）| ⚠️ 待核對 | — |

> ⚠️ **`epl-comm-todolist-prompt`/`-setsession`/`-clearsession` 不入 `openapi.yaml`**：prompt method 受 `TBD-002`、session 去留受 `TBD-008` 控制，契約形狀未定 → 先以 prose 記錄、待裁後補契約（同 00800 prompt 處置）。其餘 6 端點入 openapi。**prompt 承載的 `REDISTRIBUTION_FAILED`(500)（R2）隨 TBD-002 裁定後補入 openapi（B1 disclaim）。**

## 業務規則（Rn）
> 狀態：✅ as-is 符合 ／ ⚠️ as-is 出入 ／ 🔴 as-is 缺/風險 ／ 標 to-be＝PRD 要求。

### R1 — prompt 初始化（清 session＋回 role flags）　`covers-prd: REQ-001`　**強制點：FE+BE**
**當**使用者進入 dashboard（prompt）時，系統應 ① 清除前次 `APPLICATION_NO`/`action` session（REQ-001-01）② 回傳 role flags `isAO`/`role`/`isCA`/`isCRCOSCO`/`isCOSCO`/`isCADMERCER`（REQ-001-02），供 FE 依角色呈現對應畫面與可用動作。**as-is ⚠️**：role 來源＝JWT `loginEmployee.getRoleId()`（`ToDoListServiceImpl:155-170`）；prompt 端點與 session 清除落點待 RD 核對。

### R2 — CA/CR redistribution 側效＋prompt 非純 GET　`covers-prd: REQ-001`　**強制點：BE**　`@PENDING(TBD-002)`
**當** CA(`101`)／CR(`102/103`) role 進入 dashboard 時，系統（依 source 規則）應執行 CA／CR redistribution（REQ-001-03/04），並更新 `TB_LON_SUMMARY_INFO`（`CURRENT_USER_ID`/`CR_CODE`/`RE_DISTRIBUTION`/`RECEIVED_DATE`/`DISTRIBUTION_DATE`）＋寫 `TB_APP_HISTORY`，須同一交易（→R14 NFR）；**若** redistribution 交易失敗，系統應整批 rollback 並回 `REDISTRIBUTION_FAILED`(500)（→R14 log；B1 承載）；**因 prompt 可能異動資料，端點不得用純 GET**（REQ-001-05）。**@PENDING(TBD-002)**：是否保留此 side effect、以及保留時的 API method＝SA 待裁——**未裁前不實作 redistribution 變更**。as-is：legacy `EPROZ0_0100_mod` redistribution 分支存在（findings `:253-321`）；新系統等價物待核對。

### R3 — 待辦清單查詢（initQuery：current user＋排除狀態）　`covers-prd: REQ-002`　**強制點：FE+BE**
**當** initQuery 被呼叫時，系統應依 `CURRENT_USER_ID=:userId`（登入者）查 `V_MAIN_BORROWER_INFO`（REQ-002-01），並排除 `CASE_PROGRESS ∈ {03, D1, R0305, R0313, R0397}`（REQ-002-02）。**as-is ✅**：`VMainBorrowerInfoRepository:48`（`CURRENT_USER_ID=:userId`）＋`CaseProgressNotInEnum`（`03/D1/R0305/R0313/R0397`，與 legacy `NOT_IN_CASE_PROGRESS` 一致）；70201/role `002`/`en_US` 應回 85 筆 `CASE_PROGRESS=01`（findings）。

### R4 — 語系只影響呈現、不影響查詢筆數　`covers-prd: REQ-002`（owner 2026-06-15 i18n 裁定，`decisions.md`）　**強制點：FE+BE**
**在**任一語系（`zh_TW`/`en_US`）下，系統應回傳**相同的待辦案件筆數**——語系**只**影響元件翻譯（呈現層 i18n），**不得**作為查詢資料 WHERE 過濾條件。**as-is ⚠️→✅ 已修**：原 `LOAN_TYPE_LANG_TYPE=:langType` 把語系當資料過濾（`zh_TW`→0 筆＝regression，findings「TODO 空」）→ langType 退出資料 WHERE、多語系欄改 LEFT JOIN＋fallback（`bbbaa19`/`7e1f0d2`，五頁筆數一致）。**對齊 SOP**：屬 regression 修回（非刻意演進）。

### R5 — 清單 row enrichment（名稱／日期空白／關係人／金額）　`covers-prd: REQ-002`　**強制點：FE+BE**
系統於清單每列應：① 個人案件顯示 main borrower name、公司案件顯示 corp borrower name（REQ-002-03）② `APPLICATION_DATE=01/01/1900` 顯示為空白（REQ-002-04）③ **若**存在 `IS_Y=Y` related party record 則 `showRelated=Y`、否則 `N`（REQ-002-05）④ 依 loan condition detail 加總 `USD`/`KHR` 金額（REQ-002-06）。**as-is ⚠️**：`LEFT JOIN TB_RELATED_PARTY_INFO`（showRelated 來源）已在；金額加總（`TB_LOAN_CONDITION_DETAIL`）與 1900→空白、個金/企金名稱分流之逐項對齊待 RD 核對。

### R6 — CAD 待辦查詢（範圍＋類型＋回傳欄）　`covers-prd: REQ-003`　**強制點：FE+BE**
**當** CAD role(`404/405`) 查詢時，系統應 ① 以 current CAD user **加上 active proxy employees** 為查詢範圍（REQ-003-01）② 只允許 `LON_TYPE_CODE ∈ {01,02,03,04}`（REQ-003-02）③ 回傳 decision date display／approval level display／`docNo1`／borrower name／sales channel／`page`（REQ-003-04）；公司案件 `docNo1` 用 `REGISTER_NO`、個人案件用文件欄位轉換結果（REQ-003-05）。查詢 filter 欄位＝`applicationNo`／`docNo`／`mainBorrowerName`(trim/upper-case like)／decision date range，各為**選填 AND 條件**（REQ-003-03，B2）。**as-is ⚠️🔴**：role `404/405` 分支限 `LON_TYPE_CODE IN :lonTypeCodes`、`DECISION_DATE` 排序（`VMainBorrowerInfoRepository:49-62`）✓；但**範圍只 `CURRENT_USER_ID=:userId`、未含 active proxy**（舊 `queryCAD` 組 `IN_CURRENT_USER_ID` 含 proxy，findings `:130-150`）→ **疑 proxy scope regression、RD 核**（連動 TBD-004 docNo mapping）。

### R7 — CAD 查詢條件驗證（拒空查詢／日期成對）　`covers-prd: REQ-003`　**強制點：FE+BE**
**若** CAD 查詢未提供任何有效條件（`applicationNo`/`docNo`/`mainBorrowerName` 或完整 decision date range 之一），系統應拒絕、回 `INVALID_CAD_QUERY_CONDITION`（400），**不得**執行全量查詢（→R14 效能）；`START_DECISION_DATE`/`END_DECISION_DATE` 須成對（填一必填另一）。**強制點 BE 權威**（不可只靠 FE）。**as-is ⚠️**：BE 是否強制待核對（findings：optional filters 存在，空查詢防護未證）。**@PENDING 子點**：`TBD-005`（六個月 range 是否 backend 強制）、`TBD-004`（`DOC_NO` 送出 vs module 讀 `NO` 之相容 mapping）——詳 §@PENDING。

### R8 — 案件導頁（role/CASE_PROGRESS → page）　`covers-prd: REQ-004`　**強制點：FE+BE**
**當**使用者由清單點選案件時，系統應依 role＋`CASE_PROGRESS` 回對應頁：CA+{IS/IU/CS/CU}→`EPRO{IS/IU/CS/CU}_0171`；CAD Maker `CASE_PROGRESS 21/22`→`EPROIS_0910`、`24/25`→`EPROIS_0920`；CAD Checker `23`→`EPROIS_0910`、`25`→`EPROIS_0920`；CAD 其他→`MANUALAPP`；其他 role→`EPRO_Z0Z006.getCheckPage` 首頁。**as-is ⚠️**：清單回傳含 `page` 欄（findings response），逐條件對應與 CAD 21–25 語意待核（連 TBD-003）。

### R9 — 刪除案件（權限／必填／單一交易）　`covers-prd: REQ-005`　**強制點：FE+BE**
**當** execute（刪除）時，系統應 ① AO role `003` **不得**刪除（REQ-005-01；**BE 強制、非僅 FE 隱藏鈕**，→R14 安全）② 要求 `APPLICATION_NO` 與**至少一個 reason**，否則回 `MISSING_APPLICATION_NO`/`MISSING_REASON`（REQ-005-02）③ 選 `D99` 時 other reason 必填、`maxlength 100`，否則 `MISSING_OTHER_REASON`（REQ-005-03）④ 於**單一 `@Transactional`** 寫 `TB_DEL_REASON`（`REASON_CODE` 分號串接＋`DEL_DATE`＋`OTH_REASON`）＋`TB_APP_HISTORY`，並更新 `TB_LON_SUMMARY_INFO.CASE_PROGRESS=D1`（REQ-005-04）；任一步失敗整批 rollback ⑤ 代理人處理時 history 記 `PROCESS_AGENT_CODE`/`NAME`（REQ-005-05）。**as-is ⚠️**：待 RD 核對（mutating 端點 → BE 權威必驗）。

### R10 — CAD 結案（必填／單一交易／狀態轉換）　`covers-prd: REQ-006`　**強制點：FE+BE**
**當** executeclose（CAD 結案）時，系統應 ① 要求 `APPLICATION_NO` 與至少一個 close reason（REQ-006-01）② 選 `C99` 時 other reason 必填、`maxlength 100`（REQ-006-02）③ 於**單一 `@Transactional`** 寫 `TB_CLO_REASON`＋`TB_APP_HISTORY`，更新 `TB_LON_SUMMARY_INFO.CASE_PROGRESS=C1`（REQ-006-03）④ 結案後 `CURRENT_USER_ID` 清空（REQ-006-04）⑤ `IS_AUTODIS=M`→`MC`、`IS_AUTODIS=Y`→`YC`（REQ-006-05）。**as-is ⚠️**：待 RD 核對。

### R11 — proposal download（依 TYPE dispatch）　`covers-prd: REQ-007`　**強制點：FE+BE**　`@PENDING(TBD-006)`
**當** CA download 時，系統應依 `TYPE` dispatch 對應 `printProposal`（CS→`EPRO_CS0180`、CU→`EPRO_CU0180`、IS→`EPRO_IS0180`、IU→`EPRO_IU0180`），產製失敗回 `DOWNLOAD_FAILED`（500），且**不得異動業務資料**（→R14 audit）。**@PENDING(TBD-006)**：as-is 回傳 `encryptTempFileFullPath`（暴露可重複使用本機路徑）→ 新系統安全/檔案處理（建議 download token、授權、有效期限）＝RD 待補。**as-is ⚠️**：前端走 `goPath()` stub、非報表服務（F-9）→ 掛 R2 報表服務/檔案 API ⏸ track。

### R12 — session context（set/clear current application）　`covers-prd: REQ-002`（GOAL-002）　**強制點：FE+BE**　`@PENDING(TBD-008)`
**當**使用者點選 `applicationNo` 時，系統應建立 current application context（session `APPLICATION_NO`/`action`）；離開或結案時清除（REQ-006-04 連動）。**@PENDING(TBD-008)**：下游頁仍依賴 server session 時 `setSession`/`clearSession` 之保留期限與 session→route param 遷移策略＝RD 規劃——未裁前 session 契約形狀不定（故不入 openapi）。**as-is ⚠️**：server session、待核對。

### R13 — reason 選項取得（getReason／getCloReason）　`covers-prd: REQ-005`（§2.1）　**強制點：FE+BE**
**當** FE 開刪除/結案 popup 時，系統應由 API 回傳 `DEL_REASON`／`CLO_REASON` code→display map（`dataMap`），FE **以 API 來源為準**、不得以硬編碼覆蓋。**as-is ✅**：F-10（`2599752`）已移除 popup `setReasonList()` 硬編碼 D01–D99、改回 API 來源（空清單 fallback 照既有錯誤處理）。reason code table **值**＝`TBD-007`（PM/SA 補；不影響本取得機制）。

### R14 — 非功能（安全／效能／audit／log／交易）　`covers-prd: §7`　**強制點：BE**
系統應：① **安全**：BE 驗證 role authorization（delete/close/download），**不得只靠 FE 按鈕隱藏**；未授權回 `FORBIDDEN_ACTION`(403)（**權威於 BE**；參 Bible `TB_API_AUTH` `REF_FUNCTION_ID+API_ID+ROLE`）——**查詢端點 `epl-list-todolist` 不做 role 403**：role 只決定分支（一般/CAD）與資料範圍、403 僅適用 mutating（delete/close/download）（S6）② **效能**：initQuery/queryCAD 避免無限制大量回傳（分頁 `OFFSET/FETCH`、`size` 上限 **200**、清單查詢 **p95 < 3s**）、CAD 查詢須有條件與日期範圍限制（→R7）③ **audit**：mutating（delete/close/redistribution）audit 落 `TB_APP_HISTORY`（processor／`APP_PROCESS_CODE`／date）＋summary `CASE_PROGRESS` 轉換（前後可觀察）；prompt/query/download/session 之動作 audit 落**應用層 audit log（ops/log 層、非業務表）**（S5）④ **log**：delete/close/redistribution 記 `applicationNo`/role/processor/reason/前後 `CASE_PROGRESS`/rollback reason ⑤ **交易**：redistribution 批次更新設 timeout **30s** 與筆數上限 **500 筆/批**、逾時 rollback；delete/close/redistribution 單一交易（→R2/R9/R10）。**（②⑤ 數值＝SA 預設，RD/owner 可依實測調整）**。**as-is ⚠️**：分頁 as-is 在（`VMainBorrowerInfoRepository:63`）；其餘待 RD 核對。

## 🚩 @PENDING（PRD TBD → 規則；本表＝每個待決的單一出處）
> **TBD 不自行裁定**；裁定內容只寫這裡，他處標 token 指回。**blocking**＝是否擋契約/規則定版。
> ℹ️ 參考資源（非裁定）：TBD-001/003 → Bible v1.1 `TB_ROLE_DEFINE`/`TB_API_AUTH`/`TB_PROCESS_CODE` 錨點；TBD-003 R0397 證據 → 00100 findings（`TB_PROCESS_CODE.IS_SHOW=N`）。
> ℹ️ **R4（語系只影響呈現）＝owner 2026-06-15 已拍板、非 TBD**，不在下表 8 項內（N3）。

| id | 狀態 | 待決（PRD TBD）| 影響規則 | blocking | owner |
|---|---|---|---|---|---|
| TBD-001 | ⏸開 | 角色 001/002/003/101/102/103/201/202/203/301/302/404/405 正式名稱與**權限** | R1, R8, R14（auth）| 是（auth 完整性）| PM/SA |
| TBD-002 | ⏸開 | prompt 是否保留 CA/CR redistribution side effect；保留則 API method（init 應 POST）| R2 | 是（contract/method）| SA |
| TBD-003 | ⏸開 | `CASE_PROGRESS` `D1/C1/R0305/R0313/R0397` 與 CAD `21~25` 正式語意 | R3（排除集合 as-is 已坐實）, R8（CAD 導頁）| 部分（導頁需 21–25 語意；排除集合已坐實）| PM/SA |
| TBD-004 | ⏸開 | CAD 查詢 JSP 送 `DOC_NO`、module 讀 `NO` 之相容欄位 mapping | R6, R7 | 是（docNo 查詢正確性）| RD |
| TBD-005 | ⏸開 | CAD decision date range 是否需 backend 強制六個月限制 | R7 | 否（FE 已約 6 月；BE 強制為 polish）| SA/RD |
| TBD-006 | ⏸開 | download 回傳 encrypted temp file path 是否符新系統安全/檔案下載規範（token/授權/期限）| R11 | 是（安全/檔案設計）| RD |
| TBD-007 | ⏸開 | `DEL_REASON`/`CLO_REASON` code table 與 `D99`/`C99` other reason 規則（**值**層）| R9, R10, R13 | 部分（取得機制已定；值待補）| PM/SA |
| TBD-008 | ⏸開 | 下游頁仍依賴 server session 時 `setSession`/`clearSession` 保留期限與 session→route 遷移 | R12 | 否（可短期保留 session）| RD |

## Trade-offs（架構取捨）
- **CAD 查詢與一般清單合併同端點 `epl-list-todolist`（role 分支）vs 拆兩端點（PRD initQuery/queryCAD）**——as-is 已合併（role `404/405` 分支）。SRS 暫保留合併（減端點、共用分頁/排序），但 **proxy scope（R6）疑漏需先補**；若 RD 認為語意分歧過大再拆，屆時走 ADR。
- **prompt 端點 method（GET vs POST）**——受 redistribution 去留（TBD-002）牽動：保留 side effect→POST（REQ-001-05）；移除→可 GET。SRS 暫定 POST、待 TBD-002。
- **`clearSession` method**——PRD `clearSession=DELETE`（§6），SRS 改 **POST**（`epl-*` RPC 慣例用 POST、非 REST DELETE）；屬慣例對齊、非遺漏（N1）。

## Traceability Matrix（PRD REQ → Rn → QA）
| PRD REQ | Rn | QA covers |
|---|---|---|
| REQ-001 | R1（；R2 `@PENDING TBD-002`）| QA-001（+QA-002 `@PENDING TBD-002`）|
| REQ-002 | R3, R4, R5 | QA-003, QA-004, QA-005, QA-006 |
| REQ-002（session）| R12 `@PENDING TBD-008` | QA-013（`@PENDING TBD-008`）|
| REQ-003 | R6, R7 | QA-007, QA-008, QA-009, QA-021 |
| REQ-004 | R8 | QA-010 |
| REQ-005 | R9, R13 | QA-011, QA-012, QA-014, QA-016, QA-020 |
| REQ-006 | R10 | QA-015 |
| REQ-007 | R11 `@PENDING TBD-006` | QA-017（`@PENDING TBD-006`）|
| §7 NFR | R14 | QA-018, QA-019 |

## 硬界線
- 不得自行裁定 role/CASE_PROGRESS/reason 正式語意與權限（TBD-001/003/007）——Bible 錨點僅供 PM/SA 裁定參考，非代裁依據。
- 刪除/結案/download 為 mutating/敏感動作 → **BE 必須有權威授權與交易**（R9/R10/R14），不得僅 FE 控制。
- as-is `file:line` 為新系統現碼（產品 repo），引自 00100 findings；實作以現碼 + 本 SRS to-be 為準。

## as-is → to-be 摘要（給 RD）
- **已修（landed）**：langType regression（R4，`bbbaa19`/`7e1f0d2`，五頁筆數一致）；popup reason 改回 API 來源（R13，`2599752`）。
- **就緒子集（TBD 無關、可先核/實作）**：R3 待辦查詢主鏈（as-is ✅，整合測確認值）；R5 row enrichment 逐項對齊；R8 導頁逐條件對應（除 CAD 21–25 語意＝TBD-003）；R13 reason 取得機制。
- **blocked 子集（待 TBD）**：R2（TBD-002 redistribution/method）；R6 proxy scope＋R7 docNo（TBD-004）；R7 六月限制（TBD-005）；R11 download 安全（TBD-006）；R12 session 遷移（TBD-008）；R9/R10/R13 reason 值（TBD-007）；R1/R8/R14 role 權限（TBD-001）。
- **疑 regression（優先核）**：R6 CAD proxy scope（as-is 只 `CURRENT_USER_ID`、未含 active proxy）。
