# Build Task — `EPROZ00800` Revised Item：RI-MAT 修復包（RP1=A 解鎖項，step 2）

> 載具：Codex（後端為主，F6/F7 前端）。**規格權威＝SRS bundle** `docs/specs/srs/EPROZ00800/`（`spec.md` 的 `Rn`＋`openapi.yaml`＋`qa-cases.md`）；**as-is 證據＝** `docs/build-tasks/00800-verification-findings.md`（file:line）。
> **裁定依據**：RP1=A（保留側效＋修 bug＋audit）等裁定**內容一律見 `spec.md` §@PENDING（單一出處）**——本 prompt 只引 id、不複述理由。
> **前置**：step 1（D1–D5）已落地 `88328f9`——execute 已是 POST＋單一 `@Transactional`；本包全部修正都發生在**這個 transaction 邊界內**。
> **落地**：master-direct（沿 step1 慣例）；**BE 一個 commit（F1–F5）＋ FE 一個 commit（F6–F7）**，各 build 綠、**報 diff 等審後才推**。

## 目標
對既有 `RevisedItemServiceImpl`（及 FE `revised-item`）套 RP1=A 解鎖的 **7 項修正**：把 RI-MAT 側效引擎從「結構在、行為不對等」修到符合 R11/R13.1–13.3/R16/R5 定版行為。每項標 `Rn`＋findings＋QA。

## 範圍內（IN）— 逐項
| # | 修什麼 | as-is 證據（findings）| to-be（SRS）| QA |
|---|---|---|---|---|
| **F1 / R11** ⭐骨幹 | **移除 isNotSame gate**：側效觸發唯一依據＝BE 重查 DB 既有 `ITEM1~14` 與 request 正規化結果之二次比對；`isNotSame` 降為純前端提示輔助；查無既有 → 全視為 N | S1：側效仍被 `request.getIsNotSame()` gate（`RevisedItemServiceImpl:181-189,219-229,242-253`）；僅 ITEM2 特判 null | R11（含 PRD §5.4.1 六步驟）| QA-015 |
| **F2 / R13.1** | **還原傳空值修復**：ITEM2 Y→N 時由 `REF_APPLICATION_NO` 複製還原 guarantor＋還原 `IS_ANY_GUARANTOR`——修「取 `baseInfo.refApplicationNo/lonTypeCode` 傳空 → 還原失效」 | S2：`:316-345`、`FunctionServiceImpl:589-597` | R13.1（✅定版）| QA-007 |
| **F3 / R13.2** | **補「reference 無 guarantor」判斷**：ITEM2 N→Y 且 reference 無 guarantor → borrower `IS_ANY_GUARANTOR=Y` | S3：缺此判斷（`:346-353`）| R13.2（✅定版）| QA-024 |
| **F4 / R13.3** | **補 `IS_ANY_COLLATERAL_PROVIDER` 更新**（ITEM3 Y→N 清/還原 collateral 之後）| S4：未更新（`:357-413,436-446`）| R13.3（✅定版）| QA-008 |
| **F5 / R16** | **execute audit 側效異動摘要**（RP1=A 配套）：log/audit 記錄哪些 RI-MAT 分支觸發、各影響表/筆數；沿 R16 既有要求（requestId/applicationNo/userId/action/result/耗時、敏感遮罩）| —（新增）| R16 | RD 補實 case（見 qa-cases 覆蓋註記）|
| **F6 / R5（FE）** | **ITEM1 disabled 補強**：`LON_TYPE_CODE=03` 強制勾**且不可編輯**；`≠03` 強制不勾且不可編輯（**含「非 03 且 DB ITEM1=Y 仍可編輯」的洞**）| FE 段：會強制勾回但未 disabled（`revised-item.ts:68-73`）| R5（✅定版，RP2 已關）| QA-005 |
| **F7 / RP7（FE）** | UI 按鈕文字 **`Finshed`→`Finished`**；舊字串斷言（測試/locale 檔）隨改 | PRD TBD-002 | RP7（✅已關）| —（UI 文字）|
| **F8 / R14**（06-12 增，RP10 已關）| **checkpoint 欄位寫入對齊 DDL/R14 v0.8**：表＝`TB_CHECK_POINTS_{IS,IU,CS,CU}`；寫自欄 `EPROZ00800`＋§5.6 重處理新頁欄（IS：`EPROISU0110/0120/0130/0140/0150`；CS/CU/IU＝DDL 子集）；`pageMenuCondition` 值集合同步 | S7（重判 ⚠️）| R14（✅定版 v0.8）| QA-011/QA-016 |

