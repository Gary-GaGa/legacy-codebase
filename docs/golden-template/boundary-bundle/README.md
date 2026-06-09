# Boundary Bundle — 每頁「可驗證邊界」範本

> 配 [`../../vision-pipeline.md`](../../vision-pipeline.md) §4–5。**一個 story/page = 一束 artifacts**，全靠同一個
> ID（funcId，如 `EPROC00118`）串起來，讓 RD agent 能**機器證明**自己通過 SA/QA 邊界。
> 第一個 worked example：[`EPROC00118/`](EPROC00118/)（c0 Corporate Scorecard，**鏡像 i0 來源**）。
> 第二個：[`EPROZ00800/`](EPROZ00800/)（Revised Item，**PRD 來源**，由 `prd-to-srs` skill 從 `CDC-EPRO-0001` 產出）。
>
> **兩種來源**：① **鏡像 i0**（既有新碼為 oracle，引 i0 `file:line`）② **PRD**（PM 的 PRD 為 what，用 `.claude/skills/prd-to-srs` 轉 → 規則追溯 PRD REQ-id、TBD 寫 `@PENDING`、頁已存在則標 as-is/to-be）。

## 結構
```
<FUNC_ID>/
├─ openapi.yaml   ← SA：endpoint request/response 契約          → DoD 閘門 1（contract 一致）
├─ schema.sql     ← SA：touched 表 / 欄位 / 約束                 → DoD 閘門 2（schema 一致）
├─ spec.md        ← SA：業務規則，每條一個 rule-id（R1/R2…）
└─ qa-cases.md    ← QA：每條 case 標 `covers: Rn`（可跑驗收測試）→ DoD 閘門 4 + 5
```

## 怎麼用（複製這頁 → 換 ID → 填內容）
1. `cp -r EPROC00118 <新FUNC_ID>`，把 ID/endpoint/表名換掉。
2. **openapi.yaml**：對既有 i0 controller 的 DTO 填**確切**欄位 + `@JsonProperty`（前端契約不可變）。
3. **schema.sql**：列**本頁真的會讀寫**的表 + 欄位（JIT 從 `db-schema-catalog.md` 抽，不要全表貼）。
4. **spec.md**：每條業務規則給 `Rn`，**引用 i0 `file:line` 當證據**（不准憑印象）。
5. **qa-cases.md**：每條 case 標 `covers: Rn`；未決 / escalation 寫成 `@PENDING`。

## 落地到產品專案（閘門怎麼真的跑）
本 repo 只放**範本/契約**；實際 runner 在產品專案：
| 閘門 | 範本檔 | 產品專案怎麼跑 |
|---|---|---|
| 1 contract | `openapi.yaml` | springdoc 生 OpenAPI → 與本檔 snapshot 比對（先 code-first，見 vision §6）|
| 2 schema | `schema.sql` | Hibernate `hibernate.ddl-auto=validate` / migration 驗 entity↔表 |
| 3 結構 | —（共用）| `python scripts/verify-c0.py --git` |
| 4 驗收 | `qa-cases.md` | 把 Gherkin 落成 integration test（API 層），RD agent 跑到綠 |
| 5 覆蓋 | spec `Rn` ↔ qa `covers:` | 對表腳本：每個 `Rn` 至少一個 `covers: Rn`，否則 FAIL |

## 與 30% runbook 的關係
- 現在 runbook 的 gate＝**閘門 3（verify-c0）+ build 綠 + LLM 審查（閘門 7）**。
- boundary bundle 是把 **1 / 2 / 4 / 5** 補上的路徑（vision §8 漸進落地）——**不必一次到位**，先一頁跑通再放大。
