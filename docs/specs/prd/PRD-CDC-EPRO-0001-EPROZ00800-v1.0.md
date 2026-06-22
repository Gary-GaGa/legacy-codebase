資訊開發中心

# 業務需求導向的功能規格書

CDC-EPRO-0001 EPROZ00800 Revised Item
版本：Version 1.1
更新日期：2026/06/08

| 文件狀態 | PM Review Draft - 待 PM / SA / RD 確認後進入開發規格 |
| --- | --- |
| 文件目的 | 依舊系統 EPROZ0_0800 source code 與功能備註說明，整理 Revised Item 重構需求。 |
| 主要系統鏈路 | eProposal Frontend -> eProposal Backend -> DB |
| 本版補強重點 | 移除不屬於 EPROZ0_0800 的原範本內容，補入現行流程、資料影響、錯誤處理、驗收標準、審查清單與待確認項目。 |

## 0. 文件控制

## 0.0 文件定位與使用方式

| 項目 | 說明 |
| --- | --- |
| 文件定位 | 本文件為業務需求導向的功能規格書 PM Review Draft，用於 PM 初審、SA 業務規則核對、RD 系統開發規格書核對與 QA 測試案例設計。 |
| 目前可用於 | 確認 EPROZ00800 Revised Item 的業務範圍、現行 source code 行為、資料影響、測試重點與待確認事項。 |
| 目前不可直接用於 | 不可在 TBD 未關閉前視為開發定版規格；不可把 legacy source code 行為直接視為已核准的新需求。 |
| 進入開發前條件 | 第 12 章 PM / SA / RD Review Checklist 必須完成，且第 0.3 章 TBD 項目需關閉或有明確決策與 owner。 |

## 0.1 修訂紀錄

| 修訂時間 | 修訂記錄 | 修訂版本 | 修訂者 |
| --- | --- | --- | --- |
| 2026/06/08 | 依 EPROZ0_0800 source summary 產出 Revised Item SRS 初稿 | 1.0 | AI Agent |
| 2026/06/08 | 補 ITEM code table 對照結構、5.5 矩陣、API schema、非功能需求、Given/When/Then 測試與 DB 驗證點 | 1.1 | AI Agent |

## 0.2 文件 Review 紀錄

| 日期 | 文件 Review 記錄 | Review 版本 | Reviewer |
| --- | --- | --- | --- |
|  | PM 確認 Revised Item 業務範圍、是否保留舊系統清除/還原副作用 | 1.0 |  |
|  | SA 確認 ITEM1~ITEM14 業務名稱、LON_TYPE_CODE 規則 | 1.0 |  |
|  | RD 確認 API、DB transaction、checkpoint/page menu 更新策略 | 1.0 |  |
|  | QA 確認 SIT / UAT 測試案例與驗收標準 | 1.0 |  |
|  | PM 確認 v1.1 補強後的業務範圍、ITEM 對照、是否保留 legacy 清除 / 還原副作用 | 1.1 |  |
|  | SA 確認 ITEM1~ITEM14 業務名稱、LON_TYPE_CODE 規則、ITEM13 / ITEM14 是否有資料影響 | 1.1 |  |
|  | RD 確認 API schema、transaction、DB 清除 / 還原矩陣、checkpoint / page menu 更新策略 | 1.1 |  |
|  | QA 確認 Given / When / Then 測試案例與 DB 驗證點是否足夠 | 1.1 |  |

## 0.3 待確認項目

| TBD ID | 待確認項目 | 影響範圍 | 建議處理 |
| --- | --- | --- | --- |
| TBD-001 | ITEM1~ITEM14 在 EPRO / REVISED_ITEM code table 的正式顯示名稱 | 畫面 / 規則 / 測試 | 本版已補 source 可確認的 ITEM 對應行為；正式顯示名稱仍需由 DB 匯出 TB_COMMON_FIELD_OPTIONS 後確認。 |
| TBD-002 | 舊畫面按鈕文字為 Finshed，重構後是否修正為 Finished | UI | 由 PM / UX / RD 確認。 |
| TBD-003 | LON_TYPE_CODE = 03 時強制勾選 ITEM1 的業務原因 | 業務規則 | 由 SA 確認。 |
| TBD-004 | LON_TYPE_CODE = 04 且 ITEM12 N -> Y 時刪除 fee 的業務原因 | Loan Condition Fee | 由 SA / RD 確認。 |
| TBD-005 | ITEM1 與 ITEM10 皆還原 TENOR 的原因 | Loan Condition | 由 RD / SA 確認是否為 legacy 設計或缺陷。 |
| TBD-006 | 重構後是否完整保留舊系統清除/還原副作用，或改成明確使用者確認流程 | 流程 / 資料風險 | 由 PM / SA / RD 共同決策。 |
| TBD-007 | ITEM13 / ITEM14 是否僅為顯示與儲存項目，或是否存在未被 EPROZ0_0800_mod 涵蓋的下游資料影響 | 畫面 / 儲存 / 下游頁籤 / 測試 | 由 SA / RD 依 code table、其他 function 與實際業務流程確認。 |

## 1. 需求概述

## 1.1 需求背景

Revised Item 是 eProposal 共用頁籤，用於案件條件變更或續約情境中，記錄本次修訂項目與修訂原因。舊系統 Function ID 為 EPROZ0_0800，重構後對應頁籤為 EPROZ00800。
本文件依功能備註說明.xlsx、既有 migration inventory、EPROZ0_0800.java、EPROZ0_0800_mod.java、EPROZ00800.jsp 與相關 SQL 整理，作為後續重構、開發與測試依據。

## 1.2 業務目標

