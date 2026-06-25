# EPROC00117 — 財報評估 GI（Financial Evaluation GI）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員為**企金案**載入/計算 **GI 財報比率**並維護 **DSR/企業財報清單**，存草稿或 **Finished 定版**（Finished 會寫入「本頁完成狀態」checkpoint）。本頁**只管企金（business-only，C0）**；金額欄一律**固定 USD**（`R4`）。

## 怎麼運作（載入 → 計算 → 存）〔此段隨頁型態而異，非通用範本；照本頁 Rn〕
- **載入**：開頁同時呼選項 endpoint（如幣別清單）與 info endpoint，帶後端可辨識的 `applicationNo`/`isQuery`，回財報清單 + GI 比率（`R1`）。
- **計算/取值（依 `isQuery`）**：
  - **查詢模式（`isQuery=true`）**：讀**已存**的 GI 比率列、**不重算、不寫回**（`R2`）。
  - **編輯模式（`isQuery=false`）**：由 GI 財報來源（資產負債 / 損益 / 現金流）**算比率**並**寫回** GI 表，再回傳（`R2`/`R3`）。
- **存檔**：存草稿 或 Finished，**全替換** DSR/企業財報清單 + INFO_CORP DSR 金額群、更新 checkpoint，全包在**單一交易**（`R5`/`R6`）。

## Endpoints（3 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 選項（sele） | 載入頁面選項（如幣別清單） | R1 |
| 查詢（info） | 載入財報清單 + GI 比率（查詢讀存值；編輯算+寫回） | R1–R4, R7 |
| 存檔（save） | 存草稿 或 Finished，全替換清單並更新本頁 checkpoint | R4–R7 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載入** `R1`：選項 + info；缺 `applicationNo`/`isQuery` → 受控驗證錯；查/讀失敗走 `MSG_QUERY_FAIL`，**不得部分寫比率**。只開 `epl-*` 三支，legacy `getTotal`/`getRate`/`getExist` **不得**做相容別名。
2. **取值/計算** `R2`：`isQuery=true` 讀存值不重算不寫回；`isQuery=false` 由三張 GI 來源表算比率並寫回。⚠️ 算之前來源（資產負債/損益/現金流）筆數須相等、`DATA_SEQ` 唯一非空且集合一致、**以 `DATA_SEQ` 配對**（非 index）；不符 → 受控錯、不部分算/寫。`ratios` **永遠非 null 陣列**，無資料回 `[]`。
3. **比率/格式** `R3`：算流動/槓桿/週轉/利潤/報酬/現金流/成長等比率，回顯示字串（`%`/`x`/`N/A`/`-`），存值需符 `VARCHAR2(12)`。rounding 用 **legacy `ROUND_HALF_DOWN`**；成長率保留 legacy「當期年化 vs 前期原值」基準。⚠️ `AP_TURNOVER=0` → `DAYS_FOR_AP`/`CASH_CONVERSION_CYCLE`=`N/A`，**不得**覆寫存貨天數。
4. **DSR/清單** `R4`：攜借款人/合併 id/主借旗標/`DATA_SEQ` 等欄 + INFO_CORP DSR 金額群（`ebit`/`debtPayment`/… `dsr`），**固定 USD**（後端擋非 USD）。**最多 5 列**（FE `COMMON_MSG_LIMIT`、BE 擋第 6 列）；不可刪到剩 0（`COMMON_MSG_ONE_DATA`），save 不收空清單。
5. **存檔/Finished** `R5`：驗 `applicationNo`/`isFinish` → 載 summary → **刪舊+插新+更新 checkpoint**＝單一交易；空 `applicationNo` → `COMMON_MSG_ERROR_LON`、刪後失敗整筆 rollback、失敗回 `COMMON_MSG_SAVE_FAIL`。save **不收** client 傳的比率列（比率歸 info 算）。⚠️ 明細 `APPLICATION_NO` 一律取自 request/案件範圍、`DATA_SEQ` 唯一合法；竄改/重複/跨案 key → 變更前擋。RC 舊案（`isOld=true`）只可存草稿、後端擋直呼 Finished、不更新 parent done/checkpoint。
6. **checkpoint 路由** `R6`：由 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 分 CS/CU 寫對應 checkpoint 表；草稿寫 `"Y"`、Finished 寫 `"N"`（保留現行極性）。

