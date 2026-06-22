業務需求導向的功能規格書
CDC-EPRO-0001 EPROISU0921 Data Input 業務需求導向的功能規格書

| 文件角色 | PM / SA / RD / QA 共同審閱的業務需求導向功能規格書 |
| --- | --- |
| 功能代號 | EPROISU0921 |
| 功能名稱 | Data Input |
| Legacy 分析來源 | EPROIS_0921.java、EPROIS_0921_mod.java、EPROIS0921.jsp、EPROIS0921_JS.jsp、SQL_QUERY_001、SQL_QUERY_002 |
| 文件版本 | v1.0 |
| 產出日期 | 2026-06-10 |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
| --- | --- | --- | --- |
| 2026-06-10 | v1.0 | 依 Legacy Source EPROIS_0921 重產，版型對齊 EPROISU0920 | Codex |
| 角色 | 審閱重點 |  |  |
| PM | 確認 Data Input 在 Disbursement Process 的業務定位、案件流程與角色權限。 |  |  |
| SA | 確認 Legacy 行為、資料表交易、T24/CIF 介面與待釐清項。 |  |  |
| RD | 確認 API、交易邏輯、資料保存與錯誤處理可落地。 |  |  |
| QA | 確認驗收條件、正反向測試、邊界檢核與回歸範圍。 |  |  |

## 0.1 TBD / 待確認

| TBD | 議題 | 影響 | Owner |
| --- | --- | --- | --- |
| TBD-001 | Legacy 註解與 LOG 殘留 EPROIS_0911 / Collateral Information 字樣。 | 新版命名與追蹤需避免誤導。 | SA / RD |
| TBD-002 | 完成旗標欄位為 `EPORIS_0921`，與功能代號拼字不一致。 | 0920 Summary 放行依此旗標判斷；新版若更名需定義相容。 | SA / RD |
| TBD-003 | `DRAWDOWN_ACCOINT` 欄位拼字沿用 Legacy。 | 新版 DTO 若改正拼字需提供欄位轉換。 | RD |
| TBD-004 | `query()` 多處 `.get(0)` 假設資料必存在。 | 需確認前序功能已保證 Summary、Loan Condition、Borrower、Province 等資料。 | SA |
| TBD-005 | `CASE_PROGRESS=24` 初始化時會更新 `DISBURSING_DATE`。 | 查詢即更新資料屬副作用，需確認新版是否保留。 | PM / SA |
| TBD-006 | 主借 Product Code 對 Sector / Industry 規則需業務確認。 | 01/02 對 1001/1001，03 對 1002/1001。 | PM / SA |
| TBD-007 | 退件會清除撥款、T24 暫存、合約自動檔案與 FN 條件資料。 | 需確認新版退件清除範圍與稽核留存。 | PM / SA / QA |
| TBD-008 | `collproSize` 同時限制 CBC Member 與 Add Purchased Property 新增筆數。 | 需確認兩者是否應共用同一參數。 | PM / SA |

## 1. 目標與範圍

| 項目 | 描述 |  |
| --- | --- | --- |
| 功能定位 | EPROISU0921 是 Disbursement Process 中的 Data Input 子功能，供 CAD Maker 維護撥款、CBC、T24 借款人檢核、擔保品與新增購買標的資料。 |  |
| 使用時機 | 由 EPROISU0920 頁籤載入；主要在 `CASE_PROGRESS=24` 且角色 `404` 時進行可編輯作業。 |  |
| 主要成果 | 完成並保存 Data Input 資料，完成主借與共同借款人 T24/CIF 檢核，讓 EPROISU0920 可放行 Summary。 |  |
| 不在範圍 | EPROISU0922 Summary 的彙總畫面與送審邏輯不納入本文件。 |  |
| 目標 | 說明 | 成功標準 |
| 資料初始化 | 依 Application No. 讀取借款人、貸款條件、撥款資料、擔保品、T24 檢核結果、下拉選單與行政區資料。 | 首次載入可呈現既有資料；無撥款資料時依貸款條件預帶幣別、金額與 T24 No.。 |
| 檢核完成 | 支援主借與共同借款人 CIF No. 檢核，並保存 T24 回傳資料與檢核結果。 | `MB_CHECK=Y` 且 `CO_CHECK=Y` 才能 Finished。 |
| 資料保存 | Save 可暫存；Finished 需完成必填、金額、地址、Remark 與 T24 檢核後保存。 | Finished 成功後完成旗標為 Y，0920 Summary 可進入。 |
| 退件處理 | CAD Maker 可將案件退回前段狀態並清除相關撥款/合約暫存資料。 | 退件後回待辦清單，資料依 Legacy 清除規則處理。 |
| 範圍 | 內容 |  |
| 包含 | Data Input 畫面欄位、主借/共同借款人檢核、Save、Finished、Return、錯誤 popup、與 0920 的完成旗標介面。 |  |
| 排除 | Loan Application、Contract Preparation、Summary 送審與其他頁籤完整業務規格。 |  |

