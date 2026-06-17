# SRS — EPROZ00800 Revised Item（SA 規格層）

| 欄位 | 內容 |
|---|---|
| Status | **規格定版**: Approved (subset)——RP1/2/3/5/7（06-11）、RP10/6/4（06-12）、RP9（06-16 init-query=GET）已關；**仍 blocked**: RP8、RP11、**BP1–4**（⚠️ BP1＝顯示 gating＝Bible 災難情境「不該顯示卻顯示」**未承載**→ Approved 僅限已承載 subset、安全洞待 PM/SA）。**／實作完成**: **僅 D1–D5**（`88328f9`：transaction／execute→POST／maxlength 3000／pageMenuCondition／Y-N 驗證）；其餘（R11 移 gate、R13.1-5 還原修、R5 disabled、R14 欄對齊、R16 audit、get-body #3 GET）＝**已解鎖、未實作**。正式 SA 簽核待 owner。詳 §@PENDING（單一出處）＋文末 as-is→to-be 摘要 |
| Owner | SA（待指派）|
| Slug | `EPROZ00800`（＝funcId）|
| 版本 | v0.9（06-12：**RP6/RP4 關閉輪**——ITEM1~14 名稱由舊庫 `TB_COMMON_FIELD_OPTIONS`+`TB_MULTI_LANG` 取數定版（findings `00800-pending-recon-findings.md` E1）；RP4 裁「設計非缺陷」（ITEM1=Renew Loan Tenor≠ITEM10=ATC_Tenor）→ R13.4/13.5 定版、QA-009 拆 a/b、RP2 原因補文；rimat 加 F9。前版 v0.8（06-12：**RP10 關閉輪**——checkpoint 實表/key 由新 schema DDL 機械枚舉定版（`OVSLXLON02`，64 欄）；R14 表名修正＋key 形式定版＋as-is 由 🔴 重判 ⚠️（S7 係以 `_0260` 為 to-be 之誤）；schema.sql/openapi/QA-011 同步。前版 v0.7（06-12：**EARS 複審輪**——補 v0.6 欠的「採納修正後再審一輪」：R14 修 v0.6 引入的時序歧義（拆兩拍：checkpoint 寫入在**交易內**→R10、`pageMenuCondition` 於成功完成時回傳）、R5 句型改 state-driven 與 R6/R7 一致；其餘 v0.6 句型經 diff 複審確認零漂移。前版 v0.6＝EARS 句型整訂（skill 鐵則 1b 回溯適用，owner 指示）；v0.5＝TBD 裁定輪——各 RP 裁定內容單一出處＝§@PENDING 表；QA 異動：QA-007/008 un-pend、QA-009 改掛 RP4、新增 QA-024/025；B2/B3/§5.6 契約待決正規化為 RP9–RP11）|
| 最後更新 | 2026-06-12 |
| 上游 PRD | `CDC-EPRO-0001 v1.1` |
| as-is 來源 | `docs/build-tasks/00800-verification-findings.md` |

> **上游 PRD**：`CDC-EPRO-0001 v1.1`（PM Review Draft）。**TBD-001~007 已於 2026-06-11 裁定**（裁定內容見 §@PENDING 表；快照不直接編 → 權威 PRD 回填待下次外部改版/快照）。本 SRS 由 `prd-to-srs` skill 產出。
> **as-is 來源**：現有新系統碼之驗證結果 `docs/build-tasks/00800-verification-findings.md`（產品碼在開發機）。
> **每條規則一個 `Rn`，標 `covers-prd:` 上游追溯**；QA 用 `covers: Rn`（見 `qa-cases.md`）。
> ⚠️ **TBD 一律寫 `@PENDING` + owner，不自行裁定**；**不把 legacy 行為當已核准需求**（PRD §13）。`file:line` 待 RD 對產品碼核對。

## Scope / Non-Goals
- **本期**：Revised Item 初始查詢、選項顯示、必填檢核、儲存、關聯資料清除/還原、checkpoint/page-menu 更新。
- **非本期**：ITEM1~14 code table 維護、非本頁的其他頁籤重構、報表內容重製；**`EPROISU0173` 顯示**（下游 consumer 頁、唯讀彙整 AO 主流程資料，非本頁職責，見 `BP4-PENDING`）。
- **未承載（上游缺口）**：**顯示 gating**——Bible BR-014「EPROZ00800 僅適用展期/展變案件」未進 PRD，本 SRS 無顯示條件規則（見 `BP1-PENDING`）。