| 目標 ID | 業務目標 | 成功標準 |
| --- | --- | --- |
| GOAL-001 | 讓使用者可選擇 Revised Item 並填寫修訂原因 | 至少一個 Revised Item 被選取且原因通過驗證後可儲存。 |
| GOAL-002 | 保留現行系統對關聯資料的清除/還原邏輯 | 儲存時依 ITEM 變更正確影響 guarantor、collateral、loan condition、fee 與 checkpoint。 |
| GOAL-003 | 讓後續頁籤狀態能因 Revised Item 變更重新處理 | 儲存後回傳 pageMenuCondition，相關頁籤標記為需重新處理。 |

## 1.3 需求名稱與服務說明

| 需求名稱 | Revised Item |
| --- | --- |
| 舊 Function ID | EPROZ0_0800 |
| 重構系統頁籤 | EPROZ00800 |
| 頁籤名稱 | Revised Item |
| 分類 | 共用 |
| 案件類型 |  |
| 使用範圍 | eProposal |
| 前端系統 | eProposal Frontend |
| 後端系統 | eProposal Backend |

## 1.4 本期範圍與非本期範圍

| 類別 | 內容 |
| --- | --- |
| 本期範圍 | Revised Item 初始查詢、選項顯示、必填檢核、儲存、關聯資料清除/還原、checkpoint/page menu 更新。 |
| 非本期範圍 | ITEM1~ITEM14 code table 維護、非 EPROZ0_0800 頁籤的完整重構、報表內容重製。 |
| 文件邊界 | 本文件描述 EPROZ0_0800 現行業務邏輯與 EPROZ00800 重構需求，並提供業務層 API / Interface 草案。正式 endpoint、DTO 型別、欄位 enum、validation annotation、DB schema detail 與 repository / SQL 設計，仍以後續系統開發規格書為準。 |

## 1.5 角色與系統職責

| 角色 / 系統 | 職責 |
| --- | --- |
| 使用者 | 於 Revised Item 頁籤選擇修訂項目並填寫修訂原因。 |
| eProposal Frontend | 顯示 Revised Item checkbox、原因欄位、驗證必填與送出儲存請求。 |
| eProposal Backend | 查詢既有資料、執行儲存交易、處理關聯資料清除/還原與 checkpoint 更新。 |
| DB | 保存 Revised Item、關聯資料、checkpoint 與頁籤狀態。 |
| PM / SA / RD / QA | 確認範圍、規則、設計與驗收案例。 |

## 2. 現行系統行為

## 2.1 Source Code Mapping

| Layer | 檔案 / Method | 現行行為摘要 |
| --- | --- | --- |
| Transaction | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0800.java | 定義 prompt、initQuery、execute 三個 action。 |
| Module | EPROWeb/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0800_mod.java | 處理初始查詢、儲存、關聯資料清除/還原、checkpoint 更新。 |
| JSP | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0800/EPROZ00800.jsp | 動態產生 checkbox 表格與儲存操作。 |
| SQL | SQL/com/cathaybk/epro/z0/module/com.cathaybk.epro.z0.module.EPROZ0_0800_mod.*.sql | 查詢 reference application 的 guarantor / collateral 等資料。 |

## 2.2 Action 清單

| Action | Type | Source Method | 行為 |
| --- | --- | --- | --- |
| prompt | Submit | doPrompt | 開啟 EPROZ00800.jsp，回傳 lonTypeCode 與 attrMap。 |
| initQuery | AJAX | doInitQuery | 查詢 Revised Item 選項與既有儲存資料。 |
| execute | AJAX | doExecute | 儲存 Revised Item，並觸發關聯資料清除/還原與 checkpoint 更新。 |

## 2.3 現行畫面規則

- Revised Item checkbox 由 EPRO / REVISED_ITEM code table 動態產生。
- 至少需勾選一個 Revised Item 才可送出。
- Reason for renew/change condition 為必填，maxlength 為 3000。
- 若 LON_TYPE_CODE = 03，checkbox_01 強制勾選且不可編輯。
- 若 LON_TYPE_CODE 不是 03，checkbox_01 強制不勾選且不可編輯。
- 若 attrMap.isCU 為 true，checkbox_03 強制不勾選且不可編輯。
- 若 attrMap.isEdit 為 false，所有欄位不可編輯，且隱藏完成按鈕。
- 若 checkbox 狀態與既有資料不同，送出前提示使用者：移除 Revised Item 會清除相關修改。

## 3. 目標業務流程

## 3.1 正常流程

| 步驟 | Actor | 處理內容 | 輸出 / 結果 |
| --- | --- | --- | --- |
| 1 | 使用者 | 進入 Revised Item 頁籤。 | 前端送出 prompt。 |
| 2 | Backend | 取得 attrMap、APPLICATION_NO、角色與編輯權限。 | 回傳頁面所需屬性。 |
| 3 | Frontend | 呼叫 initQuery。 | 送出 APPLICATION_NO。 |
| 4 | Backend | 查詢 code table 與既有 Revised Item。 | 回傳 revisedType、revisedTypeSize、rtnMap。 |
| 5 | 使用者 | 勾選 Revised Item 並填寫原因。 | 前端執行必填驗證。 |
| 6 | Frontend | 若狀態變更，顯示清除相關修改提示。 | 使用者確認後送出 execute。 |
| 7 | Backend | 於 transaction 中儲存 Revised Item 並處理關聯資料。 | 更新 DB 與 checkpoint。 |
| 8 | Frontend | 依回傳結果更新頁籤狀態。 | 完成儲存。 |

## 3.2 例外流程

| 情境 | 觸發條件 | 系統處理 | 使用者結果 |
| --- | --- | --- | --- |
| APPLICATION_NO 空白 | initQuery 或 execute 未取得案件編號 | 後端回傳輸入錯誤。 | 不可完成查詢或儲存。 |
| 未勾選 Revised Item | 所有 checkbox 皆未勾選 | 前端阻擋送出。 | 提示至少需選擇一項。 |
| 未填寫原因 | Reason 欄位空白 | 前端阻擋送出。 | 提示必填。 |
| 移除既有 Revised Item | 新舊 checkbox 狀態不同 | 前端提示會清除相關修改。 | 使用者確認後才送出。 |
| 後端查無資料 | DAO 查詢拋出 DataNotFoundException | 回傳 MSG_DATA_NOT_FOUND。 | 顯示查無資料。 |
| 後端儲存失敗 | transaction 中發生例外 | rollback 並回傳 COMMON_MSG_SAVE_FAIL。 | 儲存失敗。 |

