# Bible↔PRD 對照表（trace sidecar）— `CDC-EPRO-0001` × `EPROZ00100`

> **為什麼是 sidecar**：PRD 快照 verbatim 不可編（[`README.md`](README.md) 放置規則），追溯標記故放本表。
> **誰讀**：`scripts/check-srs-bundle.py` **gateⒷ**（機械、advisory）+ `spec-reviewer`（語意）。
> **行格式（機械約定）**：表 A 每列第 1 欄 `BR-nnn`——無 `REQ-nnn` 對應時**必須**含 `BP-n` 或 `@PENDING`（否則 gateⒷ warn=漂移未登記）；表 B 每列第 1 欄 `REQ-nnn`，PRD 快照的每個 REQ 都要在本表出現。非 BR/非 REQ 開頭列（業務里程碑/情境錨點）＝佐證註解、gate 不掃。
> 來源：Bible [`../bible/bible-eproposal.md`](../bible/bible-eproposal.md)（BR 表 + 待驗測指標 + 業務里程碑）、PRD 快照 [`PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md`](PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md)、缺口登記 [`../../pending-register.md`](../../pending-register.md)。本頁 status＝**Draft / in-review**（同 bundle，未 Approved），@PENDING 引用 bundle 內 `PENDING-Z0nn`/`TBD-0nn`。

## A. Bible → PRD（下行：業務邊界有沒有被 PRD 承載）
| Bible 錨點 | PRD 承載 | 狀態 | 備註 |
|---|---|---|---|
| BR-001（E-Proposal＝徵授信放款管理、紙本電子化）| REQ-001/REQ-002（dashboard 待辦入口＋主待辦清單）| 承載 | 旅程級範圍錨點；待辦入口＝系統首站 |
| BR-022（重構後個金以 `ISU`、企金以 `CSU` 為頁面族群判斷；**案件類型只在族群內部再分流**）| REQ-004 Page Routing 承載 | 承載 | **R4 修正後對齊**：to-be route＝refactor page-family（`EPROISU`/`EPROCSU`），legacy `EPROIS_*` 降為 trace label；案件類型在族群內分流（BR-022 核心 invariant）|
| BR-023（`IS/IU/CS/CU` 為 legacy source scope、不混寫成單一 id）| REQ-004 Page Routing 承載 | 承載 | legacy page-id 僅 trace 維度、非 to-be route 主軸 |
| BR-027（PRD/SRS/API/test 需分標 `ISU/CSU` vs legacy `IS/IU/CS/CU`）| REQ-004 承載 + QA route 斷言 | 承載 | 共同語言；R4/QA 已分標 |
| 〔非 BR〕業務里程碑「待辦與案件入口」`EPROZ0_0100` TO DO LIST（Bible:252）| REQ-001/REQ-002 | 承載 | 使用者可見案件、權限與案件狀態範圍 |
| 〔非 BR〕客戶類型/重構頁面族群（Bible:793-794，已確認重構口徑）| REQ-004 Page Routing | 承載 | 個金導 `EPROISU`、企金導 `EPROCSU`；R4 invariant 之 Bible 出處 |
| 〔非 BR〕角色權限 `TB_ROLE_DEFINE`/`TB_API_AUTH`（Bible:796）| REQ-001（role flags）/REQ-003（CAD 402）/REQ-005（AO 003 不得刪）| 承載 | role-name fact DB-resolvable（`TB_ROLE_DEFINE`）；授權矩陣 `TB_API_AUTH` |
| 〔非 BR〕狀態流 `TB_PROCESS_CODE`（Bible:797）| REQ-002（排除 03/D1/...）/REQ-005（D1）/REQ-006（C1）| 承載 | 狀態碼字典已確認 |
| 〔非 BR〕利害關係人 CUB/CUBC/TCP 欄位（Bible:799）| REQ-002-05 showRelated | 承載 | `IS_CUB_RELATED`/`IS_CUBC_RELATED`/`IS_TCP`＝Y → showRelated=Y（對齊 schema 欄名） |
| 〔非 BR〕報表查詢入口（Bible:261，`EPROZ00600`）| REQ-007 Proposal Download | PARTIAL → @PENDING（`PENDING-Z006`）| 下載 token/path 策略掛 RD/Security ⏸（spec.md:162）；Bible 僅旅程級報表錨點 |

## B. PRD → Bible（上行：REQ 的業務出處）
| PRD REQ | Bible 錨點 | 備註 |
|---|---|---|
| REQ-001（Dashboard 初始化）| 業務里程碑 待辦入口（Bible:252）＋角色權限（Bible:796）| isAO/role/isCA/isCRCOSCO/isCOSCO/isCADMERCER role flags；REQ-001-05 非純 GET（prompt 有 side effect） |
| REQ-002（Main Task List）| 待辦入口（Bible:252）＋狀態流（Bible:797）＋利害關係人（Bible:799）| 排除 CASE_PROGRESS 03/D1/R0305/R0313/R0397；showRelated CUB/CUBC/TCP；USD/KHR 加總 |
| REQ-003（CAD Task Search）| 角色 402 CAD（Bible:796，定義另見 Bible:406）＋案件類型 `LON_TYPE_CODE` 01-04（Bible:792）| **承載**（R3, spec.md:79-84）：active proxy＝as-is carried（legacy 自 `TB_EMP_PROXY` 加入 `IN_CURRENT_USER_ID`、非 regression）；draft 約束 docNo↔`NO` mapping＝@PENDING（`PENDING-Z004`）、date-range 六月限制＝@PENDING（`PENDING-Z005`） |
| REQ-004（Page Routing）| 客戶類型/重構頁面族群（Bible:793-794）＋BR-022/BR-023/BR-027 | **R4 invariant**：to-be＝refactor page-family、legacy id＝trace label only |
| REQ-005（Delete）| 狀態流 D1（Bible:797）＋角色 AO 003（Bible:796）＋稽核追蹤 `TB_APP_HISTORY`（Bible:810）| 同交易寫 DEL_REASON/APP_HISTORY、CASE_PROGRESS=D1；代理人 PROCESS_AGENT_CODE/NAME |
| REQ-006（Close）| 狀態流 C1（Bible:797）＋自動撥貸 `IS_AUTODIS`（Bible:802）＋角色 CAD（Bible:796）| 同交易寫 CLO_REASON/APP_HISTORY、CASE_PROGRESS=C1；IS_AUTODIS M→MC、Y→YC |
| REQ-007（Proposal Download）| **Bible 無明確錨點**（最近＝報表查詢 Bible:261）| code-derived；下載 token/path 策略 → @PENDING（`PENDING-Z006`，RD/Security，spec.md:162） |

> **讀法**：A 表抓「Bible 有、PRD 漏」（→@PENDING 登記）；B 表抓「PRD 有、Bible 無」（→Bible 回填候選 or legacy-当-需求嫌疑，後者由 `spec-reviewer` 把關）。
> **維護**：外部 PRD 改版重新快照時，本表同步重對；@PENDING 關閉（owner/RD/DBA 裁定）時更新狀態欄。**bundle 仍 In Review、未 Approved**——本表 gap 列＝候選、非已裁。