## Assumptions / Dependencies / Constraints
- **Assumptions**：`TB_LON_SUMMARY_INFO` 有 `LON_TYPE_CODE`/`REF_APPLICATION_NO`/`LON_ATTRIBUTE`/`SECURE_ATTRIBUTE`；`REVISED_ITEM` code table 已建。
- **Dependencies**：guarantor/collateral/loan-condition/fee 各模組的資料表與 reference-copy 邏輯；checkpoint DAO（IS/IU/CS/CU）。
- **Constraints**：Oracle；RPC `epl-*` 慣例；既有 `RevisedItemController`/`RevisedItemServiceImpl`（brownfield，見 as-is）。

## Endpoints（真實 `epl-*`；PRD §6 的 `/api/...` REST 為理想化）
| 動作 | endpoint（to-be） | method（to-be） | as-is | DTO |
|---|---|---|---|---|
| prompt（開頁/屬性）| 由 routing/attr 取得（RD 定）| — | — | attrMap、lonTypeCode |
| init-query | `epl-case-query-reviseditem` | **GET**（RP9 ✅ 06-16：Follow PRD §6.1）| ⚠️ as-is FE POST/BE GET 不一致 → 改 **GET query**（BE `@RequestBody`→`@ModelAttribute`、FE GET query，同 00600 樣板；get-body sweep #3）| `QueryRevisedItemRequest/Response` |
| execute（儲存）| `epl-case-insert-reviseditem` | **POST**（會刪改資料）| 🔴 **BE GET（bug）**、FE POST | `InsertRevisedItemRequest/Response` |

> ✅ **init-query method＝GET**（RP9 已關 06-16：Follow PRD §6.1；詳 §@PENDING）。
> ⚠️ **request body 結構**＝`@PENDING RP11`（詳 §@PENDING）。
> ⚠️ **prompt 不在 openapi 範圍**：prompt 走 routing/attr 機制、**非 `epl-*` RPC**，故 `openapi.yaml` 不列；其錯誤碼 `MSG_INITIAL_FAIL`（R1/R15）由該機制承載，**落點待 RD 在 routing 層定**——QA-018 僅驗 FE 可觀察行為（停止載入+錯誤訊息）。

## 業務規則（Rn）
> 狀態：✅ as-is 符合 ／ ⚠️ as-is 出入 ／ 🔴 as-is 缺/風險 ／ 標 to-be＝PRD 要求。

### R1 — 開頁取屬性　`covers-prd: REQ-001`　**強制點：FE+BE**
**當**使用者開啟本頁（prompt）時，系統應取得 `attrMap`（`applicationNo`、`isEdit`、CU 判定）＋`lonTypeCode`；**若**初始化失敗，系統應回 `MSG_INITIAL_FAIL`（prompt 非 `epl-*` RPC、不在 openapi 範圍，落點待 RD 於 routing 層定——見 Endpoints 註）。

### R2 — init-query 選項與既有資料　`covers-prd: REQ-002`　**強制點：FE+BE**
**當** init-query 被呼叫時，系統應查 `REVISED_ITEM` code table（`getCommonFieldOptions("EPRO",locale,"REVISED_ITEM")` ← `TB_COMMON_FIELD_OPTIONS`）→ 回 `revisedType`+`revisedTypeSize`；查 `TB_LON_SUMMARY_INFO` → 回 `LON_TYPE_CODE`；查 `TB_REVISED_ITEM` → 回 `ITEM1~14`+`REASON_MEMO`（無則 blank）。**as-is ✅**（left join、null→""）。

### R3 — 至少勾 1 項　`covers-prd: REQ-003`　**強制點：FE**
**若**使用者未勾任一項即送出，系統（FE）應阻擋送出。**as-is ✅**。

### R4 — REASON_MEMO 必填 / maxlength **3000** / trim　`covers-prd: REQ-003`　**強制點：FE+BE**
系統應要求 `REASON_MEMO` 必填、上限 **3000** 字元並 trim；BE 亦應驗證。**as-is ⚠️**：maxlength=**4000**、未 trim、BE DTO 未驗 → RD 修。

