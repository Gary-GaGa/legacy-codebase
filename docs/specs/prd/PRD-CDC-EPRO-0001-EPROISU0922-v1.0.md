業務需求導向的功能規格書
CDC-EPRO-0001 EPROISU0922 Summary 業務需求導向的功能規格書

| 文件角色 | PM / SA / RD / QA 共同審閱的業務需求導向功能規格書 |
| --- | --- |
| 功能代號 | EPROISU0922 |
| 功能名稱 | Summary |
| Legacy 分析來源 | EPROIS_0922.java、EPROIS_0922_mod.java、EPRO_IS0922.java、EPROIS0922.jsp、EPROIS0922_JS.jsp、SQL_QUERY_001、SQL_QUERY_002 |
| 文件版本 | v1.0 |
| 產出日期 | 2026-06-10 |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
| --- | --- | --- | --- |
| 2026-06-10 | v1.0 | 依 Legacy Source EPROIS_0922 撰寫業務需求導向 PRD，版型對齊 EPROISU0920 | Codex |
| 角色 | 審閱重點 |  |  |
| PM | 確認 Summary、Maker Submit、Checker Return / Authorize、T24 結果查詢的業務流程。 |  |  |
| SA | 確認 Legacy 狀態流轉、T24 檔案產生、SFTP、通知與待釐清項。 |  |  |
| RD | 確認 API、資料表交易、T24/SFTP 介面與錯誤處理可落地。 |  |  |
| QA | 確認驗收條件、角色權限、狀態轉換與 T24 成敗回歸測試。 |  |  |

## 0.1 TBD / 待確認

| TBD | 議題 | 影響 | Owner |
| --- | --- | --- | --- |
| TBD-001 | `summaryQuery()` 在計算 `t24ResultTime` 時直接解析 `DISBURSING_DATE`。 | 若案件尚未 Authorize 或日期為空，初始化可能失敗；需確認前序是否保證有值。 | SA / RD |
| TBD-002 | T24 Deal Result 按鈕在 JSP 被註解，但 JS 仍保留點擊邏輯。 | 需確認新版是否提供人工查詢 T24 結果按鈕，或改由排程/背景查詢。 | PM / SA |
| TBD-003 | Authorize 先產生並上傳 T24 檔，再更新案件為 `CASE_PROGRESS=26`。 | SFTP 成功但 DB 更新失敗時的補償流程需定義。 | SA / RD |
| TBD-004 | T24 檔產生 helper `EPRO_IS0922.authorize()` 捕捉 IOException 只印出 stack trace。 | 檔案產生失敗可能回傳空路徑；新版需明確丟出錯誤。 | RD |
| TBD-005 | T24 檔欄位以 `!@#` 分隔、多筆以 CRLF 串接。 | 新版需確認 T24 規格版本、欄位順序、空值處理與編碼。 | SA |
| TBD-006 | 交易結果失敗時使用關案原因 `C10` 並將案件狀態改為 `C1`。 | 需確認關案原因碼與後續重送/補件流程。 | PM / SA |
| TBD-007 | Submit / Authorize 都要求 T24 主借與共同借款人檢核日期為當日。 | 需確認跨日時限與工作日例外規則。 | PM / SA |
| TBD-008 | 寄信使用環境參數與代理人清單，並寫入 `TB_NOTIFICATION_INFO`。 | 需確認新版通知模板、收件人、代理人與寄送失敗重試。 | SA / RD |

## 1. 目標與範圍

| 項目 | 描述 |  |
| --- | --- | --- |
| 功能定位 | EPROISU0922 是 Disbursement Process 的 Summary 與審核處理功能，彙整 0921 Data Input 結果並承接 Maker Submit、Checker Return / Authorize、T24 結果查詢。 |  |
| 使用時機 | 由 EPROISU0920 頁籤載入；0921 完成後，Maker 進入 Summary 檢視並送 Checker，Checker 審核後授權送 T24。 |  |
| 主要成果 | 顯示撥款 Summary、產出 Summary PDF、完成 Maker/Checker 流程、產生 T24 file、上傳 SFTP、查詢 T24 deal result。 |  |
| 不在範圍 | 0921 Data Input 欄位維護與檢核細節不重寫；本文件只承接其完成後的 Summary 與審核流程。 |  |
| 目標 | 說明 | 成功標準 |
| Summary 呈現 | 彙整借款人、貸款條件、撥款、CBC、法務所、費用、擔保品與新增購買標的。 | 畫面可依 `getSummaryMap` 回填 Summary、Collateral、Other Collateral 區塊。 |
| Maker Submit | CAD Maker 選擇 CAD Checker 後送出審核。 | 案件更新為 `CASE_PROGRESS=25`，指定 `CADC_CODE` / `CURRENT_USER_ID` 並寫入歷程。 |
| Checker 審核 | CAD Checker 可退回 Maker 或授權放款。 | Return 回 `CASE_PROGRESS=24`；Authorize 產生 T24 檔、上傳 SFTP 並進 `CASE_PROGRESS=26`。 |
| T24 結果 | 查詢 T24 deal result，依 Done Flag 更新案件成敗。 | 成功進 `27`，失敗進 `C1` 並寫入 message record / 關案原因。 |
| 範圍 | 內容 |  |
| 包含 | Summary 查詢、PDF/結果下載、Submit、Return Maker、Authorize、T24 file 產生與上傳、T24 deal result 查詢。 |  |
| 排除 | Data Input 編輯、T24 後台實際入帳邏輯、外部郵件系統與 SFTP 伺服器維運。 |  |

