# EPROZ00100 — 待辦清單儀表板（To Do List / Work-list Dashboard）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
各角色登入後的**待辦清單入口頁**：依角色撈出自己經手的案件清單，從這裡開案件進下一頁，並可（依角色）刪除案件、結案、下載 proposal。本頁**以讀型查詢為主**；異動只有刪除/結案/redistribution 三類。

## 怎麼運作（載入 → 查詢清單）〔此段為讀型清單頁，非編輯/Finish 型〕
1. **初始化**：進頁先清掉上次的「目前案件」session、回傳角色旗標；若是 CA/CR 角色，會順帶觸發案件重分派（redistribution，**有寫入副作用**）（`R1`）。
2. **撈清單**：
   - 一般角色 → 撈「自己經手中」的待辦案件（排除已刪除/結案/重分派中等狀態）（`R2`）。
   - CAD/TLOD 角色 → 走**條件搜尋**（申請號/文件號/借款人名/決策日期區間，含代理人案件）（`R3`）。
3. **開案件**：點選後依角色 + 案件狀態決定**導去哪一頁**（重構頁家族路由）（`R4`）。
4. **動作（依角色）**：刪除（`R5`）、結案（`R6`）、下載 proposal（`R7`）；開案件前另呼 session bridge 設定「目前案件」（`R8`）。
- ⚠️ **langType / 多語顯示**：清單同一案件不同語別（如 USD/KHR 金額加總、借款人顯示名）必須**筆數一致、不重複不漏**——這是本頁讀型的重點之一（`R2`）。

## Endpoints（8 支；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 初始化（init） | 清 session + 回角色旗標 + 觸發 CA/CR 重分派（POST，有副作用） | R1 |
| 清單查詢（list） | 一般清單 / CAD 條件搜尋（同一支用查詢模式區分） | R2, R3, R4 |
| 刪除（delete） | 寫刪除原因 + 歷程，案件轉「已刪除」 | R5 |
| 結案（close） | 寫結案原因 + 歷程，案件轉「已結案」 | R6 |
| 下載 proposal（download） | 一次性 token 換 PDF（CS/CU/IS/IU 分流） | R7 |
| session bridge | 設定/清除「目前案件」context（過渡用） | R8 |
| 刪除原因清單（sele） | 回刪除原因代碼表 | R5 |
| 結案原因清單（sele） | 回結案原因代碼表 | R6 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **初始化** `R1`：清「目前案件」session、回角色旗標；CA/CR 觸發重分派（**改資料 + 寫歷程 + 單交易 rollback**，故為 POST 非 GET）。
2. **一般清單** `R2`：依目前使用者撈、排除特定進度狀態、sentinel 申請日轉空白、加註關係人旗標、加總 USD/KHR 金額。
3. **CAD/TLOD 搜尋** `R3`：含代理人案件、限定貸款類別、日期區間 `dd/MM/yyyy`；不完整/反序/超過約六個月區間 → **後端擋**。
4. **導頁** `R4`：依角色 + 狀態導向重構頁家族路由；**legacy 頁 ID 只當追溯標籤、非驗收路由**。
5. **下載** `R7`：POST 拿**一次性短效 token**、GET 換 PDF；重用/過期/未知 token 一律擋；**不得回可重複使用的本機路徑**；type 由後端對案件屬性驗、不信前端。

**橫切（每階段都適用）**
- **錯誤/rollback** `R9`／各 Rn：刪除/結案/重分派為 **all-or-nothing**（原因 + 歷程 + 案件狀態同生同滅）；業務授權失敗與平台授權失敗碼不同（見 spec `Rn` error-code contract）。
- **授權** `R9`（mutating）：後端按角色 allow-list 擋（**藏按鈕不算授權**）；角色不在某 API 的 allow-list ＝授權失敗（即使該 API 有授權列）。
- **邊界** `R5`/`R6`/`R8`：刪除限 AO 部分角色、結案限 CAD/TLOD；原因走**陣列**輸入（分號串接是 DB 內部細節、非 API 形狀）；session bridge 為**過渡橋接**，路由不再依賴 server session 後退場。

## NFR（精確見 spec `## NFR`）
安全（後端授權、藏按鈕不足、seed 已驗）／稽核（異動案件須寫歷程）／交易（刪除/結案/重分派 all-or-nothing）／隱私（log 不印完整原因/借款人名/可重用下載路徑）／效能（查詢須帶條件、禁全表撈）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
案件主檔（清單/搜尋/重分派/刪除/結案皆讀寫）；案件歷程表（異動須同交易寫入）；刪除/結案原因表（存分號串接代碼 + 其他原因）；關係人、放款條件明細、代理人等查詢/enrich 表；角色定義、流程狀態碼、API 授權等 seed/config 表。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **init 是 POST 不是 GET**：進頁會觸發 CA/CR 重分派（改資料 + 寫歷程），必須單交易 + 失敗 rollback。
- **授權後端必擋**：藏按鈕不算；角色不在該 API allow-list ＝失敗，即使授權列存在；角色 `403` 全頁排除。
- **異動 all-or-nothing**：刪除/結案/重分派的原因 + 歷程 + 案件狀態三寫必須同交易，partial write ＝regression。

**實作踩坑**
- **原因走陣列**：API 收原因陣列；分號串接是 DB persistence 細節，別當 API 輸入形狀；`D99`/`C99` 需 otherReason（上限 100）。
- **下載一次性 token**：別回可重複使用的本機檔路徑；token 重用/過期/未知一律擋；type 由後端對案件屬性驗。
- **legacy 頁 ID ≠ 路由**：導頁回重構頁家族路由；legacy ID 只當追溯標籤。
- **日期區間後端驗**：`dd/MM/yyyy`、不完整對/反序/超過約六個月 → 後端擋（別只靠前端）。
- **session bridge 為過渡**：路由不再讀 server session 後就退場，別當長期狀態來源。

**維護註記**
- 重構 delete/close artifact 用的是 `reasonCode`/`caseProgress` + 佔位路徑 + 欄位驗證碼，本 SRS 以 PRD/legacy 的陣列契約為準（delta 見 spec `REF-D3`）；最終錯誤 envelope 待 RD 對映。
- legacy 歷程表的「代理人」欄為 legacy 證據、非 to-be 欄位，別加進 schema；代理案件改記實際經手人（見 spec `R5`/`R6`、DB-D2）。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（兩半轉換同批）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。本頁為讀型查詢清單頁（載入→查詢清單），flow 不照 00120 的 edit→Finish 型。</sub>