### R5 — ITEM1 受 `LON_TYPE_CODE=03` 強制　`covers-prd: REQ-003`（**RP2 已裁 06-11：保留強制、業務原因後補**——降為動作項，不擋定版）　**強制點：FE**
**在** `LON_TYPE_CODE=03` 期間，系統應強制 ITEM1 勾選且**不可編輯**；**在** `≠03` 期間，系統應強制不勾且不可編輯。**as-is ⚠️**：會強制勾回但欄位未 disabled；非 03 且 DB ITEM1=Y 仍可編輯 → RD 修。

### R6 — ITEM3 受 `isCU` 強制　`covers-prd: REQ-003`（as-is 判據等價性 → `@PENDING RP8`）　**強制點：FE**
**在** `isCU=true` 期間，系統應強制 ITEM3 不勾且不可編輯。**as-is ⚠️**：用 `secureAttribute==='U'` 而非 `attrMap.isCU`——兩判據是否全情境等價待 RD 確認（RP8）；QA-006 僅驗 to-be 行為表象。

### R7 — `isEdit=false` 全唯讀 + 隱藏完成鈕　`covers-prd: REQ-003`（as-is 判據等效性 → `@PENDING RP8`）　**強制點：FE**
**在** `isEdit=false` 期間，系統應使全頁唯讀並隱藏完成鈕。**as-is ⚠️**：靠 auth `canEditList`/`isShowList` 達成、非直接綁 `isEdit`——是否全情境等效待 RD 確認（RP8）；QA-019 僅驗 to-be 行為表象。

### R8 — 變更提示　`covers-prd: §2.3 / §3.1-6`　**強制點：FE**
**當** checkbox 與既有資料不同且使用者送出時，系統應先提示「移除 Revised Item 會清除相關修改」。**as-is ✅**。

### R9 — blank/N/Y 正規化　`covers-prd: §5.3.2`　**強制點：FE+BE**
系統應於 init-query 允許 blank；**當** execute 時，request / DB **只允許 Y/N**——FE 應於送出前將 blank→N；**若** BE 收到殘留 blank，系統不得存入（**結果確定**；採拒絕或正規化之**手段**待 RD，見 QA-014 註）。**as-is**：FE ✅；**BE 🔴**（`InsertRevisedItemRequest` 無 `@Pattern`，可存非 Y/N）→ RD 修。

### R10 — execute = POST + **單一 transaction**　`covers-prd: REQ-004 / §9`　**強制點：BE**
execute 應為 **POST**；**當** execute 執行時，系統應將整個儲存（刪/複製/insert/checkpoint）置於**單一 `@Transactional`**；**若**任一步失敗，系統應整批 rollback。**as-is 🔴🔴**：BE GET；**無外層 `@Transactional`** → 多表刪/還原可**半更新＝資料遺失風險**（最高優先）。

### R11 — execute 後端二次比對為準　`covers-prd: §5.4.1`　**強制點：BE**
**當** execute 時，系統應重查 DB 既有 `ITEM1~14`、與 request 正規化結果比對，並以此為觸發側效之**唯一依據**；`isNotSame` 僅前端提示輔助、**不得作判斷依據**；**若**查無既有資料，系統應將全部視為 N。**as-is ⚠️**：有重查，但側效仍被 `request.getIsNotSame()` gate；僅 ITEM2 特判 null → RD 修。

### R12 — 刪+insert TB_REVISED_ITEM　`covers-prd: §5.4-6/7`　**強制點：BE**
**當** execute 時，系統應先刪除目前 `APPLICATION_NO` 的 `TB_REVISED_ITEM`，再 insert `ITEM1~14`+`REASON_MEMO`+`UPD_DATE`。**as-is ✅**。