## 2. Source Mapping

| 來源項目 | Legacy Source | 新版需求歸納 |
| --- | --- | --- |
| Controller | EPROIS_0921.java | 提供 `query`、`save_dataInput`、`dataReturn`、`CheckMainBorr`、`CheckCoBorr`、`checkerror_Pop` 入口。 |
| Business Module | EPROIS_0921_mod.java | 承接查詢、儲存、退件、T24/CIF 檢核、費用計算、交易提交與資料清除。 |
| Main JSP | EPROIS0921.jsp | 定義 Data Input 主表單欄位、按鈕顯示條件與靜態版面。 |
| Client Script | EPROIS0921_JS.jsp | 負責 AJAX 呼叫、欄位動態產生、前端 validation、Add Property / CBC 動態列與完成旗標。 |
| SQL | SQL_QUERY_001、SQL_QUERY_002 | 查詢原始或合約來源共同借款人與 Business Section，供 T24 共同借款人檢核比對。 |
| 外部服務 | EPRO_Z0Z010.checkborrowerNo、EPRO_Z0Z010.checkcifssi | 取得 T24/CIF 借款人資料、帳戶與 SSI 資訊，產生檢核結果。 |

## 3. Legacy Behavior 摘要

| 項目 | Legacy 行為 | 新版需求歸納 |
| --- | --- | --- |
| 頁面載入 | `initApp()` 呼叫 `query`，回填 Data Input、擔保品、共同借款人、T24 檢核狀態與下拉選單。 | 新版需提供初始化 API，回傳畫面主資料、清單與可編輯狀態。 |
| 預帶資料 | 無 `TB_DISBUR_DATE` 時，以 Loan Condition 的幣別/金額預帶 Disbursement Currency / Amount。 | 首次進入 Data Input 時應自動帶出核准貸款條件。 |
| 主借檢核 | 輸入 Borrower CIF No. 後呼叫 T24/CIF 與 SSI，驗證身分、Sector/Industry、Business Section 與可用帳戶。 | 主借檢核成功才可產生 Drawdown Account 候選清單並允許 Finished。 |
| 共同借款人檢核 | 依共同借款人 Data Seq 比對 T24 回傳姓名、生日、性別與 Business Section。 | 所有共同借款人皆需檢核成功且日期為當日，才視為 `CO_CHECK=Y`。 |
| Save / Finished | Save 暫存；Finished 先做前端檢核，再保存 Data Input、擔保品、費用與完成旗標。 | Finished 成功後需讓 0920 Summary 放行。 |
| Return | 呼叫 `dataReturn`，案件退回 `CASE_PROGRESS=21`，並刪除撥款、T24 暫存、合約自動檔案路徑與 FN 條件資料。 | 退件為高影響交易，新版需保留交易一致性、稽核與清除清單。 |
| 0920 整合 | `checkApp()` 只有在 `finishedsucc == 'Y'` 時回傳 true。 | 0920 切 Summary 前需以 0921 完成旗標阻擋。 |

## 4. Functional Requirements

## 4.1 頁面初始化

| 需求 | 內容 | 驗收重點 |
| --- | --- | --- |
| FR-INIT-001 | 系統須依 `APPLICATION_NO` 查詢 Summary、Loan Condition、主借、共同借款人、既有 Data Input、擔保品、T24 檢核、法務所、行政區與下拉選單。 | 初始化回傳需足以渲染 Data Input 主區、Collateral 區與 Add Purchased Property 區。 |
| FR-INIT-002 | 若已有 `TB_DISBUR_DATE`，畫面以既有 Data Input 為準；若無，需以貸款條件預帶撥款幣別與撥款金額。 | 新案件首次進入時幣別與金額不應空白。 |
| FR-INIT-003 | 若存在已成功且當日有效的主借 T24 檢核，需依幣別載入 Drawdown Account；SSI 帳戶優先。 | 帳戶下拉選單優先顯示 SSI；無 SSI 時顯示同幣別帳戶。 |
| FR-INIT-004 | 共同借款人檢核需比對人數、`CHECK_SUCCESS` 與 `CHECK_DATE` 是否為當日，計算 `CO_CHECK`。 | 任一共同借款人未成功或非當日，`CO_CHECK=N`。 |
| FR-INIT-005 | 若 `CASE_PROGRESS=24`，Legacy 查詢時會更新 Summary 的 `DISBURSING_DATE`。 | 新版若保留此行為，需在 API 文件標示初始化具資料更新副作用。 |

