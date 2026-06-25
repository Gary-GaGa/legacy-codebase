# EPROC00118 — 企金評分卡（Corporate Scorecard）｜開發速覽

> 給 RD 快速 orient（「這頁在幹嘛、怎麼運作、要小心什麼」）。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔**不複製**欄名/錯誤碼/欄長/表名等精確值，只白話摘要 + 用 `Rn` 指回 spec。

## 這頁在幹嘛（一句）
授信人員（AO / CR 兩種角色）為**企金案**載入評分卡選項、計算風險評分（risk level），存草稿或 **Finished 定版**（會更新「本頁完成狀態」checkpoint 與案件 summary）。本頁**只管企金 C0 評分卡**；續約/變更（legacy RC `EPROC0_0218`）併入本頁、共用同一 `EPROC00118` checkpoint 欄位（`R7`）。

## 怎麼運作（依執行序）〔此段隨頁型態而異，非通用範本〕
本頁是**評分頁**（載選項→初始化→計算評分→存；分階段、可能無單一 Finish 按鈕）：
- **載選項**：select option list（17 組）由獨立 endpoint 提供（`R2`）。
- **初始化**：info 回主借款人名、本頁完成狀態（CS/CU 分支）、AO/CR 兩套評分卡 map、comment（`R1`）。
- **計算評分**：依參數表（依申請日取版本）算每項 score → total → **risk level + scoreDatetime**；calc **禁寫 DB**（`R3`）。
  - ⚠️ Default（逾期 90+ 天）：該角色直接設 `Default` / score `-1`，AO Finished+Default 還會連帶設 CR（`R4`）。
- **存（Save/Finished）**：`isFinish=false`=存草稿、`true`=定版；單一交易寫評分卡 + summary + checkpoint，任一失敗整筆 rollback（`R6`/`R7`）。

## Endpoints（4 支，POST RPC；確切名/DTO 見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 選項（sele-list） | 載入 17 組 select option list | R2 |
| 查詢（info） | 載入主借款人、本頁完成狀態、AO/CR 評分卡 map、comment | R1, R2, R5 |
| 計算（calc） | 依輸入與參數算 risk level + scoreDatetime（**禁寫 DB**） | R3, R8 |
| 存檔（save） | Save/Finished，寫評分卡 + summary + checkpoint | R4, R6, R7 |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **載選項/初始化** `R1`/`R2`：info 回主借款人名 + 本頁完成狀態 + AO/CR 兩套評分卡 map；sele-list 回選項。逾期/12 月內交易兩欄**連動互鎖**（確切碼值見 spec `R2`）。
2. **計算評分** `R3`/`R8`：依參數表（依申請日取**有效版本**）算每項 score → total → risk level + scoreDatetime。`scoreDatetime` 用 **UTC+8（Asia/Taipei）顯式時鐘**，非 JVM 預設時區。參數分數欄是字串，**非數字 = fail-fast 報錯**、不可偷當 0。calc **禁寫 DB**。
3. **Default 處理** `R4`：逾期 90+ 天 → 該角色 `Default` / score `-1`；AO Finished+Default 連帶設 CR；Finished **後端嚴驗**必填/Rate-before-Finished/CR comment。
4. **角色控制** `R5`（mutating）：AO 維護 AO 側、CR 維護 CR 側 + comment；**side-scoped 授權**（client 傳的非本側 map 不可信）；**雙層**＝四個平台授權表 seed + service guard 擋非 AO/CR。
5. **存檔/交易** `R6`/`R7`：評分卡完成度欄兩字元語意（本卡 + 另一卡）；單一交易寫評分卡 + summary + checkpoint，任一失敗 rollback；CU 案要更新 CU checkpoint 表（非只清 CS）。

**橫切（每階段都適用）**
- **數值防呆** `R8`：欄位精度/長度 BE 必擋、**不得 silent 截斷/四捨五入**；流動比率欄是 ×100/÷100 例外（UI 限整數%）。
- **授權** `R5`（mutating）：只設 API 授權不夠，service guard 必做、且 side-scoped。

## NFR（精確見 spec `## NFR`）
安全（雙層授權、side-scoped、seed 單獨不足）／資料一致（存 = 評分卡 + summary + checkpoint 同生同滅）／隱私（log 不得印完整評分卡內容或員工姓名）／效能（吃平台 AJAX timeout，無頁級 p95）。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
主寫入＝企金評分卡表（PK=案號）；連動＝案件 summary（評分卡完成度欄、兩字元）＋ 案件 checkpoint（CS / CU 分支）；讀取＝評分參數表（依申請日取版本）、主借款人表。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- **分數解析 fail-fast**：參數分數欄是字串型（見 schema），非數字 seed **必須報錯**（查詢失敗錯誤碼，見 spec），絕不可 silent 當 0。
- **時間 UTC+8**：`scoreDatetime` 用顯式 Asia/Taipei 時鐘，**別吃 JVM/container 預設時區**。
- **雙層授權 + side-scoped**：只設平台授權表 seed 不夠；service guard 必做，且 AO 只能寫 AO 側、CR 只能寫 CR 側（client 傳的非本側 map 不可信）。

**實作踩坑**
- **數值防呆**：精度/長度 BE 必擋、不得 silent 截斷或四捨五入；流動比率欄是 ×100/÷100 例外（UI 限整數%）。
- **calc 禁寫 DB**：計算 endpoint 不得改寫評分卡/summary/checkpoint。
- **Default 連帶效果**：AO Finished + AO Default 會連帶設 CR（`Default`/`-1`/AO 評分日），別漏。
- **參數版本**：取生效起日 ≤ 申請日的最新一版，生效迄日只是 seed metadata、**非 runtime filter**（確切欄名見 schema）。
- **死碼別重引**：legacy 那組逾期/12 月交易代碼是不存在的 DOM id，用 canonical 的最大逾期碼/12 月交易碼（確切欄名見 spec `R2`/schema）。

**維護註記**
- calc 公開回應只給 `riskLevel` + `scoreDatetime`，`totalScore` 為 server 端內部值（不外露）。
- RC 續約/變更併入本頁、共用 `EPROC00118` checkpoint，**不另建 RC 專屬表/欄**。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證/決策）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated 2026-06-25 from `spec.md`（digest v2.1）；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時，由 spec owner 重生本檔。</sub>