### R13 — 關聯資料清除/還原矩陣 RI-MAT　`covers-prd: REQ-005 / §5.5`　**✅ RP1 已裁（06-11）：A＝保留側效＋修 bug＋audit**　**強制點：BE**
> **RP1=A 已裁（06-11，理由/配套詳 §@PENDING＝單一出處）**：legacy 側效保留為已核准 to-be（使用者確認流程不改；R8 變更提示維持）；下列 as-is bug＝修復項而非設計取捨；execute 須留側效異動摘要 audit（→R16）。**R13.1–13.7 全數定版**（13.4/13.5 於 06-12 隨 RP4/RP6 關閉）。ITEM1~14 名稱＝RP6 定版（findings E1 名稱表）。
- **R13.1 RI-MAT-001 ✅定版**：**當** ITEM2 由 Y→N 時，系統應刪 `GUARANTOR_INFO`/`_CORP`、由 `REF_APPLICATION_NO` 複製還原，並還原 `IS_ANY_GUARANTOR`。as-is ⚠️：取 `baseInfo.refApplicationNo/lonTypeCode` 傳**空值**（還原失效）→ RD 修。
- **R13.2 RI-MAT-002 ✅定版**：**當** ITEM2 由 N→Y 且 reference 無 guarantor 時，系統應將 borrower `IS_ANY_GUARANTOR` 設為 Y。as-is ⚠️：缺「reference 無 guarantor」判斷 → RD 修。
- **R13.3 RI-MAT-003 ✅定版**：**當** ITEM3 由 Y→N 時，系統應刪 collateral/valuation/site-visit/title/provider/owner、由 reference 複製，並更新 `IS_ANY_COLLATERAL_PROVIDER`。as-is ⚠️：未更新 `IS_ANY_COLLATERAL_PROVIDER` → RD 修。
- **R13.4 RI-MAT-004 ✅定版（06-12，RP4 已關）**：**當** ITEM1/4~11 特定組合變更時，系統應刪 `LOAN_CONDITION_DETAIL`+`REVISED_ITEM_DETAIL`，並將相關 page menu 標重處理。as-is ⚠️：page menu 標 0110~0160（對齊 R14 v0.8 新欄定版）→ RD 修（rimat F9）。
- **R13.5 RI-MAT-005 ✅定版（06-12，RP4 已關＝設計非缺陷）**：**當** ITEM1/4~11 由 Y→N 時，系統應從原始 detail 還原欄位（§5.5.2 矩陣；欄對應判據＝RP6 名稱表——ITEM1=Renew Loan Tenor／ITEM10=ATC_Tenor／ITEM11=ATC_Interest Rate，各自對欄）並更新 `REVISED_ITEM_DETAIL`。as-is ⚠️：ITEM10/11 else ITEM1 之欄對應依名稱表逐欄重審（findings S6）、受 isNotSame gate（gate 移除已隨 RP1=A 定版，見 R11）→ RD 修（rimat F1+F9）。
- **R13.6 RI-MAT-006 ✅定版**：**當** `LON_TYPE=04` 且 ITEM12 由 N→Y 時，系統應刪 `LOAN_CONDITION_FEE`（**RP3 已裁 06-11：保留、業務原因後補**——降為動作項）。**as-is ✅**。
- **R13.7 RI-MAT-007 ✅定版**：**當** ITEM13/14 變更時，系統應**僅持久化勾選狀態、不觸發下游側效**（**RP5 已裁 06-11：維持現狀＝定版**；若 RP6 取數後發現 13/14 有下游語意，另開新待決 RPn）。**as-is ✅**（行為即現狀）。

### R14 — Checkpoint / Page Menu 更新　`covers-prd: REQ-006 / §5.6`（**RP10 ✅已關 06-12——key 清單 DDL 機械枚舉定版，詳 §@PENDING**）　**強制點：FE+BE**
**當** execute 時，系統應於**交易內**（→R10）依 `IS/IU/CS/CU` 寫對 checkpoint 表 **`TB_CHECK_POINTS_IS/_IU/_CS/_CU`**（06-12 DDL 實證；v0.7 前誤載舊表名 `TB_CHECK_POINT_RC/_IU/_CORP/_CU`——新 schema `OVSLXLON02` 不存在）：① 標**自身欄 `EPROZ00800`**＝完成 ② 將 §5.6 重處理頁之**新頁對應欄**標重處理——IS：`EPROISU0110/0120/0130/0140/0150`（＝舊 0210/0220/0230/0290/0250 合併後新頁）；CS/CU/IU＝各表實有欄之對應子集（**欄集合以 DDL 為準**：IS 18 欄／CS 17／CU 15／IU 13；無擔無 collateral 欄）。key＝**checkpoint 表欄位名（新 funcId 形）**，非 PRD §5.6 字面 `_0260`（舊 funcId 已併頁）。**當** execute 成功完成時，系統應於回應回傳 `pageMenuCondition`（§5.6 重處理頁清單，新頁 funcId 形、與 ② 同集合）。**as-is ⚠️（v0.8 重判）**：`pageMenuCondition` 回傳已修（D4，`88328f9`）；key 寫入——原 S7 判 🔴 係以 `_0260` 為 to-be，DDL 證實 key 本為新 funcId 形，as-is 標 `EPROZ00800`/`0160`/`0110~0150` **大致相容**，殘差（重處理欄集合精確對齊＋CU/IU 子集）→ RD 修（`00800-rimat-fix` F8）。