## 4. 需求清單與追蹤矩陣

| Requirement ID | 功能名稱 | 優先度 | 狀態 | 對應章節 |
| --- | --- | --- | --- | --- |
| EPROZ00800-REQ-001 | 開啟 Revised Item 頁面 | Must | In Scope | 5.1 |
| EPROZ00800-REQ-002 | 查詢 Revised Item 選項與既有資料 | Must | In Scope | 5.2 |
| EPROZ00800-REQ-003 | Revised Item 與原因欄位檢核 | Must | In Scope | 5.3 |
| EPROZ00800-REQ-004 | 儲存 Revised Item | Must | In Scope | 5.4 |
| EPROZ00800-REQ-005 | 關聯資料清除與還原 | Must | In Scope | 5.5 |
| EPROZ00800-REQ-006 | Checkpoint / Page Menu 更新 | Must | In Scope | 5.6 |
| EPROZ00800-REQ-007 | 錯誤處理 | Must | In Scope | 8 |

## 5. 功能需求

## 5.1 EPROZ00800-REQ-001 開啟 Revised Item 頁面

| 項目 | 內容 |
| --- | --- |
| Trigger | 使用者進入 EPROZ00800 Revised Item 頁籤。 |
| Input | lonTypeCode、使用者角色、APPLICATION_NO |
| Process | 後端呼叫 EPRO_Z0Z006.getAttribute 取得 attrMap，並開啟 EPROZ00800.jsp。 |
| Output | attrMap、lonTypeCode |
| Error | 初始化失敗回傳 MSG_INITIAL_FAIL。 |

## 5.2 EPROZ00800-REQ-002 查詢 Revised Item 選項與既有資料

## 1. 前端以 APPLICATION_NO 呼叫 initQuery。

## 2. 後端查詢 EPRO / REVISED_ITEM code table，回傳 revisedType 與 revisedTypeSize。

## 3. 後端查詢 EPRO_TB_LON_SUMMARY_INFO，回傳 LON_TYPE_CODE。

## 4. 後端查詢 EPRO_TB_REVISED_ITEM；若有資料，回傳 REASON_MEMO 與 ITEM1~ITEM14。

## 5. 若無既有 Revised Item，init-query response 中 ITEM1~ITEM14 以空白初始化；儲存送出前需正規化為 N。

## 5.3 EPROZ00800-REQ-003 Revised Item 與原因欄位檢核

| 欄位 / 項目 | 規則 |
| --- | --- |
| ITEM1~ITEM14 | 至少需勾選一項。正式業務名稱待 code table 確認。 |
| REASON_MEMO | 必填，長度上限 3000。 |
| ITEM1 | LON_TYPE_CODE = 03 時強制勾選且不可編輯；其他 LON_TYPE_CODE 強制不勾選且不可編輯。 |
| ITEM3 | attrMap.isCU = true 時強制不勾選且不可編輯。 |
| 編輯權限 | attrMap.isEdit = false 時全部欄位不可編輯，且隱藏完成按鈕。 |

## 5.3.1 ITEM1~ITEM14 code table 對照

Revised Item 顯示選項由 EPRO_Z0Z001.getCommonFieldOptions("EPRO", locale, "REVISED_ITEM") 取得，來源為 TB_COMMON_FIELD_OPTIONS。source code 未包含正式 DB code table 資料列，因此本表先列出 ITEM 編號、MSG_OPTION 與 source 可確認的資料影響；正式顯示名稱需由 DB 匯出確認後填入。

| ITEM 欄位 | MSG_OPTION | 正式顯示名稱 | source 可確認影響 | 備註 |
| --- | --- | --- | --- | --- |
| ITEM1 | 01 |  | TENOR | LON_TYPE_CODE = 03 時強制 Y；其他 loan type 強制 N。正式名稱待 TB_COMMON_FIELD_OPTIONS 確認。 |
| ITEM2 | 02 |  | Guarantor / IS_ANY_GUARANTOR | 影響 guarantor personal / corporate 資料清除、還原與 borrower flag。 |
| ITEM3 | 03 |  | Collateral / IS_ANY_COLLATERAL_PROVIDER | CU 案件強制 N；影響 collateral 與 collateral provider 資料清除、還原。 |
| ITEM4 | 04 |  | LOAN_PURPOSE、LOAN_PURPOSE_OTHER | 影響 loan condition detail 還原。 |
| ITEM5 | 05 |  | LOAN_AMOUNT_CURRENCY、LOAN_AMOUNT | 影響 loan condition detail 還原。 |
| ITEM6 | 06 |  | FACILITY_TYPE、FACILITY_TYPE_OTHER | 影響 loan condition detail 還原。 |
| ITEM7 | 07 |  | REPAYMENT_MODE、REPAYMENT_MODE_OTHER | 影響 loan condition detail 還原。 |
| ITEM8 | 08 |  | REPAYMENT_FREQUENCY | 影響 loan condition detail 還原。 |
| ITEM9 | 09 |  | GRACE_PERIOD | 影響 loan condition detail 還原。 |
| ITEM10 | 10 |  | TENOR | 影響 loan condition detail 還原；與 ITEM1 同為 TENOR，原因待確認。 |
| ITEM11 | 11 |  | RATE_TYPE、FIX_RATE、tier rate fields | 影響利率相關欄位還原。 |
| ITEM12 | 12 |  | EPRO_TB_LOAN_CONDITION_FEE | LON_TYPE_CODE = 04 且 N -> Y 時刪除 fee。 |
| ITEM13 | 13 |  |  | source 未於 EPROZ0_0800_mod 中找到明確資料清除/還原規則；待 code table 與 SA 確認。 |
| ITEM14 | 14 |  |  | source 未於 EPROZ0_0800_mod 中找到明確資料清除/還原規則；待 code table 與 SA 確認。 |