## 4.2 頁籤顯示與導覽

| 條件 | 顯示 / 可操作狀態 | 業務意義 |
| --- | --- | --- |
| `role == 404 && CASE_PROGRESS == 24` | 顯示 Back、Return、Save、Finished、主借 Check、共同借款人 Check。 | CAD Maker 可進行 Data Input 作業。 |
| `attrMap.isEdit && CASE_PROGRESS == 24` | 顯示 Add Purchased Property。 | 允許新增購買標的。 |
| `!attrMap.isEdit \|\| attrMap.isQuery` | 欄位 disabled，操作按鈕隱藏。 | 查詢或非編輯權限只能檢視。 |
| 需求 | 內容 | 驗收重點 |
| FR-UI-001 | 畫面載入時需依 `attrMap.isEdit`、`attrMap.isQuery`、`CASE_PROGRESS` 控制欄位與按鈕。 | 非可編輯或查詢模式不得保存或完成。 |
| FR-UI-002 | 當 `CASE_PROGRESS` 非 24 / 25 且不是查詢模式時，Legacy 會 disable 畫面並提示 Contract Preparation Not Finished。 | 合約準備未完成時不可誤存 Data Input。 |
| FR-UI-003 | Borrower CIF No. 或共同借款人 CIF No. 修改後，既有檢核狀態需改為未通過並提示重新檢核。 | 不可沿用舊 T24 檢核結果。 |
| FR-UI-004 | EPROISU0920 切 Summary 時須呼叫 0921 `checkApp()`，只有完成旗標為 Y 才可放行。 | 未 Finished 時 Summary 保持不可進入。 |

## 4.3 子功能邊界

| 子功能 | 0921 觸發方式 | 0921 規格需承接 | 完整規格歸屬 |
| --- | --- | --- | --- |
| T24 主借檢核 | `CheckMainBorr` AJAX | 檢核姓名、生日、性別、Sector/Industry、Business Section、同幣別帳戶與 SSI。 | EPROISU0921 |
| T24 共同借款人檢核 | `CheckCoBorr` AJAX | 逐筆檢核共同借款人姓名、生日、性別與 Business Section。 | EPROISU0921 |
| Summary 放行 | 0920 呼叫 `EPROIS_0921.checkApp()` | 0921 只提供完成旗標與檢核結果；Summary 彙總與送審不在本文件。 | EPROISU0922 |

## 4.4 Validation Rules

| 規則 | 觸發點 | Legacy 判斷 |
| --- | --- | --- |
| 必填 | Finished | 執行 `validAll.executeCheck()`，包含 Data Input、Collateral、Add Property 動態 required 欄位。 |
| Borrower CIF | 主借 Check | `BORROWER_T24_NO` 必填，最大長度 10。 |
| Co-Borrower CIF | 共同借款人 Check | 每筆共同借款人 `RECID_{DATA_SEQ}` 必填，最大長度 10。 |
| Designated Repayment Date | 欄位 change | 若不空白，值必須介於 1 至 31，否則清空並提示。 |
| Disbursement Amount | 欄位 change | 不可大於 `defaultLoanAmount`；超過時回復為核准貸款金額。 |
| T24 檢核 | Finished | `MB_CHECK` 與 `CO_CHECK` 皆須為 `Y`。 |
| Address 長度 | Finished | Collateral 或 Add Property 地址前後段合計不可超過 65。 |
| Other Remark | Finished | `LAW_FIRM_AMOUNT_90` 與 `LAW_FIRM_90_OTHER_REMARK` 任一有值時，兩欄皆 required。 |

## 5. API / Interface Draft

