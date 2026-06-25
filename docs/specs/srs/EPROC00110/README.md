# EPROC00110 — 企金徵信頁框（Corporate Credit Investigation Frame）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/SHA/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
企金徵信案的 **C0 父頁框／評分容器**：載入頁框後決定要顯示哪些子頁 tab、管它們的完成狀態（checkpoint），並提供 **GI/FI 產業別切換**——切換是**破壞性的**（會清掉財報/評估/企金評分卡資料）。本頁**只管頁框與 tab 編排**，子頁自己的業務規則不在本包。

## 怎麼運作（評分容器／狀態機型）〔此段隨頁型態而異，非通用範本〕
- **載框**：用 `applicationNo` + 來源別（一般件 / 展延變更件）載入頁框，回傳目前產業別、**該顯示的 tab 清單與順序**、tab→來源頁對照、各 tab 完成狀態（`R1`/`R5`）。
- **初始化**：summary 的評等別/產業別空白時，後端寫入預設值；啟動或切換時，**作用中的可見 tab 明確標為「待辦」**（極性見下方雷區）（`R2`/`R6`）。
- **選 GI / FI**：可編輯者才能動產業別控制；改值會觸發切換流程（`R4`）。
- **確認 switch（取 token）**：改產業別後，**先跳明確的刪除範圍警告**；使用者接受後才向 confirm endpoint 取**一次性短效 server token + 換代序號**（`R7`/`R18`）。使用者取消 → 不打後端、還原原值。
- **清資料（存檔）**：save 帶 token + 序號，後端**先驗 token/序號/權限**才動手；通過後**單一交易**內更新產業別、刪掉受影響的財報/評估/評分卡、重置 checkpoint（`R7`/`R8`）。**無 Finish 步驟**——這頁是容器，不是表單。
- **跨模組回寫**：子頁完成狀態回寫父頁 page menu 完成度（`R10`）。

## Endpoints（3 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 載框（info） | 回來源別 + 產業別 + 可見 tab 清單/順序 + tab→來源對照 + checkpoint | R1–R6, R9–R11 |
| 確認切換（confirm） | 使用者接受警告後，發一次性短效 token + 換代序號 | R7, R12, R18 |
| 存檔切換（save） | 驗 token/序號/權限 → 單交易清資料 + 重置 checkpoint | R7–R9, R11–R12 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載框** `R1`：info 回來源別、產業別、可見 tab（含順序）、tab→來源對照、checkpoint。
2. **預設值** `R2`：評等別/產業別空白 → 寫入預設（確切值見 spec `R2`）。
3. **選 CS/CU checkpoint 表** `R3`：依 summary 的屬性組合決定走哪張 checkpoint 表。
4. **顯示/守 GI/FI 控制** `R4`：顯示產業別控制；**不可編輯者不得切換**（後端權威）。
5. **組可見 tab / 對照** `R5`：依產業別、CS/CU、舊案旗標組 tab；**順序照 legacy**；`EPROC00114` **CS 限定**（CU 不得出現）；`visibleTabs` 管可見/序、`sourceTabMap` 管 tab→來源頁對照（一般件/展延件各一套）。
6. **checkpoint 狀態** `R6`：管子頁完成狀態與回呼。
7. **確認 + 取 token** `R7`/`R18`：改產業別 → 顯示刪除範圍警告 → 取一次性短效 token + 換代序號；取消則還原、不打後端。
8. **清資料交易** `R8`：通過驗證後**單一交易**更新產業別 + 刪受影響財報/評估/評分卡 + 重置 checkpoint。