## 5.3.2 ITEM blank / N / Y 正規化規則

ITEM1~ITEM14 查詢回傳與儲存送出的資料規則不同。查詢回傳允許 blank，表示案件尚未建立 Revised Item 資料；儲存送出時，Frontend 必須將 blank 正規化為 N。Backend 寫入 EPRO_TB_REVISED_ITEM 時，ITEM1~ITEM14 僅允許 Y / N，不得保存 blank。

| 階段 | ITEM1~ITEM14 允許值 | 規則 |
| --- | --- | --- |
| init-query response | Y / N / blank | blank 表示尚未建立 Revised Item 資料。 |
| execute request | Y / N | Frontend 需將 blank 正規化為 N。 |
| DB 儲存 | Y / N | Backend 不得保存 blank。 |
| 畫面顯示 | checked / unchecked | Y 顯示勾選，N / blank 顯示未勾選。 |

## 5.4 EPROZ00800-REQ-004 儲存 Revised Item

## 1. 前端將 ITEM1~ITEM14 與 REASON_MEMO 組成 itemMap JSON。

## 2. 前端將 APPLICATION_NO 與 EPROZ0_0800 = N 組成 checkPointMap JSON。

## 3. 若前端判斷新舊 itemMap 不同，送出 isNotSame 作為已提示使用者的輔助資訊。

## 4. 後端開始 transaction。

## 5. 後端重新查詢 DB 既有 ITEM1~ITEM14，與 request itemMap 正規化後結果進行二次比對。

## 6. 後端刪除目前 APPLICATION_NO 的 EPRO_TB_REVISED_ITEM。

## 7. 後端插入新的 EPRO_TB_REVISED_ITEM，包含 APPLICATION_NO、ITEM1~ITEM14、REASON_MEMO、UPD_DATE。

## 8. 後端更新 checkpoint/page menu 狀態。

## 9. 成功則 commit 並回傳 rtnList；失敗則 rollback。

## 5.4.1 Backend execute 差異判斷邏輯

isNotSame 僅作為前端是否已提示使用者的輔助資訊，不得作為後端判斷資料差異的唯一依據。Backend execute 時，必須重新查詢 DB 既有 ITEM1~ITEM14 狀態，並與 request itemMap 進行比對，作為是否觸發清除 / 還原邏輯的最終依據。

## 1. 依 applicationNo 查詢既有 EPRO_TB_REVISED_ITEM。

## 2. 若查無既有資料，將既有 ITEM1~ITEM14 視為 N。

## 3. 將 request itemMap.item1~item14 正規化為 Y / N。

## 4. 比對 oldItemMap 與 newItemMap。

## 5. 依比對結果觸發 RI-MAT-001 ~ RI-MAT-007 的清除 / 還原規則。

## 6. isNotSame 僅用於確認前端是否曾提示使用者，不作為資料異動唯一判斷條件。

## 5.5 EPROZ00800-REQ-005 關聯資料清除與還原

本章以 source code 可確認行為為基礎，整理 Revised Item 變更時對 guarantor、collateral、loan condition、fee 與 checkpoint 的資料影響。若 source code 未能確認明確資料異動邏輯，應標示為待 SA / RD 確認，不得自行推論。

## 5.5.1 關聯資料清除 / 還原矩陣

| 情境 ID | 觸發條件 | 影響資料 | 清除動作 | 還原 / 更新動作 | DB 驗證點 |
| --- | --- | --- | --- | --- | --- |
| RI-MAT-001 | 既有 ITEM2 = Y 且新 ITEM2 = N | Guarantor | 刪除目前 APPLICATION_NO 的 EPRO_TB_GUARANTOR_INFO、EPRO_TB_GUARANTOR_INFO_CORP | 由 REF_APPLICATION_NO 複製 guarantor personal / corporate；還原 IS_ANY_GUARANTOR | 目前案件 guarantor 筆數與 reference 有效資料一致；borrower flag 正確 |
| RI-MAT-002 | 既有 ITEM2 = N、新 ITEM2 = Y，且 reference application 無 guarantor | Borrower flag | 無 | 目前 borrower IS_ANY_GUARANTOR 更新為 Y | EPRO_TB_MAIN_BORROWER_PERSONAL_INFO 或 EPRO_TB_MAIN_BORROWER_INFO_CORP flag = Y |
| RI-MAT-003 | 既有 ITEM3 = Y 且新 ITEM3 = N | Collateral | 刪除目前 APPLICATION_NO 的 collateral、valuation、site visit、title、provider、owner 等資料 | 由 REF_APPLICATION_NO 複製有效 collateral 相關資料；更新 IS_ANY_COLLATERAL_PROVIDER | collateral 相關表筆數、COLL_DATA_SEQ、provider flag 正確 |
| RI-MAT-004 | ITEM1、ITEM4~ITEM11 特定組合成立 | Loan Condition Detail | 刪除目前 APPLICATION_NO 的 EPRO_TB_LOAN_CONDITION_DETAIL 與 EPRO_TB_REVISED_ITEM_DETAIL | 無；需由後續頁籤重新處理 | 兩表目前案件資料已刪除；相關 page menu 被標示需重處理 |
| RI-MAT-005 | ITEM1 / ITEM4~ITEM11 由 Y 改為 N | Loan Condition Detail | 無整批刪除 | 從原始 loan condition detail 還原對應欄位並更新 EPRO_TB_REVISED_ITEM_DETAIL | TENOR、LOAN_PURPOSE、LOAN_AMOUNT、FACILITY_TYPE、REPAYMENT、RATE 等欄位還原正確 |
| RI-MAT-006 | LON_TYPE_CODE = 04、既有 ITEM12 = N、新 ITEM12 = Y | Loan Condition Fee | 刪除目前 APPLICATION_NO 的 EPRO_TB_LOAN_CONDITION_FEE | 無 | EPRO_TB_LOAN_CONDITION_FEE 目前案件資料已刪除 |
| RI-MAT-007 | ITEM13 或 ITEM14 變更 |  |  |  | EPROZ0_0800_mod 未見明確資料清除/還原規則；待 SA/RD 確認 |

