# `specs/srs/` — SRS Boundary Bundle（每 funcId 一束可驗證邊界）

> flow 第 ③ 層（分層見 [`../README.md`](../README.md)、方法論見 [`../../spec-architecture.md`](../../spec-architecture.md)）。
> **一個 story/page = 一束 artifacts**，全靠同一個 ID（funcId，如 `EPROZ00800`）串起來，讓 RD agent 能**機器證明**自己通過 SA/QA 邊界。
> Worked examples: `EPROZ00100` and `EPROC00118` are Approved after 2026-06-20 RD/DBA contract closeout. DB seed direct apply and SELECT-only recheck passed; coverage remains 2/67. `EPROZ00800` v0.9 remains archived for rebuild.

## 結構
```
<FUNC_ID>/
├─ spec.md        ← SA：業務規則 Rn（強制點 FE/BE）＋ §@PENDING 表（該頁待決的單一出處）
├─ openapi.yaml   ← SA：FE↔BE 契約（真實 epl-* RPC 的 request/response schema）
└─ schema.sql     ← SA：BE↔DB 契約（touched 表 / 欄位 / 約束）
   〔qa-cases.md ← QA：2026-06-24 暫拔除（QA 產生/驗收先移除）；恢復見 git history〕
```

> **結構單一出處＝[`spec-template.md`](spec-template.md)**（canonical 段名/順序/Rn 格式）。新 bundle 複製它起手、須過 `check-srs-bundle.py` 結構檢查 warn-clean；既有 14 包標準定版前產出、漂移為已知（grandfathered）。

## 兩種來源
- **PRD（主路）**：叫 `/prd-to-srs`（帶 PRD）自動產 bundle（範本：00100/00118 重產中、待母資料夾；流程見 `../../build-tasks/prd-to-srs-codex-dispatch.md`）——規則追溯 PRD `REQ-`/`FR-` id、TBD→`@PENDING`、endpoint 寫真實 `epl-*`、頁已存在則標 as-is/to-be。
- **鏡像 i0（無 PRD）**：`cp -r ../../archive/EPROZ00800-v0.9-superseded/srs <新FUNC_ID>` 換 ID/endpoint/表名，再：
  1. **openapi.yaml**：對既有 i0 controller 的 DTO 填**確切**欄位 + `@JsonProperty`（前端契約不可變）。
  2. **schema.sql**：列**本頁真的會讀寫**的表 + 欄位（JIT 從 `../../legacy/db-schema-catalog.md` 抽，不要全表貼）。
  3. **spec.md**：每條業務規則給 `Rn`，**引用 i0 `file:line` 當證據**（不准憑印象）。
  〔4. qa-cases.md：2026-06-24 暫拔除。〕

## 閘門編號對照（⚠️ 本表＝兩套編號的**唯一**對齊處）
> 權威編號＝DoD 閘門牆 ①–⑦（`../../assets/ai-workflow.mmd`，code 階段）。`check-srs-bundle.py` 的 **數字** gate（①②⑤）＝牆上**同位、同義**項在 SRS 定稿階段的 pre-check（同號、不同階段）。腳本的 **SRS 階段專屬**檢查（牆上無對應格）改用**字母標**（gateⒷ/gateⓅ）+ 非數字名（xfile/doc-paths），**刻意不接續 ⑥⑦** 以免與牆上 ⑥Build/⑦LLM-advisory 撞號（2026-06-12 改）。涵蓋細節一律見**腳本檔頭**。

| DoD 閘門牆（code 階段，產品 repo）| SRS 定稿 pre-check（本 repo，`scripts/check-srs-bundle.py`）|
|---|---|
| ① Contract：springdoc OpenAPI ↔ snapshot 比對 | gate①：openapi 解析 / $ref / required |
| ② Schema：Hibernate `ddl-auto=validate` / migration | gate②：DDL 解析 + 欄長交叉 |
| ③ 結構：`scripts/verify-c0.py --git` | —（不適用 SRS 階段）|
| ~~④ QA 驗收~~ | 〔2026-06-24 暫拔除〕 |
| ~~⑤ 覆蓋率~~ | 〔gate⑤ skip（non-FAIL、機械層自動）：qa-cases.md 不存在時;隨 QA 2026-06-24 暫拔除,恢復見 git history〕 |
| ⑥ Build 綠 | —（牆上 ⑥；腳本無同號項，撞號已消除）|
| ⑦ LLM 語意審查（advisory）| `spec-reviewer`（SRS 定稿＝**blocking**，別與牆上 ⑦ 混）＝**N 軸 axis A**；全軸 A–G 見 `../../process/orchestration-playbook.md §4b` |
| —（牆上無對應格＝SRS 階段專屬）| **gateⒷ** Bible↔PRD、**gateⓅ** @PENDING↔register、**gateⓈ** Status↔安全/雙軸〔(a) Approved+`BPn-PENDING`=warn；(b) Status 未分「規格定版/實作完成」=warn——批判輪1/輪2 2026-06-16〕、**gateⒺ** 錯誤碼承載〔PRD Error 表→spec/openapi 漏承載=warn、HTTP status 不一致=warn——批判輪3 2026-06-16，源 SR-B1/B2〕、**gateⓇ** reconcile 承載〔spec.md 須有『新舊 DB 對照/更動 delta』段否則 warn——防規模化靜默跳過 db-diff/refactor-spec reconcile，2026-06-18；段內容真確＝spec-reviewer 紅旗⑥〕、xfile 跨檔、doc-paths |

## 與 vision 的關係
boundary bundle 是把閘門 ①/②/④/⑤ 從「文件 + 延後」升級成「迴圈內可跑」的路徑（`../../process/vision-pipeline.md` §8 漸進落地）——**不必一次到位**，先一頁跑通再放大。
