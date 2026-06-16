# 待決登記表（Pending Register）

> **單一視圖**：把散落在各 SRS `@PENDING`、escalation、A-1 OQ、架構待議的**開著的決策**聚一處——「**誰欠我們裁定、卡什麼、開了多久**」。
> 來源仍各自為準（改在來源檔、這裡同步）。**今＝2026-06-11**。狀態：🔴 擋主線 ／ 🟡 擋單頁/子集 ／ ⚪ 非阻擋/暫緩。
> **06-11 裁定輪**：`00800` TBD-001~007 七條全裁（五關二改追蹤），見文末 §✅ 已關。

## 🔴 擋主線（卡住才能往下走）
> **（目前無）**——2026-06-16 owner「**T24 都照舊系統規格**」後，撥貸 domain group **大縮移 🟡**；A-1（換匯 stub+conformance）、批次層 AUD-10 全結 → **無 owner 決策擋主線**，撥貸剩**執行**（Codex T24 B-group batch-fix）+ 小 domain。

## 🟡 擋單頁 / 子集（不擋主線，擋該頁定版）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| **撥貸 domain 殘**（group 大縮）| ~~T24 欄值/格式/欄寬~~（✅ 06-16「T24 照舊規格」→ 執行 `build-tasks/t24-bgroup-legacy-parity-fix.md`）、~~async~~(AUD-10)、~~KHR~~(保留)；**殘＝A-4 檢核嚴格度、M6 完工日 DTO 來源**（較小）| 撥貸 0921 檢核/M6 正確性 | 撥貸 domain | 06-05 | `disbursement-domain-escalations.md` |
| **RP11 / execute DTO 形狀** | to-be `itemMap.item1..14` vs as-is 平鋪欄位 | `00800` execute 契約定版 | RD | 06-11 | 同 |
| **RP8**（as-is findings）| R6 `secureAttribute==='U'` vs `isCU`、R7 auth list vs `isEdit`——as-is 判據與 to-be 等價/等效性 | `00800` R6/R7 定版 + QA-023 | RD | 06-10 | 同 |
| **c0 escalation E1** | CU-return checkpoint 只清 CS、無 CU 分流（`:2985`） | c0 評分決策生命週期正確性 | 信用決策 domain | 06-05 | `feature-inventory §⑤` |
| **c0 escalation E2** | `crScoreCardCompleted` 整欄覆寫 `"NN"`（`:2890`） | 同上 | 信用決策 domain | 06-05 | 同 |
| **AUD-2**（F-6）| `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard）遷/不遷——是否由 00116-00120 涵蓋 | M7 兩列定版 | 信用評分 domain | 06-11 | 同（DIFF-007）|
| **AUD-3**（F-2）| `SysNews` 公告/`BatchManager`/`cacheMonitor` 遷/不遷 | M9 admin 列定版 | PM/ops | 06-11 | 同（DIFF-016）|
| **AUD-4**（F-3）| demo 頁（`DEMOA0_*`）正式不遷裁決 | M9 demo 列定版 | PM | 06-11 | 同（DIFF-016）|
| ~~**AUD-5**~~ ✅ 06-15 關 | BIBLE-GAP-1~5 舊源存在性驗證 | — | **recon 完成（`done/bible-gap-recon.md`+findings）：五項全收斂、審計總量不變**（00670→0181/TLOD；0180→z0 ToDo/Search；0182/0183/0184→0922）| 06-11→06-15 | `bible-gap-recon-findings.md` |
| **AUD-7**（schema-diff）| 舊 schema 54 表 new02 未帶——扣 `_BK/_TEST/TMP` 後的 reference/config 表（`TB_OCCUPATION`/`TB_COLL_TYPE` 系/`TB_MENU_TREE`/`TB_SCORE_CARD_PARAM_*` 等）刻意捨棄 or 漏建。**06-16 legacy-reverify 確認**：`TB_SCORE_CARD_PARAM_MAIN/SUB` 舊有新無（新僅 `_DETAIL`）、db-schema-catalog/module 已校正——餘 54 表去留仍待裁 | 下游功能缺表風險 | SA/DBA | 06-12 | 同＋`legacy-schema-db-reverify-findings.md` |
| **AUD-8**（schema-diff）| new02 獨有 `TB_PAGE_COLUMN_AUTH_CATEGORY/_DETAIL` 用途確認（R7 三表外的新權限機制？）| 權限模型完整性 | SA/ops | 06-12 | 同 |
| **AUD-11**（F-OWN-4）| `EPROCU0160` owner 盤點分出獨立新頁 vs 我們併 `EPROCSU0160`——typo 還是真分歧 | 企金無擔 Loan Condition 頁對應 | RD（Codex 碼驗）| 06-16 | 同 F-OWN-4 |

## ⚪ 非阻擋 / 暫緩 / 待業務（可獨立排）
| ID | 待決 | owner | 來源 |
|---|---|---|---|
| R2 報表服務 | 汰換 Jasper → 新報表（0181/i0·c0 PDF/z0 PDF） | 待拍板 | `feature-inventory §⑦` |
| 檔案上傳 API | collateral/審批上傳 track | 待拍板 | 同 |
| `TB_EMP_PROXY` PK | 新 DB PK=`EMP_ID` 單鍵（一人一筆 upsert）是否符業務 | 業務 | `decisions.md` Phase 1 |
| DB schema 凍結 | 初期是否凍結 | 架構 | `decisions.md §三` |
| npm 預設 registry | 預設指 `npm-all` 是否採用 | 架構/ops | `decisions.md §三` |

## 🧩 Bible→PRD seam（跨層邊界落差；`EPROZ00800` 定版前 reconcile）
> **成因**：`CDC-EPRO-0001` 由 legacy code 反推（PRD §1.1），非由 Bible 下推 → 邊界是 code 形狀（ITEM/RI-MAT/checkpoint），Bible 的**旅程形狀**業務邊界（何時顯示/案件類型/下游頁）漏在 Bible→PRD 之間，未進 PRD REQ/TBD，故也未進 SRS。來源：`specs/bible/bible-eproposal.md`、`specs/prd/PRD-CDC-EPRO-0001-v1.1-EPROZ00800.md`、`specs/srs/EPROZ00800/spec.md`。
>
> 嚴重度：🟡 擋 `00800` 完整定版（機械閘門已綠、屬語意/上游缺口）。

| ID | 待決（Bible 有、PRD/SRS 落空） | 卡住什麼 | owner | 開立 |
|---|---|---|---|---|
| **BP-1** | 案件類型 gating：EPROZ00800 **僅展期/展變顯示**（Bible BR-014、決策準則、**災難情境「不該顯示卻顯示」**、SC-002）→ PRD 無 REQ、SRS R1 無顯示條件 Rn/@PENDING | `00800` 顯示條件無 Rn/QA 承載（Bible 點名要測） | PM/SA | 06-10 |
| **BP-2** | 兩 type 軸未對清：Bible「案件類型(新/展期/展變)」(SC-001) vs PRD/SRS「`LON_TYPE_CODE`(03/04)」——關係未定義、未標 @PENDING | `00800` 案件類型欄位來源；R5 語意基礎 | SA | 06-10 |
| **BP-3** | 展期 vs 展變「不同案件類型、目前共用驗證」(BR-015/016、SC-005) → PRD/SRS 全未提、無 @PENDING | 是否該分流驗證；回歸測試範圍 | SA | 06-10 |
| **BP-4** | 下游頁映射：Bible「影響 `EPROISU0150`、顯示於 `EPROISU0173`」(BR-017、SC-003/004) → SRS re-process 清單(0210~0290)不含 0150/0173；0173 既未覆蓋也未在 Non-Goals disclaim | `00800` 下游影響的命名級追溯 | SA/RD | 06-10 |
| **BP-5** | 用詞消歧：PRD「共用頁籤」(跨 IS/IU/CS/CU 屬性) vs Bible「條件式頁籤」(跨案件類型)——PRD 未消歧、易誤讀為所有案件必走 | 文件一致性（🟢 nit） | PM | 06-10 |
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
> 用途：站會/交接看這張就知道「等誰、等什麼」；**🔴 擋主線 owner 決策＝目前無**（2026-06-16 T24 全裁「照舊規格」後清空）——撥貸 A-1/批次層/T24 全裁，殘 owner-decision＝🟡 A-4 檢核/M6（較小）+ T24 轉 Codex 執行。
