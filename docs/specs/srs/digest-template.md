<!--
  SRS digest（README.md）結構單一出處（canonical）。新 bundle 產 spec 後，照本檔產 `<funcId>/README.md`。
  範例成品＝docs/specs/srs/EPROC00120/README.md（pilot 定版）。

  ── digest 是什麼 ──
  給 RD 實作者「快速 orient」（這頁在幹嘛、怎麼運作、要小心什麼）的衍生速覽。
  **spec.md/openapi.yaml/schema.sql 才是精確契約與權威**；digest 只摘要 + 指回。
  瀏覽 bundle 資料夾時 README.md 第一眼即見（GitHub 預設顯示）。

  ── 撰寫鐵則（產出時遵守）──
  1. **精確 identifier 一律不複製、指回 spec**：欄名/錯誤碼/表名/DB 欄/全 endpoint 名/legacy 方法名/
     commit SHA/DB 型別 **都不寫進 digest**，改用業務白話 + 「見 spec Rn / schema / openapi」。
     （保留：頁 funcId、業務縮寫與比率名 USD/KHR/ROA/ROE/GGL/NPL/DSR/PDF、rounding 詞 HALF_DOWN/HALF_UP、Rn 參照。）
     雷區若靠某 identifier 當重點 → 改寫成白話差異描述（如「兩張不同的 info 活表、非別名」），不寫表名。
  2. **繁中、白話、精簡**（目標 RD ~2 分鐘 orient；約 50–70 行）。
  3. **「怎麼運作」依頁型態改寫**，不可照抄他頁；骨架範例見文末。
  4. **規則速覽依執行序**（主流程 ①…）+ 橫切（錯誤/授權/邊界）；每條附 Rn drill-down。
  5. **雷區依 RD 接手序**：動工前必知 → 實作踩坑 → 維護註記。
  6. **不重複佐證**：digest 只摘要、指回 spec，避免變成第二份規格（staleness 雙倍）。
  7. header 註 generated date + 「spec.md 權威、變更請重生」。

  ── 固定段（所有包都有，僅換業務名/Rn/路徑）──
  這頁在幹嘛 / Endpoints / 規則速覽 / NFR / 資料表 / 雷區 / 連結。
  ── 彈性段（依頁型態改寫）──
  ① 怎麼運作流程 ② Endpoints 數/副作用（calc 禁寫、export、無 save 只狀態轉移）③ NFR 焦點/條數 ④ 規則複雜度。
-->

# <funcId> — <中文頁名>（<EN name>）｜開發速覽

> 給 RD 快速 orient。**精確契約一律以同目錄 [`spec.md`](spec.md) / [`openapi.yaml`](openapi.yaml) / [`schema.sql`](schema.sql) 為準**——本檔不複製欄名/錯誤碼/欄長/表名/SHA，只白話摘要 + 用 `Rn` 指回。

## 這頁在幹嘛（一句）
<1 句業務白話：誰、為什麼、做什麼>。

## 怎麼運作〔此段隨頁型態而異、非通用範本〕
<本頁實際流程，依頁型改寫。範例見文末骨架。>

## Endpoints（角色 + Rn；確切名見 `openapi.yaml`）
| 角色 | 做什麼 | 規則 |
|---|---|---|
| 查詢（info） | … | R… |
| 存檔（save） | … | R… |

## 規則速覽（白話；精確值見對應 `Rn`）
**主流程（依執行序）**
1. **<階段>** `R1`：<白話>。
2. …
**橫切（每階段都適用）**
- **錯誤/rollback** `R?`：<白話>。
- **授權** `R?`：<白話>。
- **邊界** `R?`–`R?`：<白話>。

## NFR（精確見 spec `## NFR`）
<交易／安全／稽核／觀測… 白話一行>。

## 資料表（確切表名/欄位/PK 見 `schema.sql`）
<白話：主寫入＝… / 來源＝… / checkpoint＝…>。

## ⚠️ 雷區（依 RD 接手順序）
**動工前必知**
- <會整筆失敗/安全/不可逆的點>。
**實作踩坑**
- <rounding / 對位 / 後端必驗 / 邊界值…>。
**維護註記**
- <殘留 🟡 / drift / 待 reconcile>。

## 連結
[`spec.md`](spec.md)（精確契約 + 附錄佐證）｜[`openapi.yaml`](openapi.yaml)｜[`schema.sql`](schema.sql)｜PRD（路徑見 `spec.md` Metadata）

---
<sub>generated <date> from `spec.md`；**spec.md 為權威**——Endpoints／NFR／規則（Rn）有實質變更時重生本檔。
**流程骨架範例**（「怎麼運作」依頁型改寫）：編輯→Finish 型＝載入→計算→存草稿→Finish→寫 checkpoint；多步驟計算頁＝選項→查詢/複製→計算→存/匯出；狀態轉移頁＝載框→選型→確認→清資料（無 Finish）；評分頁＝載選項→初始化→計算→存。</sub>
