# 待決登記表（Pending Register）

> **單一視圖**：把散落在各 SRS `@PENDING`、escalation、A-1 OQ、架構待議的**開著的決策**聚一處——「**誰欠我們裁定、卡什麼、開了多久**」。
> 來源仍各自為準（改在來源檔、這裡同步）。**最後更新＝2026-06-25**。狀態：🔴 擋主線 ／ 🟡 擋單頁/子集 ／ ⚪ 非阻擋/暫緩。
> **06-11 裁定輪**：`00800` TBD-001~007 七條全裁（五關二改追蹤），見文末 §✅ 已關。

## 🔴 擋主線（卡住才能往下走）
> **（目前無）**——2026-06-16 owner「**T24 都照舊系統規格**」後，撥貸 domain group **大縮移 🟡**；A-1（換匯 stub+conformance）、批次層 AUD-10 全結 → **無 owner 決策擋主線**，撥貸剩**執行**（Codex T24 B-group batch-fix＋殘 domain A-4/M6/B-1/G·H〔06-17 全裁照舊〕的 Codex 收尾）+ T24 UAT。

## 🟡 擋單頁 / 子集（不擋主線，擋該頁定版）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| ~~**撥貸 domain 殘**~~ ✅（06-17）| owner 全裁＝照舊系統處理（A-4 對齊舊判據、M6 照舊來源接回、B-1 取 `OVSLXLON01`、G·H 坐實舊 `DISBURSEMENT_CURRENCY`；A-5/rounding keep）→ 轉 Codex 執行 | — | 撥貸 domain | 06-05→06-17 | `disbursement-domain-escalations.md`＋`archive/decisions-2026H1-disbursement.md` 撥貸殘 domain 全裁列 |
| ~~**T24 SRS re-open**（`EPROISU0922`）~~ ✅ Approved 2026-06-23 | owner follow-legacy 收口（B8/C9 皆由 `TB_BRANCH_PROFILE.T24_COMPANY` 餵、blank→`FAILED_E999`；A15/segments B/D/H1-7/`TBD-0922-007/008` 全關）。N-axis A–G PASS + cross-model 0 Blocker + owner stamp。 | Done | 撥貸 domain owner | 06-20→06-23 | `docs/specs/srs/EPROISU0922/spec.md` `TBD-0922-007/008`/`REF-D8`；`decisions.md` 06-22 residual closeout |
| ~~**0921 A-4/M6 SRS re-open**（`EPROISU0921`）~~ ✅ Approved 2026-06-23 | owner 逐項裁定收口（A-4/`CO_CHECK`/M6 `MM/YYYY`/law firm `REF-D3`/Product→Sector mapping/Return cleanup SQL1-12/`collproSize`=5 各自計數 等）。N-axis A–G PASS + cross-model 0 Blocker + owner stamp。 | Done | 撥貸 domain＋RD/Codex | 06-20→06-23 | `docs/specs/srs/EPROISU0921/spec.md` `@PENDING`；`decisions.md` 06-22 0921 SRS checkpoint |
| ~~**SR-B1/B2**~~ ✅（06-17）| owner 裁不小修、折進 00800 重建（R15 補 `MSG_OVER_COUNT_LIMIT`/`MSG_QUERY_FAIL` 2 碼+拆 400/500；gateⒺ 持續 warn 為安全網）。 | — | RD／SA | 06-16→06-17 | `build-tasks/done/00800-spec-review-findings.md` |
| **c0 escalation E1** | CU-return checkpoint 只清 CS、無 CU 分流（`:2985`） | c0 評分決策生命週期正確性 | 信用決策 domain | 06-05 | `feature-inventory §⑤`＋**派工卡 `build-tasks/c0-crediteval-e1-e2-escalation.md`** |
| **c0 escalation E2** | `crScoreCardCompleted` 整欄覆寫 `"NN"`（`:2890`） | 同上 | 信用決策 domain | 06-05 | `verification-handoff §1`＋派工卡（同上）|
| **AUD-2**（F-6）| `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard）遷/不遷——是否由 00116-00120 涵蓋 | M7 兩列定版 | 信用評分 domain | 06-11 | 同（DIFF-007）|
| **AUD-3**（F-2）| `SysNews` 公告/`BatchManager`/`cacheMonitor` 遷/不遷 | M9 admin 列定版 | PM/ops | 06-11 | 同（DIFF-016）|
| **AUD-4**（F-3）| demo 頁（`DEMOA0_*`）正式不遷裁決 | M9 demo 列定版 | PM | 06-11 | 同（DIFF-016）|
| ~~**AUD-5**~~ ✅ 06-15 關 | BIBLE-GAP-1~5 舊源存在性驗證 | — | **recon 完成（`done/bible-gap-recon.md`+findings）：五項全收斂、審計總量不變**（00670→0181/TLOD；0180→z0 ToDo/Search；0182/0183/0184→0922）| 06-11→06-15 | `bible-gap-recon-findings.md` |
| **AUD-7**（schema-diff）| 舊 schema 54 表 new02 未帶——扣 `_BK/_TEST/TMP` 後的 reference/config 表（`TB_OCCUPATION`/`TB_COLL_TYPE` 系/`TB_MENU_TREE`/`TB_SCORE_CARD_PARAM_*` 等）刻意捨棄 or 漏建。**06-16 legacy-reverify 確認**：`TB_SCORE_CARD_PARAM_MAIN/SUB` 舊有新無（新僅 `_DETAIL`）、db-schema-catalog/module 已校正——餘 54 表去留仍待裁 | 下游功能缺表風險 | SA/DBA | 06-12 | 同＋`legacy-schema-db-reverify-findings.md` |
| **AUD-8**（schema-diff）| new02 獨有 `TB_PAGE_COLUMN_AUTH_CATEGORY/_DETAIL` 用途確認（R7 三表外的新權限機制？）| 權限模型完整性 | SA/ops | 06-12 | 同 |
| ~~**AUD-11**（F-OWN-4）~~ ✅（06-28）| owner 新版 Excel 裁定：`EPROCS_0160`/`0260` + `EPROCU_0160`/`0260` 全併 `EPROCSU0160`；`EPROCU0160` 非新 target。三判＝(b) 刻意演進·縮編 + (c) DB 結構差，keep 新、關「併 vs 分」。`CsuLoanConditionServiceImpl:597` 讀 `EPROISU0160` 另作 checkpoint potential regression，併企金線 parity 補比，不再卡 AUD-11。 | Done：`feature-inventory §1A/§2B` 已回填；`:597` 另軌 | owner/Codex | 06-16→06-28 | `decisions.md` AUD-11 2026-06-28 列；`done/aud11-cu0160-page-reverify-findings.md` closeout；`feature-inventory.md §1A` |
| **企金線 老系統 parity 補比**（reopen 06-17，**18 頁**）| 企金線（c0 評分 9 + CSU 主流程 9）由鏡像個金 i0/ISU twin 建、**未對舊企金 cs/cu 行為比**（0921「撥貸收斂後評估補比」）→ 撥貸已收斂、補比到期；E1/E2（00118）、`CsuLoanConditionServiceImpl:597` checkpoint key potential regression 合流 | 企金線各頁老系統 parity 維度定版（risk-tier 00118/00120/0170/0160 先）| 信用決策 domain＋RD/Codex（碼驗）| 06-17 | `archive/decisions-2026H1-disbursement.md` 0921＋`decisions.md` c0-parity reopen 列＋**派工卡 `build-tasks/c0-legacy-parity-recheck.md`**（18 頁批次，套 `process/legacy-parity-sop.md`）|
| **EPROCSU0170 SRS in-review** | Open SRS @PENDING IDs: RP12 RP13 RP14 RP15 RP16 RP17 RP18 RP19 RP20 RP21 RP22 RP23 RP24. | EPROCSU0170 Approved gate / human checkpoint | Credit decision domain + RD/SA/Security/DBA | 2026-06-23 | `docs/specs/srs/EPROCSU0170/spec.md` §@PENDING |
| ~~**EPROC00117 SRS in-review**~~ ✅ Approved 2026-06-24 | @PENDING none；axis A–F 確認（SaveRequest DSR fields + fixed USD closed）+ owner stamp。**follow-up**：企金線老系統 parity 補比（row 26）為另軌 downstream。 | — | owner | 2026-06-24 | `docs/specs/srs/EPROC00117/spec.md` Status |
| ~~**EPROC00115 SRS**~~ ✅ Approved 2026-06-25 | @PENDING none（12 finalize closed 06-24）；fix-card 🟡 全真修 + axis A–F 0 Blocker + owner stamp。**殘留非阻擋 🟡（折下次 touch）**：`COMMON_MSG_LIMIT` UI-only disclaim、`legacyFunctionId` 後端分流取代註明、BR-001 blank→`COMMON_MSG_ERROR_LON` 綁 R2。 | Done | owner | 2026-06-25 | `docs/specs/srs/EPROC00115/spec.md` Status |
| ~~**EPROC00119 SRS in-review**~~ ✅ Approved 2026-06-25 | @PENDING none（RP40-RP55 closed）；Round 2 補承載 PRD §8 兩條 Finished 阻擋（Balance Date 且 `DIFFERENCE!=0`、第一年度 Total Assets/Liab Equity=0）落 R7/REF-D5/DEC-RP55；axis A–F 0 Blocker + 跨模型再審 + owner stamp。**follow-up**：RD 實作回 backend 核 `E119`(第一年度零)/`E120`(difference!=0) 訊息碼方向勿標反；實作 pending RD；QA axis G 暫停。 | Done | owner | 2026-06-25 | `docs/specs/srs/EPROC00119/spec.md` Status |
| ~~**EPROC00120 SRS**~~ ✅ Approved 2026-06-25 | @PENDING none（P-001..P-013 closed 06-24）；fix-card 🟡 全真修 + axis A–F 0 Blocker + owner stamp。**殘留非阻擋 🟡（折翻新/下次 touch）**：Traceability 殘段 grandfathered、openapi 兩 row schema 重複可維護性。 | Done | owner | 2026-06-25 | `docs/specs/srs/EPROC00120/spec.md` Status |
| ~~EPROZ00100 / EPROC00118 SRS @PENDING / contract closeout~~ ✅（06-20）| owner-decision closed、RD/DBA contract closeout 完成、`TB_API_AUTH` 12 rows direct-applied + SELECT-only recheck vs OVSLXLON02、兩 bundle 轉 dual-axis Approved。 | Done | RD/DBA | 06-20 | `docs/build-tasks/done/EPROZ00100-EPROC00118-contract-closeout-card.md`＋`pilot-srs-pending-verification.md/.sql`＋`c0-authz-sql-findings.md` |

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
> 🧭 **Model A**：來源 spec（`specs/srs/<funcId>/spec.md §@PENDING`）**已移母資料夾、Codex 擁**；c0 token 列已凝縮成 per-funcId（完整 verdict 見母資料夾 spec §@PENDING / git history）。
| ID | 裁定（06-11）| 來源（＝完整內容）|
|---|---|---|
| **EPROC00110** TBD-001~006 ✅（06-24）→ R13–R18 | 6 條全關（NO_EXPOSE/APP_NO_CONTRACT/ERROR_INIT/C0_TITLE_KEY/GI_FI_KEYS/DESTRUCTIVE_SWITCH）| 母資料夾 `specs/srs/EPROC00110/spec.md §@PENDING` |
| **EPROC00112** TBD-001~007 + SEC-001 ✅（06-24）→ R9,R11–R17 | 8 條全關 | 母資料夾 `specs/srs/EPROC00112/spec.md §@PENDING` |
| **EPROC00114** PENDING-001~006,008~010 ✅（06-24）→ R11 | 9 條全關 | 母資料夾 `specs/srs/EPROC00114/spec.md §@PENDING` |
| **EPROC00116** 12 條 ✅（06-24）→ R3–R12 | REFERENCE/LEGACY-MSG/5YR/TYPO/HIGHLIGHT/REPORT-TMPL/CALC-SIDE-EFFECT/PXLS-AUTHZ/SAVE-LIST/PARITY/HAVEDATA/SERVICE-AUTHZ | 母資料夾 `specs/srs/EPROC00116/spec.md §@PENDING` |
| **EPROC00117** RP26~RP38 ✅（06-24）→ R1–R8/DB-D2 | 13 條全關 | 母資料夾 `specs/srs/EPROC00117/spec.md §@PENDING` |
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
| **00800 R7 page-column backfill** | SELECT-only proof found `TB_PAGE_COLUMN_AUTH_DETAIL` has `revised.item` and `button.butSave/butFinish`, but lacks `reason.item`; backend guard now requires `reason.item`, so current DB config blocks full implementation closeout until DBA/RD applies `docs/build-tasks/done/00800-contract-closeout-authz-backfill.sql` or equivalent and re-runs `docs/build-tasks/done/00800-contract-closeout-authz.sql`. | EPROZ00800 save/edit authorization closeout | DBA/RD | 2026-06-21 | `docs/build-tasks/done/00800-implementation-closeout-findings.md` |
| ~~**0921/0922 D-axis implementation closeout blockers**~~ ✅ closed 2026-06-23 | Backend closeout landed for both Approved-gate bundles (0921 CAD Maker/state/serialize/T24 check/fee/M6/mapping/log-mask；0922 Maker-Checker four-eyes/serialize/transactional submit-return/`epl-case-isu-summary-t24-result` idempotent result route/log-mask). `check-srs-bundle`+backend test local PASS. | Done | RD/SA | 2026-06-22→2026-06-23 | `docs/specs/srs/EPROISU0921/`；`docs/specs/srs/EPROISU0922/`；`docs/decisions.md`；`backend/.../DataInputServiceImpl.java`；`SummaryServiceImpl.java`；`RestTemplateLoggingInterceptor.java`；`LogSimplifier.java` |
