# QA Cases — EPROZ00100 TO DO LIST / Work-list Dashboard

> 每條 `covers: Rn`（對 `spec.md`）；上游＝PRD `CDC-EPRO-0001 v1.1` §8。
> `@PENDING` = 受未關 TBD 控制，**TBD 關前不列入驗收門檻 gate⑤**，但先寫好骨架。
> 寫法 test-ready（gate④ 橋接 `../../qa-to-test.md`）：Given 可 seed（表/列/欄值）、When 對得到 `epl-*`+method、Then 有 DB 斷言點。
> DB 驗證基準＝UT `OVSLXLON02`（findings 70201/role `002`/`en_US`）。

## 由 PRD §8 轉入（含 SRS 補強）
| ID | covers | Given / When / Then | DB 驗證點 |
|---|---|---|---|
| QA-001 | R1 | AO role `001` 登入 / 呼叫 `epl-comm-todolist-prompt` / 回 role flags（`isAO`=Y…）且前次 session 已清 | session 無殘留前次 `APPLICATION_NO`/`action`（FE 可觀察；role 來源 JWT `roleId`）|
| QA-002 `@PENDING TBD-002` | R2 | （placeholder，TBD-002 裁定 redistribution 去留/method 後撰寫）CA role `101` 進入、存在 active CR proxy case / 呼叫 prompt / 依裁定觸發或不觸發 redistribution | `TB_LON_SUMMARY_INFO`（`CURRENT_USER_ID`/`CR_CODE`/`RE_DISTRIBUTION`）＋`TB_APP_HISTORY` 依 TBD-002 裁定 |
| QA-003 | R3 | AO `70201`/role `002`/`en_US`，`CURRENT_USER_ID=70201` 有 85 筆 `CASE_PROGRESS=01` / POST `epl-list-todolist` / 回 85 筆、排除 `03/D1/R0305/R0313/R0397` | `V_MAIN_BORROWER_INFO` exact WHERE（`CURRENT_USER_ID=70201` ∧ `CASE_PROGRESS NOT IN(...)`）= 85；`R0397`/`D1` 不在結果 |
| QA-004 | R4 | 同一案件集 / 以 `langType=zh_TW` 與 `en_US` 各 POST `epl-list-todolist` 一次 / 兩次 `totalCount` 相同 | 兩語系筆數一致（langType 不進資料 WHERE；regression 已修 `bbbaa19`）|
| QA-005 | R5 | 案件 `APPLICATION_DATE=01/01/1900` 且有 `IS_Y=Y` related party / 查清單 / 該列日期顯示空白、`showRelated=Y` | `TB_RELATED_PARTY_INFO` `IS_Y=Y`；列 `applicationDate` 空白、`showRelated=Y` |
| QA-006 | R5 | 案件有多筆 USD+KHR loan condition detail / 查清單 / `amount` 為 USD/KHR 加總 | `TB_LOAN_CONDITION_DETAIL` 加總值與列 `amount` 一致 |
| QA-007 | R6 | CAD role `404`、提供 `applicationNo`、登入者有 active proxy / POST `epl-list-todolist`（CAD 分支）/ 範圍含本人＋active proxy、僅 `LON_TYPE_CODE∈{01,02,03,04}` | 結果命中 `TB_EMP_PROXY` active proxy 之案件（as-is proxy 疑缺→此為 to-be 斷言、RD 修點）；無 `LON_TYPE_CODE∉01-04` |
| QA-008 | R6 | 企金案件 / CAD 查詢 / `docNo1` = `REGISTER_NO`（企金）| 企金列 `docNo1`=`REGISTER_NO`；個金列為文件欄位轉換結果 |
| QA-009 | R7 | CAD role 查詢未給任何有效條件 / POST `epl-list-todolist`（CAD 分支）/ 回 `INVALID_CAD_QUERY_CONDITION`(400)、不執行全量查詢 | BE 擋下、無清單回傳（FE 與 BE 皆拒空查詢）|
| QA-010 | R8 | CAD Maker、案件 `CASE_PROGRESS=21` / 由清單點選導頁 / `page`=`EPROIS_0910` | 回傳列 `page`=`EPROIS_0910`（CAD Maker 21/22→0910）|
| QA-011 | R9 | AO role `003` / 呼叫 `epl-save-todolist-delete` / 回 403 `FORBIDDEN_ACTION`、不刪除 | `TB_DEL_REASON`/`TB_APP_HISTORY`/`TB_LON_SUMMARY_INFO` 均無異動（BE 權威擋）|
| QA-012 | R9 | role `001`、delete 選 `D99` 並填 `othReason`、同一交易 / POST `epl-save-todolist-delete` / 刪除成功 | `TB_DEL_REASON` 新增（`OTH_REASON` 有值）、`TB_APP_HISTORY` 新增、`TB_LON_SUMMARY_INFO.CASE_PROGRESS=D1` |
| QA-013 `@PENDING TBD-008` | R12 | （placeholder，TBD-008 裁定 session 保留/遷移後撰寫）點選 `applicationNo` / `epl-comm-todolist-setsession` / 建立 current application context | session `APPLICATION_NO` 正確（契約形狀待 TBD-008）|
| QA-014 | R9 | delete 未選任何 reason / POST `epl-save-todolist-delete` / 回 `MISSING_REASON`(400)、整批 rollback | `TB_DEL_REASON`/`TB_APP_HISTORY`/summary 三表零異動 |
| QA-015 | R10 | CAD close 選 `C99`、`IS_AUTODIS=Y`、同一交易 / POST `epl-save-todolist-close` / 結案成功 | `TB_CLO_REASON` 新增、`TB_APP_HISTORY` 新增、`TB_LON_SUMMARY_INFO.CASE_PROGRESS=C1` ∧ `CURRENT_USER_ID` 空白 ∧ `IS_AUTODIS=YC` |
| QA-016 | R13 | 開刪除 popup / GET `epl-sele-todolist-delreason` / 回 reason `dataMap`（來自 API、非硬編碼 D01–D99）| `dataMap` 來自 reason code table（F-10 已移除硬編碼覆蓋）|
| QA-017 `@PENDING TBD-006` | R11 | （placeholder，TBD-006 裁定 download 安全/檔案處理後撰寫）CA download `TYPE=IS` / `epl-file-todolist-download` / 回安全 file reference、不異動業務資料 | 無業務 DB 異動；audit log 有 print/download（檔案回傳形式待 TBD-006）|
| QA-018 | R14 | 未授權 role 嘗試結案 / 呼叫 `epl-save-todolist-close` / 回 403 `FORBIDDEN_ACTION`（BE 擋、非僅 FE 隱藏鈕）| 無 `TB_CLO_REASON`/`TB_APP_HISTORY` 新增 |
| QA-019 | R14 | role `001` delete 成功完成 / 完成後檢視 audit / audit 含 `applicationNo`/role/processor/reason/old-new `CASE_PROGRESS` | `TB_APP_HISTORY` `PROCESSOR_CODE`/`APP_PROCESS_CODE` 有值；audit log 含異動欄位 |

## 覆蓋率（gate⑤）
- R1：QA-001｜R3：QA-003｜R4：QA-004｜R5：QA-005/006｜R6：QA-007/008｜R7：QA-009｜R8：QA-010｜R9：QA-011/012/014（perm/happy/error 三面）｜R10：QA-015｜R13：QA-016｜R14：QA-018（安全）/QA-019（audit）。
- 每個非-@PENDING `Rn` 至少 1 case ✅。
- @PENDING（不計 gate⑤，TBD 關後解 pending）：R2＝QA-002（TBD-002）、R11＝QA-017（TBD-006）、R12＝QA-013（TBD-008）。
- 待整合測補深度（happy/error/edge 擴充，非阻擋定稿）：R5 金額加總多幣別組合、R8 全 routing 條件矩陣、R14 效能/log 量化 case。