## 5.5.2 Loan Condition ITEM 欄位影響矩陣

| ITEM | 影響欄位 |
| --- | --- |
| ITEM1 | TENOR |
| ITEM4 | LOAN_PURPOSE、LOAN_PURPOSE_OTHER |
| ITEM5 | LOAN_AMOUNT_CURRENCY、LOAN_AMOUNT |
| ITEM6 | FACILITY_TYPE、FACILITY_TYPE_OTHER |
| ITEM7 | REPAYMENT_MODE、REPAYMENT_MODE_OTHER |
| ITEM8 | REPAYMENT_FREQUENCY |
| ITEM9 | GRACE_PERIOD |
| ITEM10 | TENOR |
| ITEM11 | RATE_TYPE、FIX_RATE、tier rate fields |

## 5.5.3 Loan Condition Fee 特殊規則

當 LON_TYPE_CODE = 04、既有 ITEM12 = N 且新 ITEM12 = Y 時，系統會刪除目前案件 EPRO_TB_LOAN_CONDITION_FEE。

## 5.6 EPROZ00800-REQ-006 Checkpoint / Page Menu 更新

| Attribute | Checkpoint DAO | 儲存時標記 |
| --- | --- | --- |
| IS | EPRO_TB_CHECK_POINT_RC | EPROIS_0260 |
| IU | EPRO_TB_CHECK_POINT_RC_IU | EPROIU_0260 |
| CS | EPRO_TB_CHECK_POINT_RC_CORP | EPROCS_0260 |
| CU | EPRO_TB_CHECK_POINT_RC_CU | EPROCU_0260 |

| Attribute | Revised Item 變更時需重處理頁籤 |
| --- | --- |
| IS | EPROIS_0210、EPROIS_0220、EPROIS_0230、EPROIS_0250、EPROIS_0290 |
| IU | EPROIU_0210、EPROIU_0220、EPROIU_0230 |
| CS | EPROCS_0210、EPROCS_0220、EPROCS_0230、EPROCS_0250 |
| CU | EPROCU_0210、EPROCU_0220、EPROCU_0230 |

## 6. API / Interface 規格

## 6.1 API 清單

| API ID | 用途 | HTTP Method | Endpoint | 對應舊 action | 對應需求 |
| --- | --- | --- | --- | --- | --- |
| API-001 | 開啟頁面 / 取得頁面屬性 | GET | /api/eproposal/eproz00800/prompt | prompt | EPROZ00800-REQ-001 |
| API-002 | 初始查詢 | GET | /api/eproposal/eproz00800/init-query | initQuery | EPROZ00800-REQ-002 |
| API-003 | 儲存 Revised Item | POST | /api/eproposal/eproz00800/execute | execute | EPROZ00800-REQ-004~006 |

## 6.2 Request Schema

| API | 位置 | 欄位 | 型別 | 必填 | 規則 / 說明 |
| --- | --- | --- | --- | --- | --- |
| API-001 | query | applicationNo | String | Y | 案件編號；對應 APPLICATION_NO。 |
| API-001 | query | lonTypeCode | String | N | 舊 prompt 會回傳 lonTypeCode；重構後是否由後端自行查詢待 RD 設計。 |
| API-002 | query | applicationNo | String | Y | 不得空白。 |
| API-003 | body | applicationNo | String | Y | 不得空白；長度、格式、特殊字元限制由系統開發規格書定義。 |
| API-003 | body | itemMap.item1~item14 | String | Y | enum：Y / N；Frontend 需將 blank 正規化為 N。 |
| API-003 | body | itemMap.reasonMemo | String | Y | maxlength 3000；需 trim；是否允許換行由 RD / UX 確認。 |
| API-003 | body | checkPointMap | Object | Y | 必填 key：applicationNo、EPROZ0_0800；允許 value：Y / N。 |
| API-003 | body | isNotSame | Boolean / null | N | true 表示前端已提示使用者；false / null 不得阻止後端 oldItemMap / newItemMap 二次比對。 |

## 6.2.1 Enum / Validation 補充規則

| 欄位 | enum / validation | 備註 |
| --- | --- | --- |
| applicationNo | 必填；不可空白；長度與格式待系統開發規格書定義 | 不得依前端輸入直接信任。 |
| lonTypeCode | 已知特殊值：03、04；完整 enum 待 code table / SA 確認 | 03 影響 ITEM1；04 影響 ITEM12 fee。 |
| item1~item14 | Y / N | 儲存與 DB 僅允許 Y / N。 |
| reasonMemo | 必填；maxlength 3000；trim；換行規則待確認 | 不得儲存全空白字串。 |
| isNotSame | true / false / null | 僅為前端提示輔助資訊。 |
| checkPointMap | applicationNo、EPROZ0_0800 必填；value = Y / N | 其他 checkpoint key 由後端依 attribute 決定。 |

API schema 本章為業務層草案。實作前 RD 需於系統開發規格書補齊 DTO 欄位型別、enum、validation annotation、錯誤訊息 mapping 與 request / response 範例。

## 6.3 Response Schema

