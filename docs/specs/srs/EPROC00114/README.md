# EPROC00114 — 抵押品評估（Collateral Assessment）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員（AO / CR）為**企金案**做**抵押品評分**：選評分選項 → **後端依 seed 算總分、推風險等級與評分日期** → 存草稿或 **Finish 定版**（Finish 會寫「本頁完成狀態」checkpoint）。分數/風險等級/日期一律**後端權威**，前端送的不算數（`R4`）。本頁**只管企金 CS 案（C0）**。

## 怎麼運作（載入 → 評分 BE → 存）〔此段隨頁型態而異，非通用範本〕
- **載入**：依 `applicationNo` 查借款人/案件資料 + 既有評分列；依申請日與 CVer 載入評分選項清單（`R2`/`R3`）。
- **評分（後端做、save path 內）**：使用者只送**選項代碼**，後端在存檔交易內**先算 Rate**——讀 seed 算總分、查抵押風險等級、推評分日期，再寫入（`R4`）。
  - ⚠️ 沒有獨立的 calc endpoint——Rate **掛在 save 流程裡**；前端從 save 回應的 `rateResult` 或後續查詢顯示，**不得自己算**（`R4`）。
- **存草稿 / Finish**：草稿可不完整；Finish 後端必驗該角色必填欄 + 須有成功算出的分數/風險/日期，才寫 checkpoint（`R5`/`R6`/`R8`）。
- **角色權限**：AO 與 CR 各評各的一側；AO 不可動 CR 欄（含 review comment），後端擋（`R10`）。

## Endpoints（3 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 選項（sele） | 依申請日 + `langType` 載入評分選項清單 | R3 |
| 查詢（info） | 依 `applicationNo`/`isQuery` 載入本頁資料（不寫入） | R2, R3 |
| 存檔（save） | 跑 Rate 評分 → 存草稿 或 Finish，更新 CS checkpoint（單一交易） | R4–R10 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **頁籤/路由** `R1`：一般案與展延變更案路由到同一頁；canonical key/name = `EPROC00114` / `Collateral Assessment`。
2. **查詢** `R2`：載入借款人/案件/既有評分列；空 `applicationNo` 擋、互動查無資料回找不到（**非**空白成功頁）。
3. **選項** `R3`：依申請日 + CVer 載選項清單；CVer 缺省 `001`；CVer 001/002 顯示欄不同（確切欄見 spec `R3`）。
4. **Rate 評分** `R4`：save 流程內**後端**依 seed 算總分、查**抵押**風險等級（用對的風險變數，非個金那組）、推日期；保留小數精度；異常/查無 seed/溢位 = Rate fail。
5. **Finish 檢核** `R5`：草稿可不完整；Finish 必驗角色必填 + 須有成功 Rate 結果；未授權回授權錯。
6. **持久化** `R6`：`isFinish` ↔ legacy `check` 映射；upsert 抵押評分表（用正確的位址欄名）+ 更新完成狀態欄；單一交易。
7. **完成狀態 / checkpoint** `R7`/`R8`：AO/CR 各維護 score-card 完成狀態字元；CS 寫 checkpoint（Save=`Y`/Finish=`N`）；回傳父頁是否全 tab 完成。

**橫切（每階段都適用）**
- **錯誤/rollback** `R9`：查無資料 vs Rate 計算失敗**分開**（404 找不到 ≠ 500 計算錯）；存/Rate 失敗整筆 rollback、不覆蓋已存風險等級/日期。
- **授權** `R10`（mutating）：**雙層**＝平台 API 授權 + 後端 service guard（驗頁/角色 AO `001/002`、CR `102/103`、擋越權寫對側）；只設 API 授權不夠；AO 不得寫 CR comment。
- **邊界** `R8`/`R11`：CS-only（CU 欄是共用 schema/歷史欄、不建 CU 行為）；跨模組 reset 由 `EPROCS_0170/0270` 擁有；migration deltas 全關（見附錄）。

## NFR（精確見 spec `## NFR`）
授權（雙層、seed 單獨不足）／交易（評分表+完成狀態+checkpoint 同生同滅、Rate fail 不覆蓋已存值）／**精度**（分數對齊 `NUMBER(7,2)`、非數/溢位 fail-fast）／**稽核**（查/Rate/存/Finish 留 masked audit、不印完整借款人身分/評語）／**觀測**（交易帶 correlation id）／量過大走 over-count 錯。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主寫入＝抵押品評分表 + 借款摘要完成狀態欄 + CS checkpoint 表；讀取＝借款摘要、企金主借款人、評分參數/seed 表（seed 即評分項目/風險區間的 runtime 真值來源）。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **Rate 後端權威**：`riskLevel`/`actionDate`/分數**不收前端值**，後端 save path 內算/覆蓋（現碼曾收 client 值＝RD 要修，PENDING-010）。
- **風險變數別用錯**：抵押風險等級查 `COL_RISK_LV`，**不是**個金那組 `P_RISK_LV`（現碼用錯＝RD 要修）。
- **雙層授權**：只設 API 授權不夠，service guard 必做；AO 不可寫 CR comment（PENDING-009/009A）。

**實作踩坑**
- **精度**：分數用 BigDecimal/fail-fast 對齊 `NUMBER(7,2)`，別整數截斷、別 null→0 吞錯（PENDING-010）。
- **無獨立 calc endpoint**：別重建 phantom `epl-calc-*`；Rate 掛 save path、結果走 `rateResult`。
- **CS-only**：別因 schema 有 CU 欄就寫 CU；非 CS 直呼 save/finish 要擋、不得 mutate。
- **位址欄名**：用 `*_COLL_ADDR_*`，別用 stale `CR_ADDR_*`。
- **`isAllTabsCheck`**：save/finish 回應必含、後端交易後算（PENDING-008）。

**維護註記**
- migration deltas（PENDING-001..006）全關＝owner/DB 決策；PENDING-008/009/009A/010 = 規格已鎖、實作+測試為 RD code-stage DoD。
- 跨模組 reset（`EPROCS_0170/0270` 把本頁 checkpoint reset）由那些條件異動頁擁有，本頁只在查詢時讀結果。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。
**固定段**（所有包都有、僅換業務名/Rn/路徑）＝這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結。**彈性段**（依頁型態改寫）＝①「怎麼運作」流程（本頁＝評分頁：載入→評分 BE→存） ②Endpoints 數/副作用（3 支；無獨立 calc、Rate 掛 save path） ③NFR 焦點/條數 ④規則複雜度。</sub>
