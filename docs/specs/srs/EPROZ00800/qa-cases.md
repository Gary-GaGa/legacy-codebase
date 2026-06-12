# QA Cases — EPROZ00800 Revised Item

> 每條 `covers: Rn`（對 `spec.md`）；上游＝PRD `CDC-EPRO-0001 v1.1` §10。
> `@PENDING` = 受未關 TBD 控制，**TBD 關閉前不列入驗收門檻 ⑤**，但先寫好。**裁定輪 06-11**（裁定內容單一出處＝`spec.md` §@PENDING）：QA-007/008 解 pending、計入 gate⑤；QA-009 改掛 `RP4`；新增 QA-024（R13.2）/QA-025（R13.7）。
> Gate ④＝可跑綠、⑤＝每個 `Rn` 至少被一條 case `covers`。

## 由 PRD §10 轉入
| ID | covers | Given / When / Then | DB 驗證點 |
|---|---|---|---|
| QA-001 | R2 | 案件有 REVISED_ITEM 資料 / 開頁 init-query / 顯示既有勾選 + REASON_MEMO | `TB_REVISED_ITEM` by APPLICATION_NO 與畫面一致 |
| QA-002 | R2,R9 | 案件無 REVISED_ITEM、但 code table 有選項 / init-query / 顯示選項、ITEM 初始空白 | `TB_REVISED_ITEM` 無資料；revisedType 來自 `TB_COMMON_FIELD_OPTIONS` |
| QA-003 | R3 | 未勾任一 / 按儲存 / 阻擋 + 提示至少選一 | 無新增/異動 |
| QA-004 | R4 | 已勾但 REASON 空 / 按儲存 / 阻擋 + 提示必填 | 無新增/異動 |
| QA-005 | R5 | `LON_TYPE_CODE=03` / 進頁 / ITEM1 強制勾且不可編輯 | `LON_TYPE_CODE=03`；儲存後 ITEM1=Y |
| QA-006 | R6 | `isCU=true` / 進頁 / ITEM3 強制不勾且不可編輯 | 儲存後 ITEM3=N |
| QA-007 | R13.1 | 既有 ITEM2=Y、新=N、reference 有 guarantor / 確認提示後儲存 / 清目前 guarantor 並由 reference 還原 | `GUARANTOR_INFO`/`_CORP` 筆數與 reference 一致；`IS_ANY_GUARANTOR` 正確 |
| QA-008 | R13.3 | 既有 ITEM3=Y、新=N、reference 有 collateral / 確認後儲存 / 清 collateral 並還原 | `COLL_*`/`COLL_PROVIDER_INFO`/`COLL_TITLE_REGIS_OWNER` 正確；`IS_ANY_COLLATERAL_PROVIDER` 更新 |
| QA-009a | R13.4 | ITEM1/4~11 特定組合成立 / 確認後儲存 / 刪 detail＋page menu 標重處理 | `LOAN_CONDITION_DETAIL`/`REVISED_ITEM_DETAIL` 刪除符 RI-MAT-004；page menu 欄＝R14 v0.8 新欄（✅RP4 已關 06-12 拆分）|
| QA-009b | R13.5 | ITEM1/4~11 任一 Y→N / 確認後儲存 / 從原始 detail 逐欄還原 | 還原欄符 §5.5.2 矩陣——欄對應判據＝RP6 名稱表（ITEM1=Renew Loan Tenor／ITEM10=ATC_Tenor／ITEM11=ATC_Interest Rate 各自對欄）|
| QA-010 | R13.6 | `LON_TYPE=04`、既有 ITEM12=N、新=Y / 儲存 / 刪 fee | `LOAN_CONDITION_FEE` 目前 APPLICATION_NO 無資料 |
| QA-011 | R14 | 備 IS/IU/CS/CU 四種案件 / 各儲存 / 正確 checkpoint 表 + page-menu flag | `TB_CHECK_POINTS_{IS,IU,CS,CU}`：自欄 `EPROZ00800`=完成＋§5.6 重處理新頁欄=Y（IS: `EPROISU0110/0120/0130/0140/0150`；CS/CU/IU=DDL 子集；RP10 ✅06-12）|
| QA-012 | R10,R15,R16 | execute 中模擬 DAO exception / 送出 / rollback + `COMMON_MSG_SAVE_FAIL` | `TB_REVISED_ITEM`、關聯表、checkpoint **均無部分更新**（單一 transaction：R16）|