| API | 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- | --- |
| API-001 | attrMap | Object | Y | 頁面屬性、權限、APPLICATION_NO、isEdit、isCU 等。 |
| API-001 | lonTypeCode | String | N | loan type code。 |
| API-002 | revisedType | Object / Map | Y | Key = MSG_OPTION，Value = LANG_NAME。 |
| API-002 | revisedTypeSize | Number | Y | Revised Item 選項數量。 |
| API-002 | rtnMap.lonTypeCode | String | Y | LON_TYPE_CODE。 |
| API-002 | rtnMap.item1~item14 | String | Y | Y / N / blank。 |
| API-002 | rtnMap.reasonMemo | String | N | 既有修訂原因。 |
| API-003 | rtnList[0] | Object | Y | 儲存後 Revised Item 與 IS_ANY_GUARANTOR、IS_ANY_COLLATERAL_PROVIDER。 |
| API-003 | rtnList[1] | Object | Y | pageMenuCondition；Key 為頁籤 function id，Value = Y。 |

## 6.4 Error Response

| 錯誤代碼 | HTTP Status | 來源 action | 情境 | 前端處理 |
| --- | --- | --- | --- | --- |
| MSG_INITIAL_FAIL | 500 | prompt | 頁面初始化失敗 | 顯示初始化失敗，停止載入。 |
| COMMON_MSG_ERROR_LON | 400 | initQuery / execute | APPLICATION_NO 空白或不合法 | 顯示輸入錯誤。 |
| MSG_DATA_NOT_FOUND | 404 | initQuery / execute | 查無資料 | 顯示查無資料。 |
| MSG_OVER_COUNT_LIMIT | 400 | initQuery | 查詢筆數超過系統限制 | 提示縮小查詢範圍。 |
| MSG_QUERY_FAIL | 500 | initQuery | 查詢失敗 | 顯示查詢失敗。 |
| COMMON_MSG_SAVE_FAIL | 500 | execute | 儲存或 transaction 失敗 | 顯示儲存失敗。 |
| COMMON_MSG_SAVE_SUCCESS | 200 | execute | 儲存成功 | 顯示儲存成功並更新頁籤狀態。 |

## 7. 資料規格與 DB Mapping

## 7.1 欄位 Mapping

| 業務欄位 | DB / 欄位 | 規則 |
| --- | --- | --- |
| APPLICATION_NO | 多數相關表 APPLICATION_NO | 目前案件編號。 |
| REF_APPLICATION_NO | EPRO_TB_LON_SUMMARY_INFO.REF_APPLICATION_NO | reference application，用於還原資料。 |
| LON_TYPE_CODE | EPRO_TB_LON_SUMMARY_INFO.LON_TYPE_CODE | 控制 ITEM1 與 ITEM12 相關規則。 |
| LON_ATTRIBUTE + SECURE_ATTRIBUTE | EPRO_TB_LON_SUMMARY_INFO | 組合判斷 IS / IU / CS / CU。 |
| ITEM1~ITEM14 | EPRO_TB_REVISED_ITEM.ITEM1~ITEM14 | Y/N；正式業務名稱待 code table 確認。 |
| REASON_MEMO | EPRO_TB_REVISED_ITEM.REASON_MEMO | 修訂原因，必填，上限 3000。 |
| UPD_DATE | EPRO_TB_REVISED_ITEM.UPD_DATE | 儲存日期。 |

## 7.2 主要資料表

| Table / DAO | 用途 |
| --- | --- |
| EPRO_TB_REVISED_ITEM | 保存 Revised Item 主資料。 |
| EPRO_TB_REVISED_ITEM_DETAIL | 保存或更新與 loan condition 相關的修訂明細。 |
| EPRO_TB_LON_SUMMARY_INFO | 取得 LON_TYPE_CODE、REF_APPLICATION_NO、LON_ATTRIBUTE、SECURE_ATTRIBUTE。 |
| EPRO_TB_MAIN_BORROWER_PERSONAL_INFO | 個人主借人資料與 guarantor / collateral provider flag。 |
| EPRO_TB_MAIN_BORROWER_INFO_CORP | 法人主借人資料與 guarantor / collateral provider flag。 |
| EPRO_TB_GUARANTOR_INFO | 個人保證人資料。 |
| EPRO_TB_GUARANTOR_INFO_CORP | 法人保證人資料。 |
| EPRO_TB_COLL_* | 擔保品、鑑價、site visit、title、provider 等相關資料。 |
| EPRO_TB_LOAN_CONDITION_DETAIL | Loan condition detail。 |
| EPRO_TB_LOAN_CONDITION_FEE | Loan condition fee。 |
| EPRO_TB_CHECK_POINT_RC / RC_IU / RC_CORP / RC_CU | revised case checkpoint。 |

## 8. 錯誤處理

| Action | 情境 | 系統處理 | 訊息 |
| --- | --- | --- | --- |
| prompt | 初始化失敗 | 記錄 log 並回傳錯誤 | MSG_INITIAL_FAIL |
| initQuery | 查無資料 | 回傳查無資料 | MSG_DATA_NOT_FOUND |
| initQuery | 查詢筆數超限 | 回傳系統限制訊息 | MSG_OVER_COUNT_LIMIT |
| initQuery | 查詢失敗 | 回傳查詢失敗 | MSG_QUERY_FAIL |
| execute | 輸入錯誤 | 回傳輸入錯誤 | ErrorInputException message |
| execute | 查無資料 | 回傳查無資料 | MSG_DATA_NOT_FOUND |
| execute | 儲存失敗 | rollback 並回傳儲存失敗 | COMMON_MSG_SAVE_FAIL |
| execute | 儲存成功 | commit 並回傳成功 | COMMON_MSG_SAVE_SUCCESS |

## 9. 非功能需求

