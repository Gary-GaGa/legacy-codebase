# 待決登記表（Pending Register）

> **單一視圖**：把散落在各 SRS `@PENDING`、escalation、A-1 OQ、架構待議的**開著的決策**聚一處——「**誰欠我們裁定、卡什麼、開了多久**」。
> 來源仍各自為準（改在來源檔、這裡同步）。**最後更新＝2026-06-22**。狀態：🔴 擋主線 ／ 🟡 擋單頁/子集 ／ ⚪ 非阻擋/暫緩。
> **06-11 裁定輪**：`00800` TBD-001~007 七條全裁（五關二改追蹤），見文末 §✅ 已關。

## 🔴 擋主線（卡住才能往下走）
> **（目前無）**——2026-06-16 owner「**T24 都照舊系統規格**」後，撥貸 domain group **大縮移 🟡**；A-1（換匯 stub+conformance）、批次層 AUD-10 全結 → **無 owner 決策擋主線**，撥貸剩**執行**（Codex T24 B-group batch-fix＋殘 domain A-4/M6/B-1/G·H〔06-17 全裁照舊〕的 Codex 收尾）+ T24 UAT。

## 🟡 擋單頁 / 子集（不擋主線，擋該頁定版）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| ~~**撥貸 domain 殘**~~ ✅ **06-17 全關（照舊）**| ~~T24 欄值/格式/欄寬~~（✅ 06-16「T24 照舊規格」）、~~async~~(AUD-10)、~~A-4 檢核嚴格度~~/~~M6 完工日 DTO~~/~~B-1 `T24_COMPANY`~~/~~KHR-G·H 來源~~ → **06-17 owner 全裁＝照舊系統處理**（A-4 對齊舊判據、M6 照舊來源接回、B-1 取 `OVSLXLON01`、G·H 坐實舊 `DISBURSEMENT_CURRENCY`；A-5 收窄/rounding keep 不變）→ 轉 Codex 執行 | —（已裁，剩執行）| 撥貸 domain | 06-05→06-17 | `disbursement-domain-escalations.md` A-4/D-1/B-1/B-3＋`archive/decisions-2026H1-disbursement.md` 撥貸殘 domain 全裁列（06-17）|
| ~~**T24 SRS re-open**（`EPROISU0922`）~~ ✅ **closed（06-22 owner follow-legacy）** | 主體欄已逐欄折回 `TBD-0922-001`（v1.5 為主源；delimiter/CRLF/encoding、null/default、A16、A31/G7、G11/G12、C12/C13/C20/C26/A52、E21、G4/G10/H8）✅。06-22 residual pass closes A15 blank-preservation, segments `B`/`D`/`H1-H7` under `TBD-0922-008`, and `T24_COMPANY` feeding T24 `B8`/`C9` under `TBD-0922-007`. Owner instruction on 2026-06-22 confirms B8/C9 follow the legacy/current source with no separate T24 contract override: feed both B8 and C9 from `TB_BRANCH_PROFILE.T24_COMPANY` for the disbursing department. DB-live schema-diff and new DB reverify resolve the DB fact (`T24_COMPANY` = `VARCHAR2(5 BYTE)`), the current native-map backend path reads that key, `TBBranchProfileEntity` maps the column and aligns DB-reverified T24 column lengths, and missing branch-profile row or blank/missing `T24_COMPANY` raises the existing `FAILED_E999` T24 authorize error path instead of silently falling back to blank. T1 page remains review-checkpointed and is not auto-approved. **06-23: bundle promoted to Approved after N-axis A–G PASS + cross-model spec-reviewer 0 Blocker/0 Should-fix + owner stamp.** | Done（Approved 2026-06-23）| 撥貸 domain owner | 06-20→06-23 | `docs/specs/srs/EPROISU0922/spec.md` `REF-D8` / `TBD-0922-007` / `TBD-0922-008`; `backend/src/main/java/khd/svc/epro/entity/TBBranchProfileEntity.java:44`-`47`; `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java:1808`-`1822`, `1879`-`1881`, `1909`-`1921`; `docs/build-tasks/schema-diff-findings.md:246`-`249`; `docs/db-diff/02_tables/TB_BRANCH_PROFILE.md:47`-`50`; `epro-db/out/legacy_schema_reverify_new02_columns.tsv:37`; `decisions.md` 06-22 residual closeout |
| ~~**0921 A-4/M6 SRS re-open**（`EPROISU0921`）~~ ✅ **closed（06-23 Approved）** | 06-22 已產 `docs/specs/srs/EPROISU0921/`，`check-srs-bundle` PASS；06-23 升 Approved。§5b 坐實結果：A-4 `CO_CHECK`/`mbCheck`/address/`DATA_SEQ`/business-section 維持舊 baseline；law firm 命中並採用 `REF-D3` 偏新（refactor 一律 `IS_SHOW='Y'`，舊非 `02.21` 查全部）；M6 命中 `REF-D4` 偏新 wire format（API `MM/YYYY`，physical DATE），同時 current backend save-to-null 仍是 regression。06-22 owner 已裁定 `CO_CHECK` 照舊：無共借 `CO_CHECK=Y`，有共借需人數/`CHECK_SUCCESS`/當日 `CHECK_DATE`/`DATA_SEQ` 對應通過；Finished `mbCheck`/`coCheck` 採前端 gate + BE authority；law firm 採 `REF-D3` 只允許 `IS_SHOW='Y'`；address `UPD_DATE` 由 `APPLICATION_DATE` derive，`CASE_PROGRESS=24` 更新 `DISBURSING_DATE` 只是初始化副作用；business-section comparison 照舊 mandatory；M6 採 `REF-D4`，API `MM/YYYY` 且 `EST_COM_DATE`/`OTHER_EST_COM_DATE` 必須 round-trip，current save-to-null 屬 regression；Product Code→Sector/Industry 採 PRD 權威 mapping（`01`/`02` -> `1001`/`1001`；`03` -> `1002`/`1001`；未列不得默認通過）；Return cleanup scope 採舊系統/refactor SQL1-SQL12 DB cleanup，保留/寫入 `TB_APP_HISTORY`、`TB_CONTR_DATA.CONTR_STATUS='R'`、清 T24/Data Input/auto-file-path metadata/FN condition rows，不要求實體檔刪除；`collproSize` 採同一上限值 5，但 CBC Member 與 Add Purchased Property 各自計數，BE 需擋超限 Save/Finished。 **06-23: bundle promoted to Approved after N-axis A–G PASS + cross-model spec-reviewer 0 Blocker/0 Should-fix + owner stamp.** | Done（Approved 2026-06-23） | 撥貸 domain（逐項 confirm）＋ RD/Codex（as-is 坐實／trace＋讀 `refactor-spec`）| 06-20→06-23 | `docs/specs/srs/EPROISU0921/spec.md` `@PENDING`；`decisions.md` 06-22 0921 SRS checkpoint |
| ~~**SR-B1/B2**~~ ✅ **06-17 裁＝折進重建**（00800 spec-review）| B1：R15+openapi 漏承載 PRD §6.4 `MSG_OVER_COUNT_LIMIT`/`MSG_QUERY_FAIL`（REQ-007 未完整）；B2：R15 把查詢失敗 500 誤併入輸入錯誤 400 → **owner 06-17 裁不立即小修、折進 00800 重建**（重建時 R15 補 2 碼+拆 400/500+openapi query 400/500；**gateⒺ 持續 warn＝安全網**）| —（決策定，重建承載）| RD／SA | 06-16→06-17 | `build-tasks/done/00800-spec-review-findings.md` |
| **c0 escalation E1** | CU-return checkpoint 只清 CS、無 CU 分流（`:2985`） | c0 評分決策生命週期正確性 | 信用決策 domain | 06-05 | `feature-inventory §⑤`＋**派工卡 `build-tasks/c0-crediteval-e1-e2-escalation.md`** |
| **c0 escalation E2** | `crScoreCardCompleted` 整欄覆寫 `"NN"`（`:2890`） | 同上 | 信用決策 domain | 06-05 | `verification-handoff §1`＋派工卡（同上）|
| **AUD-2**（F-6）| `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard）遷/不遷——是否由 00116-00120 涵蓋 | M7 兩列定版 | 信用評分 domain | 06-11 | 同（DIFF-007）|
| **AUD-3**（F-2）| `SysNews` 公告/`BatchManager`/`cacheMonitor` 遷/不遷 | M9 admin 列定版 | PM/ops | 06-11 | 同（DIFF-016）|
| **AUD-4**（F-3）| demo 頁（`DEMOA0_*`）正式不遷裁決 | M9 demo 列定版 | PM | 06-11 | 同（DIFF-016）|
| ~~**AUD-5**~~ ✅ 06-15 關 | BIBLE-GAP-1~5 舊源存在性驗證 | — | **recon 完成（`done/bible-gap-recon.md`+findings）：五項全收斂、審計總量不變**（00670→0181/TLOD；0180→z0 ToDo/Search；0182/0183/0184→0922）| 06-11→06-15 | `bible-gap-recon-findings.md` |
| **AUD-7**（schema-diff）| 舊 schema 54 表 new02 未帶——扣 `_BK/_TEST/TMP` 後的 reference/config 表（`TB_OCCUPATION`/`TB_COLL_TYPE` 系/`TB_MENU_TREE`/`TB_SCORE_CARD_PARAM_*` 等）刻意捨棄 or 漏建。**06-16 legacy-reverify 確認**：`TB_SCORE_CARD_PARAM_MAIN/SUB` 舊有新無（新僅 `_DETAIL`）、db-schema-catalog/module 已校正——餘 54 表去留仍待裁 | 下游功能缺表風險 | SA/DBA | 06-12 | 同＋`legacy-schema-db-reverify-findings.md` |
| **AUD-8**（schema-diff）| new02 獨有 `TB_PAGE_COLUMN_AUTH_CATEGORY/_DETAIL` 用途確認（R7 三表外的新權限機制？）| 權限模型完整性 | SA/ops | 06-12 | 同 |
| **AUD-11**（F-OWN-4）| `EPROCU0160` typo vs 真分歧——**Codex 碼驗 06-17＝UNFOUND（先不關）**：新 source **無獨立 `EPROCU0160`**（FE pageCode/route/API + BE controller 全 → `EPROCSU0160`/`epl-*-csu-*`＝傾向 typo/已併），**但** ① checkout 無 `TB_PAGE_MENU` row data → 無法證 CU×0160 routing 實指 CSU0160 ② `CsuLoanConditionServiceImpl:597` 讀 `EPROISU0160`（CS/CU checkpoint 欄＝`EPROCSU0160`）→ CU 分流正確性存疑 | 待 ① 唯讀 SQL 查 `TB_PAGE_MENU` 無擔×0160 routing ② `:597` ISU0160 是否 CU 誤接 bug | DBA(SQL)＋RD(`:597`) | 06-16 | F-OWN-4＋`done/aud11-cu0160-page-reverify-findings.md`（push `8c376f7`）＋**派工卡 `build-tasks/aud11-closeout-dba-rd.md`** |
| **企金線 老系統 parity 補比**（reopen 06-17，**18 頁**）| 企金線（c0 評分 9 + CSU 主流程 9）由鏡像個金 i0/ISU twin 建、**未對舊企金 cs/cu 行為比**（0921「撥貸收斂後評估補比」）→ 撥貸已收斂、補比到期；E1/E2（00118）、AUD-11（CSU0160）合流 | 企金線各頁老系統 parity 維度定版（risk-tier 00118/00120/0170 先）| 信用決策 domain＋RD/Codex（碼驗）| 06-17 | `archive/decisions-2026H1-disbursement.md` 0921＋`decisions.md` c0-parity reopen 列＋**派工卡 `build-tasks/c0-legacy-parity-recheck.md`**（18 頁批次，套 `process/legacy-parity-sop.md`）|
| ~~EPROZ00100 / EPROC00118 SRS @PENDING / contract closeout~~ | Closed 2026-06-20: owner-decision pending closed, RD/DBA contract closeout completed, TB_API_AUTH 12 rows direct-applied and SELECT-only rechecked against OVSLXLON02, both SRS bundles now use dual-axis Approved status. | Done | RD/DBA | 06-20 | docs/build-tasks/done/EPROZ00100-EPROC00118-contract-closeout-card.md plus pilot-srs-pending-verification.md/.sql and c0-authz-sql-findings.md |

## ⚪ 非阻擋 / 暫緩 / 待業務（可獨立排）
| ID | 待決 | owner | 來源 |
|---|---|---|---|
| R2 報表服務 | 汰換 Jasper → 新報表（0181/i0·c0 PDF/z0 PDF） | 待拍板 | `feature-inventory §⑦` |
| 檔案上傳 API | collateral/審批上傳 track | 待拍板 | 同 |
| `TB_EMP_PROXY` PK | 新 DB PK=`EMP_ID` 單鍵（一人一筆 upsert）是否符業務 | 業務 | `decisions.md` Phase 1 |
| DB schema 凍結 | 初期是否凍結 | 架構 | `decisions.md §三` |
| npm 預設 registry | 預設指 `npm-all` 是否採用 | 架構/ops | `decisions.md §三` |

## 🧩 Bible→PRD seam（跨層邊界落差；`EPROZ00800` 定版前 reconcile）
> **成因**：`CDC-EPRO-0001` 由 legacy code 反推（PRD §1.1），非由 Bible 下推 → 邊界是 code 形狀（ITEM/RI-MAT/checkpoint），Bible 的**旅程形狀**業務邊界（何時顯示/案件類型/下游頁）漏在 Bible→PRD 之間，未進 PRD REQ/TBD，故也未進 SRS。來源：`specs/bible/bible-eproposal.md`（v1.1）、`archive/EPROZ00800-v0.9-superseded/`（舊 PRD+v0.9 SRS 已封存 2026-06-17，待重產）。
>
> 嚴重度：🟡 擋 `00800` 完整定版（機械閘門已綠、屬語意/上游缺口）。
> **✅ 2026-06-17 Bible v1.1 更新**：BP-1~5 之 **Bible 側已承載**（BR-014~017 案件類型 gating/影響 0150/顯示 0173、SC-002~005、災難情境「EPROZ00800 不該顯示卻顯示」、型三軸 `LON_ATTRIBUTE`/`LON_TYPE_CODE`/`SECURE_ATTRIBUTE`）→ BP-1~5 由「Bible 有但落空」轉「**待 PRD/SRS 下推**」（00800 重產 + 新 PRD→SRS 時承載；非 Bible 缺口）。

| ID | 待決（Bible 有、PRD/SRS 落空） | 卡住什麼 | owner | 開立 |
|---|---|---|---|---|
| **BP-7** ✅ **已收口（06-10）** | ~~Bible→PRD 漂移無 gate~~ → 控制點：trace sidecar（`specs/prd/trace-<docId>-<funcId>.md`，表 A 缺對應必標 BP/@PENDING）+ `check-srs-bundle.py` **gateⒷ**（covers-prd 懸空=FAIL、trace 缺漏=warn） | —（漂移仍會發生，但**會被登記/警示**；裁定仍須人） | 流程/SA | 06-10 |

## ✅ 已關（保留 30 天供交接，之後可清；**裁定內容單一出處＝來源 spec §@PENDING**，本表只留 verdict token）
| ID | 裁定（06-11）| 來源（＝完整內容）|
|---|---|---|
| **TBD-006 / RP1** 🔴→✅ | **A＝保留側效＋修bug＋audit** → R13.1–13.3/13.6/13.7 定版、QA-007/008 解 pending | `00800 spec.md §@PENDING` |
| **TBD-003 / RP2** ✅ | 保留強制、原因後補 → R5 定版 | 同 |
| **TBD-004 / RP3** ✅ | 保留刪 fee、原因後補 → R13.6 定版 | 同 |
| **TBD-007 / RP5** ✅ | 維持現狀（僅持久化、無側效）→ R13.7 定版 | 同 |
| **TBD-002 / RP7** ✅ | `Finshed`→`Finished` 定版 | 同 |
| **RP10** ✅（06-12）| checkpoint key＝`TB_CHECK_POINTS_{IS,IU,CS,CU}` 欄位（新 funcId 形，DDL 機械枚舉；R14 表名同步修正）→ R14 定版、殘差實作＝rimat F8 | 同 |
| **RP11** ✅（06-21）| execute DTO final shape＝`applicationNo` + required `isFinish` + required `isNotSame` + `itemMap.item1..14/reasonMemo`；legacy/PRD `checkPointMap` 不作為 client-authoritative to-be input，checkpoint/page-menu 由 backend 推導；殘差實作＝current DTO required validation gap | `00800 spec.md` R11 / REF-D3 / QA-017 |
| **BP-1** ✅（06-21）| EPROZ00800 visibility gate＝backend-owned `LON_TYPE_CODE in ('03','04')`；unsupported cases 由 tab-control/prompt 隱藏，direct query/save 在讀取 Revised Item 或 DB mutation 前以 `ACCESS_DENIED`/forbidden-page envelope 擋下；BP-2/BP-3 已分別裁定 terminology/split semantics | `00800 spec.md` R1 / R16 / QA-002 / QA-043 |
| **BP-2** ✅（06-21）| Bible case-type axis＝backend-owned `TB_LON_SUMMARY_INFO.LON_TYPE_CODE`：`01=New`、`02=Additional`、`03=Renew/展期`、`04=Change Condition/展變`、`05=Restructure` when present；`LON_ATTRIBUTE`/`SECURE_ATTRIBUTE`/`caseCategory` 只作 customer/security/checkpoint family，不可替代案件類型 | `00800 spec.md` R1 / R5 / R13.3 / R14 / QA-044 |
| **BP-3** ✅（06-21）| Renew(03) / Change Condition(04) 共用 Revised Item validation；不拆兩套 validation。03 特例＝R5 `item1` 強制 Y；04 特例＝R13.3 `item12` fee delete side effect；未來若要拆分需新 PRD/source-backed owner change | `00800 spec.md` R4 / R5 / R13.3 / QA-045 |
| **BP-4** ✅（06-21）| 下游映射拆成兩層：`EPROISU0150`/`EPROCSU0150` 僅在 active checkpoint 實體有欄位時由 00800 更新（IS/CS；IU/CU 不合成 0150）；`EPROISU0173`/`EPROCSU0173` 是摘要顯示/讀取追溯，歸 0173 bundles 驗證，不作為 00800 checkpoint/page-menu key；save 後 FE 重新打 `epl-auth-tab-control` | `00800 spec.md` R14 / REF-D5 / QA-046 |
| **BP-5** ✅（06-21）| `shared` / `common` 只表示 EPROZ00800 是共用模組與 tab config 分類，不代表所有案件必顯示或必完成；實際顯示/必填仍限 backend-owned `LON_TYPE_CODE in ('03','04')` 的展期/展變，非 03/04 不顯示且 direct query/save 需被擋 | `00800 spec.md` Scope / R1 / QA-047 |
| **RP8** ✅（06-21）| R6 定版為 backend-owned corporate-unsecured predicate：`LON_ATTRIBUTE='C' AND SECURE_ATTRIBUTE='U'` / `isCorporateUnsecured`，不接受 `secureAttribute='U'` alone；R7 接受 granular FE page-column/button auth 作 UI model，但 RD closeout 必須補 config mapping evidence 與 backend service-level page/edit guard，`TB_API_AUTH` alone 不足 | `00800 spec.md` R6 / R7 / R16 / QA-006 / QA-007 / QA-042 |
| **RP9** ✅（06-16 RD/架構）| init-query＝GET（Follow PRD §6.1；method recon 全站 280/282 POST 仍依 PRD 走 RESTful）→ R2/Endpoints/openapi 定版、get-body #3 解鎖 | `00800 spec.md §@PENDING` |
| **AUD-6** ✅（06-16 DBA/domain）| 接受財評精度縮減（`(28,2)→(20,2)`、利率 6→2 位；新 DB 為準不還原）⚠️ 利率 2 位 caveat | `schema-diff-findings.md` |
| **AUD-9** ✅（06-16）| deputy 已對齊複合 PK（`@EmbeddedId` EMP_ID+STR_TIME）＝無 bug，早期單鍵係文件假設錯、碼對 | `00700-deputy-pk-reverify-findings.md` |
| **AUD-10** ✅（06-16 碼驗）| 批次層 `EPROZ0_B001–B008` app 層完整：6/8 FOUND（新批次重編號）+ B005 銷案（backend 無 `TB_EXCHANGE_RATE` read 點→inline 換匯取代每日批次）；B008 log 歸檔＝ops（非 app，logrotate/平台確認，另立 ops 追蹤） | findings `build-tasks/done/aud10-batch-layer-reverify-findings.md` |
| **AUD-1** ✅（06-16 owner 盤點）| Property Info 家族（`EPROIS_0140/0240`、`EPROIU_0140/0240`）= owner 權威盤點表標**已無使用**＝確認不遷（F-OWN-2）→ 與 `CS_0240` 同處置 | `legacy/legacy-function-inventory.md` + `refactor-audit/owner-inventory-reconcile.md` F-OWN-2 |
| **A-1 OQ**（OQ-1~5）✅（06-16 owner：先對齊舊 parity）| OQ-1=`IdNo=OVSLXLON01`（非新 stub `02`；同 A-2 匯率源）、OQ-3=映射 `EPROIS0921_UI_RAET_FIND_ERROR`＋非 0000 中止 authorize、OQ-4=catch throw 勿回 null、OQ-5=G/H 讀 `EX_RATE_BUY`（已修 `581e717`）、OQ-2 精度（已關）→ **A-1 stub 轉施工-ready**（編碼缺口見 STATUS §三）。⚠️ 唯一復驗點＝新環境 T24 拒收 `01` | `a1-funcGetExchangeRate-spec.md` §7＋`a1-oq-legacy-recon-findings.md` |
| **TBD-001 / RP6** ✅（06-12）| ITEM1~14 名稱取數定版（舊庫 `TB_COMMON_FIELD_OPTIONS`+`TB_MULTI_LANG`，findings E1）→ 畫面顯示定版、順帶裁 RP4、RP2 原因補文 | 同 |
| **TBD-005 / RP4** ✅（06-12）| **設計非缺陷**：ITEM1=Renew Loan Tenor ≠ ITEM10=ATC_Tenor → R13.4/13.5 定版、QA-009 拆 a/b、實作＝rimat F9 | 同 |

---
> 維護：新 `@PENDING`/escalation/OQ 開立 → 加一列；**關閉時**在來源檔裁定 + 本表移除/標 ✅ + 回填 `feature-inventory.md`。**裁定內容只寫來源檔（spec §@PENDING）**，本表只留 id/狀態/owner/指回——本表＝derived 視圖。
> **機械同步**：SRS 來源列（RPn/BP-n）由 `scripts/check-srs-bundle.py` gateⓅ 對 spec §@PENDING 表自動 diff（漏登記/失步=FAIL）；非 SRS 來源列（A-1 OQ、撥貸 group、E1/E2…）仍靠人工。
> 用途：站會/交接看這張就知道「等誰、等什麼」；**🔴 擋主線 owner 決策＝目前無**（2026-06-16 T24 全裁「照舊規格」後清空）——撥貸 A-1/批次層/T24/殘 domain（A-4/M6/B-1/G·H）全裁（06-17 全照舊）→ owner-decision **全清空**、剩 Codex 執行 + T24 UAT。

## Active Implementation Closeout Blockers

| ID | Pending | Blocks | owner | Opened | Evidence |
|---|---|---|---|---|---|
| **00800 R7 page-column backfill** | SELECT-only proof found `TB_PAGE_COLUMN_AUTH_DETAIL` has `revised.item` and `button.butSave/butFinish`, but lacks `reason.item`; backend guard now requires `reason.item`, so current DB config blocks full implementation closeout until DBA/RD applies `docs/build-tasks/00800-contract-closeout-authz-backfill.sql` or equivalent and re-runs `docs/build-tasks/00800-contract-closeout-authz.sql`. | EPROZ00800 save/edit authorization closeout | DBA/RD | 2026-06-21 | `docs/build-tasks/00800-implementation-closeout-findings.md` |
| ~~**0921/0922 D-axis implementation closeout blockers**~~ ✅ **closed 2026-06-23** | Backend closeout landed for the Approved-gate D-axis blockers: 0921 now enforces CAD Maker `404`/state `24`/current handler on save, return, and borrower-check mutations, serializes on `TB_LON_SUMMARY_INFO`, rejects any save after `EPORIS_0921='Y'`, verifies current stored T24 main/co-borrower checks before money/completion mutation, handles no-co-borrower `coCheck=Y` plus `DATA_SEQ` mapping, carries `facilityFee`/`refinancingFee` in save/info responses, uses application-date address `updDate`, persists M6 `MM/YYYY` completion dates, fails unlisted product/sector/industry mappings, validates active law firm and paired other-fee remark, and masks outbound logs; 0922 submit/return/authorize now serialize on the case summary row, enforce Maker/Checker state/role/ownership and four-eyes self-approval before T24/SFTP, map stale check date to `EPROIS0922_CLICK_CHECK`/`EPROIS0922_AUTHORIZE_CHECK`, run submit/return transactionally, expose `epl-case-isu-summary-t24-result` as an idempotent `TB_MESS_RECORD` result refresh/read route deriving `27`/`C1` plus `TB_CLO_REASON=C10`, and mask outbound logs. `check-srs-bundle` and backend package/test are local PASS; page bundles remain In Review and must not be owner-stamped Approved without the final cross-model/human checkpoint. | EPROISU0921/EPROISU0922 Approved-gate checkpoint | RD/SA | 2026-06-22→2026-06-23 | `docs/specs/srs/EPROISU0921/`; `docs/specs/srs/EPROISU0922/`; `docs/decisions.md`; `backend/src/main/java/khd/svc/epro/service/individual/impl/DataInputServiceImpl.java`; `backend/src/main/java/khd/svc/epro/service/individual/impl/SummaryServiceImpl.java`; `backend/src/main/java/khd/svc/epro/config/RestTemplateLoggingInterceptor.java`; `backend/src/main/java/khd/svc/epro/util/LogSimplifier.java` |
