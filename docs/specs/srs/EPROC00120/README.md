# EPROC00120 — 企金財報評估 FI（Corporate Financial Evaluation FI）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員為**企金案**輸入/計算財報比率，存草稿或 **Finish 定版**（Finish 會寫入「本頁完成狀態」checkpoint）。本頁**只管企金（C0）**；與個金（I0）共用同一張財報表，**不得動到 I0 資料**（`R17`）。

## 怎麼運作（兩種模式）〔此段隨頁型態而異，非通用範本〕
- **查詢模式**：讀已存的歷史比率、**不重算**（`R6`）。
- **編輯模式**：由財報來源（資產負債 / 損益）**算出自動比率**，使用者另填**人工比率欄** → **存草稿**（可不完整）或 **Finish**（後端檢核必填 → 寫 checkpoint）（`R2`/`R4`/`R5`）。
  - ⚠️ 來源期別/日期變了 → 自動欄**重算**、該列人工欄**清空**，不得隱性沿用舊值（`R13`）。
- **父頁進度**：本頁存完後，前端**另呼**父頁/checkpoint endpoint 刷新整案進度——**本頁 DTO 不含父頁聚合**（`R1`/`R19`）。

## Endpoints（2 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 查詢（info） | 載入本頁資料（本頁顯示值 + 本頁完成狀態 + 比率列） | R1–R3, R6–R9, R19 |
| 存檔（save） | 存草稿 或 Finish，並更新本頁 checkpoint | R3–R9, R14–R20 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載入** `R1`：info 回本頁顯示值 + 本頁完成狀態 + 比率列。
2. **計算** `R2`：編輯模式由財報來源算 **5 個自動比率**（放款成長、成本收入比、資產報酬 ROA、股東權益報酬 ROE、放存比；確切欄名見 spec `R2`）。`R10` 來源筆數/序不符 → **嚴格擋**（不部分計算、不偷丟列）；`R11`/`R12`/`R20` 分母為 0 → N/A、rounding 照 legacy（**非**四捨五入）。
3. **填人工欄/精度** `R3`：人工比率欄**後端必驗**、不得 silent 截斷（確切欄名/欄長見 spec/openapi）。
4. **存草稿** `R4`/`R14`：整案本頁**全替換**、**單一交易**；草稿可不完整但需基本識別欄。
5. **Finish** `R5`：後端先檢核 **6 個人工填的風險/暴險類比率**（大額暴險、單一受益人暴險、關係人暴險、未避險外幣、流動性覆蓋、清償；確切欄名見 spec `R5`）+ 列識別 → 才寫 checkpoint；**checkpoint 必須剛好更新 1 列，否則 throw + 整筆 rollback**。（自動算的比率非使用者必填。）
6. **查詢模式** `R6`：`isQuery=true` 讀已存歷史、**不重算**。

**橫切（每階段都適用）**
- **錯誤/rollback** `R7`：業務錯走成功 envelope（HTTP 200）、授權失敗走 401；存/checkpoint 失敗整筆 rollback。
- **授權** `R8`（mutating）：**雙層**＝平台 API 授權 + 後端 service guard（驗案件可編輯/角色/直呼）；**只設 API 授權不夠**。
- **邊界** `R15`–`R19`：RC 舊案只可存草稿、後端擋 Finish｜本頁功能代碼｜只管 C0｜code-as-baseline（對位 legacy + 現碼）｜父頁進度走獨立 endpoint。

## NFR（精確見 spec `## NFR`）
交易（存+checkpoint 同生同滅、checkpoint 剛好 1 列）／安全（雙層授權、seed 單獨不足）／**稽核**（查/存留 audit trail）／**觀測**（log 不得印完整客戶財報數值）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主寫入＝財報評估 FI 表（C0/I0 共用、本頁只動 C0）；來源＝資產負債、損益 FI 表；另寫案件 checkpoint 表。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **checkpoint**：Finish 寫 checkpoint 必須**剛好 1 列**，0/多列 → throw + rollback。
- **RC 舊案**：`isFinish=true` 後端必從 trusted context 擋（client flag 不可信）。
- **雙層授權**：只設 API 授權不夠，service guard 必做。

**實作踩坑**
- **rounding**：用 legacy HALF_DOWN（現碼曾用四捨五入＝RD 要修）。
- **code-as-baseline**：無正式 refactor 物件 → 對位 legacy + 現碼，**別重新引入 legacy bug**（delta 見 `R10`–`R20`）。
- **人工欄後端必驗**：別只靠前端，後端要擋超長/必填。
- **分母為 0**：多處比率分母 0 → N/A，別除 0。

**維護註記**
- 殘留非阻擋 🟡：openapi Draft/Finished 兩 row schema 重複（可維護性）。
- DTO drift：兩個資本比率欄排除於契約，RD/DBA release 前 reconcile（`R9`）。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。
**本檔為其餘 8 包 digest 範本。固定段**（所有包都有、僅換業務名/Rn/路徑）＝這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結。**彈性段**（依頁型態改寫）＝①「怎麼運作」流程 ②Endpoints 數/副作用（如 calc 禁寫 DB、export、無 save 只狀態轉移） ③NFR 焦點/條數 ④規則複雜度。
**流程骨架範例**（別包改寫參考）：多步驟計算頁（如 00119）＝選項→查詢/複製→計算→存/匯出；狀態轉移頁（如 00110）＝載框→選 GI/FI→確認→清資料（無 Finish）；評分頁（如 00118）＝載選項→初始化→計算→存。</sub>
