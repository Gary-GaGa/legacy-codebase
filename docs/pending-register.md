# 待決登記表（Pending Register）

> **單一視圖**：把散落在各 SRS `@PENDING`、escalation、A-1 OQ、架構待議的**開著的決策**聚一處——「**誰欠我們裁定、卡什麼、開了多久**」。
> 來源仍各自為準（改在來源檔、這裡同步）。**今＝2026-06-11**。狀態：🔴 擋主線 ／ 🟡 擋單頁/子集 ／ ⚪ 非阻擋/暫緩。
> **06-11 裁定輪**：`00800` TBD-001~007 七條全裁（五關二改追蹤），見文末 §✅ 已關。

## 🔴 擋主線（卡住才能往下走）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| **A-1 OQ×5** | 匯率源 ID（OVSLXLON01 vs 02）、精度、錯誤碼、catch 回 null?、`EXCHANGR_RATE` 欄名 | 撥貸 authorize 端到端（換匯→T24→定案）；**撥貸上線關鍵路徑** | PM/SA/T24/DBA | 06-05 | `build-tasks/a1-funcGetExchangeRate-spec.md` |
| **撥貸 domain group** | `T24_COMPANY` 值源、檢核嚴格度、`KHR`(演進勿改回)、欄寬、async、M6 完工日 DTO 缺源 | 撥貸 0921/0922/T24 行為對等 | 撥貸 domain/T24/DBA | 06-05 | `disbursement-domain-escalations.md` |

## 🟡 擋單頁 / 子集（不擋主線，擋該頁定版）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| **§5.6 / openapi checkpoint-keys** | `EPRO{IS/IU/CS/CU}_0260` 確切 key 清單 | `00800` R14 checkpoint key 重映射（S7） | RD/PM | 06-09 | `specs/srs/EPROZ00800/openapi.yaml` |
| **init-query method** | GET（PRD §6.1）vs 全站 RPC-POST | `00800` init-query 契約 method | RD/架構 | 06-09 | `00800 spec.md Endpoints @PENDING(method)` |
| **TBD-001 / RP6** | **動作項（06-11 改寫）**：SA 對 legacy DB 跑 `SELECT * FROM TB_COMMON_FIELD_OPTIONS WHERE SYSTEM='EPRO' AND FIELD_NAME='REVISED_ITEM'` → ITEM1~14 正式名稱補 PRD §5/7/10＋SRS → **順帶裁 TBD-005** | `00800` 畫面顯示＋RP4 判據 | **SA（取數）** | 06-08 | 00800 §@PENDING |
| **TBD-005 / RP4** | ITEM1 與 ITEM10 皆 TENOR（設計 or 缺陷）——**06-11 裁：連動 TBD-001 取數後定**（ITEM10 正式名＝判據，匯出前不賭）| `00800` R13.4/5＋QA-009 | RD/SA | 06-08 | 同 |
| **RP8**（as-is findings）| R6 `secureAttribute==='U'` vs `isCU`、R7 auth list vs `isEdit`——as-is 判據與 to-be 等價/等效性 | `00800` R6/R7 定版 + QA-023 | RD | 06-10 | 同 |
| **c0 escalation E1** | CU-return checkpoint 只清 CS、無 CU 分流（`:2985`） | c0 評分決策生命週期正確性 | 信用決策 domain | 06-05 | `feature-inventory §⑤` |
| **c0 escalation E2** | `crScoreCardCompleted` 整欄覆寫 `"NN"`（`:2890`） | 同上 | 信用決策 domain | 06-05 | 同 |

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
| **BP-7** ✅ **已收口（06-10）** | ~~Bible→PRD 漂移無 gate~~ → 控制點：trace sidecar（`specs/prd/trace-<docId>-<funcId>.md`，表 A 缺對應必標 BP/@PENDING）+ `check-srs-bundle.py` **gate⑥**（covers-prd 懸空=FAIL、trace 缺漏=warn） | —（漂移仍會發生，但**會被登記/警示**；裁定仍須人） | 流程/SA | 06-10 |

## ✅ 已關（保留 30 天供交接，之後可清）
| ID | 裁定（06-11）| 來源已同步 |
|---|---|---|
| **TBD-006 / RP1** 🔴→✅ | **A＝保留 legacy 側效＋修 bug＋audit**（理由：風險在實作 bug 非設計；B 需 PRD v1.2 大改、00800 非關鍵路徑。配套：R11 isNotSame gate 移除、R13.1~13.3 修、R16 audit 側效摘要。不開 ADR）→ R13.1–13.3/13.6/13.7 定版、QA-007/008 解 pending | `00800 spec.md` v0.5 |
| **TBD-003 / RP2** ✅ | 保留 `LON_TYPE=03` 強制 ITEM1、業務原因後補（SA 動作項，不擋實作）→ R5 定版 | 同 |
| **TBD-004 / RP3** ✅ | 保留 `LON_TYPE=04` ITEM12 N→Y 刪 fee、原因後補 → R13.6 定版 | 同 |
| **TBD-007 / RP5** ✅ | ITEM13/14 維持現狀＝僅持久化、無側效 → R13.7 定版（RP6 取數後若有新事證另開）| 同 |
| **TBD-002 / RP7** ✅ | `Finshed`→`Finished` 修正定版 | 同 |

---
> 維護：新 `@PENDING`/escalation/OQ 開立 → 加一列；**關閉時**在來源檔裁定 + 本表移除/標 ✅ + 回填 `feature-inventory.md`。
> 用途：站會/交接看這張就知道「等誰、等什麼」；🔴 **兩項**（A-1 OQ、撥貸 domain group）是目前**唯一擋住主線**的決策。