## 範圍外（OUT，**不准碰**——全部受 `spec.md` §@PENDING 開著的待決控制）
- **R13.4/13.5**（ITEM1/4~11 detail 刪/還原；含 findings S6「ITEM10/11 else ITEM1 疑錯欄」）→ `RP4`（連動 RP6 取數）。**F1 移除 gate 後，R13.4/13.5 分支邏輯本身一行不改**——只允許它們改由 DB 比對觸發（gate 移除的自然結果），分支內容/欄位對應不動。
- ~~checkpoint key 值（S7）→ RP10~~ **RP10 ✅已關（06-12）→ key 修正＝F8 統一處理**；F5 audit 仍不得在 audit 實作中順手動 key（歸 F8）。
- **init-query method** → `RP9`。本包只動 execute 路徑。
- **execute DTO 形狀**（itemMap vs as-is 平鋪）→ `RP11`。**修 bug 不改 DTO 形狀**：F1–F4 以現形 DTO 實作；若落點被形狀牽動，引 RP11 標註、不先改。
- **R6/R7 判據來源**（`secureAttribute`/`canEditList` vs `isCU`/`isEdit`）→ `RP8`。F6 只修 R5 的 disabled 行為，不動判據來源。
- **R15 錯誤碼專屬 mapping**（S8）→ 另案（非 RP 控制，但不在本包；spec as-is→to-be 摘要未列入本輪解鎖）。
- R13.6/R13.7 **無程式變更**（as-is 已符）——R13.7 當回歸 guard：修完跑 QA-025 確認 ITEM13/14 仍零側效。

## 鐵則
1. **F1 是骨幹**：先把側效觸發判定改為 DB 二次比對，再驗 F2–F4（它們都在 gate 之後的路徑上）；完成後全檔搜 `getIsNotSame` 確認無殘留判斷用途（提示回傳除外）。
2. **嚴守 IN/OUT**：碰到 RP4/RP8–RP11 控制區**只讀不改**；diff 不得改變 R13.4/13.5 分支內容、checkpoint key、DTO 形狀。
3. Brownfield 鐵則照舊（`prd-to-srs` skill §Brownfield）：引 `file:line`、不臆測；異於 findings 的現碼狀況先回報再動。
4. 對齊 `openapi.yaml`（`isNotSame` description＝「僅前端提示輔助」、`ItemFlag` enum）；audit 不改契約。
5. 各 commit build 綠（BE `mvn clean package -Dmaven.test.skip=true`、FE `ng build`）；**報 diff 等審後才推**。

## 回報
- 每項 F1–F7 一句落點（檔/method）；**F1 附 `getIsNotSame` 全檔搜尋結果**；F5 附一筆 audit 記錄樣例。
- **明確聲明**：未動 R13.4/13.5 分支內容、未改 checkpoint key 值、未改 init-query method、未改 DTO 形狀、未動 R6/R7 判據來源。
- build 結果；可跑 QA：QA-015/QA-005 屬單元/靜態可驗；**QA-007/008/024/025 涉 DB 複製還原 → deferred-to-DB**（同 QA-012 模式，列 Phase V 待測）；QA-009/QA-023 為 `@PENDING`（RP4/RP8）→ 照 `docs/specs/qa-to-test.md` 產 `@Disabled` skeleton、不啟用。
- `git status --short`（應乾淨）。

> 過了：00800 的 RP1=A 解鎖項全數落地；剩 RP4/RP6/RP8/RP9/RP10/RP11（見 `spec.md` §@PENDING ↔ `pending-register.md`）。完成後本檔 `git mv` 進 `done/`、狀態回填 `feature-inventory.md` §④b。