**橫切（每階段都適用）**
- **來源別差異** `R9`：一般件 vs 展延/變更件用不同來源別名/checkpoint provenance；因實體表只有單一 PK、無 RC 鑑別欄，**用 `sourceFrame`/`sourceTabMap` 當執行期 provenance**（互斥），不靠額外欄位。
- **跨模組 page menu** `R10`：子頁完成度回寫父頁。
- **錯誤碼** `R11`：模組錯走 `ERROR_MODULE` + 模組訊息、超量走 `ERROR_MODULE` + 超量碼、一般錯走通用查詢失敗；0210 初始化例外走標準初始失敗（精確碼見 spec `R11`/`R15`）。
- **安全/稽核** `R12`：mutating 必**後端**驗可編輯/查詢/舊案；破壞性切換必須留 `EPROC00110_GI_FI_SWITCH` 稽核事件；**只設 API 授權 seed 不夠**。
- **邊界決策** `R13`–`R18`：不開個人評等別切換（0211/0213 另案）｜`applicationNo` 為必填請求欄｜0210 例外標準化｜title/GI-FI label 改 C0-owned i18n key｜破壞性切換 token 政策定版。

## NFR（精確見 spec `## NFR`）
交易（切換＝更新+刪資料+重置 checkpoint 同生同滅）／安全（後端權威權限 + 一次性短效 token + 換代序號、seed 單獨不足）／**稽核**（破壞性切換留事件、不含財報明細）／錯誤處理（模組錯/超量/通用/初始失敗碼分流）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
讀寫＝案件 summary（產業別/評等別/評分卡完成度）＋ CS/CU checkpoint 表（單一 PK、無 RC 鑑別欄）；切換時清除＝財報評估（GI/FI）、財報報表各表、企金評分卡。授權 seed＝API 授權表（單獨不足）。**注意**：checkpoint 表有一個實體欄屬於別頁（Loan Condition），**本頁契約不得輸出**（見 spec `## DB Reconcile / Delta`）。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **checkpoint 極性反直覺**：可見 tab 的 `Y`＝**待辦**、`N`＝**完成**；實體 DB 預設 `'N'` **不是**本頁啟動規則——啟動/切換時作用中可見頁要**明確設 `Y`**（`R6`）。
- **GI/FI 切換是破壞性**：會刪財報/評估/評分卡 + 重置 checkpoint，且**單一交易**全有或全無（`R8`）。
- **token 不是裝飾**：save 必帶 server 發的**一次性**短效 token + **換代序號**，後端在動刪除前驗到底（過期/重用/換代不符/綁定 context 不符都擋）；ABA 切回也不能重用舊 token（`R7`/`R18`）。
- **後端才是權限權威**：前端 confirm 不算授權；可編輯/查詢/舊案一律後端再驗（`R12`）。

**實作踩坑**
- **`EPROC00114` CS 限定**：CU 回應**不得**出現在 `visibleTabs`/`sourceTabMap`/`pageMap`（CU 表無此 checkpoint 欄）（`R5`）。
- **0210（展延/變更件）parity 是必做**：現碼只有 normalized 一般件常數、缺 0210 來源頁行為＝**failing condition、非可接受 gap**（`R9`）。
- **`visibleTabs` ≠ `pageMap`**：可見/順序靠 `visibleTabs`，`pageMap` 只管 checkpoint state；別讓 `pageMap` 當唯一可見性載體（`R5`）。
- **`EPROCSU0160` 別漏出**：實體有欄但屬 Loan Condition，本頁不得輸出（`## DB Reconcile / Delta`）。
- **0210 空 catch 別照抄**：legacy 的 `ErrorInputException` 空回傳是疑似 bug，要改回標準初始失敗碼（`R11`/`R15`）。

**維護註記**
- 不開個人評等別切換：0211/0213（normalized 00111/00113）**明確不在本包**，未來要做須另開 owner-approved bundle（`R13`）。
- i18n key 全改 C0-owned（title `R16`、GI/FI label `R17`），別依賴 I0-owned 舊 key。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。
**固定段**（所有包都有、僅換業務名/Rn/路徑）＝這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結。**彈性段**（依頁型態改寫）＝①「怎麼運作」流程（本頁＝評分容器/狀態機：載框→選 GI/FI→確認 switch（取 token）→清資料，**無 Finish**） ②Endpoints 數/副作用（3 支：info/confirm/save；save 破壞性清資料） ③NFR 焦點（交易/token 安全/稽核/錯誤分流） ④規則複雜度（18 條，含 6 條 TBD 決策）。</sub>