## 2. Source Mapping

| 來源項目 | Legacy Source | 新版需求歸納 |
| --- | --- | --- |
| Controller | EPROIS_0922.java | 提供 `getSummaryMap`、`downloadFile`、`submit`、`returnMaker`、`authorize`、`downloadTransResult`、`downloadMsgCodeRecord`、`t24DealResult`。 |
| Business Module | EPROIS_0922_mod.java | 承接 Summary 組裝、狀態流轉、寄信、匯率查詢、SFTP 上傳、T24 結果查詢與 DB 交易。 |
| T24 File Helper | EPRO_IS0922.java | 產生 T24 送檔內容，包含 LIMIT、COLLATERAL、CUSTOMER.SSI、LD、FT fee / EIR 等交易段。 |
| Main JSP | EPROIS0922.jsp | 定義 Summary 顯示欄位、角色按鈕、CAD Checker 下拉、T24 結果顯示區。 |
| Client Script | EPROIS0922_JS.jsp | 負責 Summary 初始化、按鈕事件、下載、狀態式顯示 T24 結果與訊息紀錄。 |
| SQL | SQL_QUERY_001、SQL_QUERY_002 | 查詢 Collateral Summary 與通知收件人員資訊。 |

## 3. Legacy Behavior 摘要

| 項目 | Legacy 行為 | 新版需求歸納 |
| --- | --- | --- |
| 頁面載入 | `initQuerySummary()` 呼叫 `getSummaryMap`，回填 Summary、Collateral、Other Collateral 與 Checker 下拉。 | 新版需提供 Summary 初始化 API，回傳顯示資料、可選 Checker 與狀態資訊。 |
| Summary 組裝 | 格式化幣別金額、CBC Member、法務費用、共同借款人、貸款條件、擔保品地址與代碼名稱。 | 畫面應呈現業務可審閱的摘要，而非原始代碼。 |
| Maker Submit | 角色 404 且 `CASE_PROGRESS=24` 時顯示 Checker 下拉與 Submit。 | 送出前需選 Checker，送出後案件流轉至 Checker 待辦。 |
| Checker Return | 角色 405 且 `CASE_PROGRESS=25` 可 Return Maker。 | 案件回 Maker 待辦並清空 Checker 指派。 |
| Checker Authorize | Checker 授權時檢查 T24 檢核日期、查匯率、產生 T24 檔、上傳 SFTP，案件進 26。 | Authorize 是高風險交易，需確保檔案與狀態一致。 |
| T24 結果 | 放款後超過 10 分鐘才顯示查詢結果按鈕；成功顯示 Transaction Result，失敗顯示 Message Code Record。 | 結果顯示應依案件狀態 26 / 27 / C1 控制。 |
| 下載 | 可下載 Summary PDF、Transaction Result、Message Code Record。 | 下載應走既有報表產製 API 並保留個資稽核。 |

## 4. Functional Requirements

## 4.1 頁面初始化