| API | 用途 | 主要 Input | 主要 Output |
| --- | --- | --- | --- |
| `/EPROIS_0921/query` | 初始化 Data Input 畫面 | `APPLICATION_NO` | `dataMap`、common field options、`APPLICATION_NO` |
| `/EPROIS_0921/save_dataInput` | 暫存或完成 Data Input | `APPLICATION_NO`、`Isfinished`、`CO_CHECK`、`dataInputmap`、`collateralList`、`addpurchasedList`、`coborrlist` | 成功訊息；Finished 時回傳完成成功 |
| `/EPROIS_0921/dataReturn` | 退件並清除相關資料 | `APPLICATION_NO` | 退件成功 / 失敗訊息 |
| `/EPROIS_0921/CheckMainBorr` | 主借 T24/CIF/SSI 檢核 | `APPLICATION_NO`、`BORROWER_T24_NO` | `MB_CHECK`、`errorlist`、`accList` |
| `/EPROIS_0921/CheckCoBorr` | 共同借款人 T24/CIF 檢核 | `APPLICATION_NO`、`cobroociflist` | `CO_CHECK`、`errorlist` |
| DTO | 欄位 | 說明 |  |
| dataInputmap | GROUP_BORROWER、BORROWER_T24_NO、CBC_MEMBER、CBC_MEMBER_1~4、CBC_SPECIAL、DISBURSEMENT_AMOUNT、DES_REP_DAY、DRAWDOWN_ACCOINT、DISBURSEMENT_BY、LAW_FIRM_NO、LAW_FIRM_AMOUNT*、CUBC_RELATED_CIF_NO、EPORIS_0921 | Data Input 主檔資料，保存至 `TB_DISBUR_DATE`。 |  |
| collateralList | COLL_DATA_SEQ、INS_*、PROPERTY_COLL、COLL_*、PUR_PRO_TYPE、EST_COM_DATE、TITLE_PURC_PRO、PUR_OF_LOAN_NBC、PRICE_*、AREA/FLOOR/BEDROOM | 保存至 `TB_DISBUR_COLL`。 |  |
| addpurchasedList | OTHER_COLL_DATA_SEQ、OTHER_COLL_*、OTHER_PUR_PRO_TYPE、OTHER_EST_COM_DATE、OTHER_TITLE_PURC_PRO、OTHER_PRICE_*、OTHER_AREA/FLOOR/BEDROOM | 保存至 `TB_DISBUR_OTHER_COLL`。 |  |
| coborrlist | APPLICATION_NO、DATA_SEQ、RECID、CHECK_SUCCESS | `CO_CHECK=N` 保存時，用於重建共同借款人 T24 暫存資料。 |  |
| accList | CURRENCY、ACCID / ACCTID | 主借檢核成功後，提供 Drawdown Account 下拉選單。 |  |

## 6. DB / Transaction Requirements

| 資料表 / 服務 | 用途 | 存取型態 |
| --- | --- | --- |
| TB_LON_SUMMARY_INFO | 讀取案件狀態、產品、系統版本；更新 `DISBURSING_DATE`、`RECEIVED_DATE`、退件狀態。 | Query / Update |
| TB_LOAN_CONDITION_DETAIL、TB_LOAN_CONDITION_FEE | 讀取貸款金額、幣別、費率；退件刪除 FN 條件資料。 | Query / Delete |
| TB_DISBUR_DATE、TB_DISBUR_COLL、TB_DISBUR_OTHER_COLL | 保存 Data Input 主檔、擔保品撥款資料與新增購買標的。 | Query / Delete / Insert |
| TB_T24_MAIN_BORROWER_INFO、TB_T24_CO_BORROWER_INFO、TB_MAIN_BORROWER_ACC | 保存主借 / 共同借款人 T24 檢核結果與帳戶資訊。 | Query / Delete / Insert |
| TB_MAIN_BORROWER_*、TB_CO_BORROWER_*、TB_CONTR_*、TB_COLL_* | 初始化與 T24 檢核比對基準資料。 | Query / Update / Delete |
| EPRO_Z0Z010、TB_LAW_FIRM、TB_PROVINCE、TB_APP_HISTORY | T24/CIF/SSI 檢核、法務所與行政區清單、退件歷程。 | Service / Query / Insert |
| 交易要求 | 內容 |  |
| Save / Finished | 先刪除同 Application No. 的 `TB_DISBUR_DATE`、`TB_DISBUR_COLL`、`TB_DISBUR_OTHER_COLL`，再新增本次提交資料；Finished 另更新 Summary。 |  |
| 主借檢核 | 先刪除同 Application No. 的 `TB_T24_MAIN_BORROWER_INFO` 與 `TB_MAIN_BORROWER_ACC`，再寫入最新 T24 與帳戶結果。 |  |
| 共同借款人檢核 | 先刪除同 Application No. 的 `TB_T24_CO_BORROWER_INFO`，再寫入本次所有共同借款人檢核結果。 |  |
| 退件 | Summary 更新、History 新增、T24/Disbursement/Contract/FN 條件資料清除與 Contract Status 更新需在同一交易內完成。 |  |

## 7. Role / Permission Rules

