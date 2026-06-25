# EPROC00115 — 集團暴險（Borrower Group Exposure）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員為**企金案**維護「借款人集團」各筆授信額度/暴險明細列（額度別、幣別、放款上限類型、Outstanding、擔保品…），算出 USD/KHR 合計，存草稿或 **Finish 定版**（會寫「本頁完成狀態」checkpoint）。本頁**只管企金（C0）**；底層 `TB_GROUP_EXPOSURE` 是**報表/評分模組共用資料源**，欄義/排序不得擅改（`R9`/`R16`）。

## 怎麼運作（載入 → 查/算 → 存/Finish）〔此段隨頁型態而異，非通用範本〕
- **載入**：select endpoint 回 4 組下拉選項（額度別/放款上限類型/幣別/權狀類型）；info endpoint 以 `applicationNo` 查既存暴險列（依序回傳）（`R1`/`R2`）。
- **編輯/計算**：使用者增刪暴險列、填各欄；**前端**就地算 **USD/KHR 合計**（LCC + Outstanding），**沒有獨立計算 API**（`R5`）。
- **存草稿 / Finish**：同一支 save endpoint，靠 `isFinish` 分流——草稿驗格式、Finish 加列級必填；存檔=整案**全替換** `TB_GROUP_EXPOSURE` + 更新 checkpoint，**單一交易**（`R6`/`R7`）。
- **完成狀態**：依案件 CS/CU 分流寫對應 checkpoint 欄（`R8`/`R14`）；RC 舊案不另存（已併入 CS/CU）。

## Endpoints（3 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 選項（sele） | 回 4 組下拉選項 | R1 |
| 查詢（info） | 載入本頁既存暴險列（依序） | R2, R13 |
| 存檔（save） | 存草稿 或 Finish，全替換 + 更新 checkpoint | R3, R6, R7, R8, R14, R19, R20 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載入選項** `R1`：sele 回 4 組下拉；`langType` 空 → 驗證錯。
2. **查既存列** `R2`：info 依 `DATA_SEQ` 回所有暴險列；無列回空（API 不自造列）。`R13` 既存列若 `LOAN_LIMIT_TYPE` 空白 → **擋查詢**、逼補資料，不得隱性標完成。
3. **填列/計算** `R3`/`R4`/`R5`：`facility` 為頁級欄、存時寫進每列；前端可增刪列但**不得刪到最後一列**、列數上限綁 legacy `top.groupSize` 設定（`R12`）；前端就地算 **USD/KHR** LCC+Outstanding 合計（確切桶/欄見 spec `R5`）。
4. **必填分流** `R6`/`R10`：草稿驗格式；Finish 加列級必填——`loanLimitType != "2"` 時 Outstanding/到期日/擔保品等為必填。
5. **存檔** `R7`：整案**全替換**（delete→insert，`DATA_SEQ` 由 1 起照送出序）+ 更新 checkpoint、**單一交易**；delete 後任何失敗整筆 rollback；`APPLICATION_NO` 取自 request 不取自列內容。
6. **checkpoint** `R8`/`R14`：依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 分流寫 CS/CU 的 `EPROC00115` 欄；屬性缺/不支援 → `E126` 且不寫列；RC 0215 已併入 CS/CU、不重建 RC 表。

**橫切（每階段都適用）**
- **錯誤/envelope** `R9`：成功走 EPRO envelope（`code=0000`）、業務錯走正常 envelope、授權/session 失敗走 HTTP 401（`E405`/`E498`）；log 不得印完整敏感 payload。
- **授權** `R9`/`R20`（mutating）：**雙層**＝平台 `TB_API_AUTH` + 後端 service guard（存檔前驗案件可編輯/擁有權）；**只設 API 授權不夠**。
- **跨模組穩定** `R9`/`R16`：`TB_GROUP_EXPOSURE` 欄義/`DATA_SEQ` 排序/LCC/Outstanding/擔保品語意不得無跨模組決策而改；報表收 collateral 幣別應讀 `COLLATERAL_CUR`。
- **邊界/身分** `R15`–`R18`：RC 舊案模式不另存（上游 frame 層擋）｜本頁標籤 `Group/Exposure`｜頁身分 `EPROC00115`、route/menu 走 `TB_PAGE_MENU`。

## NFR（精確見 spec `## NFR`）
交易（delete+insert+checkpoint 同生同滅）／安全（雙層授權、seed 單獨不足）／觀測（log 不得印完整敏感 payload）／跨模組穩定（共用表欄義/排序不得擅改）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主寫入＝集團暴險表（報表/評分共用、本頁只動本案 `applicationNo` 的列）；選項來源＝共用欄位選項表；另寫案件 CS/CU checkpoint 表；分流依據＝貸款摘要表（`LON_ATTRIBUTE`/`SECURE_ATTRIBUTE`）。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **雙層授權**：只設 `TB_API_AUTH` 不夠，service guard 必做（存檔前驗案件可編輯/擁有權）——現碼第二層未證，RD 必補（`R20`）。
- **USD/KHR 限制**：合計**只收 USD/KHR**；非 USD/KHR 不得偷折進 KHR（legacy 會偷折＝要修），須擋或標不支援（`R5`/`R11`／REF-D2）。
- **全替換 + 單一交易**：delete 後 insert/checkpoint 任一失敗 → 整筆 rollback，別留半套資料（`R7`）。

**實作踩坑**
- **報表幣別修正**：collateral 幣別讀 `COLLATERAL_CUR`，別抄錯成 outstanding 幣別來源（CS0181/CU0181 疑似 bug＝跨模組要對齊；`R16`／REF-D3）。
- **LCC 桶**：LCC 合計用 `lccAmountCur` 分桶（現碼用 `outstandAmountCur`＝疑似 bug 要修；`R5`／REF-D1）。
- **blank loan-limit**：既存列 `LOAN_LIMIT_TYPE` 空白要**擋查詢**逼補，不得隱性標完成（`R13`）。
- **列上限/最後一列**：列數綁 legacy `top.groupSize`、別寫死；不得刪到最後一列（`R4`/`R12`）。
- **FE 數值精度**：對齊 BE/DB 15+2（現 FE clamp 12＝要修；`R21`）。

**維護註記**
- 殘留非阻擋 🟡（見 spec Metadata / pending-register）：`COMMON_MSG_LIMIT` UI-only disclaim、`legacyFunctionId` 後端分流取代註明、BR-001 blank→`COMMON_MSG_ERROR_LON` 綁 R2。
- conformance drift（SRS 決策已關、RD 補實作）：`facilitiesList` 缺 `@NotNull`（`R19`）、service-level 授權第二層（`R20`）、FE 12→15+2（`R21`）。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。</sub>