| 需求 | 內容 | 驗收重點 |
| --- | --- | --- |
| FR-INIT-001 | 系統須依 `APPLICATION_NO` 查詢 Summary、Disbursement、Loan Condition、T24 主借、法務所、共同借款人、Collateral 與 Other Collateral。 | 畫面可一次呈現 Summary、擔保品與新增購買標的資料。 |
| FR-INIT-002 | Summary 欄位須將代碼轉成顯示名稱，並格式化 USD / KHR 金額、日期、地址與多筆 CBC / 法務費用。 | 審核人看到的是可讀摘要，不是原始代碼與未格式化數字。 |
| FR-INIT-003 | 當 `CASE_PROGRESS=24` 且角色 404 時，系統需查詢 active 的角色 405 員工作為 CAD Checker 下拉。 | Maker 可選 Checker 後送出審核。 |
| FR-INIT-004 | 當 `CASE_PROGRESS=27` 或 `C1` 時，Summary 須顯示交易成功或失敗文字與放款時間。 | T24 結果區依案件狀態顯示正確訊息。 |
| FR-INIT-005 | 系統需依 `DISBURSING_DATE` 與目前時間計算 `t24ResultTime`，放款後超過 10 分鐘才可查詢 T24 結果。 | 案件 26 且逾 10 分鐘才顯示結果查詢入口。 |

## 4.2 頁籤顯示與導覽

| 條件 | 顯示 / 可操作狀態 | 業務意義 |
| --- | --- | --- |
| `attrMap.isEdit && CASE_PROGRESS=24 && role=404` | 顯示 CAD Checker 下拉與 Submit；404 也可 Print Out。 | Maker 送出 Summary 給 Checker。 |
| `attrMap.isEdit && CASE_PROGRESS=25 && role=405` | 顯示 To-do、Return、Authorize。 | Checker 審核或退回。 |
| `CASE_PROGRESS=26 / 27 / C1` | 依狀態顯示 T24 查詢、Transaction Result、Message Code Record 與結果文字。 | 追蹤 T24 放款處理結果。 |
| 需求 | 內容 | 驗收重點 |
| FR-UI-001 | Submit 前須驗證 CAD Checker 下拉必選。 | 未選 Checker 不得送出。 |
| FR-UI-002 | Submit、Return、Authorize 成功後皆導回待辦清單。 | 使用者不會停留在舊狀態畫面。 |
| FR-UI-003 | 下載 Summary PDF、Transaction Result、Message Code Record 應透過既有列印/下載 API。 | 下載成功時回傳暫存加密檔路徑。 |
| FR-UI-004 | T24 結果區需依 `CASE_PROGRESS` 與查詢回傳結果切換按鈕顯示。 | 27 顯示交易結果與訊息紀錄；C1 顯示訊息紀錄；未完成則隱藏。 |

## 4.3 子功能邊界

| 子功能 | 0922 觸發方式 | 0922 規格需承接 | 完整規格歸屬 |
| --- | --- | --- | --- |
| Data Input 完成 | 0920 切 Summary 前由 0921 `checkApp()` 放行 | 0922 假設 0921 已完成並可讀取 Disbursement 資料。 | EPROISU0921 |
| T24 File 產生 | `authorize` 呼叫 `EPRO_IS0922.authorize()` | 0922 負責送檔內容組成、暫存檔路徑、SFTP 上傳與上傳紀錄。 | EPROISU0922 |
| T24 Deal Result | `t24DealResult` 呼叫 `EPRO_Z0Z010.checkEnqEproDeal` | 0922 負責解析 T24 回傳、寫入 message record、更新案件狀態。 | EPROISU0922 |

## 4.4 Validation Rules

| 規則 | 觸發點 | Legacy 判斷 |
| --- | --- | --- |
| Checker 必選 | Maker Submit | `empSel` 以 Validate simpleFields 驗證，不可空白。 |
| T24 檢核日期 | Submit / Authorize | 主借與共同借款人 `CHECK_DATE` 必須等於系統日，否則阻擋。 |
| Application No. | Return / Authorize / T24 Result | `APPLICATION_NO` 不可空白，否則丟 `COMMON_MSG_ERROR_LON`。 |
| Authorize 匯率 | Authorize | 呼叫 FTR37001 查詢 KHR 匯率，return code 非 `0000` 時阻擋。 |
| SFTP 上傳 | Authorize | T24 檔須上傳至設定的 SFTP inPath；JSch / SFTP 例外需回前端錯誤。 |
| T24 結果時間 | 初始化 / 結果查詢 | 放款時間超過 10 分鐘且狀態 26 才允許查詢結果。 |
| T24 成敗 | t24DealResult | `doneFlg=Y` 更新 `CASE_PROGRESS=27`；否則更新 `C1` 並寫關案原因 C10。 |
| 結果不重複寫入 | t24DealResult | 若 `TB_MESS_RECORD` 已有資料，Legacy 不再重複寫入結果明細。 |

## 5. API / Interface Draft