**橫切（每階段都適用）**
- **驗證/授權/稽核** `R7`（mutating）：每筆 info/save 前後端做平台認證 + 頁授權 + 應用存取 + 欄位/數值/日期驗 + service-level 編輯權（含 R2 算+寫回路徑）；授權/稽核失敗走 `E401`/`E405`/`E498`/`AuthError`、**不寫**任何列/checkpoint。FE 驗只是 UX，金額/計算/checkpoint 完整性以後端為權威。
- **parity 邊界** `R8`：對位**老企金** `EPROC0_0117`/`EPROC0_0217`、**非** i0/ISU；business-only 約束沿用。各 parity 點以 slug 收斂（見 `R8`）；**不**關企金 old-cs/cu parity 補比（獨立軌）。

## NFR（精確見 spec `## NFR`）
交易（存：刪/插/checkpoint 同生同滅）／比率輸出 deterministic（rounding mode + 後綴有文件）／來源筆數+`DATA_SEQ` 對齊後端先驗／payload key 與 checkpoint 後端權威／不得把 i0/ISU 行為當企金 as-is 升級。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主寫入＝GI 財報評估表（比率寫回）+ DSR/企業財報清單表；來源＝資產負債/損益/現金流 GI 表；另寫案件 checkpoint（CS/CU）。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **金額欄精度**：DSR/財報金額存值須符 `VARCHAR2(12)`，**不得 silent 截斷**；比率值同。
- **INFO / INFO_CORP 雙表 reconcile**：`TB_FINANCIAL_EVALUATION_INFO`（24 欄、PK 含 `APPLICANT_NAME`）與 `TB_FINANCIAL_EVALUATION_INFO_CORP`（14 欄）**是兩張不同的活表、非別名**；現碼映 INFO、PRD/refactor 企金證據指 INFO_CORP——RD/DBA 須**刻意對齊**，別當同一張（`R5`/DB-D2）。
- **企金 parity 補比＝另軌**：老 cs/cu parity 補比掛在 register（獨立下游軌），**不**因本規格定版而關。

**實作踩坑**
- **rounding**：用 legacy `ROUND_HALF_DOWN`（現碼曾用 `HALF_UP`＝RD 要修）；成長率保留 legacy 年化基準（`R3`）。
- **查詢模式禁寫回**：`isQuery=true` 只讀存值，**不重算/不寫回**（現碼 source-first 寫回＝code-stage 修正項）（`R2`）。
- **AP 週轉為 0**：`DAYS_FOR_AP`/`CASH_CONVERSION_CYCLE`=`N/A`，別覆寫存貨天數（legacy bug）（`R3`）。
- **null 清單**：`ratios` 永不回 null，無資料回 `[]`（`R2`）。
- **明細 key 竄改**：`APPLICATION_NO` 取 request、`DATA_SEQ` 驗唯一，變更前擋跨案/重複（`R5`）。
- **RC 舊案**：`isFinish=true` 後端必從 trusted context 擋（client flag 不可信）（`R5`/`R6`）。

**維護註記**
- 本頁 `covers-prd` 用 `PRD §x.y` 形式（非 FR-id）——保留原樣。
- QA 2026-06-24 暫拔除：spec 內原 QA-0XX 引用全 dormant、不得當已驗證；追溯靠 `covers-prd`。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。固定段（這頁在幹嘛／Endpoints／規則速覽／NFR／資料表／雷區／連結）＋彈性段（「怎麼運作」流程＝本頁載入→計算→存）。</sub>