### R15 — 錯誤處理　`covers-prd: REQ-007 / §6.4 / §8`　**強制點：FE+BE**
**若** prompt 初始化失敗，系統應回 `MSG_INITIAL_FAIL`；**若** init/execute 查詢失敗或查無資料，應回 `COMMON_MSG_ERROR_LON`/`MSG_DATA_NOT_FOUND`；**若** execute rollback，應回 `COMMON_MSG_SAVE_FAIL`；**當**儲存成功時，應回 `COMMON_MSG_SAVE_SUCCESS`。**as-is ⚠️**：無 RevisedItem 專屬 mapping。

### R16 — 非功能　`covers-prd: §9`　**強制點：BE**
系統應以單一 transaction 執行儲存（→R10）；init-query 應 ≤3s、execute 應 ≤5s（大量複製另測）；log 應含 requestId/applicationNo/userId/action/result/耗時並做敏感遮罩；**當** execute 時，系統應留 audit——**RP1=A 配套：audit 須含側效異動摘要**（哪些 RI-MAT 分支觸發、各影響表/筆數），補償「無使用者確認步驟」的可追溯性；系統應維持 IS/IU/CS/CU 四態 checkpoint。

## 🚩 @PENDING（PRD TBD → 規則；**裁定輪 2026-06-11**，✅＝已關、⏸＝仍開）
> **本表＝每個待決的單一出處**（裁定內容只寫這裡；他處只標狀態 token + 指回本表）。
> **入表判準**：擋契約/規則定版的待決一律入表（RPn 列，含非 PRD TBD 者）；純 RD 實作細節（如 prompt 錯誤碼落點）留 prose、不入表。本表 ↔ `pending-register.md` 由 gateⓅ 機械同步。