| API | 用途 | 主要 Input | 主要 Output |
| --- | --- | --- | --- |
| `/EPROIS_0922/getSummaryMap` | 初始化 Summary 畫面 | `APPLICATION_NO` | `role`、`summaryQuery`、`collateralQuery`、`disburOtherCollQuery` |
| `/EPROIS_0922/submit` | Maker 送 Checker 審核 | `APPLICATION_NO`、`EMP_ID` | 更新案件 25、寫歷程、通知 Checker |
| `/EPROIS_0922/returnMaker` / `authorize` | Checker 退回或授權 | `APPLICATION_NO` | Return 回 24；Authorize 產 T24 檔、上傳 SFTP、進 26 |
| `/EPROIS_0922/t24DealResult` | 查詢 T24 放款結果 | `APPLICATION_NO` | `t24DealResultList`、`updateMap`、`RESULT` |
| `/EPROIS_0922/downloadFile` / `downloadTransResult` / `downloadMsgCodeRecord` | 下載 Summary、交易結果、訊息紀錄 | `APPLICATION_NO` | `encryptTempFileFullPath` |
| DTO | 欄位 | 說明 |  |
| summaryQuery | CASE_PROGRESS、T24_NO、MAIN_BOR_NAME、CO_BORROWER、DIS_AMOUNT、LOAN_MATURITY_DATE、FIRM_AMOUNT、RESULT、empList、t24ResultTime 等 | Summary 主畫面顯示資料與按鈕狀態來源。 |  |
| collateralQuery | COLL_DATA_SEQ、COLL_TYPE_NAME、ADDR、INS_*、PRICE_*、TITLE_DEED_NO、PUR_*、VAL 等 | 既有擔保品 Summary 顯示資料。 |  |
| disburOtherCollQuery | OTHER_COLL_DATA_SEQ、OTHER_COLL_OF_ADDR、OTHER_PRO_OF_NAME、OTHER_PRICE_*、OTHER_VAL 等 | 新增購買標的 Summary 顯示資料。 |  |
| t24DealResultList | MESSAGE_CODE、REFERENCE_NO、STATUS、ERROR_CODE、DATA_SEQ | T24 Deal Result 明細，寫入 `TB_MESS_RECORD`。 |  |
| T24 file | LIMIT.PARENT、LIMIT.CHILD、COLLATERAL.RIGHT、COLLATERAL、CUSTOMER.SSI、LD.LOANS.AND.DEPOSITS、FT.LOAN.FEE、FT.LOAN.EIR.* | Authorize 時送 T24 的檔案交易段。 |  |

## 6. DB / Transaction Requirements

| 資料表 / 服務 | 用途 | 存取型態 |
| --- | --- | --- |
| TB_LON_SUMMARY_INFO | 讀取案件狀態；Submit / Return / Authorize / T24 result 更新 current user、CADC、狀態與放款時間。 | Query / Update |
| TB_DISBUR_DATE、TB_DISBUR_COLL、TB_DISBUR_OTHER_COLL | Summary 顯示、T24 file 產生、匯率回寫與撥款資料來源。 | Query / Update |
| TB_LOAN_CONDITION_DETAIL、TB_LOAN_CONDITION_FEE、TB_T24_*、TB_MAIN_BORROWER_*、TB_CO_BORROWER_* | Summary 與 T24 file 產生所需貸款條件、費用與借款人檢核資料。 | Query |
| TB_APP_HISTORY、TB_NOTIFICATION_INFO、TB_MESS_UPLOAD_SFTP_RECORD、TB_MESS_RECORD、TB_CLO_REASON | 流程歷程、通知、SFTP 上傳紀錄、T24 訊息明細與失敗關案原因。 | Insert / Query |
| EPRO_Z0Z010、EPRO_Z0Z004、SFTP、EPRO_IS0182/0183/0184 | 匯率查詢、T24 結果查詢、暫存檔建立、SFTP 上傳與報表下載。 | External / File / Service |
| Common code / master tables | Law Firm、Employee、Common Field Options、Branch、Collateral、District 等顯示與送檔參照。 | Query |
| 交易要求 | 內容 |  |
| Submit | 確認 T24 檢核日期為當日後，更新 Summary 為 25、指定 Checker、寫入 APP_HISTORY，並寄送審核通知。 |  |
| Return Maker | 更新 Summary 為 24、CURRENT_USER 回 Maker、清空 CADC、寫入 APP_HISTORY，並寄送退回通知。 |  |
| Authorize | 查匯率並更新撥款資料、產生 T24 file、上傳 SFTP、更新 Summary 為 26、寫入 APP_HISTORY 與 SFTP 上傳紀錄。 |  |
| T24 Result | 呼叫 T24 查詢結果，寫入 MESS_RECORD；成功更新 27，失敗更新 C1 並寫入 CLO_REASON C10。 |  |

