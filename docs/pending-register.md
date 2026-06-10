# 待決登記表（Pending Register）

> **單一視圖**：把散落在各 SRS `@PENDING`、escalation、A-1 OQ、架構待議的**開著的決策**聚一處——「**誰欠我們裁定、卡什麼、開了多久**」。
> 來源仍各自為準（改在來源檔、這裡同步）。**今＝2026-06-10**。狀態：🔴 擋主線 ／ 🟡 擋單頁/子集 ／ ⚪ 非阻擋/暫緩。

## 🔴 擋主線（卡住才能往下走）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| **TBD-006 / RP1** | 保留 legacy 清除/還原側效，或改使用者確認流程 | `00800` R13 整個 RI-MAT 引擎（R13.1–13.7）定版 | PM/SA/RD | 06-08 | `specs/srs/EPROZ00800/spec.md §@PENDING` |
| **A-1 OQ×5** | 匯率源 ID（OVSLXLON01 vs 02）、精度、錯誤碼、catch 回 null?、`EXCHANGR_RATE` 欄名 | 撥貸 authorize 端到端（換匯→T24→定案）；**撥貸上線關鍵路徑** | PM/SA/T24/DBA | 06-05 | `build-tasks/a1-funcGetExchangeRate-spec.md` |
| **撥貸 domain group** | `T24_COMPANY` 值源、檢核嚴格度、`KHR`(演進勿改回)、欄寬、async、M6 完工日 DTO 缺源 | 撥貸 0921/0922/T24 行為對等 | 撥貸 domain/T24/DBA | 06-05 | `disbursement-domain-escalations.md` |

## 🟡 擋單頁 / 子集（不擋主線，擋該頁定版）
| ID | 待決 | 卡住什麼 | owner | 開立 | 來源 |
|---|---|---|---|---|---|
| **§5.6 / openapi checkpoint-keys** | `EPRO{IS/IU/CS/CU}_0260` 確切 key 清單 | `00800` R14 checkpoint key 重映射（S7） | RD/PM | 06-09 | `specs/srs/EPROZ00800/openapi.yaml` |
| **init-query method** | GET（PRD §6.1）vs 全站 RPC-POST | `00800` init-query 契約 method | RD/架構 | 06-09 | `00800 spec.md Endpoints @PENDING(method)` |
| **TBD-003 / RP2** | `LON_TYPE=03` 強制 ITEM1 之業務原因 | `00800` R5 定版 | SA | 06-08 | 00800 §@PENDING |
| **TBD-004 / RP3** | `LON_TYPE=04` ITEM12 N→Y 刪 fee 業務原因 | `00800` R13.6 | SA/RD | 06-08 | 同 |
| **TBD-005 / RP4** | ITEM1 與 ITEM10 皆 TENOR（設計 or 缺陷） | `00800` R13.4/5 | RD/SA | 06-08 | 同 |
| **TBD-007 / RP5** | ITEM13/14 是否有下游資料影響 | `00800` R13.7 | SA/RD | 06-08 | 同 |
| **TBD-001 / RP6** | ITEM1~14 正式業務名稱（DB code table） | `00800` 畫面顯示 | SA | 06-08 | 同 |
| **TBD-002 / RP7** | `Finshed`→`Finished` | `00800` UI 文字 | PM/UX/RD | 06-08 | 同 |
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

---
> 維護：新 `@PENDING`/escalation/OQ 開立 → 加一列；**關閉時**在來源檔裁定 + 本表移除/標 ✅ + 回填 `feature-inventory.md`。
> 用途：站會/交接看這張就知道「等誰、等什麼」；🔴 三項是目前**唯一擋住主線**的決策。