| id | 狀態 | 待決（PRD TBD）| 裁定（06-11）/ 後續 | 影響規則 | owner |
|---|---|---|---|---|---|
| **RP1** | ✅已關 | TBD-006：保留 legacy 清除/還原副作用，或改使用者確認流程 | **A＝保留側效＋修 bug＋audit**。理由：(1) 資料完整性風險在實作 bug 非設計、自動維持關聯一致本身合理；(2) B 須 R13/R11/FE 大改＋PRD v1.2 重新快照，00800 非關鍵路徑、報酬率低。配套：R11 isNotSame gate 移除、R13.1~13.3 bug 修、R16 audit 側效摘要。不開 ADR（無架構變更；僅 B 需）| R13（13.4/5 另受 RP4）| ~~PM/SA/RD~~ |
| RP2 | ✅已關 | TBD-003：`LON_TYPE=03` 強制 ITEM1 之業務原因 | **保留強制**；~~原因後補~~ **原因已補（06-12，隨 RP6 取數）**：ITEM1＝`Renew Loan Tenor`，展期案（03）強制勾＝定義性必然 | R5 | ~~SA（補文）~~ |
| RP3 | ✅已關 | TBD-004：`LON_TYPE=04` ITEM12 N→Y 刪 fee 之業務原因 | **保留、原因後補**（同 RP2 模式）| R13.6 | SA/RD（補文）|
| RP4 | ✅已關 | TBD-005：ITEM1 與 ITEM10 皆 TENOR（legacy 設計 or 缺陷）| **06-12 隨 RP6 取數關閉：設計、非缺陷**——ITEM1=`Renew Loan Tenor`（展期動作本身）≠ ITEM10=`Approved T&C_Tenor`（核准條件期限欄），「皆 TENOR」係誤讀 → R13.4/13.5 定版、QA-009 拆 a/b；S6 疑錯欄重審基準＝名稱表＋設計非缺陷推理（findings `00800-pending-recon-findings.md` **E1 名稱表＋E2 推理**）、實作＝rimat F9 | R13.4/5 | ~~RD/SA~~ |
| RP5 | ✅已關 | TBD-007：ITEM13/14 是否有下游資料影響 | **維持現狀＝定版**（僅持久化、無側效；RP6 取數後若有新事證另開）| R13.7 | — |
| RP6 | ✅已關 | TBD-001：ITEM1~14 正式業務名稱 | **06-12 取數關閉**：舊庫 `TB_COMMON_FIELD_OPTIONS`(SYS_CODE=EPRO,MSG_CODE=REVISED_ITEM) JOIN `TB_MULTI_LANG`(en_US) → **14 名稱定版**（全文＝findings `00800-pending-recon-findings.md` E1；ITEM1=Renew Loan Tenor、ITEM10=ATC_Tenor…）；名稱補 PRD §5/7/10＝回填動作項（快照待下次改版）；**順帶裁 RP4 ✅** | 畫面顯示、RP4 判據 | ~~SA（取數）~~ |
| RP7 | ✅已關 | TBD-002：`Finshed` → `Finished` | **修正為 `Finished`**（UI 文字定版；若有舊字串斷言隨實作同步）| UI 文字 | RD（實作）|
| RP8 | ⏸開 | （as-is findings，非 PRD TBD）R6 `secureAttribute==='U'` vs `attrMap.isCU`、R7 `canEditList/isShowList` vs `isEdit`——as-is 判據與 to-be 語意是否全情境等價/等效 | （非本輪範圍）→ **RD 派工卡 `build-tasks/00800-rp8-rp11-rd-closeout.md`**（含 to-be/as-is 判據對照）| R6/R7 | RD |
| RP9 | ✅已關 | （契約待決，非 PRD TBD；原 B3）init-query method：PRD §6.1=GET vs 全站 RPC-POST vs as-is FE POST/BE GET | **06-16 RD/架構裁：Follow PRD §6.1 ＝ GET**（method recon `epl-method-convention-findings.md`：全站 280/282 POST 但依 PRD 走 RESTful GET，少數例外、同 00600）→ R2/Endpoints/openapi 定版 GET；as-is FE POST/BE GET → 改 GET query（get-body #3，BE `@RequestBody`→`@ModelAttribute`、FE GET query）| R2 契約 method | ~~RD/架構~~ |
| RP10 | ✅已關 | （契約待決，非 PRD TBD；原「§5.6 checkpoint-keys」）`EPRO{IS/IU/CS/CU}_0260` 確切 key 清單 | **06-12 DDL 機械枚舉關閉**：checkpoint 實表＝`TB_CHECK_POINTS_{IS,IU,CS,CU}`（v0.7 前誤載舊表名）；key＝表欄位（新 funcId 形，含自欄 `EPROZ00800`）；欄集＝DDL 為準（IS 18／CS 17／CU 15／IU 13）；PRD §5.6 之 `_0260`＝舊 funcId、已併入新頁欄。殘差實作＝rimat F8 | R14 | ~~RD/PM~~ |
| RP11 | ⏸開 | （契約待決，非 PRD TBD；原 B2）execute request body 形狀：to-be `itemMap.item1..14` vs as-is 平鋪欄位 | RD 確認 DTO 形狀（改 DTO 或 openapi 對齊）→ **派工卡 `build-tasks/00800-rp8-rp11-rd-closeout.md`**（含 checkPointMap 權威界定 S-3）| R10/R12 契約 | RD |

### @PENDING（Bible→PRD seam；PRD 未承載的上游業務邊界）
> 來源 Bible `../../bible/bible-eproposal.md`；PRD `CDC-EPRO-0001` 由 legacy code 反推、未帶下列**旅程級**邊界，故未進 PRD REQ/TBD、亦未進本 SRS。**本 SRS 標 pending、不自行裁定**。單一視圖見 [`pending-register.md`](../../../pending-register.md) §Bible→PRD seam——該表另有 **BP-5**（共用 vs 條件式頁籤用詞消歧，PRD 層）與 **BP-7**（Bible↔PRD 無機械 gate，流程層），非 SRS 承載點、故不列於下表。
| id | 待決（Bible 有、PRD/SRS 落空）| 影響 | owner |
|---|---|---|---|
| **BP1-PENDING** | 案件類型 gating：EPROZ00800 **僅展期/展變顯示**（Bible BR-014 / 決策準則 / 災難情境「不該顯示卻顯示」/ SC-002）；本 SRS 無顯示條件規則 | 顯示條件（R1 開頁）| PM/SA |
| **BP2-PENDING** | 案件類型(新/展期/展變) vs `LON_TYPE_CODE`(03/04) 兩 type 軸關係未定義（Bible SC-001）| R5 語意基礎 | SA |
| **BP3-PENDING** | 展期 vs 展變「不同案件類型、目前共用驗證」（BR-015/16、SC-005）是否該分流 | 驗證/回歸範圍 | SA |
| **BP4-PENDING** | 下游頁映射：影響 `EPROISU0150`、顯示於 `EPROISU0173`（BR-017、SC-003/004）；§5.6 re-process 清單(0210~0290)未含、0173 未 disclaim（已補 Non-Goals）| 下游命名級追溯 | SA/RD |