## SRS 補強（PRD §10 未涵蓋、但規則需驗）
| ID | covers | Given / When / Then | 驗證點 |
|---|---|---|---|
| QA-013 | R10 | execute endpoint / 呼叫 / **為 POST**（非 GET）| `epl-case-insert-reviseditem` method=POST |
| QA-014 | R9 | execute body item 帶**非法 enum 值**（如 `"X"`）/ 送出 / **BE 拒絕**（400/`COMMON_MSG_ERROR_LON`，與 openapi `ItemFlag` enum=[Y,N] 一致）、DB 不寫入 | `TB_REVISED_ITEM.ITEMn ∈ {Y,N}`、無新 insert。註：blank→N 正規化責任在 **FE**（PRD §5.3.2）；**blank 殘留至 BE 之處置（拒 400 vs 視同 N）PRD 未明定 → RD 定**，不在本 case 範圍、不裁定 |
| QA-015 | R11 | request `isNotSame=false` 但 DB 既有與新值不同 / execute / **後端仍依 DB 比對觸發側效**（不被 isNotSame 擋）| 側效依 DB 差異發生 |
| QA-016 | R14 | execute 成功 / response / 含 `pageMenuCondition`（重處理頁 key=Y）| response DTO 有 pageMenuCondition |
| QA-017 | R4 | REASON 輸入 3001 字 / 送出 / 阻擋（上限 3000）；前後空白 trim | DB REASON ≤3000、已 trim |
| QA-018 | R1 | 模擬 attrMap 取得失敗 / 開頁 prompt / 停止載入 + 顯示初始化失敗訊息 | FE 可觀察行為（prompt 非 `epl-*` RPC、無 openapi 契約點；`MSG_INITIAL_FAIL` 落點待 RD 於 routing 層定，見 spec Endpoints 註）|
| QA-019 | R7 | `attrMap.isEdit=false` / 進頁 / 所有欄位唯讀 + 隱藏完成鈕 | —（僅 to-be 表象；as-is 判據等效性見 QA-023/RP8）|
| QA-020 | R8 | checkbox 與既有不同 / 按儲存 / 送出前顯示「移除會清除相關修改」提示，確認後才送 | — |
| QA-021 | R12 | 案件已有 REVISED_ITEM / execute / 舊筆被刪、新 ITEM1~14+REASON+UPD_DATE 正確 insert | `TB_REVISED_ITEM` 僅 1 筆且值正確 |
| QA-023 `@PENDING RP8` | R6,R7 | （placeholder，RD 確認等價性後撰寫）構造 `secureAttribute≠'U'` 但 `isCU=true`（或反之）、`isEdit` 與 `canEditList/isShowList` 分歧之屬性組合 / 進頁 / 行為依 **RP8 關閉後裁定之判據**（to-be/as-is 何者為準待 RD，本 case 不預判）| 兩判據分歧情境下 ITEM3/唯讀行為符合 RP8 裁定結果 |
| QA-024 | R13.2 | 既有 ITEM2=N、新=Y、**reference 無 guarantor** / 儲存 / borrower `IS_ANY_GUARANTOR=Y` | `TB_MAIN_BORROWER_PERSONAL_INFO`（或 `_CORP`）`IS_ANY_GUARANTOR=Y`；guarantor 表無誤刪/誤增 |
| QA-025 | R13.7 | **兩方向各執行一次**：(a) 既有 ITEM13/14=N、新=Y；(b) 既有=Y、新=N / 儲存 / 僅勾選狀態持久化、**無任何關聯表側效** | 兩方向皆驗：`TB_REVISED_ITEM.ITEM13/14` 更新；guarantor/collateral/loan-condition/fee 各表**零異動** |

## 覆蓋率（gate ⑤）
- R1：QA-018｜R2：QA-001/002｜R3：QA-003｜R4：QA-004/017｜R5：QA-005｜R6：QA-006（+QA-023 @PENDING RP8）｜R7：QA-019（+QA-023 @PENDING RP8）｜R8：QA-020｜R9：QA-002/014｜R10：QA-012/013｜R11：QA-015｜R12：QA-021｜R13.1：QA-007｜R13.2：QA-024｜R13.3：QA-008｜R13.4：QA-009a｜R13.5：QA-009b（✅RP4 已關 06-12，計入 gate⑤）｜R13.6：QA-010｜R13.7：QA-025｜R14：QA-011/016｜R15：QA-012（**僅 rollback 分支**；成功/not-found path 尚無實 case → QA-022 RD 補，未撰寫）｜R16：QA-012（transaction）+ perf/log/**audit 側效摘要**（RP1=A 配套，RD 補）。
- 每個 `Rn` 至少 1 case ✅；但 R15 目前僅覆蓋 rollback 分支、R16 僅覆蓋 transaction，成功/not-found/perf/log/audit 之 happy/error path 待 RD 補實 case（QA-022 等尚未撰寫，不可當已覆蓋）。@PENDING 餘 QA-023（RP8），不計入 gate⑤；QA-007/008 已隨 RP1、QA-009a/b 已隨 RP4 關閉解 pending、計入 gate⑤。