## 7. Role / Permission Rules

| 條件 | 畫面狀態 |
| --- | --- |
| `role=404 && attrMap.isEdit && CASE_PROGRESS=24` | 顯示 CAD Checker 下拉與 Submit；Maker 可下載 Summary PDF。 |
| `role=405 && attrMap.isEdit && CASE_PROGRESS=25` | 顯示 To-do、Return、Authorize。 |
| `CASE_PROGRESS=26` | 放款後超過 10 分鐘可查詢 T24 deal result；否則隱藏結果區。 |
| `CASE_PROGRESS=27 / C1` | 顯示交易結果文字；27 顯示 Transaction Result 與 Message Code Record，C1 顯示 Message Code Record。 |

## 8. Acceptance Criteria / Test Cases

| ID | 情境 | 前置 / 輸入 | 預期結果 | Priority |
| --- | --- | --- | --- | --- |
| AC-001 | 初始化 Summary | 0921 已完成，Application No. 有撥款與貸款資料。 | Summary、Collateral、Other Collateral 區塊正確回填並格式化。 | High |
| AC-002 | Maker Submit 成功 | 角色 404、狀態 24、選擇 Checker，T24 檢核日期為當日。 | 案件更新 25，指定 Checker，寫歷程並寄送通知。 | High |
| AC-003 | Maker Submit 未選 Checker | 角色 404、狀態 24，Checker 下拉空白。 | 前端阻擋 Submit，不呼叫後端。 | High |
| AC-004 | Submit / Authorize 檢核日期過期 | T24 主借或共同借款人 CHECK_DATE 非今日。 | 阻擋流程並回傳需重新檢核訊息。 | High |
| AC-005 | Checker Return | 角色 405、狀態 25。 | 案件回 24，CURRENT_USER 回 Maker，CADC 清空，寫歷程與通知。 | High |
| AC-006 | Checker Authorize 成功 | 角色 405、狀態 25，匯率查詢與 SFTP 上傳成功。 | 產生 T24 檔、上傳紀錄、案件進 26，導回待辦。 | High |
| AC-007 | Authorize SFTP 失敗 | SFTP 連線或上傳失敗。 | 回傳 SFTP 錯誤，不應讓使用者誤認已完成授權。 | High |
| AC-008 | T24 結果成功 | 狀態 26 且 T24 `doneFlg=Y`。 | 案件進 27，寫入 message record，顯示 transaction completed successfully。 | High |
| AC-009 | T24 結果失敗 | 狀態 26 且 T24 `doneFlg` 非 Y。 | 案件進 C1，寫入 C10 關案原因與 message record，顯示 failed。 | High |
| AC-010 | 下載文件 | Summary / Transaction Result / Message Code Record 有資料。 | 下載 API 回傳 `encryptTempFileFullPath`，前端可取得檔案。 | Medium |

## 9. Non-functional / Security

| 類別 | 需求 |
| --- | --- |
| 稽核 | Summary、下載、Submit、Return、Authorize、T24 result 查詢須保留查詢/編輯 Audit Log。 |
| 個資保護 | Summary 與 T24 file 含姓名、帳號、CIF、地址與貸款資訊，log 與下載檔需遵守個資保護。 |
| 交易一致性 | 狀態更新、歷程、通知、SFTP 紀錄與 T24 result 寫入需避免部分成功造成案件卡關。 |
| 外部依賴 | T24 匯率、T24 deal result、SFTP、Email 服務失敗需有可追蹤錯誤與補償流程。 |
| 效能 | Summary 初始化查詢多表與擔保品明細，需注意大型案件載入時間。 |
| 檔案安全 | T24 暫存檔、PDF、交易結果與訊息紀錄需使用受控路徑與加密暫存檔機制。 |

## 10. Definition of Ready / Done

| 階段 | 檢核項 |
| --- | --- |
| Ready | 已確認 0921 完成旗標與 0922 Summary 可讀資料契約。 |
| Ready | 已確認 Maker / Checker 角色、CASE_PROGRESS 24/25/26/27/C1 狀態流轉與待辦歸屬。 |
| Ready | 已確認 T24 file 欄位規格、SFTP 路徑、匯率與 deal result 查詢規則。 |
| Done | Summary、Submit、Return、Authorize、T24 Result、下載 API 與 UI 行為皆已實作並通過測試。 |
| Done | QA 已完成 AC-001 至 AC-010，並完成 EPROISU0920 / 0921 / 0922 串接回歸驗證。 |
