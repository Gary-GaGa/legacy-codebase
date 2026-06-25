# EPROC00112 — CBC 銀行往來關係（CBC Banking Relationship）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員為**企金案**維護 CBC 報告與客戶聲明裡的**銀行往來關係**（借款人借款負債 BBL、借款人保證負債 BGL、保證人借款/保證負債 GBGL），按幣別算總額，存草稿或 **Finish 定版**（更新本頁完成狀態 checkpoint）。**一支規格承接舊 `EPROC0_0112`（一般）與 `EPROC0_0212`（展期/展變 RC）兩個 legacy 來源**，差異走 `legacyFunctionId` 模式分流（`R11`）。

## 怎麼運作（載入 → 輸入/計算 → 存）〔此段隨頁型態而異，非通用範本〕
- **載入**：info endpoint 回 BBL/BGL/GBGL 三區塊 + 既有 CBC 資料 + 既有總額；四組下拉代碼（幣別、loan status、product type、security type）由頁面取得（`R1`）。借款人/保證人由來源帶入、**不可手動新增人**。
- **輸入/計算**：每位借款人/保證人一張卡片，可維護主檔欄位 + 明細列（Add New / Delete，明細有筆數上限）；按明細幣別**即時算 USD/KHR 兩列總額**（`R5`）。⚠️ **只支援 USD/KHR**，第三幣別不可默默歸 KHR、不可靜默忽略（`R13`）。
- **存**：**Save 草稿**（可不完整）或 **Finish**（後端檢核必填）→ 後端**全量覆寫六張 CBC 表 + 更新 checkpoint**、單一交易（`R4`/`R6`/`R7`）。
- **查詢模式**：`isQuery=true` 唯讀，不可編輯/不可存。

## Endpoints（2 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 查詢（info） | 載入 BBL/BGL/GBGL 三區塊 + 既有資料 + 既有總額 | R1–R3, R5, R8 |
| 存檔（save） | Save 草稿 或 Finish，全量覆寫 CBC 表並更新本頁 checkpoint | R4, R6–R9 |

> calculation（依幣別算總額）為 PRD 草案的第三支，本契約收斂為兩支頁端點 + 共用計算行為（`R11`）。

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載入** `R1`：info 回三區塊資料；四組下拉代碼由頁面取得（非塞 info DTO 也可）。
2. **BBL/BGL** `R2`：主借款人 + 共同借款人，來源同一家族但 BBL/BGL **各存各表、不互蓋**。
3. **GBGL** `R3`：個人/公司保證人（依保證人類型旗標分流，見 spec `R3`）併一區；**排除已刪保證人**（依刪除旗標過濾，見 spec `R12`）。
4. **主檔/明細維護** `R4`：每卡主檔 + 明細列；Save 草稿可不完整、Finish 必填。
5. **幣別加總** `R5`：BBL/BGL/GBGL 算 USD/KHR 的 Total Credit / Total Outstanding；**KHR 為 0 位小數顯示契約**（不得出現 `.00`）。`R13` 只准 USD/KHR。
6. **存** `R6`/`R7`：**全量覆寫六張 CBC 表 + 更新 `EPROC00112` checkpoint**、單一交易、失敗整筆 rollback；回 `isAllTabsCheck` 給父框刷新整案完成狀態。

**橫切（每階段都適用）**
- **錯誤/訊息** `R8`：承載 PRD 錯誤/訊息碼（含 list-size 業務訊息）；BE 於 mutate 前擋無效 payload（含空 `applicationNo`）。
- **授權** `R9`（API + page button 雙閘）：info/save 都驗平台授權三元組（API 識別 + 本頁功能代碼 + 角色，確切欄見 spec `R9`）；save 另需 **service-level guard** 擋 query-only/非編輯/舊案 Finish——**401 未認證、403 已認證但無權**；**只設平台授權表 seed 或只靠前端隱藏按鈕都不夠**。
- **邊界/決策** `R10`–`R17`：來源差異須留決策（`R10`）｜canonical funcId/路由命名（`R11`）｜checkpoint 極性 Save=Y/Finish=N（`R14`）｜`infoList` null 視為空陣列（`R15`）｜CS/CU checkpoint 分流（`R16`）｜0212 舊案不可 Finish（`R17`）。

## NFR（精確見 spec `## NFR`）
交易（覆寫 + checkpoint 同生同滅）／安全（雙閘授權、seed 與前端可見性單獨不足）／精度（KHR 總額 0 位小數顯示契約）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
六張 CBC 表（BBL/BGL/GBGL 主檔 + 明細）全量覆寫；另寫案件 checkpoint 表（CS / CU 兩張，依案件屬性分流）；來源＝公司戶主/共同借款人、個人/公司保證人表 + 案件 summary 屬性。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **0112 vs 0212 一支承接**：差異走 `legacyFunctionId` 模式，**勿拆成兩個 funcId/bundle**（`R11`）。
- **舊案不可 Finish**：`legacyFunctionId=EPROC0_0212` 且放款類型碼 ∈ 91/92/93/94（確切欄見 spec `R17`），後端必擋 `isFinish=true`（不可信前端）（`R17`）。
- **雙閘授權**：API 授權三元組 + service guard 都要，缺一即漏（`R9`/SEC-001/SEC-002）。
- **全量覆寫單一交易**：六張表 delete→insert + checkpoint，任一失敗整筆 rollback（`R6`）。

**實作踩坑**
- **checkpoint 極性反直覺**：Save 寫 `Y`、Finish 寫 `N`（`isFinish=false→Y`、`true→N`），別寫反（`R14`）。
- **第三幣別**：只准 USD/KHR，**不可默默歸 KHR、不可靜默忽略**——FE 限選項或 BE 擋 payload（`R13`）。
- **已刪保證人過濾**：0112 舊 SQL 漏了，新版兩模式都要依刪除旗標排除（現碼 SQL7/SQL8 尚缺＝RD 要補；確切欄見 spec `R12`）（`R3`/`R12`）。
- **`infoList` null**：後端正規化為空陣列再覆寫；空陣列對草稿/`CBC available=N` 合法（`R15`）。
- **KHR 精度**：總額顯示 0 位小數，別吐 `.00`（明細實體欄仍保 2 位小數的 DB 欄型，見 schema）（`R5`）。

**維護註記**
- DB 欄長/PK 多處 db-diff markdown 與 schema reverify 不一致（名稱欄、逾期付款欄、備註欄的欄長，及保證負債明細表 PK 順序；確切欄/表見 schema）——schema/openapi 以 **reverify 為準**，見 spec `## DB Reconcile / Delta`。
- QA 2026-06-24 暫拔除：spec 內 QA-0XX 引用為 dormant、不得視為已驗證。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。固定段＝這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結；彈性段（依頁型態改寫）＝「怎麼運作」流程（本頁＝載入→輸入/計算→存）。</sub>
