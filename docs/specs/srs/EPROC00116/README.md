# EPROC00116 — 企金財報表 GI（Corporate Financial Statement GI）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員為**企金案**輸入三大財報表（資產負債 / 損益 / 現金流量），系統**算出衍生欄**，存草稿或 **Finish 定版**，並可**匯出 PDF / Excel** 報表（Finish 會寫入「本頁完成狀態」checkpoint）。本頁**只管企金（C0）GI**；報表模板與 i0 共用、但**對外只開 c0 `epl-*` 端點**（`R8`）。

## 怎麼運作（載入→計算→存/Finish→匯出）〔此段隨頁型態而異，非通用範本〕
- **載入**：select 回幣別/單位/年度選項；info 讀本案 summary + 三表 + `haveData`（`R1`）。`haveData=Y` 必須**三表（含現金流量）全到**，缺任一（含只缺現金流量）→ `N` 且**藏匿列印/匯出**。
- **計算**（read-only）：後端由輸入算出 Balance/Income/Cashflow 的**衍生欄**（總計、差額、毛利、稅前損益、期末餘額…）（`R4`/`R5`/`R6`）。⚠️ 計算端點**不得寫 checkpoint / 任何表**。
- **存草稿 / Finish**：同一支 save，delete-and-rebuild 整案三表 + 寫 checkpoint，**單一交易**（`R7`）。Finish 須先計算成功且**平衡**（差額為 0、現金流量期末餘額＝資產負債現金約當），後端 hardening 必擋直送的不平衡 payload。
- **匯出**：PDF / Excel 只能從**已存完整資料**產生、**不靠未存 UI 狀態**；缺任一表 → 受控匯出失敗錯誤碼（見 spec `R8`）（`R8`）。
- **重算閘**：金額改動或參考案複製 → 標記需重算、**藏列印/PDF**、擋 Finish 直到重算成功（`R11`）。

## Endpoints（7 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 選項（sele） | 回幣別 / 幣別單位 / 年度型態選項 | R1, R10 |
| 查詢（info） | 載本案 summary + 三表 + `haveData` | R1, R3, R8, R10 |
| 參考查詢（quer） | 查可複製的參考案三表（不得動本案） | R2, R10, R11 |
| 計算（calc） | 算衍生欄 + 驗證訊息（**read-only、禁寫表/checkpoint**） | R4–R7, R10, R11 |
| 存檔（save） | 存草稿 或 Finish，整案全替換 + 更新 checkpoint（單一交易） | R3–R7, R9, R10 |
| 匯出 PDF（ppdf） | 從已存完整資料產 PDF blob/path | R8, R10 |
| 匯出 Excel（pxls） | 從已存完整資料產 Excel binary | R8, R10 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載入** `R1`：select 回選項；info 回三表 + `haveData`（**三表全到才 Y**，缺現金流量也算缺）。
2. **參考複製** `R2`：依現行 repository/案件日期資格（案件進度碼 + 合約型態）+ 三表完整才回；不符 → 受控匯出/複製失敗錯誤碼（見 spec `R2`）、**不寫本案/checkpoint**。
3. **主檔 + 5 段重點** `R3`：主檔欄 + 5 段 highlight（API 各上限 6000 字、落地拆兩個分欄各 3000）；raw legacy 重點文字進長文字保存欄（CLOB）當 provenance（確切欄名見 spec/schema）。**KHR 幣別金額無小數**、USD 保留小數（BR-016）。
4. **計算三表** `R4`/`R5`/`R6`：後端算衍生欄（確切公式/欄名見 spec）。**衍生欄 BE 算、不信 client 送**；保留 DB 實體含拼字錯誤的欄名（見 schema），對外用 canonical 名（BE 負責 mapping）。
5. **存/Finish** `R7`：delete-and-rebuild + checkpoint，單一交易；Finish 需 **≥1 年、≤5 年**提交列、三表陣列**非空且等長、無 null**；calc **不得**寫 checkpoint；Finish 須**平衡**才可寫。
6. **匯出** `R8`：PDF/Excel 只從已存完整資料產；缺任一表 → 下載錯；對外不得露 i0 路由。

**橫切（每階段都適用）**
- **錯誤/envelope** `R10`：業務錯走 HTTP 200 envelope、授權失敗走 401；特定平衡驗證錯誤碼只從驗證分支回；錯誤碼/別名見 spec `R10`。
- **授權** `R10`（雙層）：平台授權表 seed + **後端 service case/page guard**（讀/編權限、存前先驗）；**只設 seed 不夠**。Excel 匯出端點 seed 角色比照 c0 PDF 匯出端點。
- **下游/邊界** `R9`：保留 GI 下游 schema / 列序 / 來源序 / checkpoint routing；FIX 不重建。
- **重算閘** `R11`：改金額/複製參考案 → 標記需重算、藏列印/PDF、擋 Finish。

## NFR（精確見 spec `## NFR`）
交易（三表 + checkpoint 同生同滅、post-delete 失敗整筆 rollback、save 不可自動重試）／安全（雙層授權、seed 單獨不足、衍生欄不信 client）／**觀測**（log 不得印完整財報 payload / 個資）／**匯出完整性**（只讀已存完整資料、不靠未存 UI）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主檔＝財報主表（含 5 段拆欄 + 重點長文字保存欄）；三明細＝Balance / Income / Cashflow GI（複合 PK＝案件編號 + 來源序，見 schema）；另寫案件 checkpoint 表（CS / CU 依屬性 routing）；授權＝平台授權表（Excel 匯出 seed 待補）。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **derived 欄防 client 送**：衍生欄一律 BE 重算/驗，**不可**信任 client payload 帶來的值。
- **KHR 無小數**：KHR 幣別金額欄前端顯示/輸入 0 位小數，USD 保留小數（BR-016）；不改 DB 數值精度。
- **calc 禁寫表**：計算端點是 read-only，**不得**動 checkpoint / 任何財報表（現碼曾誤寫＝RD 要修）。
- **Finish 平衡 hardening**：直送不平衡 payload 必擋（差額≠0 或現金流量期末≠現金約當），擋在任何 mutation 之前。
- **haveData 含現金流量**：缺現金流量也要回 `haveData=N` 並藏匿出（現碼漏算現金流量＝RD 要修）。

**實作踩坑**
- **雙層授權**：只設平台授權表 seed 不夠，service case/page guard 必做（存前先驗）；Excel 匯出端點的 seed 待補（角色比照 c0 PDF 匯出端點）。
- **save-list 驗證**：三表陣列必非空、等長、無 null、1–5 列，且驗在 mutation 之前。
- **delete-and-rebuild**：少送的年度會被刪——這是預期行為，別誤判資料遺失。
- **DB typo 欄名**：實體含拼字錯誤的欄名保留於落地（如收入日期/減損損失/股東貸款/應付關係人等欄，見 schema），對外 canonical 名靠 BE mapping。

**維護註記**
- **報表模板共用**：PDF/Excel 沿用 i0/EPROI00116 模板資產（核定共用、本期不 rename）；對外 API/輸出 ownership 仍是 c0 EPROC00116（`R8`）。
- 所有 `PENDING-EPROC00116-*` 已關（見 spec 附錄 Closed Decision Register）；多項實作/測試為 code-stage DoD。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。固定段＝這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結；彈性段（本頁＝財報表 GI 匯出型）＝「怎麼運作」含載入→計算→存/Finish→匯出 PDF/Excel 流程、7 支端點（含 calc read-only 禁寫、ppdf/pxls 匯出）、NFR 含匯出完整性、規則複雜度 R1–R12。</sub>