| 分類 | 需求 | 驗證方式 |
| --- | --- | --- |
| 效能 | init-query 一般情境目標 response time <= 3 秒；execute 一般情境目標 response time <= 5 秒。若觸發 collateral / guarantor 大量複製，需以實測結果確認 SLA。 | SIT 壓測或整合測試記錄 response time。 |
| 交易一致性 | execute 必須以單一 transaction 處理；任一資料清除、複製、checkpoint 更新失敗需 rollback。 | 模擬 DAO exception，驗證所有相關表未部分更新。 |
| Transaction timeout | execute transaction timeout 建議 <= 30 秒；若大量 collateral 資料可能超時，RD 需評估批次化或最佳化 SQL。 | 以最大合理筆數測試 transaction 是否逾時。 |
| 安全 | 不得於 log 中記錄完整個資、完整帳號、完整 ID、敏感 collateral 文件內容；錯誤 response 不得曝露 SQL 或 stack trace。 | 檢查 application log、error log、API response。 |
| Log | 每次 prompt / initQuery / execute 至少記錄 requestId、applicationNo、userId、action、結果、耗時、錯誤代碼；敏感資料需遮罩。 | 查核 log 欄位與遮罩規則。 |
| Audit | execute 屬資料異動，需保留操作者、時間、APPLICATION_NO、異動結果與錯誤狀態，以利稽核追蹤。 | 檢查 audit log 或等效紀錄。 |
| 可維運 | 錯誤需可依 requestId / applicationNo 追蹤至後端 log 與 DB 狀態。 | 以失敗案例驗證追蹤流程。 |
| 相容性 | 重構後需維持 IS / IU / CS / CU 四種 attribute 的 checkpoint 行為。 | 四種 attribute 各執行至少一筆儲存測試。 |

## 10. 驗收標準與測試案例

## 10.1 UAT / SIT 測試案例總表

| Test Case ID | Given | When | Then | DB 驗證點 |
| --- | --- | --- | --- | --- |
| TC-001 | 案件已有 EPRO_TB_REVISED_ITEM 資料，且 ITEM1~ITEM14 / REASON_MEMO 有值 | 使用者開啟 EPROZ00800 並呼叫 init-query | 畫面顯示既有 ITEM 勾選狀態與 REASON_MEMO | EPRO_TB_REVISED_ITEM 依 APPLICATION_NO 查詢結果與畫面一致 |
| TC-002 | 案件無 EPRO_TB_REVISED_ITEM 資料，但 TB_COMMON_FIELD_OPTIONS 有 REVISED_ITEM 選項 | 使用者開啟 EPROZ00800 並呼叫 init-query | 畫面顯示 code table 選項，ITEM1~ITEM14 初始化空白 | EPRO_TB_REVISED_ITEM 無資料；revisedType 來源為 TB_COMMON_FIELD_OPTIONS |
| TC-003 | 使用者未勾選任何 Revised Item | 按下儲存 / Finished | 前端阻擋送出並提示至少需選擇一項 | DB 無新增或異動 EPRO_TB_REVISED_ITEM |
| TC-004 | 使用者已勾選 Revised Item 但 REASON_MEMO 空白 | 按下儲存 / Finished | 前端阻擋送出並提示 reason 必填 | DB 無新增或異動 EPRO_TB_REVISED_ITEM |
| TC-005 | 案件 LON_TYPE_CODE = 03 | 使用者進入 EPROZ00800 | ITEM1 強制勾選且不可編輯 | EPRO_TB_LON_SUMMARY_INFO.LON_TYPE_CODE = 03；儲存後 ITEM1 = Y |
| TC-006 | attrMap.isCU = true | 使用者進入 EPROZ00800 | ITEM3 強制不勾選且不可編輯 | 儲存後 EPRO_TB_REVISED_ITEM.ITEM3 = N |
| TC-007 | 既有 ITEM2 = Y，新 ITEM2 = N，reference application 有 guarantor | 使用者確認清除提示後儲存 | 系統清除目前案件 guarantor 並由 reference application 還原 | EPRO_TB_GUARANTOR_INFO / CORP 目前案件筆數與 reference 有效資料一致；borrower IS_ANY_GUARANTOR 正確 |
| TC-008 | 既有 ITEM3 = Y，新 ITEM3 = N，reference application 有 collateral | 使用者確認清除提示後儲存 | 系統清除目前案件 collateral 並由 reference application 還原 | EPRO_TB_COLL_*、EPRO_TB_COLL_PROVIDER_INFO、EPRO_TB_COLL_TITLE_REGIS_OWNER 目前案件資料正確 |
| TC-009 | ITEM1、ITEM4~ITEM11 任一項由 Y 改為 N | 使用者確認清除提示後儲存 | loan condition detail 對應欄位由原始資料還原，或依組合規則刪除 | EPRO_TB_LOAN_CONDITION_DETAIL、EPRO_TB_REVISED_ITEM_DETAIL 欄位/筆數符合 RI-MAT-004 / RI-MAT-005 |
| TC-010 | LON_TYPE_CODE = 04，既有 ITEM12 = N，新 ITEM12 = Y | 使用者儲存 Revised Item | 系統刪除 loan condition fee | EPRO_TB_LOAN_CONDITION_FEE 目前 APPLICATION_NO 無資料 |
| TC-011 | 分別準備 IS / IU / CS / CU 四種案件 | 各案件儲存 Revised Item | 正確 checkpoint table 與 page menu flags 被更新 | EPRO_TB_CHECK_POINT_RC / RC_IU / RC_CORP / RC_CU 對應欄位為 Y |
| TC-012 | execute 過程中模擬 DAO exception | 使用者送出儲存 | 系統 rollback 並回傳 COMMON_MSG_SAVE_FAIL | EPRO_TB_REVISED_ITEM、關聯資料表、checkpoint table 均未產生部分更新 |

## 10.2 驗收完成條件

- Must 需求測試案例全部通過。
- ITEM1~ITEM14 正式名稱完成確認，或有明確 TBD owner。
- 清除/還原副作用已由 PM / SA / RD 確認是否保留。
- checkpoint/page menu 更新行為完成回歸測試。
- Critical / High defect 已完成修復並回歸測試。

## 11. 附件與決策紀錄

