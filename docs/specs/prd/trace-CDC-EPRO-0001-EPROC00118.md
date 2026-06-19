# Bible↔PRD 對照表（trace sidecar）— `CDC-EPRO-0001` × `EPROC00118`

> **為什麼是 sidecar**：PRD 快照 verbatim 不可編（[`README.md`](README.md) 放置規則），追溯標記故放本表。
> **誰讀**：`scripts/check-srs-bundle.py` **gateⒷ**（機械、advisory）+ `spec-reviewer`（語意）。
> **行格式（機械約定）**：表 A 每列第 1 欄 `BR-nnn`——無 `FR-nnn` 對應時**必須**含 `BP-n` 或 `@PENDING`（否則 gateⒷ warn=漂移未登記）；表 B 每列第 1 欄 `FR-nnn`，PRD 快照的每個 FR 都要在本表出現。非 BR/非 FR 開頭列（業務里程碑/情境錨點）＝佐證註解、gate 不掃。
> 來源：Bible [`../bible/bible-eproposal.md`](../bible/bible-eproposal.md)（BR 表 + 待驗測指標 + 業務里程碑）、PRD 快照 [`PRD-CDC-EPRO-0001-EPROC00118-v1.0.md`](PRD-CDC-EPRO-0001-EPROC00118-v1.0.md)、缺口登記 [`../../pending-register.md`](../../pending-register.md)。本頁 status＝**In Review**（同 bundle），@PENDING 引用 bundle 內 `PENDING-0nn`/`TBD-0nn`。
> 〔PRD 用 `FR-###` 編號慣例；gateⒷ `REQ_RE` 同時容 `FR-###`/`REQ-###`，以 PRD 為主。〕

## A. Bible → PRD（下行：業務邊界有沒有被 PRD 承載）
| Bible 錨點 | PRD 承載 | 狀態 | 備註 |
|---|---|---|---|
| BR-025（個人/公司戶財務評估·信用評分·CBC 應由個金 I0/企金 C0 徵信評分族群表示，不混入主流程 `EPROISU0120`／`EPROCSU0120`；本頁企金故聚焦 CSU 側）| FR-002 Scorecard 項目維護 | 承載 | corporate scorecard＝C0 徵信評分族群、與 AO 主流程分離；本頁＝企金 `c0-corporateScorecard`（FR-003 計算公式 code-derived、非 BR-025 承載）|
| BR-005（CA 只做行政分案、不參與信用評分與核定）| FR-005 AO/CR 角色控制 承載（界定誰非評分人）| 承載 | scorecard 由 CR/AO 維護、CA 不參與 |
| BR-006（CR 可調撥貸條件金額、非最終核定人）| FR-005 AO/CR 角色控制 | 承載 | CR vs AO 欄位/button/comment 顯示與儲存邏輯不同 |
| 〔非 BR〕業務里程碑「徵信/評分」Scorecard（Bible:258）| FR-001/FR-002/FR-003 | 承載 | 徵信評分族群完整代號 source 盤點＝本頁坐實 `EPROC00118` |
| 〔非 BR〕角色 `103 Credit Reviewer + Scorecard`（Bible:399/796）`TB_ROLE_DEFINE`/`TB_API_AUTH`| FR-005 角色控制 ＋ FR-006 儲存授權 | 承載 → @PENDING（`PENDING-012`）| **D 軸**：`TB_API_AUTH` seed 補（端點授權）＝pre-deploy `PENDING-012`；role 103＝評分專屬權限 |
| 〔非 BR〕狀態流/page-menu 連動 `TB_PROCESS_CODE`（Bible:797）| FR-007 父頁與完成狀態連動 | 承載 | 更新 page menu 與 `CR_SCORE_CARD_COMPLETED` |
| 〔非 BR〕稽核追蹤 `TB_APP_HISTORY`（Bible:810）| FR-006 Save/Finished 儲存 | 承載 | upsert `TB_CORP_SCRCARD`、更新 summary 與 checkpoint |

## B. PRD → Bible（上行：FR 的業務出處）
| PRD FR | Bible 錨點 | 備註 |
|---|---|---|
| FR-001（初始化查詢）| 業務里程碑 徵信/評分（Bible:258）＋角色權限（Bible:796）| 載入案件、主借款人、scorecard options、既有資料與 checkpoint |
| FR-002（Scorecard 項目維護）| BR-025（徵信評分歸 C0 族群，Bible:739）| 維護 23 個 corporate scorecard item；item `_SCR` 數值斷言＝F 軸 QA |
| FR-003（Rate 計算）| **Bible 無計算公式錨點**（最近＝BR-025 僅規範評分族群歸屬 Bible:739；公式 code-derived）| total score/risk level/rating date；**CUR_RATIO integer-only（不靜默截斷）**＝F 軸修正 |
| FR-004（Loan Default 90+ Days 處理）| **Bible 無 Default-flag 錨點**（BR-007 僅規範 CO/SCO 授權層級分層 Bible:721、與本頁評分卡 Default 短路無關；FR-004＝source-confirmed code 行為）| Default=Yes → 直接設 Default risk、score=-1 |
| FR-005（AO/CR 角色控制）| AO 側＝BR-004 業務單位（Bible:718）；CR 側＝BR-006 CR（Bible:720）；BR-005（CA 不參與評分 Bible:719）界定非評分人；角色 102/103（Bible:399）| AO 與 CR 欄位/button/comment 顯示與儲存邏輯不同 |
| FR-006（Save/Finished 儲存）| 稽核追蹤 `TB_APP_HISTORY`（Bible:810）| upsert `TB_CORP_SCRCARD`、更新 summary 與 checkpoint；端點授權 → @PENDING（`PENDING-012`） |
| FR-007（父頁與完成狀態連動）| 狀態流/page-menu（Bible:797）| 更新 page menu 與 `CR_SCORE_CARD_COMPLETED`（`EPROC0_0110`/`EPROC0_0210`/`EPRO_Z0Z006`） |
| FR-008（參數有效日期）| **Bible 無明確錨點**（code-derived；`TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001`）| 依申請日取有效版本與 score range；Bible 回填候選 |

> **讀法**：A 表抓「Bible 有、PRD 漏」（→@PENDING 登記）；B 表抓「PRD 有、Bible 無」（→Bible 回填候選 or legacy-当-需求嫌疑，後者由 `spec-reviewer` 把關）。
> **維護**：外部 PRD 改版重新快照時，本表同步重對；@PENDING 關閉（owner/RD/DBA 裁定）時更新狀態欄。**bundle 仍 In Review、未 Approved**——本表 gap 列＝候選、非已裁。