## Trade-offs（架構取捨）
- **RI-MAT 側效：保留 legacy（A）vs 改使用者確認流程（B）**——已裁 06-11＝A（理由/配套詳 §@PENDING RP1）。本區只留取捨紀錄：**已知弱點留檔**＝使用者無確認步驟即被清資料；若日後內控提出要求，屆時走 B＋ADR。走 A 不開 ADR（無架構變更）。
- **side-effect 判定來源**：以「DB 二次比對」（R11）為準 vs 信前端 `isNotSame`——SRS 選前者（正確性 > 省一次查詢）；隨 RP1=A 一併定版。

## Traceability Matrix（PRD REQ → Rn → QA）
| PRD REQ | Rn | QA covers |
|---|---|---|
| REQ-001 | R1 | QA-018 |
| REQ-002 | R2 | QA-001, QA-002 |
| REQ-003 | R3,R4,R5,R6,R9 | QA-003,004,005,006,014,017（+QA-023 @PENDING RP8）|
| REQ-003 | R7,R8 | QA-019, QA-020（+QA-023 @PENDING RP8）|
| REQ-004 | R10,R11,R12 | QA-012,013,015,021 |
| REQ-005 | R13.1,R13.2,R13.3（✅定版，RP1=A）| QA-007,QA-024,QA-008 |
| REQ-005 | R13.4,R13.5（✅定版 06-12，RP4 已關）| QA-009a,QA-009b |
| REQ-005 | R13.6 fee（✅定版；原因後補 RP3已關）| QA-010 |
| REQ-005 | R13.7 ITEM13/14（✅定版，RP5已關）| QA-025 |
| REQ-006 | R14 | QA-011,016 |
| REQ-007 | R15 | QA-012（rollback）；成功/not-found path 尚無實 case → QA-022（RD 補，未撰寫）|
| §9 NFR | R16 | QA-012（transaction）；perf/log/audit（RD 補）|

## 硬界線
- ~~不得自行裁定 ITEM 業務名稱~~ → RP6 已關（06-12 取數定版，findings E1）；~~不得把 legacy 側效當已核准需求~~ → RP1 已關（詳 §@PENDING）：R13.1–13.3/13.6/13.7 之 legacy 側效＝已核准 to-be；R13.4/13.5 在 RP4 關閉前仍不定版。
- execute 必須單一 transaction（R10）——已隨 D1–D5 修復（`88328f9`）。
- as-is 的 `file:line` 證據見 `00800-verification-findings.md`；實作以該頁現碼 + 本 SRS to-be 為準。

## as-is → to-be 摘要（給 RD）
- **已修（D1–D5，`88328f9`）**：R10 transaction、execute→POST、R9 BE Y/N 驗證、R14 回 pageMenuCondition、R4 maxlength 3000。
- **已解鎖（可實作）**：R11 移除 isNotSame gate；R13.1 還原傳空值修復；R13.2 補「reference 無 guarantor」判斷；R13.3 補 `IS_ANY_COLLATERAL_PROVIDER` 更新；R5 補 disabled（含非 03 且 DB=Y 不可編）；R16 execute audit 側效異動摘要；UI `Finshed`→`Finished`（RP7）；**R14 checkpoint 欄位寫入對齊 DDL（RP10 → rimat F8）**；**R13.4/13.5 矩陣修正（RP4/RP6 已關 06-12 → rimat F9，欄對應判據＝名稱表）**。
- **已解鎖（可實作）＋06-16**：init-query method＝**GET**（RP9 關，Follow PRD §6.1）→ FE/BE 改 GET query（同 00600，get-body #3）。
- **仍待**：execute DTO 形狀（RP11）、R6/R7 判據等價性（RP8）。