## 11.1 參考文件

| 文件 / 資料 | 說明 |
| --- | --- |
| 功能備註說明.xlsx | 確認 EPROZ0_0800 對應 Revised Item / EPROZ00800。 |
| EPROZ0_0800-srs-source-summary.md | source code 深度摘要。 |
| function-inventory.csv | 既有 function inventory。 |
| EPROZ0_0800.java | 舊系統 transaction action。 |
| EPROZ0_0800_mod.java | 舊系統業務邏輯。 |
| EPROZ00800.jsp | 舊系統畫面與前端驗證。 |

## 11.2 Decision Log

| Decision ID | 日期 | 決策事項 | 決策結果 | Owner |
| --- | --- | --- | --- | --- |
| DEC-001 |  | 是否修正 Finshed 文字 |  | PM / UX / RD |
| DEC-002 |  | 是否完整保留 legacy 清除/還原副作用 |  | PM / SA / RD |
| DEC-003 |  | ITEM1~ITEM14 正式業務名稱 |  | SA / RD |

## 12. PM / SA / RD / QA 審查清單

## 12.1 PM Review Checklist

| 檢查項目 | 確認結果 | 備註 |
| --- | --- | --- |
| 本文件範圍是否僅限 EPROZ00800 Revised Item |  |  |
| 是否同意 Revised Item 屬於共用頁籤 |  |  |
| 是否同意本期範圍包含查詢、顯示、檢核、儲存、關聯資料清除/還原與 checkpoint 更新 |  |  |
| 是否同意非本期範圍不包含 ITEM code table 維護與其他頁籤完整重構 |  |  |
| 是否同意重構後保留舊系統清除/還原副作用 |  | 若不同意，需建立需求變更。 |
| 是否同意按鈕文字 Finshed 於重構後修正為 Finished |  |  |

## 12.2 SA Review Checklist

| 檢查項目 | 確認結果 | 備註 |
| --- | --- | --- |
| ITEM1~ITEM14 正式業務名稱是否補齊 |  | 對應 EPRO / REVISED_ITEM。 |
| LON_TYPE_CODE = 03 強制 ITEM1 的業務原因是否確認 |  |  |
| LON_TYPE_CODE = 04 與 ITEM12 刪除 fee 的業務原因是否確認 |  |  |
| ITEM2 對 guarantor 資料的清除/還原規則是否符合業務預期 |  |  |
| ITEM3 對 collateral 資料的清除/還原規則是否符合業務預期 |  |  |
| ITEM1、ITEM4~ITEM11 對 loan condition detail 的清除/還原規則是否符合業務預期 |  |  |
| ITEM1 與 ITEM10 皆影響 TENOR 是否合理 |  | 若不合理，需標示為 legacy defect 或需求變更。 |
| IS / IU / CS / CU 對 checkpoint/page menu 的影響是否正確 |  |  |

## 12.3 RD Review Checklist

| 檢查項目 | 確認結果 | 備註 |
| --- | --- | --- |
| 是否已將 prompt / initQuery / execute 拆成重構後 API 或 service method |  |  |
| request / response schema 是否已定義欄位型別、必填、長度、enum |  |  |
| execute 是否保留單一 transaction 與 rollback 行為 |  |  |
| 關聯資料刪除與複製是否已設計防重複、防遺漏與錯誤處理 |  |  |
| checkpoint table 是否依 IS / IU / CS / CU 使用正確 DAO / repository |  |  |
| 是否已補齊 DB 欄位級 mapping 與 SQL / repository 設計 |  |  |
| 是否已確認敏感資料不落 log |  |  |

## 12.4 QA Review Checklist

| 檢查項目 | 確認結果 | 備註 |
| --- | --- | --- |
| 第 10 章測試案例是否覆蓋 Must 需求 |  |  |
| 是否補齊 ITEM1~ITEM14 每一項的正向、反向與回歸案例 |  |  |
| 是否覆蓋 LON_TYPE_CODE = 03 / 04 的特殊規則 |  |  |
| 是否覆蓋 IS / IU / CS / CU 四種 attribute |  |  |
| 是否覆蓋 transaction rollback 測試 |  |  |
| 是否覆蓋資料清除/還原後的下游頁籤狀態 |  |  |

## 12.5 開發交付條件 Definition of Ready

| 條件 | 狀態 | 說明 |
| --- | --- | --- |
| TBD-001 至 TBD-007 已關閉，或已明確標示決策與 owner |  |  |
| ITEM1~ITEM14 code table 對照已補入第 5 / 7 / 10 章 |  |  |
| ITEM1~ITEM14 blank / N / Y 正規化規則已確認 |  | 查詢可回傳 blank；儲存與 DB 僅允許 Y / N。 |
| execute 已明確設計後端 oldItemMap / newItemMap 二次比對邏輯 |  | 不得完全依賴前端 isNotSame 判斷資料差異。 |
| API endpoint、request、response、error code 已於系統開發規格書定義 |  |  |
| DB 欄位級 mapping 已於系統開發規格書定義 |  |  |
| 清除/還原副作用已由 PM / SA / RD 簽核 |  |  |
| QA 已依第 10 章擴充 SIT / UAT 測試腳本 |  |  |

## 13. AI / 人員開發注意事項

- 開發前必須先讀第 0.3 章待確認項目與第 12 章審查清單。
- 不可自行推論 ITEM1~ITEM14 的業務名稱；未確認前只能以 ITEM 編號實作或標示 TBD。
- 不可因 legacy source code 有清除/還原副作用，就直接視為 PM 已核准的新需求；需依第 12 章確認結果執行。
- execute 涉及多表刪除、複製、更新，重構時需維持 transaction 與 rollback。
- 若重構後 API 拆分為多個 service，仍需保證業務結果與 checkpoint/page menu 狀態一致。
- 若發現 source code 與本文件不一致，需先列為 Issue，不可直接修改需求或程式。
