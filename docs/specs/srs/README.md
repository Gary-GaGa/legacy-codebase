# `specs/srs/` — SRS Boundary Bundle（每 funcId 一束可驗證邊界）

> flow 第 ③ 層（分層見 [`../README.md`](../README.md)、方法論見 [`../../spec-architecture.md`](../../spec-architecture.md)）。
> **一個 story/page = 一束 artifacts**，全靠同一個 ID（funcId，如 `EPROZ00800`）串起來，讓 RD agent 能**機器證明**自己通過 SA/QA 邊界。
> Worked example：[`EPROZ00800/`](EPROZ00800/)（Revised Item，**PRD 來源**，由 `/prd-to-srs` 從 `CDC-EPRO-0001` 產出）。

## 結構
```
<FUNC_ID>/
├─ spec.md        ← SA：業務規則 Rn（強制點 FE/BE）＋ §@PENDING 表（該頁待決的單一出處）
├─ openapi.yaml   ← SA：FE↔BE 契約（真實 epl-* RPC 的 request/response schema）
├─ schema.sql     ← SA：BE↔DB 契約（touched 表 / 欄位 / 約束）
└─ qa-cases.md    ← QA：每條 case 標 `covers: Rn`（test-ready 寫法，見 ../qa-to-test.md）
```

## 兩種來源
- **PRD（主路）**：叫 `/prd-to-srs`（帶 PRD）自動產 bundle（見 `EPROZ00800/`）——規則追溯 PRD REQ-id、TBD→`@PENDING`、endpoint 寫真實 `epl-*`、頁已存在則標 as-is/to-be。
- **鏡像 i0（無 PRD）**：`cp -r EPROZ00800 <新FUNC_ID>` 換 ID/endpoint/表名，再：
  1. **openapi.yaml**：對既有 i0 controller 的 DTO 填**確切**欄位 + `@JsonProperty`（前端契約不可變）。
  2. **schema.sql**：列**本頁真的會讀寫**的表 + 欄位（JIT 從 `../../legacy/db-schema-catalog.md` 抽，不要全表貼）。
  3. **spec.md**：每條業務規則給 `Rn`，**引用 i0 `file:line` 當證據**（不准憑印象）。
  4. **qa-cases.md**：每條 case 標 `covers: Rn`；未決 / escalation 寫成 `@PENDING`。

## 閘門編號對照（⚠️ 本表＝兩套編號的**唯一**對齊處）
> 權威編號＝DoD 閘門牆 ①–⑦（`../../assets/ai-workflow.mmd`，code 階段）。`check-srs-bundle.py` 的 **數字** gate（①②⑤）＝牆上**同位、同義**項在 SRS 定稿階段的 pre-check（同號、不同階段）。腳本的 **SRS 階段專屬**檢查（牆上無對應格）改用**字母標**（gateⒷ/gateⓅ）+ 非數字名（xfile/doc-paths），**刻意不接續 ⑥⑦** 以免與牆上 ⑥Build/⑦LLM-advisory 撞號（2026-06-12 改）。涵蓋細節一律見**腳本檔頭**。

| DoD 閘門牆（code 階段，產品 repo）| SRS 定稿 pre-check（本 repo，`scripts/check-srs-bundle.py`）|
|---|---|
| ① Contract：springdoc OpenAPI ↔ snapshot 比對 | gate①：openapi 解析 / $ref / required |
| ② Schema：Hibernate `ddl-auto=validate` / migration | gate②：DDL 解析 + 欄長交叉 |
| ③ 結構：`scripts/verify-c0.py --git` | —（不適用 SRS 階段）|
| ④ QA 驗收：Testcontainers oracle-xe 跑 case（橋接 `../qa-to-test.md`）| —（寫法閘＝qa-cases **test-ready**）|
| ⑤ 覆蓋率：ID 對表 | gate⑤：Rn↔QA covers / 懸空引用 / **分支覆蓋自承不完整=warn**（2026-06-16）|
| ⑥ Build 綠 | —（牆上 ⑥；腳本無同號項，撞號已消除）|
| ⑦ LLM 語意審查（advisory）| `spec-reviewer`（SRS 定稿＝**blocking**，別與牆上 ⑦ 混）|
| —（牆上無對應格＝SRS 階段專屬）| **gateⒷ** Bible↔PRD、**gateⓅ** @PENDING↔register、**gateⓈ** Status↔安全/雙軸〔(a) Approved+`BPn-PENDING`=warn；(b) Status 未分「規格定版/實作完成」=warn——批判輪1/輪2 2026-06-16〕、xfile 跨檔、doc-paths |

## 與 vision 的關係
boundary bundle 是把閘門 ①/②/④/⑤ 從「文件 + 延後」升級成「迴圈內可跑」的路徑（`../../process/vision-pipeline.md` §8 漸進落地）——**不必一次到位**，先一頁跑通再放大。