| 條件 | 畫面狀態 |
| --- | --- |
| `role == 404 && CASE_PROGRESS == 24` | 顯示 Back、Return、Save、Finished、主借 Check、共同借款人 Check，是主要可作業狀態。 |
| `attrMap.isEdit && CASE_PROGRESS == 24` | 顯示 Add Purchased Property 按鈕。 |
| `!attrMap.isEdit \|\| attrMap.isQuery` | 欄位 disabled，操作按鈕隱藏，僅可檢視。 |
| `!attrMap.isQuery && CASE_PROGRESS != 24 && CASE_PROGRESS != 25` | 欄位 disabled、按鈕隱藏，提示 Contract Preparation Not Finished。 |

## 8. Acceptance Criteria / Test Cases

| ID | 情境 | 前置 / 輸入 | 預期結果 | Priority |
| --- | --- | --- | --- | --- |
| AC-001 | 初始化既有 Data Input | Application No. 已有撥款、擔保品與 T24 檢核資料。 | 畫面回填既有資料與 `MB_CHECK` / `CO_CHECK`。 | High |
| AC-002 | 初始化新 Data Input | Application No. 無 `TB_DISBUR_DATE`，Loan Condition 有幣別與金額。 | 系統預帶 Disbursement Currency、Disbursement Amount、Borrower T24 No. 與可用帳戶。 | High |
| AC-003 | 主借檢核成功 | T24/CIF/SSI 服務成功，身分、分類、Business Section 與帳戶皆符合。 | `MB_CHECK=Y`，寫入主借 T24 與帳戶資料，Drawdown Account 下拉更新。 | High |
| AC-004 | 主借檢核失敗 | 姓名或生日或性別不符，或無同幣別帳戶。 | `MB_CHECK=N`，清空 Drawdown Account 候選並開啟錯誤 popup。 | High |
| AC-005 | 共同借款人檢核成功 | 每筆共同借款人 T24 資料與基準資料一致。 | `CO_CHECK=Y`，寫入 `TB_T24_CO_BORROWER_INFO`。 | High |
| AC-006 | Save 暫存 | 填寫部分資料，點 Save，`Isfinished=N`。 | Data Input 與擔保品資料保存成功，完成旗標為未完成。 | High |
| AC-007 | Finished 成功 | `MB_CHECK=Y`、`CO_CHECK=Y`、必填皆通過、地址長度符合。 | 資料保存、費用計算、Received Date 更新、完成旗標為 Y。 | High |
| AC-008 | Finished 檢核未完成 | `MB_CHECK=N` 或 `CO_CHECK=N`。 | 阻擋完成並提示需完成對應 T24 檢核。 | High |
| AC-009 | 金額與日期邊界 | Disbursement Amount 超額，或 Designated Repayment Date 為 0 / 32。 | 金額回復為核准金額；日期清空並提示。 | Medium |
| AC-010 | 退件成功 | 點 Return 並後端交易成功。 | 案件回 `CASE_PROGRESS=21`，寫入 APP_HISTORY，清除相關暫存資料，導回待辦。 | High |

## 9. Non-functional / Security

| 類別 | 需求 |
| --- | --- |
| 稽核 | 查詢需記錄 ID、姓名、生日、地址欄位存取；儲存、退件與檢核需記錄編輯操作。 |
| 個資保護 | T24/CIF 回傳包含姓名、生日、地址、帳戶資訊，新版 API 回應與 log 不應輸出非必要個資。 |
| 交易一致性 | Save、檢核與 Return 都採先刪後新增或多表更新，必須有 transaction 與 rollback。 |
| 冪等與重送 | 相同 Application No. 重複 Save / 檢核應以最新提交資料覆蓋，不可累積重複明細。 |
| 效能 | 初始化同時查多表與行政區清單，需注意大型擔保品 / 新增標的案件載入時間。 |
| 相容性 | Legacy 欄位拼字如 `EPORIS_0921`、`DRAWDOWN_ACCOINT` 若於新版修正，需在 API 層保留轉換。 |

## 10. Definition of Ready / Done

| 階段 | 檢核項 |
| --- | --- |
| Ready | 已確認 0921 與 0920/0922 的完成旗標與 Summary 放行契約。 |
| Ready | 已確認 Product Code 對 Sector / Industry 規則、共同借款人檢核範圍與 `collproSize` 業務定義。 |
| Ready | 已確認退件刪除資料清單與稽核留存要求。 |
| Done | 初始化、Save、Finished、Return、主借檢核、共同借款人檢核 API 與 UI 行為皆已實作並通過測試。 |
| Done | QA 已完成 AC-001 至 AC-010 測試，並完成與 EPROISU0920 Summary 阻擋邏輯的回歸驗證。 |
